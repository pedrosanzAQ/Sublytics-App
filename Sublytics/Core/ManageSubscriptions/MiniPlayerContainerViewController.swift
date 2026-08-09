//
//  MiniPlayerContainerViewController.swift
//  Sublytics
//
//  Created by pedrosanz on 19/05/26.
//
import UIKit

protocol MiniPlayerPresentable: UIViewController {
    var miniplayerView: EditSubscriptionMIniPlayerView { get }
    var mainStack: UIStackView { get }
    var topBarStack: UIStackView { get }
    var onDismissRequested: (() -> Void)? { get set }
    var onExpandRequested: (() -> Void)? { get set }
    var onCloseRequested: (() -> Void)? { get set }
}

// MARK: - PassthroughView

final class PassthroughView: UIView {
    var interactiveRect: CGRect?
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if let rect = interactiveRect {
            guard rect.contains(point) else { return nil }
        }
        
        return super.hitTest(point, with: event)
    }
}

// MARK: - MiniPlayerContainerViewController

final class MiniPlayerContainerViewController: UIViewController {
    
    // MARK: Properties
    
    private var currentVC: (any MiniPlayerPresentable)?
    private var topConstraint: NSLayoutConstraint!
    private let miniHeight: CGFloat = 70
    var bottomOffset: CGFloat = 0
    private var isExpanded = true
    
    var onWillMinimize: (() -> Void)?
    var onWillMaximize: (() -> Void)?
    var onCloseRequested: (() -> Void)?
    
    private var passthroughView: PassthroughView {
        view as! PassthroughView
    }
    
    // MARK: - View Lifecycle
    
    override func loadView() {
        view = PassthroughView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = false
        view.isHidden = true 
    }
    
    // MARK: - Public API
    
    func displayMiniPlayer(_ vc: any MiniPlayerPresentable, startMinimized: Bool = false) {
        removeCurrent()
        
        currentVC = vc
        addChild(vc)
        view.addSubview(vc.view)
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        
        view.clipsToBounds = true
        topConstraint = vc.view.topAnchor.constraint(equalTo: view.topAnchor)
        
        NSLayoutConstraint.activate([
            vc.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            vc.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            vc.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            topConstraint
        ])
        
        vc.didMove(toParent: self)
        view.isUserInteractionEnabled = true
        view.isHidden = false
        
        passthroughView.interactiveRect = nil
        
        if startMinimized {
            setupInitialMinimizedState()
        } else {
            setupInitialExpandedState()
        }
        
        vc.onDismissRequested = { [weak self] in
            self?.minimize()
        }
        
        vc.onExpandRequested = { [weak self] in
            self?.maximize()
        }
        
        vc.onCloseRequested = { [weak self] in
            self?.close()
        }
    }
    
    // MARK: - State
    
    func minimize() {
        guard let currentVC else { return }
        isExpanded = false
        onWillMinimize?()
        
        let targetY = view.bounds.height - miniHeight - bottomOffset
        topConstraint.constant = targetY
        currentVC.view.clipsToBounds = true
        currentVC.view.backgroundColor = .clear
        view.clipsToBounds = true
        
        UIView.animate(withDuration: 0.3) {
            currentVC.mainStack.alpha = 0
            currentVC.topBarStack.alpha = 0
            currentVC.miniplayerView.show(animated: false)
            self.view.layoutIfNeeded()
        } completion: { _ in
            let miniRect = CGRect(
                x: 0,
                y: self.view.bounds.height - self.miniHeight,
                width: self.view.bounds.width,
                height: self.miniHeight
            )
            self.passthroughView.interactiveRect = miniRect
        }
    }
    
    func maximize() {
        guard let currentVC else { return }
        isExpanded = true
        onWillMaximize?()
        
        passthroughView.interactiveRect = nil
        topConstraint.constant = 0
        currentVC.view.backgroundColor = .backgroundColor
        view.clipsToBounds = false
        
        UIView.animate(withDuration: 0.3) {
            currentVC.mainStack.alpha = 1
            currentVC.topBarStack.alpha = 1
            currentVC.miniplayerView.hide(animated: false)
            self.view.layoutIfNeeded()
        }
    }
    
    func close() {
        UIView.animate(withDuration: 0.2) {
            self.view.alpha = 0
        } completion: { _ in
            self.removeCurrent()
            self.view.alpha = 1
            self.view.isHidden = true
            self.view.isUserInteractionEnabled = false
            self.passthroughView.interactiveRect = nil
            self.onCloseRequested?()
        }
    }
    
    // MARK: - Private
    private func setupInitialMinimizedState() {
        currentVC?.mainStack.alpha = 0
        currentVC?.topBarStack.alpha = 0
        currentVC?.miniplayerView.show(animated: false)
        isExpanded = false
    }
    
    private func setupInitialExpandedState() {
        currentVC?.mainStack.alpha = 1
        currentVC?.topBarStack.alpha = 1
        currentVC?.miniplayerView.hide(animated: false)
        isExpanded = true
        passthroughView.interactiveRect = nil
    }
    
    private func removeCurrent() {
        currentVC?.willMove(toParent: nil)
        currentVC?.view.removeFromSuperview()
        currentVC?.removeFromParent()
        currentVC = nil
    }
    
    @objc
    private func handleMiniTap() {
        guard !isExpanded else { return }
        maximize()
    }
}


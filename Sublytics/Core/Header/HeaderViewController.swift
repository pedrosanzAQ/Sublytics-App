//
//  HeaderViewController.swift
//  Sublytics
//
//  Created by pedrosanz on 17/04/26.
//

import UIKit

class HeaderViewController: UIViewController, UIScrollViewDelegate{
    
    private(set) var headerView: HeaderView!
    
    var lastOffset: CGFloat = 0
    
    var headerScrollView: UIScrollView? {
        didSet {
            headerScrollView?.delegate = self
            headerScrollView?.contentInsetAdjustmentBehavior = .never
        }
    }
    
    override func viewDidLoad() {
        if headerView == nil {
            headerView = HeaderView()
        }
        view.backgroundColor = .clear
        super.viewDidLoad()
        setupHeaderUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    private func setupHeaderUI() {
        view.addSubview(headerView)
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.movingContainer.isUserInteractionEnabled = true
        headerView.isUserInteractionEnabled = true
        
//        let window = UIApplication.shared.windows.first
        let window = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first(where: { $0.activationState == .foregroundActive })?
            .windows
            .first(where: \.isKeyWindow)
        
        let topPadding = window?.safeAreaInsets.top ?? 0
        let totalHeight = headerView.contentHeight + topPadding
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: totalHeight)
        ])
        
        view.bringSubviewToFront(headerView)
        headerView.layer.zPosition = 999 // Elevación máxima
    }
    
    func setCustomHeader(_ customHeader: HeaderView) {
        self.headerView = customHeader
    }
    
    func bringHeaderToFront() {
        view.bringSubviewToFront(headerView)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentOffset = scrollView.contentOffset.y
        let limit = headerView.contentHeight
        let topSafeArea = view.safeAreaInsets.top
        
        if currentOffset <= -topSafeArea {
            headerView.layer.removeAllAnimations()
            
            let distanceToSafeArea = -currentOffset - topSafeArea
            let newConstant = max(-limit, min(0, distanceToSafeArea - limit))
            
            headerView.movingTopConstraint.constant = newConstant
            headerView.movingContainer.alpha = (newConstant + limit) / limit
            
            lastOffset = currentOffset
            return
        }
        
        let scrollBottom = scrollView.contentSize.height - scrollView.frame.size.height
        if currentOffset >= scrollBottom { return }
        
        let delta = currentOffset - lastOffset
        if abs(delta) < 3 { return }
        
        if delta > 0 {
            if headerView.movingTopConstraint.constant > -limit {
                performHeaderTransition(visible: false)
            }
        } else if delta < -25 {
            if headerView.movingTopConstraint.constant < 0 && currentOffset > -topSafeArea {
                performHeaderTransition(visible: true)
            }
        }
        
        lastOffset = currentOffset
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let currentOffset = scrollView.contentOffset.y
        let topSafeArea = view.safeAreaInsets.top
        let limit = headerView.contentHeight
        
        // Solo aplicamos Snap si estamos en la zona del tope
        if currentOffset > -(topSafeArea + limit) && currentOffset < -topSafeArea {
            let midPoint = -(topSafeArea + (limit / 2))
            let shouldShow = currentOffset < midPoint
            performHeaderTransition(visible: shouldShow)
        }
    }
    
    private func performHeaderTransition(visible: Bool) {
        let targetConstant: CGFloat = visible ? 0 : -headerView.contentHeight
        let targetAlpha: CGFloat = visible ? 1.0 : 0.0
        
        
        UIView.animate(withDuration: 0.2,
                       delay: 0,
                       options: [.curveEaseOut, .allowUserInteraction, .beginFromCurrentState]) {
            self.headerView.movingTopConstraint.constant = targetConstant
            self.headerView.movingContainer.alpha = targetAlpha
            self.view.layoutIfNeeded()
        }
    }
}

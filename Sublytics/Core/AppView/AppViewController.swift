//
//  AppViewController.swift
//  Sublytics
//
//  Created by pedrosanz on 04/03/26.
//

import UIKit
import SwiftUI

class AppViewController: UIViewController {

    private let viewModel: AppViewModel
    private var currentChild: UIViewController?
    
    init(viewModel: AppViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = PassthroughView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundGradient()
        observeState()
    }
    
    private func observeState() {
        withObservationTracking {
            let shouldShowTabBar = viewModel.showTabbar
            self.render(showTabbar: shouldShowTabBar)
        } onChange: { [weak self] in
            DispatchQueue.main.async {
                self?.observeState()
            }
        }
    }
    
    private func render(showTabbar: Bool) {
        
        if showTabbar, currentChild is TabBarViewController { return }
        if !showTabbar, currentChild is WelcomeViewController { return }
        
        let nextVC: UIViewController
        
        if showTabbar {
            let tabbar = TabBarViewController(viewmodel: TabBarViewModel(container: viewModel.container))
            nextVC = tabbar
            
        } else {
            let welcomeVC = WelcomeViewController(viewModel: WelcomeViewModel(container: viewModel.container))
            nextVC = welcomeVC
        }
        
        updateChild(nextVC)
    }
    
    private func updateChild(_ child: UIViewController) {

        if let current = currentChild {
            current.willMove(toParent: nil)
            current.view.removeFromSuperview()
            current.removeFromParent()
        }
        
        addChild(child)
        child.view.frame = view.bounds
        child.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        child.view.isUserInteractionEnabled = true
        
        UIView.transition(with: view, duration: 0.35, options: .transitionCrossDissolve) {
            self.view.addSubview(child.view)
        } completion: { _ in
            child.didMove(toParent: self)
            self.currentChild = child
        }
    }
}

#Preview("Tabbar - False") {
    let container = DevPreview.shared.container
    var userManager = UserManager(service: MockUserService(currentUser: UserModel.mocks[1]))
    container.register(UserManager.self, service: userManager)
    
    return VCPreview {
        AppViewController(viewModel: AppViewModel(container: DevPreview.shared.container))
    }
    .ignoresSafeArea()
}

#Preview("Tabbar - True") {
    let container = DevPreview.shared.container
    container.register(AppStateManager.self, service: AppStateManager(service: MockAppStateService(showTabBar: true)))
    let subscriptionManager = SubscriptionManager(service: MockSubscriptionService())
    subscriptionManager.addUserSubscriptionsListener(userId: "user1")
    container.register(SubscriptionManager.self, service: subscriptionManager)
    
    return VCPreview {
        AppViewController(viewModel: AppViewModel(container: container))
    }
    .ignoresSafeArea()
}

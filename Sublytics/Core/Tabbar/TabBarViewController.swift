//
//  TabBarViewController.swift
//  Sublytics
//
//  Created by pedrosanz on 05/03/26.
//

import UIKit

class TabBarViewController: UITabBarController {
    let miniPlayerContainer = MiniPlayerContainerViewController()
    private var miniPlayerLeading: NSLayoutConstraint!
    private var miniPlayerTrailing: NSLayoutConstraint!
    private var miniPlayerBottom: NSLayoutConstraint!
    private var hasInitialLayoutBeenPerformed = false
    
    private let viewmodel: TabBarViewModel
    
    init(viewmodel: TabBarViewModel) {
        self.viewmodel = viewmodel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
        setupMiniPlayer()
        
        viewmodel.startUserListener()
    }
    
    private func setupTabs() {

        let dashboard = UINavigationController(rootViewController: DashboardViewController(viewModel: DashboardViewModel(container: viewmodel.container)))
        dashboard.setNavigationBarHidden(true, animated: false)
        dashboard.tabBarItem = UITabBarItem (
            title: "Dashboard",
            image: UIImage(systemName: "chart.bar"),
            tag: 0
        )
        
        let insights = UINavigationController(rootViewController: InsightsViewController(viewModel: InsightsViewModel(container:viewmodel.container)))
        insights.setNavigationBarHidden(true, animated: false)
        insights.tabBarItem = UITabBarItem(
            title: "Insights",
            image: UIImage(systemName: "chart.line.uptrend.xyaxis"),
            tag: 1
        )
        
        let subscriptions = UINavigationController(rootViewController: SubscriptionsViewController(viewmodel: SubscriptionViewModel(container: viewmodel.container)))
        subscriptions.setNavigationBarHidden(true, animated: false)
        subscriptions.tabBarItem = UITabBarItem(
            title: "Subscriptions",
            image: UIImage(systemName: "creditcard"),
            tag: 2
        )
        
        let settings = UINavigationController(rootViewController: SettingsViewController(viewModel: SettingsViewModel(container: viewmodel.container)))
        settings.setNavigationBarHidden(true, animated: false)
        settings.tabBarItem = UITabBarItem(
            title: "Settings",
            image: UIImage(systemName: "gearshape"),
            tag: 3
        )
        
        viewControllers = [dashboard, insights, subscriptions, settings]
    }
    
    private func setupMiniPlayer() {
        view.addSubview(miniPlayerContainer.view)
        miniPlayerContainer.view.translatesAutoresizingMaskIntoConstraints = false
        
        miniPlayerLeading = miniPlayerContainer.view.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        miniPlayerTrailing = miniPlayerContainer.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        miniPlayerBottom = miniPlayerContainer.view.bottomAnchor.constraint(equalTo: tabBar.topAnchor)
        
        NSLayoutConstraint.activate([
            miniPlayerContainer.view.topAnchor.constraint(equalTo: view.topAnchor),
            miniPlayerLeading,
            miniPlayerTrailing,
            miniPlayerBottom
        ])
        
        view.bringSubviewToFront(miniPlayerContainer.view)
        
        miniPlayerContainer.onWillMinimize = { [weak self] in
            self?.collapseMiniPlayerConstraints()
        }
        
        miniPlayerContainer.onWillMaximize = { [weak self] in
            self?.expandMiniPlayerConstraints()
        }
        
        miniPlayerContainer.onCloseRequested = { [weak self] in
            self?.collapseMiniPlayerConstraints()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if !hasInitialLayoutBeenPerformed && miniPlayerContainer.view.bounds.height > 0 {
            hasInitialLayoutBeenPerformed = true
            miniPlayerContainer.minimize()
        }
    }
    
    func presentMiniPlayerMinimized(_ vc: any MiniPlayerPresentable) {
        view.bringSubviewToFront(miniPlayerContainer.view)
        miniPlayerContainer.bottomOffset = tabBar.frame.height
        
        vc.mainStack.alpha = 0
        vc.topBarStack.alpha = 0
        vc.miniplayerView.show(animated: false)
        
        miniPlayerContainer.displayMiniPlayer(vc, startMinimized: true)
        if miniPlayerContainer.view.bounds.height > 0 {
            miniPlayerContainer.minimize()
        }
    }
    
    func expandMiniPlayerConstraints() {
        miniPlayerLeading.constant = 0
        miniPlayerTrailing.constant = 0
        miniPlayerBottom.constant = tabBar.frame.height
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    func collapseMiniPlayerConstraints() {
        miniPlayerLeading.constant = 20
        miniPlayerTrailing.constant = -20
        miniPlayerBottom.constant = -8
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    func hideMiniPlayerContainer() {
        miniPlayerContainer.view.isHidden = true
    }
    
    func showMiniPlayerContainer() {
        miniPlayerContainer.view.isHidden = false
    }
    
    private func waitForLayoutThenMinimize() {
        if miniPlayerContainer.view.bounds.height > 0 {
            miniPlayerContainer.minimize()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
                self?.waitForLayoutThenMinimize()
            }
        }
    }
}

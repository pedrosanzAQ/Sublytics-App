//
//  SubscriptionsViewController.swift
//  Sublytics
//
//  Created by pedrosanz on 05/03/26.
//

import UIKit
import SwiftUI

class SubscriptionsViewController: HeaderViewController {
    
    //MARK: -VIEWS
    
    private let mainScrollView: UIScrollView = {
        let scrollview = UIScrollView()
        scrollview.alwaysBounceVertical = true
        scrollview.showsHorizontalScrollIndicator = false
        scrollview.showsVerticalScrollIndicator = false
        scrollview.translatesAutoresizingMaskIntoConstraints = false
        return scrollview
    }()
    
    private let mainStackView: UIStackView = {
       let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    //  ---- CATEGORIES VIEW
    private let categoriesScrollView: UIScrollView = {
        let scrollview = UIScrollView()
        scrollview.showsVerticalScrollIndicator = false
        scrollview.showsHorizontalScrollIndicator = false
        scrollview.alwaysBounceVertical = false
        scrollview.alwaysBounceHorizontal = true
        scrollview.translatesAutoresizingMaskIntoConstraints = false
        return scrollview
    }()
    
    private let horizontalCategoryStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // ---- UPCOMING SECTION VIEW
    private let mainVerticalUpcomingStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let horizontalUpcomingScrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.showsVerticalScrollIndicator = false
        scroll.showsHorizontalScrollIndicator = false
        scroll.alwaysBounceVertical = false
        scroll.alwaysBounceHorizontal = true
        scroll.translatesAutoresizingMaskIntoConstraints = false
        return scroll
    }()
    
    private let upcomignCharguesTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .headline)
        label.textColor = .primaryText
        label.text = "Upcoming Charges"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let upcomingHorizontalStackView: UIStackView = {
       let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // SUBSCRIPTIONS
    private let subscriptionsSectionStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let subscriptionsTitleStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let subscriptionsTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.text = "Subscriptions"
        label.textColor = .primaryText
        return label
    }()
    
    private let emptyPotentialLabel: UILabel = {
        let label = UILabel()
        label.text = "You don't have any subscriptions yet. Add a new subscription to get started!"
        label.font = .preferredFont(forTextStyle: .callout)
        label.textColor = .secondaryText
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subscriptionIconButton: UIButton = {
        let button = UIButton(type: .system)
        var config = UIButton.Configuration.filled()
        config.image = UIImage(systemName: "ellipsis")
        config.baseBackgroundColor = .backgroundColor
        config.baseForegroundColor = .primaryText
        config.cornerStyle = .capsule
        config.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
        
        button.configuration = config
        return button
    }()
    
    private let subscriptionsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let bottomSpacerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setContentHuggingPriority(.defaultLow, for: .vertical)
        view.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        return view
    }()
    
    // MARK: - DATA
    private let viewmodel: SubscriptionViewModel
    
    // MARK: - LIFECYCLE
    
    init(viewmodel: SubscriptionViewModel) {
        self.viewmodel = viewmodel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        let extendedHeader = SubscriptionsHeaderViewExtentended()
        self.setCustomHeader(extendedHeader)
        
        super.viewDidLoad()
        view.backgroundColor = .backgroundColor
        self.headerScrollView = mainScrollView
        headerView.delegate = self
        extendedHeader.subDelegate = self
        setupMainView()
        setupUpcomingCharguesSection()
        setupAllSubscriptions()
        bringHeaderToFront()
        
        observeViewModel()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        let topPadding = view.safeAreaInsets.top
        let totalHeaderHeight = headerView.contentHeight + topPadding
        
        if mainScrollView.contentInset.top != totalHeaderHeight {
            mainScrollView.contentInset = UIEdgeInsets(top: totalHeaderHeight, left: 0, bottom: 0, right: 0)
            
            if lastOffset == 0 {
                mainScrollView.contentOffset = CGPoint(x: 0, y: -totalHeaderHeight)
                lastOffset = -totalHeaderHeight 
            }
        }
    }
    
    private func setupMainView() {
        view.addSubview(mainScrollView)
        mainScrollView.addSubview(mainStackView)
        mainStackView.isLayoutMarginsRelativeArrangement = true
        mainStackView.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        mainStackView.addArrangedSubview(mainVerticalUpcomingStackView)
        mainStackView.addArrangedSubview(subscriptionsSectionStack)
        mainStackView.addArrangedSubview(bottomSpacerView)
        
        NSLayoutConstraint.activate([
            mainScrollView.topAnchor.constraint(equalTo: view.topAnchor, constant: 12),
            mainScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mainScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mainScrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            mainStackView.topAnchor.constraint(equalTo: mainScrollView.contentLayoutGuide.topAnchor),
            mainStackView.leadingAnchor.constraint(equalTo: mainScrollView.contentLayoutGuide.leadingAnchor),
            mainStackView.trailingAnchor.constraint(equalTo: mainScrollView.contentLayoutGuide.trailingAnchor),
            mainStackView.bottomAnchor.constraint(equalTo: mainScrollView.contentLayoutGuide.bottomAnchor, constant: -16),
            mainStackView.widthAnchor.constraint(equalTo: mainScrollView.frameLayoutGuide.widthAnchor),
            
            mainStackView.heightAnchor.constraint(greaterThanOrEqualTo: mainScrollView.frameLayoutGuide.heightAnchor),
            
            categoriesScrollView.heightAnchor.constraint(equalToConstant: 40),
        ])
    }
    
    private func setupUpcomingCharguesSection() {
        upcomingHorizontalStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        subscriptionIconButton.transform = CGAffineTransform(rotationAngle: .pi / 2)
        
        if mainVerticalUpcomingStackView.arrangedSubviews.isEmpty {
            mainVerticalUpcomingStackView.addArrangedSubview(upcomignCharguesTitleLabel)
            mainVerticalUpcomingStackView.addArrangedSubview(horizontalUpcomingScrollView)
            horizontalUpcomingScrollView.addSubview(upcomingHorizontalStackView)
            
            NSLayoutConstraint.activate([
                horizontalUpcomingScrollView.heightAnchor.constraint(equalToConstant: 180),
                
                upcomingHorizontalStackView.topAnchor.constraint(equalTo: horizontalUpcomingScrollView.contentLayoutGuide.topAnchor),
                upcomingHorizontalStackView.leadingAnchor.constraint(equalTo: horizontalUpcomingScrollView.contentLayoutGuide.leadingAnchor),
                upcomingHorizontalStackView.trailingAnchor.constraint(equalTo: horizontalUpcomingScrollView.contentLayoutGuide.trailingAnchor),
                upcomingHorizontalStackView.bottomAnchor.constraint(equalTo: horizontalUpcomingScrollView.contentLayoutGuide.bottomAnchor),
                upcomingHorizontalStackView.heightAnchor.constraint(equalTo: horizontalUpcomingScrollView.frameLayoutGuide.heightAnchor),
            ])
        }
        
        let upcomingSubscriptions = viewmodel.upcomingSubscriptions
        mainVerticalUpcomingStackView.isHidden = upcomingSubscriptions.isEmpty
        horizontalUpcomingScrollView.isScrollEnabled = upcomingSubscriptions.count > 2
        
        upcomingSubscriptions.forEach { subscription in
            let subscriptionBoxRow = SubscriptionBoxCellUIView()
            subscriptionBoxRow.translatesAutoresizingMaskIntoConstraints = false
            subscriptionBoxRow.widthAnchor.constraint(equalToConstant: 140).isActive = true
            
            subscriptionBoxRow.config(with: subscription)
            upcomingHorizontalStackView.addArrangedSubview(subscriptionBoxRow)
        }
    }
    
    private func setupAllSubscriptions() {
        subscriptionsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        if subscriptionsSectionStack.arrangedSubviews.isEmpty {
            subscriptionsTitleStack.addArrangedSubview(subscriptionsTitleLabel)
            subscriptionsTitleStack.addArrangedSubview(subscriptionIconButton)
            subscriptionsSectionStack.addArrangedSubview(subscriptionsTitleStack)
            subscriptionsSectionStack.addArrangedSubview(subscriptionsStackView)
            subscriptionsSectionStack.addArrangedSubview(emptyPotentialLabel)
        }
        
        let filteredSubs = viewmodel.allSubsctiptions
        let isEmpty = filteredSubs.isEmpty
        
        emptyPotentialLabel.isHidden = !filteredSubs.isEmpty
        subscriptionsStackView.isHidden = isEmpty
        
        guard !isEmpty else { return }
        
        filteredSubs.forEach { sub in
            let cell = SubscriptionRowCellUIView()
            
            cell.configure(subscription: sub, isOnSubscriptionView: true)
            
            cell.onTap = { [weak self] in
                guard let self = self, let nav = self.navigationController else { return }
                let editVC = EditSubscriptionViewController(viewmodel: EditSubscriptionViewModel(container: viewmodel.container , subscription: sub))
                nav.pushViewController(editVC, animated: true)
            }
            
            var tagTasks: [() -> Void] = []
            tagTasks.append {
                cell.addTag(text: "\(sub.remainingDays) DAYS", textColor: .secondaryText, bgColor: .white.withAlphaComponent(0.1))
            }
            tagTasks.append {
                cell.addTag(text: sub.status.rawValue.capitalized, textColor: .secondaryText, bgColor: sub.statusColor)
            }
            if sub.isTrial {
                tagTasks.append {
                    cell.addTag(text: "Trial", textColor: .secondaryText, bgColor: .systemPurple.withAlphaComponent(0.3))
                }
            }
            
            tagTasks.shuffled().forEach { $0() }
            subscriptionsStackView.addArrangedSubview(cell)
        }
    }
    
    private func observeViewModel() {
        withObservationTracking {
            _ = viewmodel.isAnnonymousUser
            _ = viewmodel.allSubsctiptions
            _ = viewmodel.upcomingSubscriptions
        } onChange: { [weak self] in
            Task { @MainActor [weak self] in
                guard let self else { return }
                self.observeViewModel()
                self.setupUpcomingCharguesSection()
                self.setupAllSubscriptions()
            }
        }
    }
}

extension SubscriptionsViewController: HeaderViewDelegate {
    func onAddSubscriptionPressed(_ header: HeaderView) {
        
        if !viewmodel.isAnnonymousUser {
            let addVC = AddSubscriptionViewController(viewmodel: AddSusbcriptionViewModel(container: viewmodel.container))
            addVC.modalPresentationStyle = .fullScreen
            
            addVC.onDismissRequested = { [weak self] in
                
                guard let tabbar = self?.tabBarController as? TabBarViewController else {
                    addVC.dismiss(animated: true)
                    return
                }
                
                addVC.dismiss(animated: false) {
                    tabbar.presentMiniPlayerMinimized(addVC)
                }
            }
            
            addVC.onCloseRequested = {
                addVC.dismiss(animated: true)
            }
            
            present(addVC, animated: true)
        } else {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.warning)
            showToast(message: "Only signed-in users can add subscriptions.")
        }
    }
    
    func onSearchPreseed(_ header: HeaderView) {
        guard let nav = navigationController else {
            return
        }
        let rootVC = SearchRootViewController(viewmodel: SearchRootViewModel(container: viewmodel.container))
        nav.pushViewController(rootVC, animated: true)
    }
}

extension SubscriptionsViewController: SubscriptionsHeaderViewExtendedDelegate {
    func didSelectCategory(_ category: String?) {
        viewmodel.selectedCategory = category ?? ""
    }
}

#Preview("Subscriptions") {
    let container = DevPreview.shared.container
    let subscriptionManager = SubscriptionManager(service: MockSubscriptionService())
    subscriptionManager.addUserSubscriptionsListener(userId: "user1")
    container.register(SubscriptionManager.self, service: subscriptionManager)
    
    return VCPreview {
        let viewController = SubscriptionsViewController(viewmodel: SubscriptionViewModel(container: container))
        
        return viewController
    }
    .ignoresSafeArea()
}

#Preview("No-Subscriptions") {
    let container = DevPreview.shared.container
    let subscriptionManager = SubscriptionManager(service: MockSubscriptionService(subscriptions: []))
    subscriptionManager.addUserSubscriptionsListener(userId: "user1")
    container.register(SubscriptionManager.self, service: subscriptionManager)
    
    return VCPreview {
        let viewController = SubscriptionsViewController(viewmodel: SubscriptionViewModel(container: container))
        
        return viewController
    }
    .ignoresSafeArea()
}

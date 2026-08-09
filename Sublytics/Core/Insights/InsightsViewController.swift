//
//  InsightsViewController.swift
//  Sublytics
//
//  Created by pedrosanz on 05/03/26.
//

import Foundation
import UIKit
import SwiftUI

extension UIStackView {
    func removeAllArrangedSubviews() {
        arrangedSubviews.forEach { view in
            removeArrangedSubview(view)
            view.removeFromSuperview()
        }
    }
}

class InsightsViewController: HeaderViewController {
    //MARK: -VIEWS
    
    private let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.showsVerticalScrollIndicator = false
        scroll.alwaysBounceVertical = true
        return scroll
    }()
    
    private let mainStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 24
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let topSectionStack: UIStackView = {
        let stack = UIStackView()
        stack.spacing = 16
        stack.axis = .vertical
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let topSubscriptionsLabel: UILabel = {
        let label = UILabel()
        label.text = "Top 3 Costliest"
        label.textColor = .primaryText
        label.font = .preferredFont(forTextStyle: .headline)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subscriptionsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let subscriptionProjectionsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private let savingSectionStack: UIStackView = {
        let stack = UIStackView()
        stack.spacing = 16
        stack.axis = .vertical
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let savingLabel: UILabel = {
        let label = UILabel()
        label.text = "Potential Savings"
        label.textColor = .primaryText
        label.font = .preferredFont(forTextStyle: .headline)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let containerBox: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let chartScrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.isPagingEnabled = true
        scroll.showsHorizontalScrollIndicator = false
        return scroll
    }()
    
    private let containerSectionStack: UIStackView = {
        let stack = UIStackView()
        stack.spacing = 12
        stack.axis = .horizontal
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let pageControl: UIPageControl = {
        let pc = UIPageControl()
        pc.numberOfPages = 2
        pc.currentPage = 0
        pc.currentPageIndicatorTintColor = .systemGreen
        pc.pageIndicatorTintColor = .systemGray4
        pc.translatesAutoresizingMaskIntoConstraints = false
        return pc
    }()
    
    private let emptyCostliestLabel: UILabel = {
        let label = UILabel()
        label.text = "Add your first subscriptions to start seeing content in this section."
        label.font = .preferredFont(forTextStyle: .callout)
        label.textColor = .secondaryText
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emptyPotentialLabel: UILabel = {
        let label = UILabel()
        label.text = "Add two or more active subscriptions to see your potential savings and spending insights."
        label.font = .preferredFont(forTextStyle: .callout)
        label.textColor = .secondaryText
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let bottomSpacerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setContentHuggingPriority(.defaultLow, for: .vertical)
        view.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        return view
    }()
    
    private var chartHostingController: UIHostingController<CumulativeChartView>?
    
    // MARK: - DATA
    private let viewmodel: InsightsViewModel
    
    // MARK: - LIFECYCLE
    
    init(viewModel: InsightsViewModel) {
        self.viewmodel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundColor
        self.headerScrollView = scrollView
        headerView.delegate = self
        setupLayout()
        
        chartScrollView.delegate = self
        
        setupAnalyticsHeader()
        setupTopCostliestSubscriptions()
        setupPotentialSavings()
        bringHeaderToFront()
        observeViewModel()
    }
    
    private func observeViewModel() {
        withObservationTracking {
            _ = viewmodel.isAnnonymousUser
            _ = viewmodel.allActiveSubscriptions
        } onChange: { [weak self] in
            Task { @MainActor [weak self] in
                guard let self else { return }
                self.setupAnalyticsHeader()
                self.setupTopCostliestSubscriptions()
                self.setupPotentialSavings()
                self.observeViewModel()
            }
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        let topPadding = view.safeAreaInsets.top
        let totalHeaderHeight = headerView.contentHeight + topPadding
        
        if scrollView.contentInset.top != totalHeaderHeight {
            scrollView.contentInset = UIEdgeInsets(top: totalHeaderHeight, left: 0, bottom: 0, right: 0)
            
            if lastOffset == 0 {
                scrollView.contentOffset = CGPoint(x: 0, y: -totalHeaderHeight)
                lastOffset = -totalHeaderHeight
            }
        }
    }
        
    private func setupLayout() {
        view.addSubview(scrollView)
        scrollView.addSubview(mainStackView)
        
        topSectionStack.addArrangedSubview(topSubscriptionsLabel)
        topSectionStack.addArrangedSubview(subscriptionsStackView)
        topSectionStack.addArrangedSubview(emptyCostliestLabel)
        
        savingSectionStack.addArrangedSubview(savingLabel)
        savingSectionStack.addArrangedSubview(containerBox)
        savingSectionStack.addArrangedSubview(emptyPotentialLabel)
        savingSectionStack.addArrangedSubview(pageControl)
        
        containerBox.addSubview(chartScrollView)
        chartScrollView.addSubview(containerSectionStack)
        
        mainStackView.addArrangedSubview(topSectionStack)
        mainStackView.addArrangedSubview(savingSectionStack)
        mainStackView.addArrangedSubview(bottomSpacerView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            mainStackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            mainStackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 16),
            mainStackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -16),
            mainStackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -16),
            
            mainStackView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -32),
            // adding
            mainStackView.heightAnchor.constraint(greaterThanOrEqualTo: scrollView.frameLayoutGuide.heightAnchor),
            
            chartScrollView.topAnchor.constraint(equalTo: containerBox.topAnchor),
            chartScrollView.leadingAnchor.constraint(equalTo: containerBox.leadingAnchor),
            chartScrollView.trailingAnchor.constraint(equalTo: containerBox.trailingAnchor),
            chartScrollView.bottomAnchor.constraint(equalTo: containerBox.bottomAnchor),
            
            containerSectionStack.topAnchor.constraint(equalTo: chartScrollView.contentLayoutGuide.topAnchor),
            containerSectionStack.leadingAnchor.constraint(equalTo: chartScrollView.contentLayoutGuide.leadingAnchor),
            containerSectionStack.trailingAnchor.constraint(equalTo: chartScrollView.contentLayoutGuide.trailingAnchor),
            containerSectionStack.bottomAnchor.constraint(equalTo: chartScrollView.contentLayoutGuide.bottomAnchor),
            
            containerSectionStack.heightAnchor.constraint(equalTo: chartScrollView.frameLayoutGuide.heightAnchor)
        ])
    }
    
    private func setupAnalyticsHeader() {
        if let hostingController = chartHostingController {
            hostingController.rootView = CumulativeChartView(subscriptions: viewmodel.allActiveSubscriptions)
            return
        }
        
        let chartView = CumulativeChartView(subscriptions: viewmodel.allActiveSubscriptions)
        let hostingController = UIHostingController(rootView: chartView)
        
        hostingController.view.backgroundColor = .clear
        
        addChild(hostingController)
        mainStackView.insertArrangedSubview(hostingController.view, at: 0)
        hostingController.didMove(toParent: self)
        
        self.chartHostingController = hostingController
    }
    
    private func setupTopCostliestSubscriptions() {
        
        subscriptionsStackView.removeAllArrangedSubviews()
        let costliestSubscriptions = viewmodel.costliestSubscriptions
        
        if costliestSubscriptions.isEmpty {
            subscriptionsStackView.isHidden = true
            emptyCostliestLabel.isHidden = false
        } else {
            subscriptionsStackView.isHidden = false
            emptyCostliestLabel.isHidden = true
            
            costliestSubscriptions.forEach { sub in
                let row = SubscriptionRowCellUIView()
                
                row.configure(subscription: sub)
                row.addTag(text: "Then $\(sub.monthlyPrice)/mo", textColor: .lightGray, bgColor: .white.withAlphaComponent(0.1))
                // check 
                row.setContentHuggingPriority(.required, for: .vertical)
                
                subscriptionsStackView.addArrangedSubview(row)
            }
        }
    }
    
    private func setupPotentialSavings() {
        containerSectionStack.removeAllArrangedSubviews()
        
        let activeSubs = viewmodel.allActiveSubscriptions.filter { $0.status == .active }
        
        if activeSubs.count < 2 {
            savingSectionStack.isHidden = true
            return
        } else {
            savingSectionStack.isHidden = false
        }
        
        let data1 = viewmodel.highestSubscriptionSaving()
        let data2 = viewmodel.costliestCategorySubSaving()
        
        let footnoteSize = UIFont.preferredFont(forTextStyle: .footnote).pointSize
        let boldFont = UIFont.boldSystemFont(ofSize: footnoteSize)
        
        var pagesCount = 0
          
        if data1.isEmpty {
            containerBox.isHidden = true
            emptyPotentialLabel.isHidden = false
        } else {
            containerBox.isHidden = false
            emptyPotentialLabel.isHidden = true
            
            if let sub = viewmodel.globalCostliestSub {
                let priceStr = "$\(String(format: "%.2f", sub.monthlyPrice))"
                let fullText = "Removing \(sub.title) would free up $\(priceStr) each month. See how your overall budget rebalances."
                
                let styledText = fullText.highlight(
                    words: [sub.title, priceStr],
                    font: boldFont,
                    color: .greenColorPlus
                )
                
                addPage(
                    to: containerSectionStack,
                    attributedDescription: styledText,
                    data: data1
                )
                pagesCount += 1
            }
        }
        
        if !data2.isEmpty {
            if let sub = viewmodel.costliestInCategory {
                let priceStr = "$\(String(format: "%.2f", sub.monthlyPrice))"
                let fullText = "You have multiple subscriptions in \(sub.category). Canceling \(sub.title) would save you $\(priceStr) every month."
                
                let styledText = fullText.highlight(
                    words: [sub.title, priceStr],
                    font: boldFont,
                    color: .greenColorPlus
                )
                
                addPage(
                    to: containerSectionStack,
                    attributedDescription: styledText,
                    data: data2
                )
                pagesCount += 1
            }
        }
        
        pageControl.numberOfPages = pagesCount
        pageControl.isHidden = pagesCount <= 1
    }
    
    private func addPage(to stack: UIStackView, attributedDescription: NSAttributedString, data: [ChartItem]) {
        let pageStack: UIStackView = {
            let stack = UIStackView()
            stack.spacing = 0
            stack.axis = .vertical
            stack.translatesAutoresizingMaskIntoConstraints = false
            return stack
        }()
        
        let chart = InfographicChartView()
        chart.updateData(with: data)
        chart.translatesAutoresizingMaskIntoConstraints = false
        chart.heightAnchor.constraint(equalToConstant: 240).isActive = true
        
        let chartDescriptionLabel: UILabel = {
            let label = UILabel()
            label.attributedText = attributedDescription
            label.numberOfLines = 0
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
        
        pageStack.addArrangedSubview(chart)
        pageStack.addArrangedSubview(chartDescriptionLabel)
        
        stack.addArrangedSubview(pageStack)
        pageStack.widthAnchor.constraint(equalTo: chartScrollView.frameLayoutGuide.widthAnchor).isActive = true
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == chartScrollView {
            guard scrollView.frame.width > 0 else { return }
            let pageIndex = round(scrollView.contentOffset.x / scrollView.frame.width)
            pageControl.currentPage = Int(pageIndex)
        } else {
            super.scrollViewDidScroll(scrollView)
        }
    }
    
}

extension InsightsViewController: HeaderViewDelegate {
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

#Preview("Subscriptions") {
    let container = DevPreview.shared.container
    let subscriptionManager = SubscriptionManager(service: MockSubscriptionService())
    subscriptionManager.addUserSubscriptionsListener(userId: "user1")
    
    container.register(SubscriptionManager.self, service: subscriptionManager)
    
    return VCPreview {
        let viewController = InsightsViewController(viewModel: InsightsViewModel(container: container) )
        
        return viewController
    }
    .ignoresSafeArea()
}

#Preview("One-Subscription") {
    let configuredContainer: DependencyContainer = {
        let container = DevPreview.shared.container
        
        let mockService = MockSubscriptionService(subscriptions: [SubscriptionModel.mocks[0]])
        let subscriptionManager = SubscriptionManager(service: mockService)
        subscriptionManager.addUserSubscriptionsListener(userId: "user1")
        
        container.register(SubscriptionManager.self, service: subscriptionManager)
        return container
    }()
    
    
    return VCPreview {
        let viewController = InsightsViewController(viewModel: InsightsViewModel(container: configuredContainer) )
        
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
        let viewController = InsightsViewController(viewModel: InsightsViewModel(container: container) )
        
        return viewController
    }
    .ignoresSafeArea()
}

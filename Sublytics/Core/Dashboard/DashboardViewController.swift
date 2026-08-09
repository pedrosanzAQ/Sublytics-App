//
//  DashboardViewController.swift
//  Sublytics
//
//  Created by pedrosanz on 05/03/26.
//

import UIKit
import SwiftUI

class DashboardViewController: HeaderViewController {
    
    //MARK: -VIEWS
    private let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.contentInsetAdjustmentBehavior = .never
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.alwaysBounceVertical = true
        scroll.showsVerticalScrollIndicator = false
        return scroll
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
        // MAINSTACK
    private let mainStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 30
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let cardView: CardUIView
    
    private let cardSectionStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        return stack
    }()
    
    private let cardTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Overview"
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.textColor = .primaryText
        return label
    }()
    
    // Chart Section
    private let chartView = InfographicChartView()
    
    private let chartSectionStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 6
        return stack
    }()
    
    private let chartTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Monthly spending"
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.textColor = .primaryText
        return label
    }()
    
    private let chartDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .footnote)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()
    
    // Subscription Section
    private let subscriptionsSectionStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 20
        return stack
    }()
    
    private let subscriptionsTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Upcoming charges"
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.textColor = .primaryText
        return label
    }()
    
    private let subscriptionsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let emptyUpcomingLabel: UILabel = {
        let label = UILabel()
        label.text = "No upcoming charges detected yet."
        label.font = .preferredFont(forTextStyle: .callout)
        label.textColor = .secondaryText
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let iconImageView: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(systemName: "chart.bar")
        image.tintColor = .primaryText
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    private let bottomSpacerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setContentHuggingPriority(.defaultLow, for: .vertical)
        view.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        return view
    }()
    
    // MARK: - DATA
    private let viewModel: DashboardViewModel
    
    // MARK: - LIFECYCLE
    
    init(viewModel: DashboardViewModel) {
        self.viewModel = viewModel
        self.cardView = CardUIView(viewModel: viewModel)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {    
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.headerScrollView = scrollView
        headerView.delegate = self
        view.backgroundColor = .backgroundColor

        setupView()
        setupConstraints()
        renderCharts()
        renderSubcriptions()
        bringHeaderToFront()
        observeViewModel()
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
    
    private func setupView() {
        cardView.translatesAutoresizingMaskIntoConstraints = false
        chartView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(mainStackView)
        
        cardSectionStack.addArrangedSubview(cardTitleLabel)
        cardSectionStack.addArrangedSubview(cardView)
        
        chartSectionStack.addArrangedSubview(chartTitleLabel)
        chartSectionStack.addArrangedSubview(chartView)
        chartSectionStack.addArrangedSubview(chartDescriptionLabel)
        
        subscriptionsSectionStack.addArrangedSubview(subscriptionsTitleLabel)
        subscriptionsSectionStack.addArrangedSubview(subscriptionsStackView)
        subscriptionsSectionStack.addArrangedSubview(emptyUpcomingLabel)
        
        mainStackView.addArrangedSubview(cardSectionStack)
        mainStackView.addArrangedSubview(chartSectionStack)
        mainStackView.addArrangedSubview(subscriptionsSectionStack)
        mainStackView.addArrangedSubview(bottomSpacerView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            contentView.heightAnchor.constraint(greaterThanOrEqualTo: scrollView.frameLayoutGuide.heightAnchor),
            
            mainStackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            mainStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            mainStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            mainStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            
            cardView.heightAnchor.constraint(equalToConstant: 240),
            chartView.heightAnchor.constraint(equalToConstant: 240),
        ])
    }
    
    private func observeViewModel() {
        withObservationTracking {
            _ = viewModel.isAnonymousUser
            _ = viewModel.allSubscriptions
            _ = viewModel.currentMonthlySpending
            _ = viewModel.currentAnnualSpending
            _ = viewModel.upcomingsubsCharges
        } onChange: { [weak self] in
            Task { @MainActor [weak self] in
                guard let self else { return }
                self.renderCharts()
                self.renderSubcriptions()
                self.observeViewModel()
            }
        }
    }
    
    private func renderCharts() {
        let chartData = viewModel.montlySpendingInfograficChart()
        chartView.updateData(with: chartData)
        
        let boldFont = UIFont.systemFont(ofSize: 13, weight: .bold)
        
        if viewModel.currentMonthlySpending > viewModel.previousMonthlySpending {
            let difTotal = String(format: "%.2f", (viewModel.currentMonthlySpending - viewModel.previousMonthlySpending))
            let fullText = "Your monthly overhead increased by $\(difTotal) compared to last month."
            
            chartDescriptionLabel.attributedText = fullText.highlight(
                words: ["$\(difTotal)", "increased"],
                font: boldFont,
                color: .greenColorPlus
            )
            
        } else {
            let percentage = abs(viewModel.getDiferencePorcentage())
            let fullText = "Great job! Your monthly spending dropped by \(percentage)%."
            
            chartDescriptionLabel.attributedText = fullText.highlight(
                words: ["\(percentage)%", "dropped"],
                font: boldFont,
                color: .greenColorPlus
            )
        }
    }
    
    private func renderSubcriptions() {
        let subs = viewModel.upcomingsubsCharges
        
        subscriptionsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        if subs.isEmpty {
            subscriptionsStackView.isHidden = true
            emptyUpcomingLabel.isHidden = false
        } else {
            subscriptionsStackView.isHidden = false
            emptyUpcomingLabel.isHidden = true
            
            subs.forEach { sub in
                let row = SubscriptionRowCellUIView()
                row.configure(subscription: sub)
                
                sub.isTrial ?
                row.addTag(text: "Trial", textColor: .white, bgColor: .systemPurple.withAlphaComponent(0.3)) :
                row.addTag(text: "Then $\(sub.monthlyPrice)/mo", textColor: .secondaryText, bgColor: .greenColorPlus.withAlphaComponent(0.4))
                
                subscriptionsStackView.addArrangedSubview(row)
            }
        }
    }
}

extension DashboardViewController: HeaderViewDelegate {
    func onAddSubscriptionPressed(_ header: HeaderView) {
        
        if !viewModel.isAnonymousUser {
            let addVC = AddSubscriptionViewController(viewmodel: AddSusbcriptionViewModel(container: viewModel.container))
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
        let rootVC = SearchRootViewController(viewmodel: SearchRootViewModel(container: viewModel.container))
        nav.pushViewController(rootVC, animated: true)
    }
}

extension UIViewController {
    
    func showToast(message: String, duration: TimeInterval = 1.8) {
        let containerView = UIView()
        containerView.backgroundColor = UIColor.black.withAlphaComponent(0.85)
        containerView.layer.cornerRadius = 12
        containerView.clipsToBounds = true
        containerView.alpha = 0.0
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        let toastLabel = UILabel()
        toastLabel.text = message
        toastLabel.textColor = .white
        toastLabel.font = .preferredFont(forTextStyle: .subheadline)
        toastLabel.textAlignment = .center
        toastLabel.numberOfLines = 0
        toastLabel.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(toastLabel)
        view.addSubview(containerView)
        
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -120),
            containerView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 24),
            containerView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -24),
            
            toastLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            toastLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10),
            toastLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            toastLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20)
        ])
        
        containerView.transform = CGAffineTransform(translationX: 0, y: 10)
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            containerView.alpha = 1.0
            containerView.transform = .identity
        }) { _ in
            UIView.animate(withDuration: 0.3, delay: duration, options: .curveEaseIn, animations: {
                containerView.alpha = 0.0
                containerView.transform = CGAffineTransform(translationX: 0, y: 10)
            }) { _ in
                containerView.removeFromSuperview()
            }
        }
    }
}

#Preview("Subscriptions") {
    let container = DevPreview.shared.container
    
    let mockService = MockSubscriptionService()
    let subscriptionManager = SubscriptionManager(service: mockService)
    
    subscriptionManager.addUserSubscriptionsListener(userId: "user1")
    container.register(SubscriptionManager.self, service: subscriptionManager)
    
    return VCPreview { DashboardViewController(viewModel: DashboardViewModel(container: container)) }
        .ignoresSafeArea()
}

#Preview("No-Subscriptions") {
    let container = DevPreview.shared.container
    
    let subscriptionManager = SubscriptionManager(service: MockSubscriptionService(subscriptions: []))
    container.register(SubscriptionManager.self, service: subscriptionManager)
    
    return VCPreview { DashboardViewController(viewModel: DashboardViewModel(container: container)) }
        .ignoresSafeArea()
    
}

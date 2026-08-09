//
//  SubscriptionsExtendedHeader.swift
//  Sublytics
//
//  Created by pedrosanz on 17/04/26.
//

import UIKit

protocol SubscriptionsHeaderViewExtendedDelegate: AnyObject {
    func didSelectCategory(_ category: String?)
}

class SubscriptionsHeaderViewExtentended: HeaderView {
    
    weak var subDelegate: SubscriptionsHeaderViewExtendedDelegate?
    private var selectedCategoryTitle: String = "All"
    
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
    
    override var contentHeight: CGFloat { return 100 }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupExtendedHeaderUI()
    }
    
    func setupExtendedHeaderUI() {
        movingContainer.addSubview(categoriesScrollView)
        categoriesScrollView.addSubview(horizontalCategoryStackView)

        
        horizontalCategoryStackView.distribution = .fill
        horizontalCategoryStackView.alignment = .fill
        
        NSLayoutConstraint.activate([
            categoriesScrollView.topAnchor.constraint(equalTo: baseHeaderStack.bottomAnchor),
            categoriesScrollView.leadingAnchor.constraint(equalTo: movingContainer.leadingAnchor),
            categoriesScrollView.trailingAnchor.constraint(equalTo: movingContainer.trailingAnchor),
            categoriesScrollView.heightAnchor.constraint(equalToConstant: 48),
            categoriesScrollView.bottomAnchor.constraint(equalTo: movingContainer.bottomAnchor, constant: -4),
            
            horizontalCategoryStackView.topAnchor.constraint(equalTo: categoriesScrollView.contentLayoutGuide.topAnchor),
            horizontalCategoryStackView.leadingAnchor.constraint(equalTo: categoriesScrollView.contentLayoutGuide.leadingAnchor, constant: 16),
            horizontalCategoryStackView.trailingAnchor.constraint(equalTo: categoriesScrollView.contentLayoutGuide.trailingAnchor, constant: -16),
            horizontalCategoryStackView.bottomAnchor.constraint(equalTo: categoriesScrollView.contentLayoutGuide.bottomAnchor),
            
            horizontalCategoryStackView.heightAnchor.constraint(equalTo: categoriesScrollView.frameLayoutGuide.heightAnchor)
            
        ])
        
        horizontalCategoryStackView.distribution = .fill
        horizontalCategoryStackView.alignment = .center
        
        setupCategoryButtons()
    }
    
    private func setupCategoryButtons() {
        horizontalCategoryStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let allButton = createCategoryButton(title: "All")
        horizontalCategoryStackView.addArrangedSubview(allButton)
        
        SubCategory.allCases.forEach { category in
            let title = category.rawValue.capitalized
            let button = createCategoryButton(title: title)
            horizontalCategoryStackView.addArrangedSubview(button)
        }
    }
    
    private func createCategoryButton(title: String) -> UIButton {
        let isSelected = (title == selectedCategoryTitle)
        
        var config = UIButton.Configuration.filled()
        config.title = title
        config.baseForegroundColor = isSelected ? .primaryText : .secondaryText
        config.baseBackgroundColor = isSelected ? .greenColor : .systemGray.withAlphaComponent(0.3)
        config.cornerStyle = .large
        config.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12)
        
        let action = UIAction { [weak self] _ in
            self?.categoryButtonTapped(title: title)
        }
        
        let button = UIButton(configuration: config, primaryAction: action)
        button.setContentHuggingPriority(.required, for: .horizontal)
        button.setContentCompressionResistancePriority(.required, for: .horizontal)
        return button
    }
    
    private func categoryButtonTapped(title: String) {
        guard selectedCategoryTitle != title else { return }
        
        selectedCategoryTitle = title
        setupCategoryButtons()
        
        if title == "All" {
            subDelegate?.didSelectCategory(nil)
        } else {
            subDelegate?.didSelectCategory(title.lowercased())
        }
    }

    required init?(coder: NSCoder) { fatalError() }
}

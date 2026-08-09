//
//  SubscriptionBoxCellUIView.swift
//  Sublytics
//
//  Created by pedrosanz on 19/03/26.
//

import UIKit
import SwiftUI

class SubscriptionBoxCellUIView: UIView {
    
    private let mainStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.distribution = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let iconContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.borderWidth = 1.5
        view.layer.cornerRadius = 24
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let informationSectionStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 6
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let horizontalTitleStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.textColor = .primaryText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let monthPriceLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.textColor = .primaryText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let renewalDaysLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .footnote)
        label.textColor = .secondaryText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        self.addSubview(mainStack)
        
        iconContainerView.addSubview(iconImageView)
        
        horizontalTitleStack.addArrangedSubview(titleLabel)
        horizontalTitleStack.addArrangedSubview(monthPriceLabel)
        
        informationSectionStack.addArrangedSubview(horizontalTitleStack)
        informationSectionStack.addArrangedSubview(renewalDaysLabel)
        
        mainStack.addArrangedSubview(iconContainerView)
        mainStack.addArrangedSubview(informationSectionStack)
        let spacer = UIView()
        spacer.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: self.topAnchor, constant: 8),
            mainStack.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8),
            mainStack.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8),
            
            iconContainerView.heightAnchor.constraint(equalToConstant: 120),
            
            iconImageView.centerXAnchor.constraint(equalTo: iconContainerView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainerView.centerYAnchor)
            
        ])
        
    }
    
    func config(with subscription: SubscriptionModel) {
        iconImageView.image = UIImage(systemName: subscription.iconName)
        titleLabel.text = subscription.title
        monthPriceLabel.text = "$\(subscription.monthlyPrice)"
        
        if subscription.remainingDays == 1 {
            renewalDaysLabel.text = "Renew in 1 day"
        } else {
            renewalDaysLabel.text = "Renew in \(subscription.remainingDays) days"
        }
    }
    
}


struct SubscriptionBoxCellUIView_Preview: UIViewRepresentable {
    let configure: (SubscriptionBoxCellUIView) -> Void
    
    func makeUIView(context: Context) -> SubscriptionBoxCellUIView {
        let view = SubscriptionBoxCellUIView()
        configure(view)
        return view
    }
    
    func updateUIView(_ uiView: SubscriptionBoxCellUIView, context: Context) {
    }
}

struct SubscriptionBoxCellUIView_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView(.horizontal){
            HStack(spacing: 2){
                SubscriptionBoxCellUIView_Preview(configure: { view in
                    view.config(with: SubscriptionModel.mocks[3])
                })
                .frame(height: 190)
                .frame(width: 140)
                
                SubscriptionBoxCellUIView_Preview(configure: { view in
                    view.config(with: SubscriptionModel.mocks[1])
                })
                .frame(height: 190)
                .frame(width: 140)
                
                SubscriptionBoxCellUIView_Preview(configure: { view in
                    view.config(with: SubscriptionModel.mocks[2])
                })
                .frame(height: 190)
                .frame(width: 140)
            }

        }
    }
}

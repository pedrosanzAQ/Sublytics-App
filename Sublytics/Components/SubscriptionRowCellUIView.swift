//
//  SubscriptionRowCellUIView.swift
//  Sublytics
//
//  Created by pedrosanz on 11/03/26.
//

import UIKit
class PaddingLabel: UILabel {
    var insets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: insets))
    }
    
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + insets.left + insets.right,
                      height: size.height + insets.top + insets.bottom)
    }
}

class SubscriptionRowCellUIView: UIView {
    
    var onTap: (() -> Void)?
    
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
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.textColor = .white
        return label
    }()
    
    private let categoryLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        label.textColor = .lightGray
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.textColor = .white
        label.textAlignment = .right
        return label
    }()
    
    private let tagsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 4
        stack.alignment = .center
        return stack
    }()
    
    private let blurView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .systemThinMaterialDark) // O .dark
        let view = UIVisualEffectView(effect: blurEffect)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupTapGesture()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        self.backgroundColor = .backgroundColor.withAlphaComponent(0.9)
        self.layer.cornerRadius = 20
        self.clipsToBounds = true
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.white.withAlphaComponent(0.1).cgColor
        
        addSubview(blurView)
        
        let middleStack = UIStackView(arrangedSubviews: [titleLabel, categoryLabel])
        middleStack.axis = .vertical
        middleStack.spacing = 4
        middleStack.alignment = .leading
        
        let rightStack = UIStackView(arrangedSubviews: [priceLabel, tagsStackView])
        rightStack.axis = .vertical
        rightStack.spacing = 4
        rightStack.alignment = .trailing
        
        let mainStack = UIStackView(arrangedSubviews: [iconContainerView, middleStack, rightStack])
        mainStack.axis = .horizontal
        mainStack.spacing = 16
        mainStack.alignment = .center
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        
        iconContainerView.addSubview(iconImageView)
        addSubview(mainStack)
        
        NSLayoutConstraint.activate([
            blurView.topAnchor.constraint(equalTo: topAnchor),
            blurView.leadingAnchor.constraint(equalTo: leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: trailingAnchor),
            blurView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            iconContainerView.widthAnchor.constraint(equalToConstant: 48),
            iconContainerView.heightAnchor.constraint(equalToConstant: 48),
            
            iconImageView.centerXAnchor.constraint(equalTo: iconContainerView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainerView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),
            
            mainStack.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            mainStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            mainStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
    }
    
    func configure(subscription: SubscriptionModel, isOnSubscriptionView: Bool = false) {
        titleLabel.text = subscription.title
        categoryLabel.text = subscription.category
        
        if isOnSubscriptionView {
            priceLabel.text = "$\(subscription.monthlyPrice)"
        } else {
            priceLabel.text = "\(subscription.remainingDays) days"
        }
        
        iconImageView.image = UIImage(systemName: subscription.iconName)
        iconImageView.tintColor = subscription.iconColor
        iconContainerView.layer.borderColor = subscription.iconColor.withAlphaComponent(0.3).cgColor
        
        tagsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
    }
    
    private func setupTapGesture() {
        gestureRecognizers?.removeAll()
        
        self.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        
        self.addGestureRecognizer(tap)
    }

    func addTag(text: String, textColor: UIColor, bgColor: UIColor) {
        let tagLabel = PaddingLabel()
        tagLabel.text = text
        tagLabel.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        tagLabel.textColor = textColor
        tagLabel.backgroundColor = bgColor
        tagLabel.layer.cornerRadius = 6
        tagLabel.clipsToBounds = true
        
        tagsStackView.addArrangedSubview(tagLabel)
    }
    
    @objc private func handleTap() {
        onTap?()
    }
}

import SwiftUI

struct SubscriptionRowCellUIView_Preview: UIViewRepresentable {
    let configure: (SubscriptionRowCellUIView) -> Void
    
    
    func makeUIView(context: Context) -> SubscriptionRowCellUIView {
        let view = SubscriptionRowCellUIView()
        configure(view)
        return view
    }
    
    func updateUIView(_ uiView: SubscriptionRowCellUIView, context: Context) {
    }
}

struct SubscriptionRowView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.init(uiColor: .backgroundColor)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 16) {
                SubscriptionRowCellUIView_Preview(configure: { view in
                    view.configure(subscription: SubscriptionModel.mocks[0])
                    
                    view.addTag(text: "Trial",
                                textColor: UIColor(red: 0.5, green: 0.4, blue: 0.9, alpha: 1.0),
                                bgColor: UIColor(red: 0.2, green: 0.15, blue: 0.3, alpha: 1.0))
                    
                    view.addTag(text: "Then $9.99/mo",
                                textColor: UIColor(red: 0.2, green: 0.8, blue: 0.6, alpha: 1.0),
                                bgColor: UIColor(red: 0.1, green: 0.3, blue: 0.25, alpha: 1.0))
                })
                .frame(height: 80)
                
                SubscriptionRowCellUIView_Preview(configure: { view in
                    view.configure(subscription: SubscriptionModel.mocks[1], isOnSubscriptionView: true)
                    
                    view.addTag(text: "10 DAYS",
                                textColor: .lightGray,
                                bgColor: UIColor(white: 0.2, alpha: 1.0))
                })
                .frame(height: 80)
            }
            .padding(20)
        }
    }
}

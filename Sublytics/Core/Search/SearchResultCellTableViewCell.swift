//
//  SearchResultCellTableViewCell.swift
//  Sublytics
//
//  Created by pedrosanz on 15/05/26.
//

import UIKit
import SwiftUI

class SearchResultCellTableViewCell: UITableViewCell {
    
    //MARK: -VIEWS
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

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    private func setupUI(){
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        
        blurView.layer.cornerRadius = 16
        blurView.clipsToBounds = true
        blurView.layer.borderWidth = 1
        blurView.layer.borderColor = UIColor.white.withAlphaComponent(0.15).cgColor
        
        contentView.addSubview(blurView)
        
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
        blurView.contentView.addSubview(mainStack)
        
        NSLayoutConstraint.activate([
            blurView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            blurView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            blurView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            blurView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            iconContainerView.widthAnchor.constraint(equalToConstant: 48),
            iconContainerView.heightAnchor.constraint(equalToConstant: 48),
            
            iconImageView.centerXAnchor.constraint(equalTo: iconContainerView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainerView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),
            
            mainStack.topAnchor.constraint(equalTo: blurView.contentView.topAnchor, constant: 16),
            mainStack.leadingAnchor.constraint(equalTo: blurView.contentView.leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: blurView.contentView.trailingAnchor, constant: -16),
            mainStack.bottomAnchor.constraint(equalTo: blurView.contentView.bottomAnchor, constant: -16)
        ])
    }
    
    func configure(subscription: SubscriptionModel) {
        titleLabel.text = subscription.title
        categoryLabel.text = subscription.category
        priceLabel.text = "$\(subscription.monthlyPrice)"
        
        iconImageView.image = UIImage(systemName: subscription.iconName)
        iconImageView.tintColor = subscription.iconColor
        iconContainerView.layer.borderColor = subscription.iconColor.withAlphaComponent(0.3).cgColor
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
}

struct CellPreviewContainer: UIViewRepresentable {
    
    func makeUIView(context: Context) -> UITableViewCell {
        let cell = SearchResultCellTableViewCell(style: .default, reuseIdentifier: "PreviewCell")
        
        cell.configure(subscription: SubscriptionModel.mock)
        cell.addTag(text: "PREMIUM", textColor: .black, bgColor: .systemYellow)
        cell.addTag(text: "4K ULTRA", textColor: .white, bgColor: .systemPurple)
        
        return cell
    }
    
    func updateUIView(_ uiView: UITableViewCell, context: Context) {
        
    }
}


#Preview {
    CellPreviewContainer()
        .background(Color(uiColor: .backgroundColor))
        .padding()
}

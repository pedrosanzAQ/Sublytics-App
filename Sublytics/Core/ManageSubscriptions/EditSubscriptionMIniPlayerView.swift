//
//  EditSubscriptionMIniPlayerView.swift
//  Sublytics
//
//  Created by pedrosanz on 25/05/26.
//

import UIKit
import SwiftUI

class EditSubscriptionMIniPlayerView: UIView {

    let glassEffectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .systemChromeMaterialDark)
        let ev = UIVisualEffectView(effect: blurEffect)
        ev.layer.cornerRadius = 18
        ev.clipsToBounds = true
        ev.translatesAutoresizingMaskIntoConstraints = false
        
        ev.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        ev.layer.borderWidth = 0.6
        ev.layer.borderColor = UIColor.white.withAlphaComponent(0.28).cgColor
        return ev
    }()
    
    let miniPlayerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.cornerRadius = 18
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alpha = 0
        
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 8)
        view.layer.shadowRadius = 16
        view.layer.shadowOpacity = 0.45
        return view
    }()
    
    let miniIconImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    let miniTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        label.textColor = .primaryText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let miniSubtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .caption1)
        label.textColor = .secondaryText
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let miniCloseButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "xmark.circle.fill")
        let button = UIButton(configuration: config)
        button.tintColor = .secondaryText
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var onExpandTapped: (() -> Void)?
    var onCloseTapped: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        miniPlayerView.layer.shadowPath = UIBezierPath(roundedRect: miniPlayerView.bounds, cornerRadius: 18).cgPath
    }
    
    private func setup() {
        addSubview(miniPlayerView)
        miniPlayerView.addSubview(glassEffectView)
        
        let textStack = UIStackView(arrangedSubviews: [miniTitleLabel, miniSubtitleLabel])
        textStack.axis = .vertical
        textStack.spacing = 4
        textStack.translatesAutoresizingMaskIntoConstraints = false
        
        glassEffectView.contentView.addSubview(miniIconImageView)
        glassEffectView.contentView.addSubview(textStack)
        glassEffectView.contentView.addSubview(miniCloseButton)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(expandTapped))
        miniPlayerView.addGestureRecognizer(tap)
        
        miniCloseButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            miniPlayerView.topAnchor.constraint(equalTo: topAnchor),
            miniPlayerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            miniPlayerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            miniPlayerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            glassEffectView.topAnchor.constraint(equalTo: miniPlayerView.topAnchor),
            glassEffectView.leadingAnchor.constraint(equalTo: miniPlayerView.leadingAnchor),
            glassEffectView.trailingAnchor.constraint(equalTo: miniPlayerView.trailingAnchor),
            glassEffectView.bottomAnchor.constraint(equalTo: miniPlayerView.bottomAnchor),
            
            miniIconImageView.leadingAnchor.constraint(equalTo: glassEffectView.contentView.leadingAnchor, constant: 16),
            miniIconImageView.centerYAnchor.constraint(equalTo: miniPlayerView.centerYAnchor),
            miniIconImageView.widthAnchor.constraint(equalToConstant: 32),
            miniIconImageView.heightAnchor.constraint(equalToConstant: 32),
            
            textStack.leadingAnchor.constraint(equalTo: miniIconImageView.trailingAnchor, constant: 16),
            textStack.trailingAnchor.constraint(equalTo: miniCloseButton.leadingAnchor, constant: -8),
            textStack.centerYAnchor.constraint(equalTo: glassEffectView.contentView.centerYAnchor),
            
            miniCloseButton.trailingAnchor.constraint(equalTo: glassEffectView.contentView.trailingAnchor, constant: -10),
            miniCloseButton.centerYAnchor.constraint(equalTo: glassEffectView.contentView.centerYAnchor),
            miniCloseButton.widthAnchor.constraint(equalToConstant: 44),
            miniCloseButton.heightAnchor.constraint(equalToConstant: 44),
        ])
    }
    
    func configure(title: String, iconName: String, price: String? = nil, nextPayment: String? = nil) {
        miniTitleLabel.text = title
        miniIconImageView.image = UIImage(systemName: iconName)
        
        if let price, let nextPayment {
            miniSubtitleLabel.text = "$\(price)/mo · Next \(nextPayment)"
            miniSubtitleLabel.isHidden = false
        } else if let price {
            miniSubtitleLabel.text = "$\(price)/mo"
            miniSubtitleLabel.isHidden = false
        } else {
            miniSubtitleLabel.isHidden = true
        }
    }
    
    func show(animated: Bool = true) {
        if animated {
            UIView.animate(withDuration: 0.3) {
                self.miniPlayerView.alpha = 1
            }
        } else {
            miniPlayerView.alpha = 1
        }
    }
    
    func hide(animated: Bool = true) {
        if animated {
            UIView.animate(withDuration: 0.3) {
                self.miniPlayerView.alpha = 0
            }
        } else {
            miniPlayerView.alpha = 0
        }
    }
    
    @objc private func expandTapped() {
        onExpandTapped?()
    }
    
    @objc private func closeTapped() {
        onCloseTapped?()
    }
}

#Preview("MiniPlayer") {
    VCPreview {
        let vc = UIViewController()
        vc.view.backgroundColor = .backgroundColor
        
        let miniPlayer = EditSubscriptionMIniPlayerView()
        miniPlayer.translatesAutoresizingMaskIntoConstraints = false
        miniPlayer.configure(title: "Spotify", iconName: "music.note", price: "6.87", nextPayment: "25")
        miniPlayer.show(animated: false)
        
        vc.view.addSubview(miniPlayer)
        NSLayoutConstraint.activate([
            miniPlayer.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            miniPlayer.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16),
            miniPlayer.bottomAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
            miniPlayer.heightAnchor.constraint(equalToConstant: 65),
        ])
        
        return vc
    }
    .ignoresSafeArea()
}

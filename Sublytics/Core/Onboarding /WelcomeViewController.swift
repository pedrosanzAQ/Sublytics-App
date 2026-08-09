//
//  WelcomeViewController.swift
//  Sublytics
//
//  Created by pedrosanz on 04/03/26.
//

import UIKit
import SwiftUI

class WelcomeViewController: UIViewController {
    
    private let viewModel: WelcomeViewModel
    
    private let iconImageView: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(systemName: "chart.bar.xaxis")
        image.tintColor = .primaryText
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    private let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.text = "Sublytics"
        titleLabel.font = UIFont.preferredFont(forTextStyle: .title1)
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.textColor = .primaryText
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
    }()
    
    private let descripcionLabel: UILabel = {
        let label = UILabel()
        label.text = "Keep track of all your subscriptions, analyze recurring costs, and gain clear insights into your spending habits."
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        label.adjustsFontForContentSizeCategory = true
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .secondaryText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let getStartedButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Get started"
        config.baseBackgroundColor = .primaryText
        config.baseBackgroundColor = .backgroundColor
        config.cornerStyle = .capsule
        
        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let haveAccountLabel: UILabel = {
        let label = UILabel()
        label.text = "Already have an account?"
        label.font = UIFont.preferredFont(forTextStyle: .caption1)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .secondaryText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let signinLabel: UILabel = {
        let label = UILabel()
        label.text = "Sign in."
        label.font = UIFont.preferredFont(forTextStyle: .caption1)
        label.textColor = .primaryText
        label.adjustsFontForContentSizeCategory = true
        label.isUserInteractionEnabled = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var accountStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [haveAccountLabel, signinLabel])
        stack.axis = .horizontal
        stack.spacing = 6
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let underlineView: UIView = {
        let view = UIView()
        view.backgroundColor = .primaryText
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let termOfServiceLabel: UILabel = {
        let label = UILabel()
        label.text = "Terms of Service"
        label.font = UIFont.preferredFont(forTextStyle: .caption1)
        label.textColor = .primaryText
        label.adjustsFontForContentSizeCategory = true
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private let privacyPocilyLabel: UILabel = {
       let label = UILabel()
        label.text = "Privacy Policy"
        label.font = UIFont.preferredFont(forTextStyle: .caption1)
        label.textColor = .primaryText
        label.adjustsFontForContentSizeCategory = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dotimageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "circle.fill")?.applyingSymbolConfiguration(.init(pointSize: 8))
        imageView.tintColor = .primaryText
        return imageView
    }()
    
    private lazy var termsOfServiceStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [termOfServiceLabel, dotimageView, privacyPocilyLabel])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    init(viewModel: WelcomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Task {
            await viewModel.checkAuthUserStatus()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundGradient()
        setupView()
        setupConstraints()
        setupActions()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let gradientLayer = view.layer.sublayers?.first(where: { $0.name == "MyGradient" }) as? CAGradientLayer {
            gradientLayer.frame = view.bounds
        }
    }
    
    private func setupView() {
        view.addSubview(iconImageView)
        view.addSubview(titleLabel)
        view.addSubview(descripcionLabel)
        view.addSubview(getStartedButton)
        view.addSubview(accountStack)
        view.addSubview(underlineView)
        view.addSubview(termsOfServiceStack)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: view.topAnchor),
            
            iconImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -30),
            iconImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 100),
            iconImageView.heightAnchor.constraint(equalToConstant: 100),
            
            titleLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 4),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            descripcionLabel.bottomAnchor.constraint(equalTo: getStartedButton.topAnchor, constant: -25),
            descripcionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            descripcionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            getStartedButton.bottomAnchor.constraint(equalTo: accountStack.topAnchor, constant: -20),
            getStartedButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            getStartedButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            getStartedButton.heightAnchor.constraint(equalToConstant: 50),
            
            accountStack.bottomAnchor.constraint(equalTo: termOfServiceLabel.topAnchor, constant: -50),
            accountStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            underlineView.topAnchor.constraint(equalTo: accountStack.bottomAnchor, constant: 0),
            underlineView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            underlineView.widthAnchor.constraint(equalTo: accountStack.widthAnchor),
            underlineView.heightAnchor.constraint(equalToConstant: 1),
            
            termsOfServiceStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            termsOfServiceStack.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func setupActions() {
        getStartedButton.addTarget(self, action: #selector(getStartedTapped), for: .touchUpInside)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(signInTapped))
        signinLabel.addGestureRecognizer(tap)
    }
    
    @objc private func signInTapped() {
        UIView.animate(withDuration: 0.2, animations: {
            self.signinLabel.alpha = 0.5
        }) { _ in
            self.signinLabel.alpha = 1
        }
        
        let modalVC = SignInModalViewController(viewmodel: SignInModalViewModel(container: viewModel.container), fromView: .welcome)
        if let sheet = modalVC.sheetPresentationController {
            sheet.detents = [.medium()]
        }

        present(modalVC, animated: true)
    }
    
    @objc private func getStartedTapped() {
        viewModel.onStartedPressed()
    }
}

struct WelcomeViewController_Preview: PreviewProvider {
    static var previews: some View {
        VCPreview { WelcomeViewController(viewModel: WelcomeViewModel(container: DevPreview.shared.container)) }
            .ignoresSafeArea()
    }
}

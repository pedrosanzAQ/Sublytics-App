//
//  UsernameViewController.swift
//  Sublytics
//
//  Created by pedrosanz on 24/04/26.
//

import UIKit
import SwiftUI

class UsernameViewController: UIViewController {
    
    var onContinuePressed: ((String) -> Void)?
    
    private let mainStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.text = "Username"
        let font = UIFont.preferredFont(forTextStyle: .title1)
        
        if let descriptor = font.fontDescriptor.withSymbolicTraits(.traitBold) {
            titleLabel.font = UIFont(descriptor: descriptor, size: 0)
        } else {
            titleLabel.font = .systemFont(ofSize: 28, weight: .bold)
        }
        
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.textColor = .primaryText
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
    }()
    
    private let descriptionLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.text = "This username is private. It will only be visible to you for account identification"
        titleLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        titleLabel.numberOfLines = 0
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.textColor = .secondaryText
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
    }()
    
    let userTextfield: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Enter your username"
        
        tf.borderStyle = .none
        tf.layer.cornerRadius = 16
        tf.clipsToBounds = true
        
        tf.backgroundColor = .systemGray2
        tf.textColor = .black
        tf.tintColor = .systemBlue
        tf.translatesAutoresizingMaskIntoConstraints = false
        
        let leftPadding = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        tf.leftView = leftPadding
        tf.leftViewMode = .always
        
        let rightPadding = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        tf.rightView = rightPadding
        tf.rightViewMode = .always
        
        tf.keyboardType = .default
        tf.returnKeyType = .done
        tf.autocorrectionType = .no
        tf.autocapitalizationType = .words
        return tf
    }()
    
    private lazy var informtionSection: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [descriptionLabel, userTextfield])
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let continueButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Continue"
        config.baseBackgroundColor = .primaryText
        config.baseBackgroundColor = .backgroundColor
        config.cornerStyle = .capsule
        
        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundGradient()
        setupView()
        setupConstraints()
        setupActions()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        userTextfield.becomeFirstResponder()
    }
    
    func setupView() {
        view.addSubview(mainStackView)
        mainStackView.addArrangedSubview(titleLabel)
        mainStackView.addArrangedSubview(informtionSection)
        mainStackView.addArrangedSubview(continueButton)
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor , constant: 35),
            mainStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            mainStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            informtionSection.leadingAnchor.constraint(equalTo: mainStackView.leadingAnchor, constant: 8),
            informtionSection.trailingAnchor.constraint(equalTo: mainStackView.trailingAnchor, constant: -8),
            continueButton.leadingAnchor.constraint(equalTo: mainStackView.leadingAnchor, constant: 8),
            continueButton.trailingAnchor.constraint(equalTo: mainStackView.trailingAnchor, constant: -8),
            
            userTextfield.heightAnchor.constraint(equalToConstant: 50),
            continueButton.heightAnchor.constraint(equalToConstant: 55)
        ])
    }
    
    func setupActions() {
        userTextfield.delegate = self
        continueButton.addTarget(self, action: #selector(handleContinue), for: .touchUpInside)
    }
    
    @objc private func handleContinue() {
        guard let newUsername = userTextfield.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !newUsername.isEmpty else { return }
        
        onContinuePressed?(newUsername)
        dismiss(animated: true)
    }
}

extension UsernameViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleContinue()
        return true
    }
}


#Preview("SinginView") {
    return VCPreview {
        let vc = UsernameViewController()
    
        let nav = UINavigationController(rootViewController: vc)
        return nav
    }
    .ignoresSafeArea()
}

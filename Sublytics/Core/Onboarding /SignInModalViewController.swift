//
//  SignInModalViewController.swift
//  Sublytics
//
//  Created by pedrosanz on 26/04/26.
//

import UIKit
import SwiftUI
import FirebaseAuth
import GoogleSignIn

enum SignInFrom {
    case welcome
    case settings
}

class SignInModalViewController: UIViewController {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Sign in"
        let font = UIFont.preferredFont(forTextStyle: .title1)
        if let descriptor = font.fontDescriptor.withSymbolicTraits(.traitBold) {
            label.font = UIFont(descriptor: descriptor, size: 0)
        }
        label.textColor = .primaryText
        label.textAlignment = .left
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Connect to an existing account."
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        label.textColor = .secondaryText
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var mainStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel, descriptionLabel])
        stack.axis = .vertical
        stack.spacing = 12
        stack.alignment = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let googleButton = GIDSignInButton()
    private let viewmodel: SignInModalViewModel
    private let fromView: SignInFrom
    
    
    init(viewmodel: SignInModalViewModel, fromView: SignInFrom) {
        self.viewmodel = viewmodel
        self.fromView = fromView
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundGradient()
        
        googleButton.style = .wide
        googleButton.center = view.center
        setupLayout()
        setupActions()
    }
    
    private func setupLayout() {
        view.addSubview(mainStackView)
        view.addSubview(googleButton)
        googleButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            mainStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            mainStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            
            googleButton.topAnchor.constraint(equalTo: mainStackView.bottomAnchor, constant: 20),
            googleButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            googleButton.widthAnchor.constraint(equalToConstant: 300),
            googleButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }
    
    private func setupActions() {
        googleButton.addTarget(self, action: #selector(handleGoogleSignIn), for: .touchUpInside)
    }
    
    @objc private func continueTapped() {
        dismiss(animated: true)
    }
    
    @objc func handleGoogleSignIn() {
        Task {
            do {
                let signInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: self)
                guard let idToken = signInResult.user.idToken?.tokenString else { return }
                let accessToken = signInResult.user.accessToken.tokenString
                
                do {
                    
                    let userAuthInfo = try await viewmodel.linkWithGoogle(idToken: idToken, accessToken: accessToken)
                    guard let auth = userAuthInfo else { return print("no userAuthInfo")}
                    
                    try await viewmodel.logIn(auth: auth)
                    viewmodel.addUserSubscriptionListener(userId: auth.uid)
                    
                    self.dismiss(animated: true)
                    
                } catch let error as NSError {
                    if error.code == AuthErrorCode.credentialAlreadyInUse.rawValue ||
                        error.code == AuthErrorCode.emailAlreadyInUse.rawValue {
                        
                        switch fromView {
                        case .welcome:
                            do {
                               try await viewmodel.deleteAnnonimuysAccount()
                            } catch {
                           
                            }
                            
                            do {
                                _ = try await viewmodel.singInAnExistingGoogleAccount(idToken: idToken, accesToken: accessToken)
                                self.dismiss(animated: true)
                            } catch {
                                
                            }
                            
                        case .settings:
                            showSwitchAccountAlert(idToken: idToken, accessToken: accessToken)
                        }
                        
                    } else {
                        
                    }
                }
            } catch {
                print("definitive error")
                self.dismiss(animated: true)
            }
        }
    }
    
    private func showSwitchAccountAlert(idToken: String, accessToken: String) {
        let alert = UIAlertController(
            title: "Account Already in Use",
            message: "This email is already associated with an account. Do you want to switch to it?",
            preferredStyle: .alert
        )
        
        let yesAction = UIAlertAction(title: "Yes, switch", style: .default) { [weak self] _ in
            Task {
                
                do {
                    try await self?.viewmodel.deleteAnnonimuysAccount()
                } catch {
                    
                }
                
                do {
                    let userAuthInfo = try await self?.viewmodel.singInAnExistingGoogleAccount(idToken: idToken, accesToken: accessToken)
                    
                    if let userAuthInfo {
                        try await self?.viewmodel.logIn(auth: userAuthInfo)
                        self?.viewmodel.addUserSubscriptionListener(userId: userAuthInfo.uid)
                    }
                    
                    self?.dismiss(animated: true)
                } catch {
                    print("Error swithing account: \(error.localizedDescription)")
                }
            }
        }
        
        let noAction = UIAlertAction(title: "No", style: .cancel) { _ in
            self.dismiss(animated: true)
        }
        
        alert.addAction(yesAction)
        alert.addAction(noAction)
        self.present(alert, animated: true)
    }

}


#Preview("SinginModalView") {
    VCPreview {
        SignInModalViewController(viewmodel: SignInModalViewModel(container: DevPreview.shared.container), fromView: .welcome)
    }
    .ignoresSafeArea()
}

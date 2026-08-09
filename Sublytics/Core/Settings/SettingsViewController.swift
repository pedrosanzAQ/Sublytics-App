//
//  SettingsViewController.swift
//  Sublytics
//
//  Created by pedrosanz on 05/03/26.
//

import UIKit
import SwiftUI
import GoogleSignIn

struct SettingItem {
    let title: String
    let icon: String
    let color: UIColor
}

class SettingsViewController: HeaderViewController {
    
    private let viewModel: SettingsViewModel
    private let headerContainerView = UIView()
    
    private let containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 20
        view.clipsToBounds = true
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.white.withAlphaComponent(0.08).cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "person.crop.circle.fill")
        iv.tintColor = .systemGray
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 30
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .primaryText
        let font = UIFont.preferredFont(forTextStyle: .title2)
        
        if let descriptor = font.fontDescriptor.withSymbolicTraits(.traitBold) {
            label.font = UIFont(descriptor: descriptor, size: 0)
        }
        
        label.isUserInteractionEnabled = true
        
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.textColor = .secondaryText
        return label
    }()
    
    private lazy var labelStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stack.axis = .vertical
        stack.spacing = 2
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let anonymousWarningLabel: UILabel = {
        let label = UILabel()
        label.text = "Sign in to view your personal information."
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.textColor = .secondaryText
        label.numberOfLines = 0
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private var items: [SettingItem] {
        return [
            SettingItem(title: "Manage Subscriptions", icon: "calendar.badge.clock", color: .systemBlue),
            SettingItem(title: "Notifications", icon: "bell.fill", color: .systemGreen),
            SettingItem(title: "Help And Feedback", icon: "questionmark.circle.fill", color: .systemPink),
            SettingItem(
                title: viewModel.currentUser?.isAnonymous ?? true ? "Create account" : "Log out",
                icon: viewModel.currentUser?.isAnonymous ?? true ? "person.badge.plus" : "rectangle.portrait.and.arrow.right",
                color: .purple
            )
        ]
    }
    
    init(viewModel: SettingsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        let settingsHeader = SettingsHeaderViewExtentended()
        self.setCustomHeader(settingsHeader)
        super.viewDidLoad()
        self.headerScrollView = tableView
        view.backgroundColor = .backgroundColor
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        setupTableView()
        setupTableHeader()
        setupTableFooter()
        bringHeaderToFront()
        observeViewModel()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        let topPadding = view.safeAreaInsets.top
        let totalHeaderHeight = headerView.contentHeight + topPadding
        
        if tableView.contentInset.top != totalHeaderHeight {
            tableView.contentInset = UIEdgeInsets(top: totalHeaderHeight, left: 0, bottom: 0, right: 0)
            
            if lastOffset == 0 {
                tableView.contentOffset = CGPoint(x: 0, y: -totalHeaderHeight)
                lastOffset = -totalHeaderHeight
            }
        }
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        
        tableView.backgroundColor = .clear
        tableView.backgroundView = nil
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func setupTableHeader() {
        headerContainerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 100)
        
        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterialDark))
        blur.translatesAutoresizingMaskIntoConstraints = false
        
        headerContainerView.addSubview(containerView)
        containerView.addSubview(blur)
        
        containerView.addSubview(profileImageView)
        containerView.addSubview(labelStack)
        containerView.addSubview(anonymousWarningLabel)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleEditUsername))
        titleLabel.addGestureRecognizer(tap)
        
        if viewModel.currentUser?.isAnonymous ?? true {
            labelStack.isHidden = true
            anonymousWarningLabel.isHidden = false
            titleLabel.text = ""
            subtitleLabel.text = ""
        } else {
            labelStack.isHidden = false
            anonymousWarningLabel.isHidden = true
            
            if let username = viewModel.currentUser?.username, !username.isEmpty {
                titleLabel.text = username
            } else {
                titleLabel.text = "Add username"
            }
            
            subtitleLabel.text = viewModel.currentUser?.email
        }
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: headerContainerView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: headerContainerView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: headerContainerView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: headerContainerView.bottomAnchor),
            
            blur.topAnchor.constraint(equalTo: containerView.topAnchor),
            blur.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            blur.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            blur.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            profileImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            profileImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 60),
            profileImageView.heightAnchor.constraint(equalToConstant: 60),
            
            labelStack.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 16),
            labelStack.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            labelStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            anonymousWarningLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 16),
            anonymousWarningLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            anonymousWarningLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16)
        ])
        
        tableView.tableHeaderView = headerContainerView
    }
    
    private func setupTableFooter() {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 160))
        
        let actionButton = UIButton(type: .system)
        var config = UIButton.Configuration.filled()
        config.title = "Delete Account"
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.preferredFont(forTextStyle: .headline)
            return outgoing
        }
        config.baseBackgroundColor = .clear
        config.baseForegroundColor = .systemRed
        config.cornerStyle = .large
        actionButton.configuration = config
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        
        let blurEffect = UIBlurEffect(style: .systemThinMaterialDark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.layer.cornerRadius = 12
        blurView.clipsToBounds = true
        blurView.isUserInteractionEnabled = false
        blurView.translatesAutoresizingMaskIntoConstraints = false
        
        blurView.layer.borderWidth = 1
        blurView.layer.borderColor = UIColor.white.withAlphaComponent(0.08).cgColor
        
        actionButton.insertSubview(blurView, at: 0)
        footerView.addSubview(actionButton)
        
        NSLayoutConstraint.activate([
            actionButton.topAnchor.constraint(equalTo: footerView.topAnchor, constant: 10),
            actionButton.leadingAnchor.constraint(equalTo: footerView.leadingAnchor, constant: 16),
            actionButton.trailingAnchor.constraint(equalTo: footerView.trailingAnchor, constant: -16),
            actionButton.heightAnchor.constraint(equalToConstant: 55),
            
            blurView.topAnchor.constraint(equalTo: actionButton.topAnchor),
            blurView.leadingAnchor.constraint(equalTo: actionButton.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: actionButton.trailingAnchor),
            blurView.bottomAnchor.constraint(equalTo: actionButton.bottomAnchor)
        ])
        
        tableView.tableFooterView = footerView
        actionButton.addTarget(self, action: #selector(handleDeleteAccount), for: .touchUpInside)
    }
    
    private func refreshUserUI() {
        if viewModel.currentUser?.isAnonymous ?? true {
            labelStack.isHidden = true
            anonymousWarningLabel.isHidden = false
            titleLabel.text = ""
            subtitleLabel.text = ""
        } else{
            labelStack.isHidden = false
            anonymousWarningLabel.isHidden = true
            
            if let username = viewModel.currentUser?.username, !username.isEmpty {
                titleLabel.text = username
            } else {
                titleLabel.text = "Add username"
            }
            
            subtitleLabel.text = viewModel.currentUser?.email
        }
        
        tableView.reloadData()
    }
    
    private func observeViewModel() {
        withObservationTracking {
            _ = viewModel.auth
            _ = viewModel.currentUser
        } onChange: { [weak self] in
            Task { @MainActor [weak self] in
                guard let self else { return }
                self.refreshUserUI()
                self.observeViewModel()
            }
        }
    }
    
    @objc private func handleLogout() {
        let isAnonymous = viewModel.currentUser?.isAnonymous ?? true
        
        if isAnonymous {
            let modalVC = SignInModalViewController(viewmodel: SignInModalViewModel(container: viewModel.container), fromView: .settings)
            if let sheet = modalVC.sheetPresentationController {
                sheet.detents = [.medium()]
            }
            
            present(modalVC, animated: true)
        } else {
            
            Task{
                await viewModel.logOut()
            }
            viewModel.stopListenUserSusbscriptions()
        }
    }
    
    @objc private func handleDeleteAccount() {
        let alert = UIAlertController(
            title: "Delete Account",
            message: "",
            preferredStyle: .alert
        )
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        let messageText = "Are you sure you want to delete your account? This action is permanent and all your data, including subscriptions, will be lost forever."
        let attributedString = NSAttributedString(
            string: messageText,
            attributes: [
                .paragraphStyle: paragraphStyle,
                .font: UIFont.preferredFont(forTextStyle: .footnote),
                .foregroundColor: UIColor.label 
            ]
        )
        
        alert.setValue(attributedString, forKey: "attributedMessage")
    
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            
            Task {
                
                let isAnonymous = viewModel.currentUser?.isAnonymous
                
                if isAnonymous ?? true {
                    await self.viewModel.deleteAccount(idToken: nil, accessToken: nil)
                } else {
                    var idToken: String? = nil
                    var accessToken: String? = nil
                    
                    if let googleUser = GIDSignIn.sharedInstance.currentUser {
                        idToken = googleUser.idToken?.tokenString
                        accessToken = googleUser.accessToken.tokenString
                    } else {
                        do {
                            let restoredUser = try await GIDSignIn.sharedInstance.restorePreviousSignIn()
                            idToken = restoredUser.idToken?.tokenString
                            accessToken = restoredUser.accessToken.tokenString
                        } catch {
                            do {
                                let signInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: self)
                                idToken = signInResult.user.idToken?.tokenString
                                accessToken = signInResult.user.accessToken.tokenString
                            } catch {
                                print("❌ Error en reautenticación de Google: \(error)")
                                return
                            }
                        }
                    }
                    
                    viewModel.stopListenUserSusbscriptions()
                    await self.viewModel.deleteAccount(idToken: idToken, accessToken: accessToken)
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(cancelAction)
        alert.addAction(deleteAction)
        
        present(alert, animated: true)
    }
    
    @objc private func handleEditUsername() {
        guard !(viewModel.currentUser?.isAnonymous ?? true) else { return }
        
        let usernameVC = UsernameViewController()
        
        usernameVC.userTextfield.text = viewModel.currentUser?.username
        
        usernameVC.onContinuePressed = { [weak self] newUsername in
            Task { [weak self] in
                await self?.viewModel.updateUsername(username: newUsername)
            }
        }
        
        
        if let sheet = usernameVC.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
        }
        
        present(usernameVC, animated: true)
    }
    
}

extension SettingsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Settings"
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            header.textLabel?.textColor = .primaryText
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let item = items[indexPath.row]
        
        let chevronConfig = UIImage.SymbolConfiguration(weight: .thin)
        let chevronImage = UIImage(systemName: "chevron.right", withConfiguration: chevronConfig)?
            .withTintColor(.white, renderingMode: .alwaysOriginal)
        cell.accessoryView = UIImageView(image: chevronImage)
        
        var content = cell.defaultContentConfiguration()
        content.text = item.title
        content.textProperties.color = .primaryText
        content.image = UIImage(systemName: item.icon)
        content.imageProperties.tintColor = item.color
        cell.contentConfiguration = content
  
        let blurEffect = UIBlurEffect(style: .systemThinMaterialDark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        
        let backgroundContainer = UIView()
        backgroundContainer.isUserInteractionEnabled = false
        blurView.isUserInteractionEnabled = false
        backgroundContainer.addSubview(blurView)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            blurView.topAnchor.constraint(equalTo: backgroundContainer.topAnchor),
            blurView.leadingAnchor.constraint(equalTo: backgroundContainer.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: backgroundContainer.trailingAnchor),
            blurView.bottomAnchor.constraint(equalTo: backgroundContainer.bottomAnchor)
        ])
        
        cell.backgroundView = backgroundContainer
        cell.backgroundColor = .clear
        
        backgroundContainer.layer.borderColor = UIColor.white.withAlphaComponent(0.08).cgColor
        backgroundContainer.layer.borderWidth = 1
        
        let selectedView = UIView()
        selectedView.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        cell.selectedBackgroundView = selectedView
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedItem = items[indexPath.row]
        
        if selectedItem.title == "Log out" || selectedItem.title == "Create account" {
            handleLogout()
        }
    }
}

#Preview("Anonymous User") {
    let container = DevPreview.shared.container
    container.register(AppStateManager.self, service: AppStateManager(service: MockAppStateService(showTabBar: true)))
    
    let mockService = MockUserService()
    let userManager = UserManager(service: mockService)
    
    if let mockUser = mockService.currentUser {
        userManager.addCurrentUserListener(userId: mockUser.userId)
    }
    
    container.register(UserManager.self, service: userManager)
    
    return VCPreview { SettingsViewController(viewModel: SettingsViewModel(container: container))}
        .ignoresSafeArea()
}

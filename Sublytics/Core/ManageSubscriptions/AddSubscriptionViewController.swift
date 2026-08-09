//
//  AddSubscriptionViewController.swift
//  Sublytics
//
//  Created by pedrosanz on 29/04/26.
//

import UIKit
import SwiftUI

class AddSubscriptionViewController: UIViewController, MiniPlayerPresentable {
    
    let miniplayerView = EditSubscriptionMIniPlayerView()
    var onDismissRequested: (() -> Void)?
    var onExpandRequested: (() -> Void)?
    var onCloseRequested: (() -> Void)?

    private var selectedCurrencyCode: String = "USD"
    private var selectedCategory: SubCategory = .entertainment
    
    internal let mainStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 24
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let backButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "chevron.left")
        config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 8)
        
        let button = UIButton(configuration: config)
        button.tintColor = .primaryText
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let closeButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "xmark")
        config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 16)
        let button = UIButton(configuration: config)
        button.tintColor = .primaryText
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let screenTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Add Subscription"
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.textColor = .primaryText
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let topBarStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .equalSpacing
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let subscriptionNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .callout)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .primaryText
        label.text = "Subscription Name"
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let susbscriptionNameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Netflix"
        tf.backgroundColor = .systemGray5
        tf.textColor = .black
        tf.borderStyle = .none
        tf.layer.cornerRadius = 15
        tf.clipsToBounds = true
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        tf.leftView = paddingView
        tf.leftViewMode = .always
        
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.heightAnchor.constraint(equalToConstant: 55).isActive = true
        return tf
    }()
    
    private let subscriptionNameSection: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let subscriptionAmountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .callout)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .primaryText
        label.text = "Subscription Amount"
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subscriptionAmountTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "0.00 USD"
        tf.backgroundColor = .systemGray5
        tf.textColor = .black
        tf.borderStyle = .none
        tf.layer.cornerRadius = 15
        tf.clipsToBounds = true
        tf.keyboardType = .decimalPad
        
        let container = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 55))
        let currencyButton = UIButton(type: .system)
        currencyButton.setTitle("$", for: .normal)
        currencyButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        currencyButton.tintColor = .backgroundColor
        currencyButton.frame = CGRect(x: 8, y: 0, width: 45, height: 55)
        
        container.addSubview(currencyButton)
        
        tf.leftView = container
        tf.leftViewMode = .always
        
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.heightAnchor.constraint(equalToConstant: 55).isActive = true
        return tf
    }()
    
    private let subscriptionAmountSection: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let nextPaymentDateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .callout)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .primaryText
        label.text = "Next Payment Day"
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dateTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Billing Date"
        tf.backgroundColor = .systemGray5
        tf.textColor = .black
        tf.borderStyle = .none
        tf.layer.cornerRadius = 15
        tf.clipsToBounds = true
        tf.isUserInteractionEnabled = true
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        tf.leftView = paddingView
        tf.leftViewMode = .always
        
        let iconContainer = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 55))
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "calendar"), for: .normal)
        button.tintColor = .systemGray
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 55)
        button.addTarget(AddSubscriptionViewController.self, action: #selector(textFieldIconTapped(_:)), for: .touchUpInside)
        
        iconContainer.addSubview(button)
        tf.rightView = iconContainer
        tf.rightViewMode = .always
        
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.heightAnchor.constraint(equalToConstant: 55).isActive = true
        return tf
    }()
    
    private let datePickerView: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .wheels
        return picker
    }()
    
    private let nextPaymentDateSection: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    let categoryButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Seleccionar Categoría"
        config.image = UIImage(systemName: "chevron.up.down")
        config.imagePlacement = .trailing
        config.imagePadding = 16
        config.baseBackgroundColor = .systemGray5
        config.baseForegroundColor = .black
        
        let button = UIButton(configuration: config)
        button.heightAnchor.constraint(equalToConstant: 55).isActive = true
        button.showsMenuAsPrimaryAction = true
        button.changesSelectionAsPrimaryAction = true
        return button
    }()
    
    private let trialLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .callout)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .primaryText
        label.text = "Free trial"
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let trialSwitch: UISwitch = {
        let sw = UISwitch()
        sw.onTintColor = .systemPurple
        sw.isOn = false
        
        sw.layer.cornerRadius = sw.frame.height / 2
        sw.backgroundColor = .systemGray4
        return sw
    }()
    
    private let trialSection: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let endsOnLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .callout)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .primaryText
        label.text = "Ends on: "
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.translatesAutoresizingMaskIntoConstraints = false
        label.widthAnchor.constraint(equalToConstant: 80).isActive = true
        return label
    }()
    
    private let trialExpirationDateTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Trial Expiration Date"
        tf.backgroundColor = .systemGray5
        tf.textColor = .black
        tf.borderStyle = .none
        tf.layer.cornerRadius = 15
        tf.clipsToBounds = true
        tf.isUserInteractionEnabled = true
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        tf.leftView = paddingView
        tf.leftViewMode = .always
        
        let iconContainer = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 55))
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "calendar"), for: .normal)
        button.tintColor = .systemGray
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 55)
        button.addTarget(AddSubscriptionViewController.self, action: #selector(textFieldIconTapped(_:)), for: .touchUpInside)
        
        iconContainer.addSubview(button)
        tf.rightView = iconContainer
        tf.rightViewMode = .always
        
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.heightAnchor.constraint(equalToConstant: 55).isActive = true
        return tf
    }()
    
    private let trialExpirationDateStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fill
        stack.isHidden = false
        stack.alpha = 0.5
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let saveButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Save Subscription"
        config.baseBackgroundColor = .greenColor
        config.baseForegroundColor = .white
        config.cornerStyle = .capsule
        
        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var viewmodel: AddSusbcriptionViewModel
    
    init(viewmodel: AddSusbcriptionViewModel) {
        self.viewmodel = viewmodel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateTrialFieldState(isEnabled: trialSwitch.isOn)
        dateTextField.inputView = datePickerView
        trialExpirationDateTextField.inputView = datePickerView
        
        dateTextField.delegate = self
        trialExpirationDateTextField.delegate = self
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        
        tapGesture.cancelsTouchesInView = false
        
        [susbscriptionNameTextField, subscriptionAmountTextField].forEach {
            $0.addTarget(self, action: #selector(clearErrorOnType), for: .editingChanged)
        }
        
        view.addGestureRecognizer(tapGesture)
        
        view.backgroundColor = .backgroundColor
        setupUIView()
        setupConstraints()
        setupActions()
        setupCurrencyMenu()
        setupCategoryMenu()
    }
    
    private func setupUIView() {
        miniplayerView.translatesAutoresizingMaskIntoConstraints = false
        topBarStack.addArrangedSubview(backButton)
        topBarStack.addArrangedSubview(screenTitleLabel)
        topBarStack.addArrangedSubview(closeButton)
        
        subscriptionNameSection.addArrangedSubview(subscriptionNameLabel)
        subscriptionNameSection.addArrangedSubview(susbscriptionNameTextField)
        
        subscriptionAmountSection.addArrangedSubview(subscriptionAmountLabel)
        subscriptionAmountSection.addArrangedSubview(subscriptionAmountTextField)
        
        nextPaymentDateSection.addArrangedSubview(nextPaymentDateLabel)
        nextPaymentDateSection.addArrangedSubview(dateTextField)
        
        trialSection.addArrangedSubview(trialLabel)
        trialSection.addArrangedSubview(trialSwitch)
        
        trialExpirationDateStack.addArrangedSubview(endsOnLabel)
        trialExpirationDateStack.addArrangedSubview(trialExpirationDateTextField)
        
        let horizontalStack: UIStackView = {
            let stack = UIStackView(arrangedSubviews: [subscriptionAmountSection, nextPaymentDateSection])
            stack.axis = .horizontal
            stack.alignment = .fill
            stack.distribution = .fillEqually
            stack.spacing = 20
            stack.translatesAutoresizingMaskIntoConstraints = false
            return stack
        }()
        
        let horizontalStack2: UIStackView = {
            let stack = UIStackView(arrangedSubviews: [categoryButton, trialSection])
            stack.axis = .horizontal
            stack.alignment = .fill
            stack.distribution = .fill
            stack.spacing = 20
            stack.translatesAutoresizingMaskIntoConstraints = false
            return stack
        }()
        
        view.addSubview(topBarStack)
        view.addSubview(mainStack)
        mainStack.addArrangedSubview(subscriptionNameSection)
        mainStack.addArrangedSubview(horizontalStack)
        mainStack.addArrangedSubview(horizontalStack2)
        mainStack.addArrangedSubview(trialExpirationDateStack)
        mainStack.addArrangedSubview(saveButton)
        view.addSubview(miniplayerView)
    }
    
    private func setupConstraints() {        
        NSLayoutConstraint.activate([
            topBarStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            topBarStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            topBarStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            topBarStack.heightAnchor.constraint(equalToConstant: 44),
            
            miniplayerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            miniplayerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            miniplayerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            miniplayerView.heightAnchor.constraint(equalToConstant: 65),
            
            mainStack.topAnchor.constraint(equalTo: topBarStack.bottomAnchor, constant: 20),
            mainStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            saveButton.heightAnchor.constraint(equalToConstant: 55),
        ])
        
        miniplayerView.onExpandTapped = { [weak self] in
            self?.onExpandRequested?()
        }
        miniplayerView.onCloseTapped = { [weak self] in
            self?.onCloseRequested?()
        }
    }
    
    private func setupActions() {
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        
        datePickerView.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        trialSwitch.addTarget(self, action: #selector(trialSwitchChanged(_:)), for: .valueChanged)
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
    }
    
    private func setupCurrencyMenu() {
        guard let container = subscriptionAmountTextField.leftView,
              let button = container.subviews.first(where: { $0 is UIButton }) as? UIButton else { return }
        
        let currencies = [
            UIAction(title: "Dólar (USD)",
                     image: UIImage(systemName: "dollarsign.circle.fill"),
                     state: selectedCurrencyCode == "USD" ? .on : .off) { _ in
                         self.updateCurrency(symbol: "$", code: "USD", button: button)
                     },
            UIAction(title: "Peso Mexicano (MXN)",
                     image: UIImage(systemName: "dollarsign.circle"),
                     state: selectedCurrencyCode == "MXN" ? .on : .off) { _ in
                         self.updateCurrency(symbol: "$", code: "MXN", button: button)
                     },
            UIAction(title: "Euro (EUR)",
                     image: UIImage(systemName: "eurosign.circle"),
                     state: selectedCurrencyCode == "EUR" ? .on : .off) { _ in
                         self.updateCurrency(symbol: "€", code: "EUR", button: button)
                     }
        ]
        
        button.menu = UIMenu(title: "Seleccionar Moneda", children: currencies)
        button.showsMenuAsPrimaryAction = true
    }
    
    private func updateCurrency(symbol: String, code: String, button: UIButton) {
        self.selectedCurrencyCode = code
        button.setTitle(symbol, for: .normal)
        subscriptionAmountTextField.placeholder = "0.00 \(code)"
        setupCurrencyMenu()
    }
    
    func setupCategoryMenu() {
        let menuItems = SubCategory.allCases.map { category in
            UIAction(title: category.rawValue, image: UIImage(systemName: category.iconName)) { action in
                self.selectedCategory = category
                
                var config = self.categoryButton.configuration
                config?.title = category.rawValue
                self.categoryButton.configuration = config
            }
        }
        categoryButton.menu = UIMenu(title: "Categorías", children: menuItems)
    }
    
    @objc private func textFieldIconTapped(_ sender: UIButton) {
        let textField = [dateTextField, trialExpirationDateTextField].first { tf in
            return tf.rightView?.subviews.contains(sender) == true
        }
        
        if let tf = textField, let text = tf.text, !text.isEmpty {
            tf.text = ""
            sender.setImage(UIImage(systemName: "calendar"), for: .normal)
            
            if tf == dateTextField {
                trialExpirationDateTextField.text = ""
                if let container = trialExpirationDateTextField.rightView,
                   let otherBtn = container.subviews.first(where: { $0 is UIButton }) as? UIButton {
                    otherBtn.setImage(UIImage(systemName: "calendar"), for: .normal)
                }
            }
        } else {
            textField?.becomeFirstResponder()
        }
    }
    
    private func validateForm() -> Bool {
        var isValid = true
        
        let fieldsToValidate: [UITextField: Bool] = [
            susbscriptionNameTextField: susbscriptionNameTextField.text?.isEmpty ?? true,
            subscriptionAmountTextField: subscriptionAmountTextField.text?.isEmpty ?? true,
            dateTextField: dateTextField.text?.isEmpty ?? true
        ]
        
        fieldsToValidate.forEach { textField, isError in
            if isError {
                showError(on: textField)
                isValid = false
            } else {
                clearError(on: textField)
            }
        }
    
        if trialSwitch.isOn {
            if trialExpirationDateTextField.text?.isEmpty ?? true {
                showError(on: trialExpirationDateTextField)
                isValid = false
            } else {
                clearError(on: trialExpirationDateTextField)
            }
        } else {
            clearError(on: trialExpirationDateTextField)
        }
        
        return isValid
    }
    
    private func showError(on textField: UITextField) {
        UIView.animate(withDuration: 0.3) {
            textField.backgroundColor = .systemRed.withAlphaComponent(0.2)
            textField.layer.borderWidth = 1
            textField.layer.borderColor = UIColor.systemRed.cgColor
        }
    }
    
    private func clearError(on textField: UITextField) {
        UIView.animate(withDuration: 0.3) {
            textField.backgroundColor = .systemGray5
            textField.layer.borderWidth = 0
        }
    }
    
    private func updateTrialFieldState(isEnabled: Bool) {
        UIView.animate(withDuration: 0.3) {
            self.trialExpirationDateStack.alpha = isEnabled ? 1.0 : 0.4
            self.trialExpirationDateTextField.isUserInteractionEnabled = isEnabled
            self.trialExpirationDateTextField.backgroundColor = isEnabled ? .systemGray5 : .systemGray6
            
            if !isEnabled {
                self.trialExpirationDateTextField.text = ""
                if let container = self.trialExpirationDateTextField.rightView,
                   let btn = container.subviews.first(where: { $0 is UIButton }) as? UIButton {
                    btn.setImage(UIImage(systemName: "calendar"), for: .normal)
                    btn.isUserInteractionEnabled = false
                }
            } else {
                if let container = self.trialExpirationDateTextField.rightView,
                   let btn = container.subviews.first(where: { $0 is UIButton }) as? UIButton {
                    btn.isUserInteractionEnabled = true
                }
            }
        }
    }
    
    @objc private func backButtonTapped() {
        view.endEditing(true)
        let name = susbscriptionNameTextField.text?.isEmpty == false ? susbscriptionNameTextField.text! : "new subscription"
        let price = subscriptionAmountTextField.text?.isEmpty == false ? " • $\(subscriptionAmountTextField.text!)" : ""
        
        miniplayerView.configure(title: "Adding \"\(name)\"", iconName: "plus.circle")
        
        miniplayerView.configure(
            title: "Adding \(name)",
            iconName: "plus.circle.fill",
            price: price,
            nextPayment: dateTextField.text ?? ""
        )
        
        onDismissRequested?()
    }
    
    
    @objc private func closeButtonTapped() {
        onCloseRequested?()
    }
    
    @objc private func saveButtonTapped() {
        if validateForm() {
            let title = susbscriptionNameTextField.text ?? ""
            let category = selectedCategory
            let price = subscriptionAmountTextField.text ?? ""
            let isTrial = trialSwitch.isOn
            
            let paymentDay = datePickerView.date
            let trialEndDate = isTrial ? datePickerView.date : nil
            
            Task {
               let success = await viewmodel.saveSubscription(title: title, category: category, stringPrice: price, billingDate: paymentDay, isTrial: isTrial, trialEndDate: trialEndDate)
                
                if success {
                    onCloseRequested?()
                } else {
                    
                }
            }
        } else {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
        }
    }
    
    @objc private func clearErrorOnType(_ textField: UITextField) {
        clearError(on: textField)
    }
    
    @objc func dateChanged(_ sender: UIDatePicker) {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_ES")
        formatter.dateStyle = .medium
        let dateString = formatter.string(from: sender.date)
        
        let activeField: UITextField? = dateTextField.isFirstResponder ? dateTextField :
        (trialExpirationDateTextField.isFirstResponder ? trialExpirationDateTextField : nil)
        
        if let tf = activeField {
            tf.text = dateString
            if let container = tf.rightView,
               let btn = container.subviews.first(where: { $0 is UIButton }) as? UIButton {
                btn.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
            }
            if tf == dateTextField {
                trialExpirationDateTextField.text = ""
                if let container = trialExpirationDateTextField.rightView,
                   let trialBtn = container.subviews.first(where: { $0 is UIButton }) as? UIButton {
                    trialBtn.setImage(UIImage(systemName: "calendar"), for: .normal)
                }
            }
        }
    }
    
    @objc func trialSwitchChanged(_ sender: UISwitch) {
        updateTrialFieldState(isEnabled: sender.isOn)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension AddSubscriptionViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == trialExpirationDateTextField {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "es_ES")
            formatter.dateStyle = .medium
            
            if let dateText = dateTextField.text, !dateText.isEmpty,
                let baseDate = formatter.date(from: dateText) {
            
                datePickerView.minimumDate = baseDate
            } else {
                datePickerView.minimumDate = Date()
            }
            
        } else if textField == dateTextField {
            datePickerView.minimumDate = Date()
        }
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let sheet = self.sheetPresentationController {
            sheet.animateChanges {
                sheet.selectedDetentIdentifier = .large
            }
        }
    }
}

#Preview("AddSubscriptionView") {
    let container = DevPreview.shared.container
    
    let mockService = MockUserService()
    let userManager = UserManager(service: mockService)
    
    if let mockUser = mockService.currentUser {
        userManager.addCurrentUserListener(userId: mockUser.userId)
    }
    
    container.register(UserManager.self, service: userManager)
    
    return VCPreview {
        AddSubscriptionViewController(viewmodel: AddSusbcriptionViewModel(container: container))
    }
    .ignoresSafeArea()
}

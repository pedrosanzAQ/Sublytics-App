//
//  EditSubscriptionViewController.swift
//  Sublytics
//
//  Created by pedrosanz on 29/04/26.

import UIKit

class EditSubscriptionViewController: UIViewController /*MiniPlayerPresentable*/ {
    private var selectedCurrencyCode: String = "USD"
    var selectedCategory: SubCategory?
    let miniplayerView = EditSubscriptionMIniPlayerView()
    var onDismissRequested: (() -> Void)?
    var onExpandRequested: (() -> Void)?
    var onCloseRequested: (() -> Void)?
    
    let mainStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let backButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "chevron.left")
        config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
        
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
    
    let screenTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Edit Subscription"
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.textColor = .primaryText
        label.textAlignment = .center
        label.isUserInteractionEnabled = false
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let topSaveButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.title = "Save"
        config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 16)
        let button = UIButton(configuration: config)
        button.tintColor = .systemBlue
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let topBarStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let iconContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.borderWidth = 1.5
        view.layer.cornerRadius = 44
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
    
    let subscriptionNameTextField: UITextField = {
        let tf = UITextField()
        tf.font = UIFont.preferredFont(forTextStyle: .headline)
        tf.adjustsFontForContentSizeCategory = true
        tf.textColor = .primaryText
        tf.text = "Subscription Name"
        tf.textAlignment = .center
        tf.borderStyle = .none
        tf.returnKeyType = .done
        tf.autocorrectionType = .no
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    // AMOUNT
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
    
    let subscriptionAmountTextField: UITextField = {
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
    
    // NEXT PAYMENT
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
    
    let dateTextField: UITextField = {
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
        button.addTarget(EditSubscriptionViewController.self, action: #selector(textFieldIconTapped(_:)), for: .touchUpInside)
        
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
        return button
    }()
    
    private let deleteButton: UIButton = {
        var config = UIButton.Configuration.tinted()
        config.title = "Delete subscription"
        config.cornerStyle = .large
        config.baseBackgroundColor = .systemRed
        config.baseForegroundColor = .systemRed
        
        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 55).isActive = true
        return button
    }()
    
    private let viewmodel: EditSubscriptionViewModel
    
    init(viewmodel: EditSubscriptionViewModel) {
        self.viewmodel = viewmodel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundColor
        
        setupUI()
        setupActions()
        setupCurrencyMenu()
        setupCategoryMenu()
        configureUI()
    }
    
    private func setupUI() {
        view.addSubview(miniplayerView)
        miniplayerView.layer.zPosition = 999
        miniplayerView.translatesAutoresizingMaskIntoConstraints = false
        
        topBarStack.addArrangedSubview(backButton)
        topBarStack.addArrangedSubview(screenTitleLabel)
        topBarStack.addArrangedSubview(topSaveButton)
        
        view.addSubview(topBarStack)
        
        iconContainerView.addSubview(iconImageView)
        
        subscriptionAmountSection.addArrangedSubview(subscriptionAmountLabel)
        subscriptionAmountSection.addArrangedSubview(subscriptionAmountTextField)
        
        nextPaymentDateSection.addArrangedSubview(nextPaymentDateLabel)
        nextPaymentDateSection.addArrangedSubview(dateTextField)
        
        let horizontalStack: UIStackView = {
            let stack = UIStackView(arrangedSubviews: [subscriptionAmountSection, nextPaymentDateSection])
            stack.axis = .horizontal
            stack.alignment = .fill
            stack.distribution = .fillEqually
            stack.spacing = 20
            stack.translatesAutoresizingMaskIntoConstraints = false
            return stack
        }()
        
        let iconCenterWrapper = UIView()
        iconCenterWrapper.addSubview(iconContainerView)
        subscriptionNameTextField.delegate = self
        
        mainStack.addArrangedSubview(iconCenterWrapper)
        mainStack.addArrangedSubview(subscriptionNameTextField)
        mainStack.setCustomSpacing(30, after: subscriptionNameTextField)
        mainStack.addArrangedSubview(horizontalStack)
        mainStack.addArrangedSubview(categoryButton)
        mainStack.setCustomSpacing(30 , after: categoryButton)
        mainStack.addArrangedSubview(deleteButton)
        
        view.addSubview(mainStack)
        
        NSLayoutConstraint.activate([
            
            topBarStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            topBarStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            topBarStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            topBarStack.heightAnchor.constraint(equalToConstant: 44),
            
            screenTitleLabel.centerXAnchor.constraint(equalTo: topBarStack.centerXAnchor),
                        
            iconContainerView.topAnchor.constraint(equalTo: iconCenterWrapper.topAnchor),
            iconContainerView.bottomAnchor.constraint(equalTo: iconCenterWrapper.bottomAnchor),
            iconContainerView.centerXAnchor.constraint(equalTo: iconCenterWrapper.centerXAnchor),
            iconContainerView.widthAnchor.constraint(equalToConstant: 88),
            iconContainerView.heightAnchor.constraint(equalToConstant: 88),
            
            iconImageView.centerXAnchor.constraint(equalTo: iconContainerView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainerView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),
            
            mainStack.topAnchor.constraint(equalTo: topBarStack.bottomAnchor, constant: 24),
            mainStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
        
        dateTextField.inputView = datePickerView
        
        miniplayerView.onExpandTapped = { [weak self] in
            self?.onExpandRequested?()
        }
        
        miniplayerView.onCloseTapped = { [weak self] in
            self?.onCloseRequested?()
        }

    }
    
    private func setupActions() {
        datePickerView.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        topSaveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        
        subscriptionNameTextField.addTarget(self, action: #selector(textfiledsChanged), for: .editingChanged)
        subscriptionAmountTextField.addTarget(self, action: #selector(textfiledsChanged), for: .editingChanged)
    }
    
    private func configureUI() {
        subscriptionNameTextField.text = viewmodel.subscriptionName
        subscriptionAmountTextField.text = viewmodel.amountText
        subscriptionAmountTextField.placeholder = "0.00 \(selectedCurrencyCode)"
        
        dateTextField.text = viewmodel.formattedDate
        datePickerView.date = viewmodel.date
        
        if let initialCategory = SubCategory(rawValue: viewmodel.subscription.category) {
            self.selectedCategory = initialCategory
        }
        categoryButton.setTitle(viewmodel.subscription.category, for: .normal)
        
        iconImageView.image = UIImage(systemName: viewmodel.iconName)
        miniplayerView.configure(title: viewmodel.subscriptionName, iconName: viewmodel.iconName, price: viewmodel.amountText, nextPayment: viewmodel.formattedDate)
        
        self.textfiledsChanged()
    }
    
    private func setupCurrencyMenu() {
        guard let container = subscriptionAmountTextField.leftView,
              let button = container.subviews.first(where: { $0 is UIButton }) as? UIButton else { return }
        
        let currencies = [
            UIAction(title: "Dolar (USD)",
                     image: UIImage(systemName: "dollarsign.circle.fill"),
                     state: selectedCurrencyCode == "USD" ? .on : .off) { [weak self] _ in
                         self?.updateCurrency(symbol: "$", code: "USD", button: button)
                     },
            UIAction(title: "Peso Mexicano (MXN)",
                     image: UIImage(systemName: "dollarsign.circle"),
                     state: selectedCurrencyCode == "MXN" ? .on : .off) { [weak self] _ in
                         self?.updateCurrency(symbol: "$", code: "MXN", button: button)
                     },
            UIAction(title: "Euro (EUR)",
                     image: UIImage(systemName: "eurosign.circle"),
                     state: selectedCurrencyCode == "EUR" ? .on : .off) { [weak self] _ in
                         self?.updateCurrency(symbol: "€", code: "EUR", button: button)
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
        
        self.textfiledsChanged()
    }
    
    func setupCategoryMenu() {
        let menuItems = SubCategory.allCases.map { category in
            UIAction(
                title: category.rawValue,
                image: UIImage( systemName: category.iconName))
            { [weak self] _ in
                guard let self = self else { return }
                self.selectedCategory = category
                self.categoryButton.setTitle(category.rawValue, for: .normal)
                
                self.textfiledsChanged()
            }
        }
        categoryButton.menu = UIMenu(title: "Categorías", children: menuItems)
    }
    
    @objc private func backButtonTapped() {
        view.endEditing(true)
        
        if hasUnsavedChanges() {
            showDiscardChangesAlert()
        } else {
            performDismiss()
        }
    }
    
    @objc private func saveButtonTapped() {
        onSavePressed()
    }
    
    @objc private func deleteButtonTapped() {
        let alert = UIAlertController(
            title: "Delete Subscription?",
            message: "This action cannot be undone. Are you sure you want to delete it?",
            preferredStyle: .alert
        )
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.onDeletePressed()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    @objc private func textFieldIconTapped(_ sender: UIButton) {
        dateTextField.becomeFirstResponder()
    }
    
    @objc private func dateChanged(_ sender: UIDatePicker) {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        dateTextField.text = formatter.string(from: sender.date)
        
        self.textfiledsChanged()
    }
    
    private func performDismiss() {
        if let nav = navigationController, nav.viewControllers.count > 1 {
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }
    
    @objc private func textfiledsChanged() {
        let currentName = subscriptionNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let currentAmount = subscriptionAmountTextField.text ?? ""
        
        let result = hasUnsavedChanges()
        
        let isFormValid = !currentName.isEmpty && !currentAmount.isEmpty
        let hasAnyChanged = result
        
        let shouldEnable = isFormValid && hasAnyChanged
        
        UIView.animate(withDuration: 0.2) {
            self.topSaveButton.isUserInteractionEnabled = shouldEnable
            self.topSaveButton.alpha = shouldEnable ? 1.0 : 0.4
        }
    }
    
    private func hasUnsavedChanges() -> Bool {
        let currentName = subscriptionNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let currentAmount = subscriptionAmountTextField.text ?? ""
        let currentDate = dateTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        let nameChanged = currentName != viewmodel.subscriptionName
        let amountChanged = currentAmount != viewmodel.amountText
        let dateChanged = currentDate != viewmodel.formattedDate
        let categoryChanged = selectedCategory?.rawValue ?? "" != viewmodel.subscription.category
        
        return nameChanged || amountChanged || categoryChanged || dateChanged
    }
    
    private func onSavePressed() {
        view.endEditing(true)
        
        let currentName = subscriptionNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let currentAmount = subscriptionAmountTextField.text ?? ""
        
        guard !currentName.isEmpty else { return }
        
        let sanitizedAmount = currentAmount.replacingOccurrences(of: ",", with: ".")
        guard let amount = Double(sanitizedAmount), amount > 0 else { return }
        
        guard let category = selectedCategory else { return }
        let selectedBillingDate = datePickerView.date
        
        Task {
           let succes = await viewmodel.saveSubscription(subscriptionName: currentName, category: category, price: amount, billingDate: selectedBillingDate)
            
            if succes {
                performDismiss()
            } else {
                print("Error saving Subscription")
            }
        }
    }
    
    func onDeletePressed() {
        Task {
            let success = await viewmodel.deleteSubscription()
            if success {
                performDismiss()
            } else {
                print("Error deliting Subscription")
            }
        }
    }
    
    private func showDiscardChangesAlert() {
        let alert = UIAlertController(
            title: "Discard Changes",
            message: "You have unsaved changes. Are you sure you want to leave?",
            preferredStyle: .alert
        )
        
        let discardAction = UIAlertAction(title: "Discard", style: .destructive) { [weak self] _ in
            self?.performDismiss()
        }
        
        let keepEditingAction = UIAlertAction(title: "Keep editing", style: .cancel)
        
        alert.addAction(discardAction)
        alert.addAction(keepEditingAction)
        
        present(alert, animated: true)
    }
}

extension EditSubscriptionViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == subscriptionNameTextField {
        }
    }
}

import SwiftUI

#Preview("EditSubscriptioView") {
    let container = DevPreview.shared.container
    
    VCPreview {
        EditSubscriptionViewController(viewmodel: EditSubscriptionViewModel(container: container, subscription: SubscriptionModel.mock))
    }
    .ignoresSafeArea()
}

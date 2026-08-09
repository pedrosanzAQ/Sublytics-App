//
//  SettingsHeaderViewExtentended.swift
//  Sublytics
//
//  Created by pedrosanz on 22/04/26.
//

import UIKit

class SettingsHeaderViewExtentended: HeaderView {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Settings"
        label.textColor = .primaryText
        label.font = .systemFont(ofSize: 28, weight: .bold)
        return label
    }()
    
    override var contentHeight: CGFloat { return 80 }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSettingsLayout()
    }
    
    private func setupSettingsLayout() {
        baseHeaderStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        baseHeaderStack.addArrangedSubview(titleLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// SEARCH HEADER
protocol YTHeaderDelegate: AnyObject {
    func header(_ header: SearchHeaderViewExtentended, didSubmitQuery query: String)
    func header(_ header: SearchHeaderViewExtentended, didUpdateText text: String)
    func headerDidTapBack(_ header: SearchHeaderViewExtentended)
}

class SearchHeaderViewExtentended: HeaderView, UITextFieldDelegate {
    weak var searchDelegate: YTHeaderDelegate?
    
    private let backButton: UIButton = {
        let btn = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(weight: .bold)
        let image = UIImage(systemName: "chevron.left", withConfiguration: config)
        
        btn.setImage(image, for: .normal)
        btn.tintColor = .white
        btn.backgroundColor = .backgroundColor
        return btn
    }()
    
    private(set) var searchTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Search Subscriptions"
        tf.backgroundColor = .systemGray5
        tf.layer.cornerRadius = 16
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        tf.leftViewMode = .always
        
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "xmark.circle.fill")
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 8)
        
        let clearButton = UIButton(configuration: config)
        clearButton.tintColor = .gray
        clearButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        
        clearButton.addTarget(nil, action: #selector(clearTextField), for: .touchUpInside)
        
        tf.rightView = clearButton
        tf.rightViewMode = .never
        tf.returnKeyType = .search
        return tf
    }()
    
    override var contentHeight: CGFloat { return 60 }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSearchLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSearchLayout() {
        baseHeaderStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        searchTextField.delegate = self
        searchTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        
        let horizontalStack = UIStackView(arrangedSubviews: [backButton, searchTextField])
        horizontalStack.axis = .horizontal
        horizontalStack.spacing = 4
        horizontalStack.alignment = .center
        horizontalStack.translatesAutoresizingMaskIntoConstraints = false
        
        baseHeaderStack.addArrangedSubview(horizontalStack)
        
        NSLayoutConstraint.activate([
            baseHeaderStack.leadingAnchor.constraint(equalTo: movingContainer.leadingAnchor, constant: 12),
            baseHeaderStack.trailingAnchor.constraint(equalTo: movingContainer.trailingAnchor, constant: -12),
            
            backButton.widthAnchor.constraint(equalToConstant: 50),
            backButton.heightAnchor.constraint(equalToConstant: 50),
            
            searchTextField.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        backButton.layer.cornerRadius = 25
        backButton.clipsToBounds = true
    }
    
    func updateTextfield(_ text: String) {
        searchTextField.text = text
        updateClearButtonVisibility()
        searchTextField.resignFirstResponder()
    }
    
    private func updateClearButtonVisibility() {
        let hasText = !(searchTextField.text?.isEmpty ?? true)

        searchTextField.rightViewMode = hasText ? .always : .never
    }
    
    @objc private func backTapped() { searchDelegate?.headerDidTapBack(self) }
    
    @objc private func clearTextField() {
        searchTextField.text = ""
        updateClearButtonVisibility()
        searchDelegate?.header(self, didUpdateText: "")
        searchTextField.becomeFirstResponder()
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        updateClearButtonVisibility()
        searchDelegate?.header(self, didUpdateText: textField.text ?? "")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = textField.text, !text.isEmpty {
            searchDelegate?.header(self, didSubmitQuery: text)
        }
        return true
    }
}

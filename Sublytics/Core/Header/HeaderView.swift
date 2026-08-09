//
//  CustomHeaderView.swift
//  Sublytics
//
//  Created by pedrosanz on 03/04/26.
//

import UIKit

protocol HeaderViewDelegate: AnyObject {
    func onSearchPreseed(_ header: HeaderView)
    func onAddSubscriptionPressed(_ header: HeaderView)
}

class HeaderView: UIView {
    weak var delegate: HeaderViewDelegate?
    
    // be dinamic height
    var contentHeight: CGFloat {
        return 52
    }
    
    var movingTopConstraint: NSLayoutConstraint!
    
    private let safeAreaBackground: UIView = {
        let view = UIView()
        view.backgroundColor = .backgroundColor
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = true
        return view
    }()
    
    let movingContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .backgroundColor
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = false
        return view
    }()
    
    let baseHeaderStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 16
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    let notificationButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "bell"), for: .normal)
        btn.tintColor = .primaryText
        return btn
    }()
    
    let addSubscriptionButton : UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "plus"), for: .normal)
        btn.tintColor = .primaryText
        return btn
    }()
    
    let searchButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
        button.tintColor = .primaryText
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.clipsToBounds = false
        setupLayout()
    }
    
    private func setupLayout() {
        addSubview(movingContainer)
        addSubview(safeAreaBackground)
        
        let spacer = UIView()
        baseHeaderStack.addArrangedSubview(spacer)
        baseHeaderStack.addArrangedSubview(notificationButton)
        baseHeaderStack.addArrangedSubview(addSubscriptionButton)
        baseHeaderStack.addArrangedSubview(searchButton)
        searchButton.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)
        addSubscriptionButton.addTarget(self, action: #selector(onAddSubscriptionPressed), for: .touchUpInside)
        
        movingContainer.addSubview(baseHeaderStack)
        movingTopConstraint = movingContainer.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor)
        
        NSLayoutConstraint.activate([
            safeAreaBackground.topAnchor.constraint(equalTo: self.topAnchor),
            safeAreaBackground.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            safeAreaBackground.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            safeAreaBackground.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 2),
            
            movingTopConstraint,
            movingContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            movingContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            movingContainer.heightAnchor.constraint(equalToConstant: contentHeight),
            
            baseHeaderStack.topAnchor.constraint(equalTo: movingContainer.topAnchor),
            baseHeaderStack.leadingAnchor.constraint(equalTo: movingContainer.leadingAnchor, constant: 16),
            baseHeaderStack.trailingAnchor.constraint(equalTo: movingContainer.trailingAnchor, constant: -16),
            baseHeaderStack.heightAnchor.constraint(equalToConstant: contentHeight)
        ])
        
        movingContainer.isUserInteractionEnabled = true
        self.isUserInteractionEnabled = true
        safeAreaBackground.isUserInteractionEnabled = false
        self.clipsToBounds = false
        
        safeAreaBackground.layer.zPosition = 10
        movingContainer.layer.zPosition = 0
        baseHeaderStack.layer.zPosition = 1
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        let pointInIsland = convert(point, to: safeAreaBackground)
        if safeAreaBackground.point(inside: pointInIsland, with: event) {
            return safeAreaBackground
        }
        
        if hitView == self || hitView == movingContainer {
            return nil
        }
    
        return hitView
    }
    
    @objc private func searchButtonTapped() {
        delegate?.onSearchPreseed(self)
    }
    
    @objc private func onAddSubscriptionPressed() {
        delegate?.onAddSubscriptionPressed(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

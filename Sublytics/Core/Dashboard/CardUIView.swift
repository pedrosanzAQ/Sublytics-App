//
//  CardUIView.swift
//  Sublytics
//
//  Created by pedrosanz on 06/03/26.
//

import UIKit
import SwiftUI

class CardUIView: UIView {
    
    private let viewmodel: DashboardViewModel
    
    private let monthlyLabel: UILabel = {
        let label = UILabel()
        label.textColor = .primaryText
        label.font = UIFont.preferredFont(forTextStyle: .title1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let yearLabel: UILabel = {
        let label = UILabel()
        label.textColor = .primaryText
        label.font = UIFont.preferredFont(forTextStyle: .title2)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descripcionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .caption1)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let expensesLabel: UILabel = {
        let label = UILabel()
        label.text = "Expenses"
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .primaryText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let circleView: UIView = {
        let view = UIView()
        view.backgroundColor = .orange
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    init(viewModel: DashboardViewModel) {
        self.viewmodel = viewModel
        
        super.init(frame: .zero)
        setupView()
        configChip()
        configLogo()
        configLabels()
        activeLogo()
        
        updateUI()
        observeViewModel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func updateUI() {
        let monthlyAmount = String(format: "%.2f", viewmodel.currentMonthlySpending)
        monthlyLabel.text = "$\(monthlyAmount) / month"
        
        let annualAmount = String(format: "%.2f", viewmodel.currentAnnualSpending)
        yearLabel.text = "$\(annualAmount) / year"
        
        // Evitamos problemas si los opcionales o estimados vienen vacíos
        let estimate = viewmodel.subscriptionEstimate.isEmpty ? "subscriptions" : viewmodel.subscriptionEstimate
        let saving = viewmodel.savingEstimate
        
        let boldFont = UIFont.systemFont(ofSize: 13, weight: .bold)
        
        if viewmodel.allSubscriptions.count > 1 {
            let fullText = "By cancelling \(estimate), you could save $\(String(format: "%.2f", saving)) per year."
            
            descripcionLabel.attributedText = fullText.highlight(
                words: [estimate, "$\(String(format: "%.2f", saving))"],
                font: boldFont,
                color: .greenColorPlus
            )
        } else if viewmodel.allSubscriptions.count == 1 {
            let fullText = "By cancelling your only subscription \(estimate), you could save $\(String(format: "%.2f", saving)) per year."
            
            descripcionLabel.attributedText = fullText.highlight(
                words: [estimate, "$\(String(format: "%.2f", saving))"],
                font: boldFont,
                color: .greenColorPlus
            )
        } else {
            let fullText = "You don't have any active subscriptions to cancel."
            
            descripcionLabel.attributedText = fullText.highlight(
                words: [estimate, "$\(String(format: "%.2f", saving))"],
                font: boldFont,
                color: .greenColorPlus
            )
        }
    }

    private func setupView() {
        backgroundGradient(cornerRadius: 12)
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowOffset = CGSize(width: 0, height: 6)
        layer.shadowRadius = 12
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func configChip() {
        let chipView: UIView = {
            let view = UIView()
            view.backgroundColor = .yellow
            view.layer.cornerRadius = 6
            view.layer.borderWidth = 1
            view.layer.borderColor = UIColor.systemOrange.cgColor
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()
        
        let vLine: UIView = {
            let view = UIView()
            view.backgroundColor = .brown
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()
        
        func makeLine() -> UIView {
            let view = UIView()
            view.backgroundColor = .brown
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }
        
        lazy var stackHorizontalLeftChipLines: UIStackView = {
            let line1 = makeLine()
            let line2 = makeLine()
            let line3 = makeLine()
            
            [line1, line2, line3].forEach {
                $0.heightAnchor.constraint(equalToConstant: 2).isActive = true
            }
            
            let stack = UIStackView(arrangedSubviews: [line1, line2, line3])
            stack.axis = .vertical
            stack.spacing = 10
            stack.translatesAutoresizingMaskIntoConstraints = false
            return stack
        }()
        
        lazy var stackHorizontalRightChipLines: UIStackView = {
            let line1 = makeLine()
            let line2 = makeLine()
            
            [line1, line2].forEach {
                $0.heightAnchor.constraint(equalToConstant: 2).isActive = true
            }
            
            let stack = UIStackView(arrangedSubviews: [line1, line2])
            stack.axis = .vertical
            stack.spacing = 10
            stack.translatesAutoresizingMaskIntoConstraints = false
            return stack
        }()
        
        addSubview(chipView)
        chipView.addSubview(vLine)
        chipView.addSubview(stackHorizontalLeftChipLines)
        chipView.addSubview(stackHorizontalRightChipLines)
        
        NSLayoutConstraint.activate([
            // chip
            chipView.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            chipView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            chipView.heightAnchor.constraint(equalToConstant: 40),
            chipView.widthAnchor.constraint(equalToConstant: 40),
            
            vLine.centerXAnchor.constraint(equalTo: chipView.centerXAnchor),
            vLine.topAnchor.constraint(equalTo: chipView.topAnchor),
            vLine.bottomAnchor.constraint(equalTo: chipView.bottomAnchor),
            vLine.widthAnchor.constraint(equalToConstant: 2),
            
            stackHorizontalLeftChipLines.centerYAnchor.constraint(equalTo: chipView.centerYAnchor),
            stackHorizontalLeftChipLines.leadingAnchor.constraint(equalTo: chipView.leadingAnchor),
            stackHorizontalLeftChipLines.trailingAnchor.constraint(equalTo: chipView.trailingAnchor, constant: -22.5),
            
            stackHorizontalRightChipLines.centerYAnchor.constraint(equalTo: chipView.centerYAnchor, constant: 4),
            stackHorizontalRightChipLines.leadingAnchor.constraint(equalTo: chipView.leadingAnchor, constant: 30),
            stackHorizontalRightChipLines.trailingAnchor.constraint(equalTo: chipView.trailingAnchor),
        ])

    }
    
    private func configLogo() {
        addSubview(circleView)
        circleView.addSubview(expensesLabel)
        
        NSLayoutConstraint.activate([
            circleView.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            circleView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            circleView.heightAnchor.constraint(equalToConstant: 46),
            circleView.widthAnchor.constraint(equalToConstant: 46),
            
            expensesLabel.centerXAnchor.constraint(equalTo: circleView.centerXAnchor),
            expensesLabel.centerYAnchor.constraint(equalTo: circleView.centerYAnchor)
        ])
    }
    
    private func configLabels() {
        
        let monthIcon: UIImageView = {
            let image = UIImageView()
            let config = UIImage.SymbolConfiguration(font: UIFont.preferredFont(forTextStyle: .title1))
            image.image = UIImage(systemName: "dollarsign.circle", withConfiguration: config)
            image.tintColor = .primaryText
            image.translatesAutoresizingMaskIntoConstraints = false
            return image
        }()
        
        let yearIcon: UIImageView = {
            let image = UIImageView()
            let config = UIImage.SymbolConfiguration(font: UIFont.preferredFont(forTextStyle: .title2))
            image.image = UIImage(systemName: "calendar", withConfiguration: config)
            image.tintColor = .primaryText
            image.translatesAutoresizingMaskIntoConstraints = false
            return image
        }()
        
        // STACK MONTH
        let monthStack = UIStackView(arrangedSubviews: [monthIcon, monthlyLabel])
        monthStack.axis = .horizontal
        monthStack.spacing = 12
        monthStack.alignment = .center
        monthStack.translatesAutoresizingMaskIntoConstraints = false
        
        // STACK YEAR
        let yearStack = UIStackView(arrangedSubviews: [yearIcon, yearLabel])
        yearStack.axis = .horizontal
        yearStack.spacing = 12
        yearStack.alignment = .center
        yearStack.translatesAutoresizingMaskIntoConstraints = false
        
        // STACK PRINCIPAL (vertical)
        let mainStack = UIStackView(arrangedSubviews: [monthStack, yearStack])
        mainStack.axis = .vertical
        mainStack.spacing = 18
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(mainStack)
        addSubview(descripcionLabel)
        
        NSLayoutConstraint.activate([
            mainStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -80),
            mainStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 40),
            
            descripcionLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),
            descripcionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 30),
            descripcionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -80),
        ])
    }
    
    private func activeLogo() {
        let activeLabel: UILabel = {
            let label = UILabel()
            label.text = "Active"
            label.font = UIFont.preferredFont(forTextStyle: .headline)
            label.textColor = .primaryText
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
        
        let blueSquare: UIView = {
            let view = UIView()
            view.backgroundColor = .blue
            view.layer.cornerRadius = 12
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()
        
        let orangeSquare: UIView = {
            let view = UIView()
            view.backgroundColor = .orange
            view.layer.cornerRadius = 12
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()
        
        addSubview(orangeSquare)
        addSubview(blueSquare)
        addSubview(activeLabel)
        
        NSLayoutConstraint.activate([
            orangeSquare.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),
            orangeSquare.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            orangeSquare.heightAnchor.constraint(equalToConstant: 35),
            orangeSquare.widthAnchor.constraint(equalToConstant: 35),
            
            blueSquare.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -25),
            blueSquare.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -45),
            blueSquare.heightAnchor.constraint(equalToConstant: 35),
            blueSquare.widthAnchor.constraint(equalToConstant: 35),
            
            activeLabel.centerYAnchor.constraint(equalTo: blueSquare.centerYAnchor, constant: 2),
            activeLabel.centerXAnchor.constraint(equalTo: blueSquare.centerXAnchor, constant: 13)
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        circleView.layer.cornerRadius = circleView.frame.height / 2
        
        if let gradient = layer.sublayers?.first as? CAGradientLayer {
            gradient.frame = bounds
        }
    }
    
    private func observeViewModel() {
        withObservationTracking {
            _ = viewmodel.allSubscriptions
            _ = viewmodel.currentMonthlySpending
            _ = viewmodel.currentAnnualSpending
        } onChange: { [weak self] in
            Task { @MainActor in
                self?.updateUI()
                self?.observeViewModel()
            }
        }
    }
}


struct DashboardViewController_Preview: PreviewProvider {
    static var previews: some View {
        VCPreview { DashboardViewController(viewModel: DashboardViewModel(container: DevPreview.shared.container)) }
            .ignoresSafeArea()
    }
}


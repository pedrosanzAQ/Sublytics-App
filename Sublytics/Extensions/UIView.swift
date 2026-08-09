//
//  UIView.swift
//  Sublytics
//
//  Created by pedrosanz on 05/03/26.
//

import UIKit
import SwiftUI

extension UIView {
    
    func backgroundGradient(cornerRadius: CGFloat = 0) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.name = "MyGradient"
        
        gradientLayer.colors = [
            UIColor(red: 0.08, green: 0.35, blue: 0.24, alpha: 1.0).cgColor,
            UIColor(red: 0.05, green: 0.22, blue: 0.15, alpha: 1.0).cgColor
        ]
        
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.frame = bounds
        gradientLayer.cornerRadius = cornerRadius
        
        layer.insertSublayer(gradientLayer, at: 0)
    }
}

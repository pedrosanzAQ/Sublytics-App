//
//  Color.swift
//  Sublytics
//
//  Created by pedrosanz on 04/03/26.
//
import UIKit

extension UIColor {
    static let primaryText = UIColor(white: 0.95, alpha: 1.0)
    
    static let secondaryText = UIColor(red: 0.85, green: 0.88, blue: 0.87, alpha: 1.0)
    
    static let backgroundColor = UIColor(red: 0.12, green: 0.12, blue: 0.12, alpha: 1)
    
    static let greenColor = UIColor(red: 0.08, green: 0.35, blue: 0.24, alpha: 1.0)
    static let greenColorPlus = UIColor(red: 0.0, green: 1.0, blue: 0.4, alpha: 1.0)
    
    
    // Convert hexacolor to UIColor
    convenience init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }
        
        let r, g, b: CGFloat
        
        if hexSanitized.count == 6 {
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x0000FF) / 255.0
            
            self.init(red: r, green: g, blue: b, alpha: 1.0)
        } else if hexSanitized.count == 8 {
            r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            let a = CGFloat(rgb & 0x000000FF) / 255.0
            
            self.init(red: r, green: g, blue: b, alpha: a)
        } else {
            return nil
        }
    }
}

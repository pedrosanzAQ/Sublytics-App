//
//  Untitled.swift
//  Sublytics
//
//  Created by pedrosanz on 06/03/26.
//
import UIKit

extension String {
    func highlight(words: [String], font: UIFont, color: UIColor) -> NSAttributedString {
        let baseFont = UIFont.preferredFont(forTextStyle: .footnote)
        let baseAttributes: [NSAttributedString.Key: Any] = [
            .font: baseFont,
            .foregroundColor: UIColor.primaryText
        ]
        
        let attributedString = NSMutableAttributedString(string: self, attributes: baseAttributes)
        
        for word in words {
            let range = (self as NSString).range(of: word)
            if range.location != NSNotFound {
                attributedString.addAttributes([
                    .font: font, 
                    .foregroundColor: color
                ], range: range)
            }
        }
        return attributedString
    }
}

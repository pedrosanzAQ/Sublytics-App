//
//  CylinderBarChatView.swift
//  Sublytics
//
//  Created by pedrosanz on 09/03/26.
//
import UIKit
import SwiftUI

struct ChartItem {
    let label: String
    let value: Double
}

class InfographicChartView: UIView {
    
    var percentages: [CGFloat]
    var categories: [String]

    let barColors: [UIColor] = [
        UIColor(red: 0.13, green: 0.35, blue: 0.25, alpha: 1.0), // Forest Green (Marca)
        UIColor(red: 0.60, green: 0.89, blue: 0.75, alpha: 1.0), // Soft Mint
        UIColor(red: 0.82, green: 0.67, blue: 0.34, alpha: 1.0), // Muted Gold (Premium)
        UIColor(red: 0.40, green: 0.50, blue: 0.65, alpha: 1.0), // Slate Blue
        UIColor(red: 0.75, green: 0.40, blue: 0.45, alpha: 1.0), // Deep Rose (Warning)
        UIColor(red: 0.25, green: 0.60, blue: 0.60, alpha: 1.0), // Deep Teal
        UIColor(red: 0.85, green: 0.55, blue: 0.25, alpha: 1.0), // Amber/Orange
        UIColor(red: 0.35, green: 0.35, blue: 0.65, alpha: 1.0), // Indigo
        UIColor(red: 0.55, green: 0.65, blue: 0.50, alpha: 1.0), // Sage
        UIColor(red: 0.65, green: 0.65, blue: 0.70, alpha: 1.0)  // Cool Gray (Other)
    ]
    
    override init(frame: CGRect) {
        self.percentages = []
        self.categories = []
        super.init(frame: frame)
        self.backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        // --- SPACING & SCALING CONFIGS ---
        let maxDataValue: CGFloat = 100.0
        let padding: CGFloat = 8.0
        let gridTopPadding: CGFloat = 14.0
        
        let bottomSpace: CGFloat = 50.0
        let topSpace: CGFloat = 70.0
        
        let graphHeight = rect.height - bottomSpace - topSpace
        let barWidth: CGFloat = 34.0
        let numberOfBars = CGFloat(percentages.count)
        
        // --- DRAW HORIZONTAL LINES (GRID) ---
        let numberOfLines = 6
        let gridEndHeight = rect.height * 0.6
        
        for i in 0..<numberOfLines {
            let yPosLine = gridTopPadding + (CGFloat(i) * ((gridEndHeight - gridTopPadding) / CGFloat(numberOfLines - 1)))
            
            let linePath = UIBezierPath()
            linePath.move(to: CGPoint(x: 0, y: yPosLine))
            linePath.addLine(to: CGPoint(x: rect.width, y: yPosLine))
            
            UIColor.lightGray.withAlphaComponent(0.15).setStroke()
            linePath.lineWidth = 0.5
            linePath.stroke()
        }
        
        // --- CALCULATE BAR POSITIONS ---
        let availableWidth = rect.width - (padding * 2)
        let spacing = (availableWidth - (barWidth * numberOfBars)) / (numberOfBars - 1)
        
        var linePoints: [CGPoint] = []
        
        // --- DRAW BARS AND LABELS ---
        for (index, value) in percentages.enumerated() {
            let xPos = padding + CGFloat(index) * (barWidth + spacing)
            
            let clampedValue = min(max(value, 0), maxDataValue)
            let barHeight = (clampedValue / maxDataValue) * graphHeight
            
            let baseY = rect.height - bottomSpace
            let yPos = baseY - barHeight
            
            let customCornerRadius: CGFloat = 6.0
            let barRect = CGRect(x: xPos, y: yPos, width: barWidth, height: barHeight)
            let path = UIBezierPath(roundedRect: barRect,
                                    byRoundingCorners: [.topLeft, .topRight],
                                    cornerRadii: CGSize(width: customCornerRadius, height: customCornerRadius))
            
            barColors[index].setFill()
            path.fill()
            
            let linePointX = xPos + (barWidth / 2)
            let linePointY = yPos - 50
            linePoints.append(CGPoint(x: linePointX, y: linePointY))
        
            drawText("\(Int(value))%", at: CGPoint(x: linePointX, y: yPos - 22), fontSize: 13, color: .primaryText)
            
            if index < categories.count {
                drawText(categories[index], at: CGPoint(x: linePointX, y: baseY + 10), fontSize: 11, color: .secondaryText.withAlphaComponent(0.65))
            }
        }
        
        // --- DRAW TREND LINE & NODES ---
        if linePoints.count > 1 {
            let linePath = UIBezierPath()
            linePath.move(to: linePoints[0])
            for i in 1..<linePoints.count {
                linePath.addLine(to: linePoints[i])
            }
            
            UIColor.greenColorPlus.withAlphaComponent(0.5) .setStroke()
            linePath.lineWidth = 1.0
            linePath.stroke()
            
            for point in linePoints {
                let nodePath = UIBezierPath(arcCenter: point, radius: 4.0, startAngle: 0, endAngle: .pi * 2, clockwise: true)
                UIColor.greenColorPlus.setFill()
                nodePath.fill()
            }
        }
    }
    
    func updateData(with items: [ChartItem]) {
        self.categories = items.map { $0.label }
        let total = items.reduce(0) { $0 + $1.value }
        
        if total > 0 {
            self.percentages = items.map { CGFloat(($0.value / total) * 100) }
        } else {
            self.percentages = items.map { _ in 0.0 }
        }
        
        setNeedsDisplay()
    }
    
    private func drawText(_ text: String, at centerPoint: CGPoint, fontSize: CGFloat, color: UIColor) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: fontSize, weight: .bold),
            .foregroundColor: color,
            .paragraphStyle: paragraphStyle
        ]
        
        let textSize = text.size(withAttributes: attributes)
        let textRect = CGRect(x: centerPoint.x - (textSize.width / 2),
                              y: centerPoint.y,
                              width: textSize.width,
                              height: textSize.height)
        
        text.draw(in: textRect, withAttributes: attributes)
    }
}

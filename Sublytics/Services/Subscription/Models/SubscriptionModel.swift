//
//  SubscriptionResponse.swift
//  Sublytics
//
//  Created by pedrosanz on 11/03/26.
//
import UIKit

struct SubscriptionModel: Hashable, Codable {
    var id: String = UUID().uuidString
    let userId: String
    let title: String
    let category: String
    let monthlyPrice: Double
    let billingDate: Date
    let iconName: String
    let iconColorName: AppIconColorName
    let isTrial: Bool
    let remainingDays: Int
    let isCancelled: Bool
    
    var iconColor: UIColor {
        return iconColorName.color
    }
    
    var priceDisplayText: String {
        if isTrial {
            return "\(remainingDays) days left"
        } else {
            return String(format: "$%.2f", monthlyPrice)
        }
    }
    
    var status: SubscriptionStatus{
        if remainingDays <= 0 {
            return .expired
        } else if isCancelled {
            return .cancelled
        } else {
            return .active
        }
    }

    var statusColor: UIColor {
        switch status {
        case .active: return UIColor(red: 0.0, green: 0.6, blue: 0.1, alpha: 1.0)
        case .expired: return UIColor(red: 0.8, green: 0.1, blue: 0.1, alpha: 1.0)
        case .cancelled: return UIColor(red: 0.9, green: 0.4, blue: 0.0, alpha: 1.0)
        }
    }
    
    init(
        id: String,
        userId: String,
        title: String,
        category: String,
        monthlyPrice: Double,
        billingDate: Date,
        iconName: String,
        iconColorName: AppIconColorName,
        isTrial: Bool,
        remainingDays: Int,
        isCancelled: Bool
    ) {
        self.id = id
        self.userId = userId
        self.title = title
        self.category = category
        self.monthlyPrice = monthlyPrice
        self.billingDate = billingDate
        self.iconName = iconName
        self.iconColorName = iconColorName
        self.isTrial = isTrial
        self.remainingDays = remainingDays
        self.isCancelled = isCancelled
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case userId = "user_id"
        case title = "title"
        case category = "category"
        case monthlyPrice = "monthly_price"
        case billingDate = "billing_date"
        case iconName = "icon_name"
        case iconColorName = "icon_color_name"
        case isTrial = "is_trial"
        case remainingDays = "remaining_days"
        case isCancelled = "is_cancelled"
    }
    
    static var mock: Self {
        return mocks[0]
    }
    
    static var mocks: [Self] {
        [
            SubscriptionModel(
                id: "1",
                userId: "user1",
                title: "Spotify",
                category: SubCategory.music.rawValue,
                monthlyPrice: 7.99,
                billingDate: Date(),
                iconName: SubCategory.music.iconName,
                iconColorName: SubCategory.music.defaultColorName,
                isTrial: true,
                remainingDays: 30,
                isCancelled: false
            ),
            SubscriptionModel(
                id: "2",
                userId: "user1",
                title: "Netflix",
                category: SubCategory.entertainment.rawValue,
                monthlyPrice: 9.99,
                billingDate: Date(),
                iconName: SubCategory.entertainment.iconName,
                iconColorName: SubCategory.entertainment.defaultColorName,
                isTrial: false,
                remainingDays: 6,
                isCancelled: false
            ),
            SubscriptionModel(
                id: "3",
                userId: "user1",
                title: "Disney+",
                category: SubCategory.entertainment.rawValue,
                monthlyPrice: 11.99,
                billingDate: Date(),
                iconName: SubCategory.entertainment.iconName,
                iconColorName: SubCategory.entertainment.defaultColorName,
                isTrial: true,
                remainingDays: 3,
                isCancelled: false
            ),
            SubscriptionModel(
                id: "4",
                userId: "user2",
                title: "iCloud",
                category: SubCategory.storage.rawValue,
                monthlyPrice: 4.99,
                billingDate: Date(),
                iconName: SubCategory.storage.iconName,
                iconColorName: SubCategory.storage.defaultColorName,
                isTrial: false,
                remainingDays: 1,
                isCancelled: false
            ),
            SubscriptionModel(
                id: "5",
                userId: "user2",
                title: "Amazon Prime",
                category: SubCategory.shopping.rawValue,
                monthlyPrice: 5.99,
                billingDate: Date(),
                iconName: SubCategory.shopping.iconName,
                iconColorName: SubCategory.shopping.defaultColorName,
                isTrial: false,
                remainingDays: 15,
                isCancelled: true
            ),
            SubscriptionModel(
                id: "6",
                userId: "user3",
                title: "Spotify",
                category: SubCategory.music.rawValue,
                monthlyPrice: 6.99,
                billingDate: Date(),
                iconName: SubCategory.music.iconName,
                iconColorName: SubCategory.music.defaultColorName,
                isTrial: true,
                remainingDays: 20,
                isCancelled: false
            ),
        ]
    }
}

enum SubscriptionStatus: String, CaseIterable, Codable {
    case active
    case expired
    case cancelled
}

enum AppIconColorName: String, Codable {
    case purple
    case pink
    case blue
    case grayBlue
    case orange
    case green
    case red
    case yellow
    case brown
    case gray
    
    private var hexString: String {
        switch self {
        case .purple:   return "#9C27B0"
        case .pink:     return "#E91E63"
        case .blue:     return "#2196F3"
        case .grayBlue: return "#607D8B"
        case .orange:   return "#FF9800"
        case .green:    return "#4CAF50"
        case .red:      return "#F44336"
        case .yellow:   return "#FFEB3B"
        case .brown:    return "#00BCD4"
        case .gray:     return "#9E9E9E"
        }
    }
    
    var color: UIColor {
        return UIColor(hex: self.hexString) ?? .gray
    }
}

enum SubCategory: String, CaseIterable, Codable {
    case entertainment = "Entertain"
    case music = "Music"
    case software = "Software"
    case storage = "Storage"
    case food = "Food"
    case health = "Health"
    case shopping = "Shopping"
    case gaming = "Gaming"
    case utilities = "Utilities"
    case other = "Other"
    
    var iconName: String {
        switch self {
        case .entertainment: return "play.tv.fill"
        case .music:         return "music.note"
        case .software:      return "terminal.fill"
        case .storage:       return "icloud.fill"
        case .food:          return "hamburger.fill"
        case .health:        return "heart.fill"
        case .shopping:      return "bag.fill"
        case .gaming:        return "gamecontroller.fill"
        case .utilities:     return "wrench.and.screwdriver.fill"
        case .other:         return "ellipsis.circle.fill"
        }
    }
    
    var defaultColorName: AppIconColorName {
        switch self {
        case .entertainment: .purple
        case .music:         .pink
        case .software:      .blue
        case .storage:       .grayBlue
        case .food:          .orange
        case .health:        .green
        case .shopping:      .red
        case .gaming:        .yellow
        case .utilities:     .brown
        case .other:         .gray
        }
    }
}

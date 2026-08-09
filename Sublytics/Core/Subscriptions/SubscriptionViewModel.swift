//
//  SubscriptionViewModel.swift
//  Sublytics
//
//  Created by pedrosanz on 13/07/26.
//
import Foundation
import UIKit

@Observable
@MainActor
class SubscriptionViewModel {
    let container: DependencyContainer
    private let userManager: UserManager
    private let subscriptionManager: SubscriptionManager
    
    var selectedCategory: String = ""
    
    init(container: DependencyContainer) {
        self.container = container
        self.userManager = container.resolve(UserManager.self)!
        self.subscriptionManager = container.resolve(SubscriptionManager.self)!
    }
    
    var isAnnonymousUser: Bool {
        return userManager.currentUser?.isAnonymous ?? true
    }
    
    var allSubsctiptions: [SubscriptionModel] {
        let baseSubscriptions = subscriptionManager.allSubscriptions ?? []
        
        if selectedCategory.isEmpty || selectedCategory.lowercased() == "all" {
            return baseSubscriptions
        }
        
        return baseSubscriptions.filter { $0.category.lowercased() == selectedCategory.lowercased() }
    }
    
    var upcomingSubscriptions: [SubscriptionModel] {
        let activeSubs = subscriptionManager.allSubscriptions?.filter { $0.status == .active } ?? []
        let nearUpcoming = activeSubs.filter { $0.remainingDays <= 10 }
        
        if selectedCategory.isEmpty || selectedCategory.lowercased() == "all" {
            return nearUpcoming
        }
        //        return nearUpcoming.filter { $0.category.lowercased() == selectedCategory.lowercased() }
        return []
    }
    
}

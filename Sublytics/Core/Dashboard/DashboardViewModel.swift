//
//  DashboardViewModel.swift
//  Sublytics
//
//  Created by pedrosanz on 10/07/26.
//

import Foundation
import UIKit

@Observable
@MainActor
class DashboardViewModel {
    let container: DependencyContainer
    private let userManager: UserManager
    private let subscriptionManager: SubscriptionManager
    private var cachedChartItems: [ChartItem] = []
    private var lastSubscriptionsCount: Int = -1
    
    var isAnonymousUser: Bool {
        userManager.currentUser?.isAnonymous ?? true
    }
    
    var allSubscriptions: [SubscriptionModel] {
        subscriptionManager.allSubscriptions ?? []
    }
    
    var currentMonthlySpending: Double {
        allSubscriptions
            .filter { $0.status == .active }
            .reduce(0) { $0 + $1.monthlyPrice }
    }
    
    var currentAnnualSpending: Double {
        currentMonthlySpending * 12
    }
    
    // take it from the dataBase
    var previousMonthlySpending: Double = 0
    
    var subscriptionEstimate: String {
        let activeSubs = allSubscriptions.filter { $0.status == .active }
        let sortedSubs = activeSubs.sorted { $0.monthlyPrice > $1.monthlyPrice }
        
        if currentMonthlySpending > 1000 {
            return sortedSubs.prefix(2).map { $0.title }.joined(separator: " & ")
        } else {
            return sortedSubs.first?.title ?? ""
        }
    }
    
    var savingEstimate: Double {
        let activeSubs = allSubscriptions.filter { $0.status == .active }
        let sortedSubs = activeSubs.sorted { $0.monthlyPrice > $1.monthlyPrice }
        let count = currentMonthlySpending > 1000 ? 2 : 1
        
        return sortedSubs.prefix(count).reduce(0.0) { $0 + $1.monthlyPrice } * 12
    }
    
    init(container: DependencyContainer) {
        self.container = container
        self.userManager = container.resolve(UserManager.self)!
        self.subscriptionManager = container.resolve(SubscriptionManager.self)!
    }
    
    var upcomingsubsCharges: [SubscriptionModel] {
        return allSubscriptions.filter { $0.remainingDays <= 5 }
    }
    
    func montlySpendingInfograficChart() -> [ChartItem] {
        if !cachedChartItems.isEmpty && allSubscriptions.count == lastSubscriptionsCount {
            return cachedChartItems
        }
        
        var categoryTotals : [String: Double] = [:]
        
        for subscription in allSubscriptions {
            categoryTotals[subscription.category, default: 0.0] += subscription.monthlyPrice
        }
        
        var chartItems = categoryTotals.map {ChartItem(label: $0.key, value: $0.value) }
        chartItems.sort { $0.value > $1.value }
        
        var first5: [ChartItem] = []
        var othersValue: Double = 0.0
        
        if chartItems.count > 6 {
            first5 = Array(chartItems.prefix(5))
            othersValue = chartItems[5...].reduce(0) { $0 + $1.value }
        } else {
            first5 = chartItems
            
            let placeholders = ["Apps", "Gaming", "Health", "Cloud", "Education"]
            let currentLabels = Set(first5.map { $0.label })
            let available = placeholders.filter { !currentLabels.contains($0) }.shuffled()
            
            if chartItems.count == 6 {
                let last = first5.removeLast()
                othersValue = last.value
            }
            
            var i = 0
            while first5.count < 5 && i < available.count {
                first5.append(ChartItem(label: available[i], value: 0.0))
                i += 1
            }
        }
        
        let randomizedTop5 = first5.shuffled()
        let othersItem = ChartItem(label: "Others", value: othersValue)
        
        let result = randomizedTop5 + [othersItem]
        self.cachedChartItems = result
        self.lastSubscriptionsCount = allSubscriptions.count
        
        return result
    }
    
    func getDiferencePorcentage() -> Int {
        guard previousMonthlySpending > 0 else { return 0 }
        
        let difference = currentMonthlySpending - previousMonthlySpending
        let percentage = (difference / previousMonthlySpending) * 100
        
        return Int(percentage.rounded())
    }
    
    func addUserSubscriptionsListener() {
        guard let currentUser = userManager.currentUser, let isAnonymous = currentUser.isAnonymous else { return print("something worng")}
        
        if !isAnonymous {
            subscriptionManager.addUserSubscriptionsListener(userId: currentUser.userId)
            print("user listener subs added")
        }
    }
    
}

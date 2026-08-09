//
//  Untitled.swift
//  Sublytics
//
//  Created by pedrosanz on 13/07/26.
//
import Foundation
import UIKit

@Observable
@MainActor
class InsightsViewModel {
    let container: DependencyContainer
    private let userManager: UserManager
    private let subscriptionManager: SubscriptionManager
    
    init(container: DependencyContainer) {
        self.container = container
        self.userManager = container.resolve(UserManager.self)!
        self.subscriptionManager = container.resolve(SubscriptionManager.self)!
    }
    
    var isAnnonymousUser: Bool {
        return userManager.currentUser?.isAnonymous ?? true
    }
    
    var allActiveSubscriptions: [SubscriptionModel] {
        return subscriptionManager.allSubscriptions?.filter { $0.status == .active } ?? []
    }
    
    var costliestSubscriptions: [SubscriptionModel] {
        return Array(allActiveSubscriptions.sorted(by: { $0.monthlyPrice > $1.monthlyPrice }).prefix(3))
    }
    
    private(set) var globalCostliestSub: SubscriptionModel? = nil
    private(set) var costliestInCategory: SubscriptionModel? = nil
    
    func highestSubscriptionSaving() -> [ChartItem]{
        guard let targetSub = allActiveSubscriptions.max(by: { $0.monthlyPrice < $1.monthlyPrice }) else { return [] }
        
        if allActiveSubscriptions.count >= 3 {
            globalCostliestSub = targetSub
            
            let remainingSubs = allActiveSubscriptions.filter { $0.id != targetSub.id }
            
            var categoryTotals: [String : Double] = [:]
            for sub in remainingSubs {
                categoryTotals[sub.category, default: 0.0] += sub.monthlyPrice
            }
            
            var chartItems = categoryTotals.map{ ChartItem(label: $0.key, value: $0.value) }
            chartItems.sort { $0.value > $1.value }
            
            var finalItems: [ChartItem] = []
            var othersValue: Double = 0.0
            
            if chartItems.count > 6 {
                finalItems = Array(chartItems.prefix(5))
                othersValue = chartItems[5...].reduce(0) { $0 + $1.value }
            } else if chartItems.count == 6 {
                finalItems = Array(chartItems.prefix(5))
                othersValue = chartItems[5].value
            } else {
                finalItems = chartItems
                
                let placeholders = ["Apps", "Gaming", "Health", "Cloud", "Education", "Travel"]
                let currentLabels = Set(finalItems.map { $0.label })
                var available = placeholders.filter { !currentLabels.contains($0) }.shuffled()
                
                while finalItems.count < 5 && !available.isEmpty {
                    finalItems.append(ChartItem(label: available.removeFirst(), value: 0.0))
                }
            }
            
            let randomizedTop5 = finalItems.shuffled()
            return randomizedTop5 + [ChartItem(label: "Others", value: othersValue)]
        }
        
        return []
    }
    
    // remove the highest subscription by one random category
    func costliestCategorySubSaving() -> [ChartItem] {
        let gruped = Dictionary(grouping: allActiveSubscriptions, by: { $0.category })
        let eligibleCategories = gruped.filter { key, value in
            return value.count >= 2 && value.contains(where: { $0.id != globalCostliestSub?.id })
        }.map { $0.key }
        
        print(eligibleCategories)
        
        guard let randomCategory = eligibleCategories.randomElement(), let subsInCategory = gruped[randomCategory] else {
            return []
        }
        
        let candidate = subsInCategory
            .filter { $0.id != globalCostliestSub?.id}
            .max(by: { $0.monthlyPrice < $1.monthlyPrice })
        
        guard let targetSub = candidate else { return [] }
        costliestInCategory = targetSub
        
        let remainingSubs = allActiveSubscriptions.filter { $0.id != targetSub.id}
        
        var categoryTotals: [String : Double] = [:]
        for sub in remainingSubs {
            categoryTotals[sub.category, default: 0.0] += sub.monthlyPrice
        }
        
        var chartItems = categoryTotals.map{ ChartItem(label: $0.key, value: $0.value) }
        chartItems.sort { $0.value > $1.value }
        
        var finalItems: [ChartItem] = []
        var othersValue: Double = 0.0
        
        if chartItems.count > 6 {
            finalItems = Array(chartItems.prefix(5))
            othersValue = chartItems[5...].reduce(0) { $0 + $1.value }
        } else if chartItems.count == 6 {
            finalItems = Array(chartItems.prefix(5))
            othersValue = chartItems[5].value
        } else {
            finalItems = chartItems
            
            let placeholders = ["Apps", "Gaming", "Health", "Cloud", "Education", "Travel"]
            let currentLabels = Set(finalItems.map { $0.label })
            var available = placeholders.filter { !currentLabels.contains($0) }.shuffled()
            
            while finalItems.count < 5 && !available.isEmpty {
                finalItems.append(ChartItem(label: available.removeFirst(), value: 0.0))
            }
        }
        
        let randomizedTop5 = finalItems.shuffled()
        return randomizedTop5 + [ChartItem(label: "Others", value: othersValue)]
    }
}

    

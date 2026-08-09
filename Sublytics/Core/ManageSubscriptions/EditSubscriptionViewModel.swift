//
//  EditSubscriptionViewModel.swift
//  Sublytics
//
//  Created by pedrosanz on 22/07/26.
//

import UIKit

@Observable
@MainActor
class EditSubscriptionViewModel {
    let container: DependencyContainer
    private(set) var subscriptionManager: SubscriptionManager
    
    private(set) var subscription: SubscriptionModel
    
    init(container: DependencyContainer, subscription: SubscriptionModel) {
        self.subscription = subscription
        self.container = container
        self.subscriptionManager = container.resolve(SubscriptionManager.self)!
    }
    
    var subscriptionName: String { subscription.title }
    var iconName: String { subscription.iconName }
    
    var amountText: String {
        return String(format: "%.2f", subscription.monthlyPrice)
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: subscription.billingDate)
    }
    
    var date: Date { subscription.billingDate }
    
    func saveSubscription(subscriptionName: String, category: SubCategory, price: Double, billingDate: Date) async -> Bool {
        let remainingDays = calculateRemainingDays(from: billingDate)
        
        let subscription = SubscriptionModel(
            id: subscription.id,
            userId: subscription.userId,
            title: subscriptionName,
            category: category.rawValue,
            monthlyPrice: price,
            billingDate: billingDate,
            iconName: category.iconName,
            iconColorName: category.defaultColorName,
            isTrial: subscription.isTrial,
            remainingDays: remainingDays,
            isCancelled: subscription.isCancelled
        )
        
        do {
            try await subscriptionManager.saveSubscription(subscription: subscription)
            return true
        } catch {
            return false
        }
    }
    
    func deleteSubscription() async -> Bool {
        do {
            try await subscriptionManager.deleteSubscription(subscription: subscription)
            return true
        } catch {
            return false
        }
    }
    
    private func calculateRemainingDays(from date: Date) -> Int {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())
        let startOfTarget = calendar.startOfDay(for: date)
        let components = calendar.dateComponents([.day], from: startOfToday, to: startOfTarget)
        return max(0, components.day ?? 0)
    }
    
}

//
//  AddSubscriptionViewModel.swift
//  Sublytics
//
//  Created by pedrosanz on 20/07/26.
//
import UIKit

@Observable
@MainActor
class AddSusbcriptionViewModel {
    let container: DependencyContainer
    private let userManager: UserManager
    private let subscriptionManager: SubscriptionManager
    
    init(container: DependencyContainer) {
        self.container = container
        self.userManager = container.resolve(UserManager.self)!
        self.subscriptionManager = container.resolve(SubscriptionManager.self)!
    }
    
    func saveSubscription(
        title: String,
        category: SubCategory,
        stringPrice: String,
        billingDate: Date,
        isTrial: Bool,
        trialEndDate: Date?
    ) async -> Bool {
        
        let cleanedPrice = stringPrice.replacingOccurrences(of: ",", with: ".")
        let price = Double(cleanedPrice) ?? 0.0
        let remainingDays = calculateRemainingDays(from: isTrial ? (trialEndDate ?? billingDate) : billingDate)
        
        guard let currentUser = userManager.currentUser else { return false }
        
        let subscription = SubscriptionModel(
            id: UUID().uuidString,
            userId: currentUser.userId,
            title: title,
            category: category.rawValue,
            monthlyPrice: price,
            billingDate: billingDate,
            iconName: category.iconName,
            iconColorName: category.defaultColorName,
            isTrial: isTrial,
            remainingDays: remainingDays,
            isCancelled: false
        )
        
        do {
            try await subscriptionManager.saveSubscription(subscription: subscription)
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

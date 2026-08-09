//
//  SubscriptionManager.swift
//  Sublytics
//
//  Created by pedrosanz on 06/08/26.
//
import Foundation
import FirebaseFirestore

@Observable
@MainActor
class SubscriptionManager {
    private let service: SubscriptionService
    private(set) var allSubscriptions: [SubscriptionModel]?
    private var subscriptionListener: ListenerRegistration?
    
    init(service: SubscriptionService) {
        self.service = service
    }
    
    func addUserSubscriptionsListener(userId: String) {
        subscriptionListener?.remove()
        Task {
            for try await value in service.streamAllSubscriptions(userId, onListenerAttached: { listener in
                self.subscriptionListener = listener
            }) {
                self.allSubscriptions = value
                print("Success listener subscriptions:  \(String(describing: value))")
            }
        }
    }
    
    func removeUserSubscriptionsListener() {
        subscriptionListener?.remove()
        subscriptionListener = nil
        allSubscriptions = nil
        print("user subscription listener removed")
    }
    
    func saveSubscription(subscription: SubscriptionModel) async throws {
        try await service.saveSubscription(subscription)
    }
    
    func deleteSubscription(subscription: SubscriptionModel) async throws {
        try await service.deleteSubscription(subscription)
    }
    
}

//
//  MockSubscriptionService.swift
//  Sublytics
//
//  Created by pedrosanz on 06/08/26.
//

import Foundation
import UIKit
import FirebaseFirestore

struct MockSubscriptionService: SubscriptionService {
    let subscriptions: [SubscriptionModel]
    
    init(subscriptions: [SubscriptionModel] = SubscriptionModel.mocks) {
        self.subscriptions = subscriptions
    }
    
    func streamAllSubscriptions(_ userId: String, onListenerAttached: (any ListenerRegistration) -> Void) -> AsyncStream<[SubscriptionModel]?> {
        AsyncStream { continuation in
            let userSubs = subscriptions.filter { $0.userId == userId }
            continuation.yield(userSubs)
            continuation.finish()
        }
    }
    
    func saveSubscription(_ subscription: SubscriptionModel) async throws {
        print("Subscription succesfully saved: \(subscription)")
    }
    
    func deleteSubscription(_ subscription: SubscriptionModel) async throws {
        print("subcription succesfully deleted: \(subscription)")
    }
}

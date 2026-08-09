//
//  FirebaseSubscriptionService.swift
//  Sublytics
//
//  Created by pedrosanz on 06/08/26.
//

import Foundation
import FirebaseFirestore

struct FirebaseSubscriptionService: SubscriptionService {
    
    var collection: CollectionReference {
        Firestore.firestore().collection("subscriptions")
    }
    
    func streamAllSubscriptions(_ userId: String, onListenerAttached: (any ListenerRegistration) -> Void ) -> AsyncStream<[SubscriptionModel]?> {
        AsyncStream { continuation in
            let listener = collection.whereField("user_id", isEqualTo: userId).addSnapshotListener { snapshot, _ in
                if let snapshot {
                    do {
                        let allSubs = snapshot.documents.compactMap { doc in
                            try? doc.data(as: SubscriptionModel.self)
                        }
                        continuation.yield(allSubs)
                    }
                } else {
                    continuation.yield([])
                }
            }
            
            onListenerAttached(listener)
        }
    }
    
    func saveSubscription(_ subscription: SubscriptionModel) async throws {
        try? collection.document(subscription.id).setData(from: subscription, merge: true)
    }
    
    func deleteSubscription(_ subscription: SubscriptionModel) async throws {
        try? await collection.document(subscription.id).delete()
    }
}

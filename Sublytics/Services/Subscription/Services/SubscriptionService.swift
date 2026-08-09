//
//  Untitled.swift
//  Sublytics
//
//  Created by pedrosanz on 02/07/26.
//
import UIKit
import FirebaseFirestore

protocol SubscriptionService: Sendable{
    func streamAllSubscriptions(_ userId: String, onListenerAttached: (any ListenerRegistration) -> Void ) -> AsyncStream<[SubscriptionModel]?>
    func saveSubscription(_ subscription: SubscriptionModel) async throws
    func deleteSubscription(_ subscription: SubscriptionModel) async throws
}

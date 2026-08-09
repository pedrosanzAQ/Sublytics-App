//
//  SearchRootViewModel.swift
//  Sublytics
//
//  Created by pedrosanz on 24/07/26.
//
import Foundation
import UIKit

@Observable
@MainActor
class SearchRootViewModel {
    let container: DependencyContainer
    private let appStateManager: AppStateManager
    private let subscriptionManager: SubscriptionManager
    
    private(set) var initialQuery: String?
    
    init(container: DependencyContainer, query: String? = nil) {
        self.container = container
        self.appStateManager = container.resolve(AppStateManager.self)!
        self.subscriptionManager = container.resolve(SubscriptionManager.self)!
        self.initialQuery = query
    }
    
    var recentSearches: [String] {
        appStateManager.recentSearches
    }
    
    var allSubscriptions: [SubscriptionModel] {
        subscriptionManager.allSubscriptions ?? []
    }
    
    func saveRecents(query: String) {
        appStateManager.saveRecentSearches(search: query)
    }
}

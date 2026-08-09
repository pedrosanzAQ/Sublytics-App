//
//  ProtocolAppStateService.swift
//  Sublytics
//
//  Created by pedrosanz on 22/04/26.
//

import UIKit

struct AppState: AppStateService {
    var showTabBar: Bool {
        get {
            return UserDefaults.showTabbarView
        }
        set {
            UserDefaults.showTabbarView = newValue
        }
    }
    
    var recentSearches: [String] {
        get {
            return UserDefaults.recentSearches
        } set {
            UserDefaults.recentSearches = newValue
        }
    }
    
    mutating func updateViewState(showTabBarView: Bool) {
        self.showTabBar = showTabBarView
    }
    
    mutating func saveRecentSearchs(_ search: String) {
        let maxLimit: Int = 15
        let trimmed = search.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        var current = recentSearches
        current.removeAll { $0.localizedCaseInsensitiveCompare(trimmed) == .orderedSame }
        current.insert(trimmed, at: 0)
        
        if current.count > maxLimit {
            current = Array(current.prefix(maxLimit))
        }
        
        self.recentSearches = current
    }
    
    mutating func clearRecentSearches() {
        self.recentSearches = []
    }
}

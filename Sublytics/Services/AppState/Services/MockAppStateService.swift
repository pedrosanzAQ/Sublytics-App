//
//  MockAppStateService.swift
//  Sublytics
//
//  Created by pedrosanz on 22/04/26.
//
import Foundation

struct MockAppStateService: AppStateService {
    var showTabBar: Bool
    var recentSearches: [String]
    
    init(showTabBar: Bool, recentSearches: [String] = ["amazon", "apple music"]) {
        self.showTabBar = showTabBar
        self.recentSearches = recentSearches
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
        current.insert(search, at: 0)
        
        if current.count > maxLimit {
            current = Array(current.prefix(maxLimit))
        }
        
        self.recentSearches = current
    }
    
    mutating func clearRecentSearches() {
        
    }
}

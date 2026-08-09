//
//  AppStateManager.swift
//  Sublytics
//
//  Created by pedrosanz on 22/04/26.
//
import UIKit

@Observable
@MainActor
class AppStateManager {
    private var service: AppStateService
    
    var showTabBar: Bool {
        return service.showTabBar
    }
    
    var recentSearches: [String] {
        return service.recentSearches
    }
    
    init(service: AppStateService) {
        self.service = service
    }
    
    func updateViewState(showTabBarView: Bool) {
        service.updateViewState(showTabBarView: showTabBarView)
    }
    
    func saveRecentSearches(search: String) {
        service.saveRecentSearchs(search)
    }
}

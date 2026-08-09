//
//  AppStateService.swift
//  Sublytics
//
//  Created by pedrosanz on 22/04/26.
//

import UIKit

protocol AppStateService: Sendable {
    var showTabBar: Bool { get set }
    var recentSearches: [String]  { get set }
    mutating func updateViewState(showTabBarView: Bool)
    mutating func saveRecentSearchs(_ search: String)
    mutating func clearRecentSearches()
}

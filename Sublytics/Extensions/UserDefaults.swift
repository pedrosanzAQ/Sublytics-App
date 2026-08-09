//
//  UserDefaults.swift
//  Sublytics
//
//  Created by pedrosanz on 22/04/26.
//
import Foundation

extension UserDefaults {
    private struct Keys {
        static let showTabbarView = "showTabbarView"
        static let recentSearches = "recentSearches"
    }
    
    static var showTabbarView: Bool {
        get {
            standard.bool(forKey: Keys.showTabbarView)
        }
        set {
            standard.set(newValue, forKey: Keys.showTabbarView)
        }
    }
    
    static var recentSearches: [String] {
        get {
            standard.stringArray(forKey: Keys.recentSearches) ?? []
        }
        set {
            standard.set(newValue, forKey: Keys.recentSearches)
        }
    }
}

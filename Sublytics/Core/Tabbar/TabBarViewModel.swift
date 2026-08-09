//
//  TabBarViewModel.swift
//  Sublytics
//
//  Created by pedrosanz on 06/08/26.
//

import Foundation

@Observable
@MainActor
class TabBarViewModel {
    let container: DependencyContainer
    private let authManager: AuthManager
    private let userManager: UserManager
    private let subscriptionManager: SubscriptionManager
    
    init(container: DependencyContainer) {
        self.container = container
        self.authManager = container.resolve(AuthManager.self)!
        self.userManager = container.resolve(UserManager.self)!
        self.subscriptionManager = container.resolve(SubscriptionManager.self)!
    }
    
    
    func startUserListener() {
        guard let auth = authManager.auth else {
            print("⚠️ No hay usuario autenticado al cargar TabBar")
            return
        }
        
        userManager.addCurrentUserListener(userId: auth.uid)
        
        if !(auth.isAnonymous ?? true) {
            subscriptionManager.addUserSubscriptionsListener(userId: auth.uid)
            print("user listener subs added")
        }
    }
}

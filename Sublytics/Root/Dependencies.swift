//
//  Dependencies.swift
//  Sublytics
//
//  Created by pedrosanz on 22/04/26.
//
import UIKit

@MainActor
struct Dependencies {
    let container: DependencyContainer
    let appStateManager: AppStateManager
    let authManager: AuthManager
    let userManager: UserManager
    let subscriptionManager: SubscriptionManager
    
    init() {
        self.appStateManager = AppStateManager(service: AppState())
        self.authManager = AuthManager(service: FireabaseAuthService())
        self.userManager = UserManager(service: FirebaseUserService())
        self.subscriptionManager = SubscriptionManager(service: FirebaseSubscriptionService())
        
        let container = DependencyContainer()
        container.register(AppStateManager.self, service: appStateManager)
        container.register(AuthManager.self, service: authManager)
        container.register(UserManager.self, service: userManager)
        container.register(SubscriptionManager.self, service: subscriptionManager)
        self.container = container
    }
}


@MainActor
class DevPreview {
    static let shared = DevPreview()
    
    let container: DependencyContainer
    let appStateManager: AppStateManager
    let authManager: AuthManager
    let userManager: UserManager
    let subscriptionManager: SubscriptionManager
    
    init() {
        self.appStateManager = AppStateManager(service: MockAppStateService(showTabBar: false))
        self.authManager = AuthManager(service: MockAuthService())
        self.userManager = UserManager(service: MockUserService(currentUser: UserModel.mock))
        self.subscriptionManager = SubscriptionManager(service: MockSubscriptionService(subscriptions: SubscriptionModel.mocks))
        
        let container = DependencyContainer()
        container.register(AppStateManager.self, service: appStateManager)
        container.register(AuthManager.self, service: authManager)
        container.register(UserManager.self , service: userManager)
        container.register(SubscriptionManager.self, service: subscriptionManager)
        self.container = container
    }
    
}

//
//  SignInModalViewModel.swift
//  Sublytics
//
//  Created by pedrosanz on 01/08/26.
//

import Foundation

@Observable
@MainActor
class SignInModalViewModel {
    let container: DependencyContainer
    private let authManager: AuthManager
    private let appStateManager: AppStateManager
    private let userManager: UserManager
    private let subscriptionManager: SubscriptionManager
    
    init(container: DependencyContainer) {
        self.container = container
        self.authManager = container.resolve(AuthManager.self)!
        self.appStateManager = container.resolve(AppStateManager.self)!
        self.userManager = container.resolve(UserManager.self)!
        self.subscriptionManager = container.resolve(SubscriptionManager.self)!
    }
    
    func linkWithGoogle(idToken: String, accessToken: String) async throws -> UserAuthInfo? {
        let result = try await authManager.signInGoogle(idToken: idToken, accessToken: accessToken)
        updateTabbar()
        return result
    }
    
    func singInAnExistingGoogleAccount(idToken: String, accesToken: String) async throws -> UserAuthInfo?{
        let result = try await authManager.singInAnExistingGoogleAccount(idToken: idToken, accessToken: accesToken)
        updateTabbar()
        return result
    }
    
    func logIn(auth: UserAuthInfo) async throws {
        try await userManager.logIn(auth: auth)
    }
    
    func deleteAnnonimuysAccount() async throws {
        try await userManager.deleteUserData()
    }
    
    func addUserSubscriptionListener(userId: String) {
        subscriptionManager.addUserSubscriptionsListener(userId: userId)
    }
    
    private func updateTabbar() {
        appStateManager.updateViewState(showTabBarView: true)
    }
    
}

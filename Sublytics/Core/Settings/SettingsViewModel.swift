//
//  SettingsViewModel.swift
//  Sublytics
//
//  Created by pedrosanz on 26/07/26.
//
import Foundation
import UIKit

@Observable
@MainActor
class SettingsViewModel {
    let container: DependencyContainer
    private let appStateManager: AppStateManager
    private let authManager: AuthManager
    private let userManager: UserManager
    private let subscriptionManager: SubscriptionManager
    
    init(container: DependencyContainer) {
        self.container = container
        self.appStateManager = container.resolve(AppStateManager.self)!
        self.authManager = container.resolve(AuthManager.self)!
        self.userManager = container.resolve(UserManager.self)!
        self.subscriptionManager = container.resolve(SubscriptionManager.self)!
    }
    
    var currentUser: UserModel? {
        userManager.currentUser ?? nil
    }
    
    var auth: UserAuthInfo? {
        authManager.auth
    }
    
    func updateUsername(username: String) async {
        guard let currentUser else { return }
        
        let userUpdated = UserModel(
            userId: currentUser.userId,
            email: currentUser.email,
            username: username,
            isAnonymous: currentUser.isAnonymous,
            creationDate: currentUser.creationDate,
            lastSignIn: currentUser.lastSignIn
        )
        
        try? await userManager.updateUserData(user: userUpdated)
    }
    
    func stopListenUserSusbscriptions() {
        guard let currentUser = userManager.currentUser else { return }
        
        if currentUser.isAnonymous == false {
            subscriptionManager.removeUserSubscriptionsListener()
        }
    }
    
    func logOut() async {
        do {
            try await authManager.logOut()
            appStateManager.updateViewState(showTabBarView: false)
        } catch {
            print("cannot logOut")
        }
    }
    
    func deleteAccount(idToken: String? = nil, accessToken: String? = nil) async{
        do {
            try await userManager.deleteUserData()
            try await authManager.deleteAccount(idToken: idToken, accessToken: accessToken)
            appStateManager.updateViewState(showTabBarView: false)
        } catch {
            print(error)
        }
    }
    
}

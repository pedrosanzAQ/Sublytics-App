//
//  WelcomeViewModel.swift
//  Sublytics
//
//  Created by pedrosanz on 06/08/26.
//

import Foundation
import UIKit

@Observable
@MainActor
class WelcomeViewModel {
    let container: DependencyContainer
    private let appStateManager: AppStateManager
    private let authManager: AuthManager
    private let userManager: UserManager
    
    init(container: DependencyContainer) {
        self.container = container
        self.appStateManager = container.resolve(AppStateManager.self)!
        self.authManager = container.resolve(AuthManager.self)!
        self.userManager = container.resolve(UserManager.self)!
    }
    
    func onStartedPressed() {
        appStateManager.updateViewState(showTabBarView: true)
    }
    
    func checkAuthUserStatus() async {
        if let auth = authManager.auth {
            print("user already authenticated \(auth.uid)")
            do {
                try await userManager.logIn(auth: auth)
            } catch {
                print("Failed to log in for existing user")
            }
        } else {
            do {
                let result = try await authManager.signInAnonymously()
                if let result {
                    try await userManager.logIn(auth: result)
                }
                print("user anonymusly authenticated \(result?.uid ?? "no uid")")
            } catch {
                print(error)
            }
        }
    }
}



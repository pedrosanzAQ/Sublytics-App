//
//  File.swift
//  Sublytics
//
//  Created by pedrosanz on 06/08/26.
//

import Foundation
import UIKit

@Observable
@MainActor
class AppViewModel {
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
    
    var showTabbar: Bool {
        appStateManager.showTabBar
    }
    
    var currentUser: UserModel? {
        userManager.currentUser
    }
}

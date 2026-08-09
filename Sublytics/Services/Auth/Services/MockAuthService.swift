//
//  Untitled 2.swift
//  Sublytics
//
//  Created by pedrosanz on 06/08/26.
//

import Foundation

struct MockAuthService: AuthService {
    var currentUser: UserAuthInfo?
    
    init(currentUser: UserAuthInfo? = UserAuthInfo.mock) {
        self.currentUser = currentUser
    }
    
    func authenticatedUserListener(onListenerAttached: (any NSObjectProtocol) -> Void) -> AsyncStream<UserAuthInfo?> {
        AsyncStream { continuation in
            continuation.yield(currentUser)
        }
    }
    
    func getAuthenticatedUser() -> UserAuthInfo? {
        return currentUser
    }
    
    func signInAnonymously() async throws -> UserAuthInfo {
        let user = UserAuthInfo.mock
        return user
    }
    
    func signInGoogle(idtoken: String, accesToken: String) async throws -> UserAuthInfo? {
        return UserAuthInfo.mock
    }
    
    func singInAnExistingGoogleAccount(idToken: String, accessToken: String) async throws -> UserAuthInfo? {
        return UserAuthInfo.mock
    }
    
    func signOut() async throws {
        
    }
    
    func deleteAccount(idToken: String?, accessToken: String?) async throws {
        
    }
}

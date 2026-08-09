//
//  Untitled.swift
//  Sublytics
//
//  Created by pedrosanz on 26/05/26.
//

import UIKit

@Observable
@MainActor
class AuthManager {
    private let service: AuthService
    private(set) var auth: UserAuthInfo?
    private var listener: (any NSObjectProtocol)?
    
    init(service: AuthService) {
        self.service = service
        self.auth = service.getAuthenticatedUser()
        self.addAuthListener()
    }
    
    private func addAuthListener() {
        Task { @MainActor in
            for await value in service.authenticatedUserListener(onListenerAttached:  { listener in
                self.listener = listener
            }) {
                self.auth = value
            }
        }
    }
    
    func signInAnonymously() async throws -> UserAuthInfo? {
        try await service.signInAnonymously()
    }
    
    func signInGoogle(idToken: String, accessToken: String) async throws -> UserAuthInfo? {
        try await service.signInGoogle(idtoken: idToken, accesToken: accessToken)
    }
    
    func singInAnExistingGoogleAccount(idToken: String, accessToken: String) async throws -> UserAuthInfo? {
        try await service.singInAnExistingGoogleAccount(idToken: idToken, accessToken: accessToken)
    }
    
    func logOut() async throws {
        try await service.signOut()
        auth = nil
    }
    
    func deleteAccount(idToken: String?, accessToken: String?) async throws{
        try await service.deleteAccount(idToken: idToken, accessToken: accessToken)
        auth = nil
    }
}

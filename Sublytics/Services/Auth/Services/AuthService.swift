//
//  AuthService.swift
//  Sublytics
//
//  Created by pedrosanz on 06/08/26.
//

import Foundation

protocol AuthService: Sendable {
    func authenticatedUserListener(onListenerAttached: (any NSObjectProtocol) -> Void) -> AsyncStream<UserAuthInfo?>
    func getAuthenticatedUser() -> UserAuthInfo?
    func signInAnonymously() async throws -> UserAuthInfo
    func signInGoogle(idtoken: String, accesToken: String) async throws -> UserAuthInfo?
    func singInAnExistingGoogleAccount(idToken: String, accessToken: String) async throws -> UserAuthInfo?
    func signOut() async throws
    func deleteAccount(idToken: String?, accessToken: String?) async throws
}

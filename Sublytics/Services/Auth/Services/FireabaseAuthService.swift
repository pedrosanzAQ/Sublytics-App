//
//  Untitled.swift
//  Sublytics
//
//  Created by pedrosanz on 26/05/26.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import GoogleSignIn

struct FireabaseAuthService: AuthService {
    func authenticatedUserListener(onListenerAttached: (any NSObjectProtocol) -> Void) -> AsyncStream<UserAuthInfo?> {
        AsyncStream { continuation in
            let listener = Auth.auth().addStateDidChangeListener { _, currentUser in
                if let currentUser {
                    let user = UserAuthInfo(user: currentUser)
                    continuation.yield(user)
                } else {
                    continuation.yield(nil)
                }
            }

            onListenerAttached(listener)
        }
    }
    
    func getAuthenticatedUser() -> UserAuthInfo? {
        if let user = Auth.auth().currentUser {
            return UserAuthInfo(user: user)
        }
        return nil
    }
    
    func signInAnonymously() async throws -> UserAuthInfo {
        let result = try await Auth.auth().signInAnonymously()
        let user = UserAuthInfo(user: result.user)
        return user
    }
    
    //linking google
    func signInGoogle(idtoken: String, accesToken: String) async throws -> UserAuthInfo?{
        let credential = GoogleAuthProvider.credential(withIDToken: idtoken, accessToken: accesToken)
        let currentUser = Auth.auth().currentUser
        
        if let currentUser = currentUser, currentUser.isAnonymous {
            do {
                let result = try await currentUser.link(with: credential)
                return UserAuthInfo(user: result.user)
            } catch let error as NSError {
                if error.code == AuthErrorCode.credentialAlreadyInUse.rawValue ||
                    error.code == AuthErrorCode.emailAlreadyInUse.rawValue {
                    
                   throw error
                }
                throw error
            }
        } else {
            let result = try await Auth.auth().signIn(with: credential)
            return UserAuthInfo(user: result.user)
        }
    }
    
    func singInAnExistingGoogleAccount(idToken: String, accessToken: String) async throws -> UserAuthInfo? {
        
        guard let currentUser = Auth.auth().currentUser else { return nil }
        try await currentUser.delete()
        
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
        let result = try await Auth.auth().signIn(with: credential)
        
        return UserAuthInfo(user: result.user)
    }
    
    func signOut() async throws {
        try Auth.auth().signOut()
        GIDSignIn.sharedInstance.signOut()
    }
    
    func deleteAccount(idToken: String?, accessToken: String?) async throws{
        guard let user = Auth.auth().currentUser else {
            print("No user to delete found ")
            return
        }
        
        if user.isAnonymous {
            try await user.delete()
            print("Anonymous account sucellessly deleted")
            return
        }
        
        guard let idToken = idToken, let accessToken = accessToken else {
            throw NSError(domain: "AuthManager", code: 401, userInfo: [NSLocalizedDescriptionKey: "Fresh Google credentials are required to delete this account."])
        }
        
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
        let authResult = try await user.reauthenticate(with: credential)
        try await authResult.user.delete()
        GIDSignIn.sharedInstance.signOut()
        print("Google account deleted successfully.")
    }
    
}

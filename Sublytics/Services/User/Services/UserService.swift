//
//  Untitled.swift
//  Sublytics
//
//  Created by pedrosanz on 18/06/26.
//

import UIKit

protocol UserService: Sendable {
    func saveUser(user: UserModel) async throws
    func daleteUser(userId: String) async throws
    func streamUser(userId: String, onListenerAttached: (any ListenerRegistration) -> Void) -> AsyncStream<UserModel?>
}


struct MockUserService: UserService {
    var currentUser: UserModel?
    
    init(currentUser: UserModel? = UserModel.mock) {
        self.currentUser = currentUser
    }
    
    func streamUser(userId: String, onListenerAttached: (any ListenerRegistration) -> Void) -> AsyncStream<UserModel?> {
        AsyncStream { continuation in
            continuation.yield(currentUser)
        }
    }
    
    func saveUser(user: UserModel) async throws {
        
    }
    
    func daleteUser(userId: String) async throws {
        
    }
}

import FirebaseFirestore
struct FirebaseUserService: UserService {
    
    var collection: CollectionReference {
        Firestore.firestore().collection("users")
    }
    
    func streamUser(userId: String, onListenerAttached: (any ListenerRegistration) -> Void) -> AsyncStream<UserModel?> {
        AsyncStream { continuation in
            let listener = collection.document(userId).addSnapshotListener { snapshot, _ in
                if let snapshot {
                    do {
                        let user = try snapshot.data(as: UserModel.self)
                        continuation.yield(user)
                    } catch {
                        print("Error decodificando usuario: \(error)")
                        continuation.yield(nil)
                    }
                } else {
                    continuation.yield(nil)
                }
            }
            
            onListenerAttached(listener)
        }
    }
    
    func saveUser(user: UserModel) async throws {
        try collection.document(user.userId).setData(from: user, merge: true)
    }
    
    func daleteUser(userId: String) async throws {
        try await collection.document(userId).delete()
    }
}

@Observable
@MainActor
class UserManager {
    private let service: UserService
    private(set) var currentUser: UserModel?
    private var currenteUserListener: ListenerRegistration?
    
    init(service: UserService) {
        self.service = service
        currentUser = nil
    }
    
    func logIn(auth: UserAuthInfo) async throws {
        let user = UserModel(Auth: auth)
        try await service.saveUser(user: user)
        addCurrentUserListener(userId: auth.uid)
    }
    
    func updateUserData(user: UserModel) async throws {
        try await service.saveUser(user: user)
    }
    
    func deleteUserData() async throws {
        guard let userId = currentUser?.userId else {
            print("No userId from currentUser")
            return
        }
        
        currenteUserListener?.remove()
        try await service.daleteUser(userId: userId)
        currentUser = nil
    }
    
    func addCurrentUserListener(userId: String) {
        currenteUserListener?.remove()
        Task {
            for try await value in service.streamUser(userId: userId, onListenerAttached: { listener in
                self.currenteUserListener = listener
            }) {
                self.currentUser = value
                print("Success listener user:  \(value)")
            }
        }
    }
}

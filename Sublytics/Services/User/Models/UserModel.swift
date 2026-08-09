//
//  UserModel.swift
//  Sublytics
//
//  Created by pedrosanz on 18/06/26.
//
import UIKit

struct UserModel: Codable {
    let userId: String
    let email: String?
    let username: String?
    let isAnonymous: Bool?
    let creationDate: Date?
    let lastSignIn: Date?
    
    init(userId: String, email: String?, username: String?, isAnonymous: Bool?, creationDate: Date?, lastSignIn: Date?) {
        self.userId = userId
        self.email = email
        self.username = username
        self.isAnonymous = isAnonymous
        self.creationDate = creationDate
        self.lastSignIn = lastSignIn
    }
    
    init(Auth: UserAuthInfo) {
        self.init(
            userId: Auth.uid,
            email: Auth.email,
            username: Auth.username,
            isAnonymous: Auth.isAnonymous,
            creationDate: Auth.creationDate,
            lastSignIn: Auth.lastSignIn
        )
    }
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case email = "email"
        case username = "username"
        case isAnonymous = "is_anonymous"
        case creationDate = "creation_date"
        case lastSignIn = "last_sign_in"
    }
    
    static var mock: UserModel {
        return mocks[0]
    }
    
    static var mocks: [Self] {
        return [
            UserModel(
                userId: "user1",
                email: "user1@gmail.com",
                username: "user1",
                isAnonymous: false,
                creationDate: Date(),
                lastSignIn: nil,
            ),
            UserModel(
                userId: "user2",
                email: "user2@gmail.com",
                username: "user2",
                isAnonymous: true,
                creationDate: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(),
                lastSignIn: nil,
            ),
            UserModel(
                userId: "user3",
                email: "user3@gmail.com",
                username: "user3",
                isAnonymous: false,
                creationDate: Calendar.current.date(byAdding: .day, value: -5, to: Date()) ?? Date(),
                lastSignIn: nil,
            ),
            UserModel(
                userId: "user4",
                email: "user4@gmail.com",
                username: "user4",
                isAnonymous: true,
                creationDate: Calendar.current.date(byAdding: .day, value: -6, to: Date()) ?? Date(),
                lastSignIn: nil,
            )
        ]
    }
    
}


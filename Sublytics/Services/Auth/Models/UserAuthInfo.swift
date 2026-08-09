//
//  UserAuthInfo.swift
//  Sublytics
//
//  Created by pedrosanz on 06/08/26.
//

import Foundation
import UIKit
import FirebaseAuth


struct UserAuthInfo: Sendable{
    let uid: String
    let email: String?
    let username: String?
    let isAnonymous: Bool?
    let creationDate: Date?
    let lastSignIn: Date?
    
    init(
        uid: String,
        email: String?,
        username: String?,
        isAnonymous: Bool?,
        creationName: Date?,
        lastSignIn: Date?
    ){
        self.uid = uid
        self.email = email
        self.username = username
        self.isAnonymous = isAnonymous
        self.creationDate = creationName
        self.lastSignIn = lastSignIn
    }
    
    init(user: User) {
        self.uid = user.uid
        self.email = user.email
        self.username = user.displayName
        self.isAnonymous = user.isAnonymous
        self.creationDate = user.metadata.creationDate
        self.lastSignIn = user.metadata.lastSignInDate
    }
    
    static var mock = UserAuthInfo(
        uid: "mock-uid",
        email: "mock@mock.com",
        username: "mock",
        isAnonymous: false,
        creationName: Date(),
        lastSignIn: Date()
    )
}

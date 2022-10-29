//
//  UserModel.swift
//  TwitterUIKit
//
//  Created by Maciej on 29/10/2022.
//

import FirebaseCoreInternal
import FirebaseFirestore
import FirebaseCore

struct User: Identifiable, Codable {
    var id: String?
    let email: String
    let username: String
    let fullname: String
    let profileImageUrl: String
}

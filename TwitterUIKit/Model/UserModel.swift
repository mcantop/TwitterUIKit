//
//  UserModel.swift
//  TwitterUIKit
//
//  Created by Maciej on 29/10/2022.
//

import FirebaseFirestoreSwift
import FirebaseAuth

struct User: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    
    let email: String
    var username: String
    var fullname: String
    var profileImageUrl: URL
    
    var bio: String?
    var isFollowed: Bool? = false
    var stats: UserRelationStats?
    
    var isCurrentUser: Bool {
        return Auth.auth().currentUser?.uid == id
    }
}

struct UserRelationStats: Codable, Hashable {
    var following: Int
    var followers: Int
}

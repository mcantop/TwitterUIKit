//
//  UserModel.swift
//  TwitterUIKit
//
//  Created by Maciej on 29/10/2022.
//

import FirebaseFirestoreSwift
import FirebaseAuth

struct User: Identifiable, Codable {
    @DocumentID var id: String?
    let email: String
    let username: String
    let fullname: String
    let profileImageUrl: URL
    
    var isCurrentUser: Bool {
        return Auth.auth().currentUser?.uid == id
    }
}

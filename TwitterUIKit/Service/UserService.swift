//
//  UserService.swift
//  TwitterUIKit
//
//  Created by Maciej on 29/10/2022.
//

import FirebaseAuth
import FirebaseFirestore

struct UserService {
    static let shared = UserService()
    
    func fetchUser(withUid uid: String, completion: @escaping(User) -> Void) {        
        Firestore.firestore().collection("users")
            .document(uid)
            .getDocument { snapshot, _ in
                guard let snapshot = snapshot else { return }
                guard let user = try? snapshot.data(as: User.self) else { return }
                
                completion(user)
            }
    }
}

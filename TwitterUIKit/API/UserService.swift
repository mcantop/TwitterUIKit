//
//  UserService.swift
//  TwitterUIKit
//
//  Created by Maciej on 29/10/2022.
//

import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

struct UserService {
    static let shared = UserService()
    
    func fetchUser(completion: @escaping(User) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        print("DEBUG: Fetching user for uid: \(uid)")
        
        Firestore.firestore().collection("users")
            .document(uid)
            .getDocument { snapshot, _ in
                guard let snapshot = snapshot else { return }
                guard let user = try? snapshot.data(as: User.self) else { return }
                
                completion(user)
            }
    }
}

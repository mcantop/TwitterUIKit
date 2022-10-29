//
//  UserService.swift
//  TwitterUIKit
//
//  Created by Maciej on 29/10/2022.
//

import FirebaseAuth
import FirebaseFirestore
import firebaseFirestore

struct UserService {
    static let shared = UserService()
    
    func fetchUser() {
        print("DEBUG: Fetch user data here.")
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        print("DEBUG: Current uid is: \(uid)")
        
        Firestore.firestore().collection("users")
            .document(uid)
            .getDocument { snapshot, _ in
                guard let snapshot = snapshot else { return }
                guard let user = try? snapshot.data(as: User.self) else { return }
                
                print(user)
            }
    }
    
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

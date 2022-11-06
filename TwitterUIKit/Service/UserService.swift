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
    
    func fetchUsers(completion: @escaping([User]) -> Void) {
        Firestore.firestore().collection("users")
            .getDocuments { snapshot, _ in
                guard let documents = snapshot?.documents else { return }
                
                var users = [User]()
                
                documents.forEach { document in
                    fetchUser(withUid: document.documentID) { user in
                        users.append(user)
                        completion(users)
                    }
                }
            }
    }
    
    func followUser(uid: String, completion: @escaping(Result<Void, Error>) -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }

        let userFollowingRef = Firestore.firestore().collection("users")
            .document(currentUid)
            .collection("user-following")
        
        let userFollowersRef = Firestore.firestore().collection("users")
            .document(uid)
            .collection("user-followers")
        
        userFollowingRef
            .document(uid)
            .setData([:]) { error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                userFollowersRef
                    .document(currentUid)
                    .setData([:]) { error in
                        if let error = error {
                            completion(.failure(error))
                            return
                        }
                        
                        completion(.success(()))
                    }
            }
    }
    
    func unfollowUser(uid: String, completion: @escaping(Result<Void, Error>) -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }

        let userFollowingRef = Firestore.firestore().collection("users")
            .document(currentUid)
            .collection("user-following")
        
        let userFollowersRef = Firestore.firestore().collection("users")
            .document(uid)
            .collection("user-followers")
        
        userFollowingRef
            .document(uid)
            .delete { error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                userFollowersRef
                    .document(currentUid)
                    .delete { error in
                        if let error = error {
                            completion(.failure(error))
                            return
                        }
                        
                        completion(.success(()))
                    }
            }
    }
    
    func checkIfUserIsFollowed(uid: String, completion: @escaping(Bool) -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }

        let userFollowingRef = Firestore.firestore().collection("users")
            .document(currentUid)
            .collection("user-following")
        
        userFollowingRef
            .document(uid)
            .getDocument { snapshot, _ in
                guard let snapshot = snapshot else { return }
                print("DEBUG: User is followed: \(snapshot.exists)")
                completion(snapshot.exists)
            }
    }
    
    func fetchUserStats(uid: String, completion: @escaping(UserRelationStats) -> Void) {
        let userFollowingRef = Firestore.firestore().collection("users")
            .document(uid)
            .collection("user-following")
                
        let userFollowersRef = Firestore.firestore().collection("users")
            .document(uid)
            .collection("user-followers")
        
        
        userFollowingRef
            .getDocuments { snapshot, _ in
                let following = snapshot?.count
                
                userFollowersRef
                    .getDocuments { snapshot, _ in
                        let followers = snapshot?.count
                        
                        let stats = UserRelationStats(following: following!, followers: followers!)
                        completion(stats)
                    }
            }
    }
}

//
//  AuthService.swift
//  TwitterUIKit
//
//  Created by Maciej on 28/10/2022.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

struct AuthCredentials {
    let email: String
    let password: String
    let fullname: String
    let username: String
    let profileImage: UIImage
}

struct AuthService {
    static let shared = AuthService()
    
    func logUserIn(withEmail email: String, password: String, completion: ((AuthDataResult?, Error?) -> Void)?) {
        Auth.auth().signIn(withEmail: email, password: password, completion: completion)
    }
    
    func registerUser(credentials: AuthCredentials, completion: @escaping(Result<Void, Error>) -> Void) {
        guard let imageData = credentials.profileImage.jpegData(compressionQuality: 0.3) else { return }
        let filename = NSUUID().uuidString
        let storageRef = Storage.storage().reference(withPath: "/profile_image/\(filename)")
        
        storageRef.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            storageRef.downloadURL { imageUrl, error in
                guard let profileImageUrl = imageUrl?.absoluteString else { return }
                
                Auth.auth().createUser(withEmail: credentials.email, password: credentials.password) { result, error in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }
                    
                    guard let user = result?.user else { return }
                    
                    let data = ["email": credentials.email,
                                "username": credentials.username,
                                "fullname": credentials.fullname,
                                "profileImageUrl": profileImageUrl]

                    Firestore.firestore().collection("users")
                        .document(user.uid)
                        .setData(data) { error in
                            if let error = error {
                                completion(.failure(error))
                                return
                            }
                            
                            completion(.success(()))
                        }
                }
                
            }
        }
    }
}

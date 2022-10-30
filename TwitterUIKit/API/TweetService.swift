//
//  TweetService.swift
//  TwitterUIKit
//
//  Created by Maciej on 30/10/2022.
//

import FirebaseFirestore
import FirebaseCore
import FirebaseAuth

struct TweetService {
    static let shared = TweetService()
    
    func uploadTweet(caption: String, completion: @escaping(Result<Void, Error>) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let data = ["uid": uid,
//                    "timestamp": Timestamp(date: Date()),
                    "timestamp": Int(Date().timeIntervalSince1970),
                    "caption": caption,
                    "likes": 0,
                    "retweets": 0] as [String: Any]
        
        Firestore.firestore().collection("tweets").document()
            .setData(data) { error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                completion(.success(()))
            }
    }
}

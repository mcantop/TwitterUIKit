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
    
    func fetchTweets(completion: @escaping([Tweet]) -> Void) {
        Firestore.firestore().collection("tweets")
            .order(by: "timestamp", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("DEBUG: Error while fetching tweets with error: \(error.localizedDescription).")
                }
                guard let documents = snapshot?.documents else { return }
                
//                var tweets = [Tweet]()
//
//                documents.forEach { document in
//                    guard let tweet = try? document.data(as: Tweet.self) else { return }
//                    tweets.append(tweet)
//                }
                
                let tweets = documents.compactMap { try? $0.data(as: Tweet.self) }
                
                completion(tweets)
            }
    }
}

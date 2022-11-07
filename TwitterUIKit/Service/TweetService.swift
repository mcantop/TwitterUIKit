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
    
    func uploadTweet(type: UploadTweetConfiguration, caption: String, completion: @escaping(Result<Void, Error>) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let data = ["uid": uid,
                    "timestamp": Timestamp(date: Date()),
                    //                    "timestamp": Int(Date().timeIntervalSince1970),
                    "caption": caption,
                    "likes": 0,
                    "retweets": 0] as [String: Any]
        
        let userTweetsRef = Firestore.firestore().collection("users")
            .document(uid)
            .collection("user-tweets")
        
        let tweetsRef = Firestore.firestore().collection("tweets")
            .document()
        
        switch type {
        case .tweet:
            tweetsRef
                .setData(data) { error in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }
                    
                    userTweetsRef.document(tweetsRef.documentID).setData([:]) { _ in
                        completion(.success(()))
                    }
                }
            
        case .reply(let tweet):
            guard let tweetId = tweet.id else { return }
            
            let tweetRepliesRef = Firestore.firestore().collection("tweets")
                .document(tweetId)
                .collection("tweet-replies")
                
            print(tweetId)
            
            tweetRepliesRef
                .document()
                .setData(data) { error in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }

                    print("DEBUG: REPLIED WITH SUCCESS")

                    completion(.success(()))
                }
            
        }
    }
    
    func fetchTweet(forTweetId tweetId: String, completion: @escaping(Tweet) -> Void) {
        Firestore.firestore().collection("tweets")
            .document(tweetId)
            .getDocument { snapshot, error in
                if let _ = error {
                    return
                }
                
                guard var tweet = try? snapshot?.data(as: Tweet.self) else { return }
                
                UserService.shared.fetchUser(withUid: tweet.uid) { user in
                    tweet.user = user
                    completion(tweet)
                }
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
                
                var tweets = [Tweet]()
                
                documents.forEach { document in
                    guard var tweet = try? document.data(as: Tweet.self) else { return }
                    UserService.shared.fetchUser(withUid: tweet.uid) { user in
                        tweet.user = user
                        tweets.append(tweet)
                        completion(tweets.sorted(by: { $0.timestamp > $1.timestamp }))
                    }
                }
            }
    }
    
    func fetchTweets(forUid uid: String, completion: @escaping([Tweet]) -> Void) {
        Firestore.firestore().collection("users")
            .document(uid)
            .collection("user-tweets")
            .getDocuments { snapshot, error in
                if let error = error {
                    print("DEBUG: Error while fetching tweets with error: \(error.localizedDescription).")
                }
                
                guard let documents = snapshot?.documents else { return }
                                
                var tweets = [Tweet]()
                
                documents.forEach { document in
                    fetchTweet(forTweetId: document.documentID) { tweet in
                        tweets.append(tweet)
                        completion(tweets.sorted(by: { $0.timestamp > $1.timestamp }))
                    }
                }
            }
    }
    
    func fetchReplies(forTweet tweet: Tweet, completion: @escaping([Tweet]) -> Void) {
        guard let tweetId = tweet.id else { return }
        
        Firestore.firestore().collection("tweets")
            .document(tweetId)
            .collection("tweet-replies")
            .getDocuments { snapshot, error in
                if let error = error {
                    print("DEBUG: Error while fetching tweet replies with error: \(error.localizedDescription).")
                }
                
                guard let documents = snapshot?.documents else { return }
                
                var tweets = [Tweet]()
                
                documents.forEach { document in
                    guard var tweet = try? document.data(as: Tweet.self) else { return }
                    UserService.shared.fetchUser(withUid: tweet.uid) { user in
                        tweet.user = user
                        tweets.append(tweet)
                        completion(tweets.sorted(by: { $0.timestamp > $1.timestamp }))
                    }
                }
            }
    }
}

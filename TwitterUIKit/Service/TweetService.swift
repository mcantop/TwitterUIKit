//
//  TweetService.swift
//  TwitterUIKit
//
//  Created by Maciej on 30/10/2022.
//

import FirebaseFirestore
import FirebaseCore
import FirebaseAuth

private let usersRef = Firestore.firestore().collection("users")
private let tweetsRef = Firestore.firestore().collection("tweets")

struct TweetService {
    static let shared = TweetService()
    
    func uploadTweet(type: UploadTweetConfiguration, caption: String, completion: @escaping(Result<Void, Error>) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let data = ["uid": uid,
                    "timestamp": Timestamp(date: Date()),
                    // "timestamp": Int(Date().timeIntervalSince1970),
                    "caption": caption,
                    "likes": 0,
                    "retweets": 0] as [String: Any]
        
        let userTweetsRef = usersRef.document(uid).collection("user-tweets")
        let tweetsDocRef = tweetsRef.document()
        
        switch type {
        case .tweet:
            tweetsDocRef
                .setData(data) { error in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }
                    
                    userTweetsRef.document(tweetsDocRef.documentID).setData([:]) { _ in
                        completion(.success(()))
                    }
                }
        case .reply(let tweet):
            guard let tweetId = tweet.id else { return }
            
            let tweetRepliesRef = tweetsRef.document(tweetId).collection("tweet-replies")
            
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
        tweetsRef.document(tweetId)
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
        tweetsRef.order(by: "timestamp", descending: true)
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
        usersRef.document(uid).collection("user-tweets")
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
        
        tweetsRef.document(tweetId).collection("tweet-replies")
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
    
    func checkIfUserLikedTweet(_ tweet: Tweet, completion: @escaping(Bool) -> Void) {
        guard let tweetId = tweet.id else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let tweetRef = tweetsRef.document(tweetId)
        
        tweetRef.collection("tweet-likes").document(uid)
            .getDocument { snapshot, _ in
                guard let snapshot = snapshot else { return }
                completion(snapshot.exists)
            }
    }
    
    func likeTweet(_ tweet: Tweet, completion: @escaping(Result<Void, Error>) -> Void) {
        guard let tweetId = tweet.id else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let tweetDocRef = tweetsRef.document(tweetId)
        let userDocRef = usersRef.document(uid)
        
        guard let isLiked = tweet.isLiked else { return }
        let likes = isLiked ? tweet.likes - 1 : tweet.likes + 1
        
        tweetDocRef
            .updateData(["likes": likes])
        
        if isLiked {
            tweetDocRef.collection("tweet-likes").document(uid)
                .delete()
            
            userDocRef.collection("user-likes").document(tweetId)
                .delete()
            
            completion(.success(()))
        } else {
            tweetDocRef.collection("tweet-likes").document(uid)
                .setData([:]) { _ in
                    
                    userDocRef.collection("user-likes").document(tweetId)
                        .setData([:]) { _ in
                            
                            completion(.success(()))
                        }
                }
            
        }
    }
    
    func deleteTweet(_ tweet: Tweet, completion: @escaping() -> Void) {
        guard let tweetId = tweet.id else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        tweetsRef.document(tweetId)
            .delete()
        
        usersRef.document(uid).collection("user-tweets").document(tweetId)
            .delete()
        
        completion()
    }
}

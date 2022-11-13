//
//  TweetModel.swift
//  TwitterUIKit
//
//  Created by Maciej on 30/10/2022.
//

import FirebaseCore
import FirebaseFirestoreSwift
import FirebaseFirestore

struct Tweet: Identifiable, Codable {
    @DocumentID var id: String?
    
    let uid: String
    let timestamp: Date
    let caption: String
    
    var likes: Int
    var retweets: Int
    var user: User?
    var isLiked: Bool? = false
    var replyingTo: String?
}

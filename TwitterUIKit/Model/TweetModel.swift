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
    let timestamp: Int
    let caption: String
    let likes: Int
    let retweets: Int
}

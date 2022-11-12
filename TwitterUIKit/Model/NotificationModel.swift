//
//  NotificationModel.swift
//  TwitterUIKit
//
//  Created by Maciej on 08/11/2022.
//

import Foundation

enum NotificationType: Int, Codable {
    case follow
    case like
    case reply
    case retweet
    case mention
}

struct Notification: Codable {
    var user: User?
    let tweetId: String?
    let uid: String
    let type: NotificationType
    
    var tweet: Tweet?
    var timestamp: Date
}

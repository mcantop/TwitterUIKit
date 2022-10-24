//
//  UIImage+Extension.swift
//  TwitterUIKit
//
//  Created by Maciej on 24/10/2022.
//

import UIKit

extension UIImage {
    enum Images {
        case feed
        case explore
        case notifications
        case messages
        case twitterLogoBlue
        case newTweet
        
        var description: String {
            switch self {
            case .feed: return "house"
            case .explore: return "magnifyingglass"
            case .notifications: return "heart"
            case .messages: return "message"
            case .twitterLogoBlue: return "twitter_logo_blue"
            case .newTweet: return "new_tweet"
            }
        }
    }
    
    static let feed = UIImage(systemName: Images.feed.description)
    static let explore = UIImage(systemName: Images.explore.description)
    static let notifications = UIImage(systemName: Images.notifications.description)
    static let messages = UIImage(systemName: Images.messages.description)
    static let twitterLogoBlue = UIImage(named: Images.twitterLogoBlue.description)
    static let newTweet = UIImage(named: Images.newTweet.description)
}

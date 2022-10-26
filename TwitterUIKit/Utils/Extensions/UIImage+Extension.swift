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
        case notification
        case message
        case twitterLogoBlue
        case newTweet
        case twitterLogoWhite
        case lock
        case mail
        case plusPhoto
        case person
        
        var description: String {
            switch self {
            case .feed: return "house"
            case .explore: return "magnifyingglass"
            case .notification: return "heart"
            case .message: return "message"
            case .twitterLogoBlue: return "twitter_logo_blue"
            case .newTweet: return "new_tweet"
            case .twitterLogoWhite: return "TwitterLogo"
            case .lock: return "lock"
            case .mail: return "envelope"
            case .plusPhoto: return "plus_photo"
            case .person: return "person"
            }
        }
    }
    
    static let feed = UIImage(systemName: Images.feed.description)
    static let explore = UIImage(systemName: Images.explore.description)
    static let notification = UIImage(systemName: Images.notification.description)
    static let message = UIImage(systemName: Images.message.description)
    static let twitterLogoBlue = UIImage(named: Images.twitterLogoBlue.description)
    static let twitterLogoWhite = UIImage(named: Images.twitterLogoWhite.description)
    static let newTweet = UIImage(named: Images.newTweet.description)
    static let lock = UIImage(systemName: Images.lock.description)
    static let mail = UIImage(systemName: Images.mail.description)
    static let plusPhoto = UIImage(named: Images.plusPhoto.description)
    static let person = UIImage(systemName: Images.person.description)
}

//
//  TweetViewModel.swift
//  TwitterUIKit
//
//  Created by Maciej on 01/11/2022.
//

import UIKit

struct TweetViewModel {
    let tweet: Tweet
    let user: User?
    
    var profileImageUrl: URL? {
        return user?.profileImageUrl
    }
    
    var userInfoText: NSAttributedString {
        let title = NSMutableAttributedString(string: user?.fullname ?? "",
                                              attributes: [.font: UIFont.boldSystemFont(ofSize: 14)])
        
        title.append(NSAttributedString(string: " @\(user?.username.lowercased() ?? "")",
                                        attributes: [.font: UIFont.systemFont(ofSize: 14), .foregroundColor: UIColor.lightGray]))
        
        title.append(NSAttributedString(string: " · \(timestamp)",
                                        attributes: [.font: UIFont.systemFont(ofSize: 14), .foregroundColor: UIColor.lightGray]))
                
        return title
    }
    
    var timestamp: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.second, .minute, .hour, .day, .weekOfMonth]
        formatter.maximumUnitCount = 1
        formatter.unitsStyle = .abbreviated

        let now = Date()
        return formatter.string(from: tweet.timestamp, to: now) ?? ""
    }
    
    init(tweet: Tweet) {
        self.tweet = tweet
        self.user = tweet.user
    }
}

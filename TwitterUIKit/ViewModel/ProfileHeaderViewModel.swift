//
//  ProfileHeaderViewModel.swift
//  TwitterUIKit
//
//  Created by Maciej on 04/11/2022.
//

import UIKit

enum ProfileFilterOptions: Int, CaseIterable {
    case tweets
    case replies
    case likes
    
    var description: String {
        switch self {
        case .tweets: return "Tweets"
        case .replies: return "Tweets & Replies"
        case .likes: return "Likes"
        }
    }
}

struct ProfileHeaderViewModel {
    private var user: User
    
    init(user: User) {
        self.user = user
    }
    
    var username: String {
        return "@\(user.username)"
    }
    
    var followingString: NSAttributedString? {
        return attributedText(withValue: user.stats?.following ?? 0, text: "following")
    }
    
    var followersString: NSAttributedString? {
        return attributedText(withValue: user.stats?.followers ?? 0, text: "followers")
    }
    
    var actionButtonTitle: String {
        guard let isFollowed = user.isFollowed else { return "" }
        
        if user.isCurrentUser { return "Edit Profile" }
        
        if !isFollowed && !user.isCurrentUser { return "Follow" }
        
        if isFollowed { return "Unfollow" }
        
        return ""
    }
    
    fileprivate func attributedText(withValue value: Int, text: String) -> NSAttributedString {
        let attributedTitle = NSMutableAttributedString(string: "\(value)",
                                                        attributes: [.font: UIFont.boldSystemFont(ofSize: 14)])
        
        attributedTitle.append(NSAttributedString(string: " \(text)",
                                                  attributes: [.font: UIFont.systemFont(ofSize: 14), .foregroundColor: UIColor.lightGray]))
        
        return attributedTitle
    }
}

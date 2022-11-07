//
//  ActionSheetViewModel.swift
//  TwitterUIKit
//
//  Created by Maciej on 06/11/2022.
//

import Foundation

enum ActionSheetOptions {
    case follow(User)
    case unfollow(User)
    case report
    case delete
    
    var description: String {
        switch self {
        case .follow(let user): return "Follow @\(user.username)"
        case .unfollow(let user): return "Unfollow @\(user.username)"
        case .report: return "Report Tweet"
        case .delete: return "Delete Tweet"
        }
    }
}

struct ActionSheetViewModel {
    private let user: User
    var options: [ActionSheetOptions] {
        var results = [ActionSheetOptions]()
        
        if user.isCurrentUser {
            results.append(.delete)
        } else {
            if let isFollowed = user.isFollowed {
                let followOption: ActionSheetOptions = isFollowed ? .unfollow(user) : .follow(user)
                results.append(followOption)
            }
        }
        
        results.append(.report)
        
        return results
    }
    
    init(user: User) {
        self.user = user
    }
}

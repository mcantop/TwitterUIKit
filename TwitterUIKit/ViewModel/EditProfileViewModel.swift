//
//  EditProfileViewModel.swift
//  TwitterUIKit
//
//  Created by Maciej on 13/11/2022.
//

import Foundation

enum EditProfileOption: Int, CaseIterable {
    case fullname
    case username
    case bio
    
    var description: String {
        switch self {
        case .fullname: return "Fullname"
        case .username: return "Username"
        case .bio: return "Bio"
        }
    }
}

struct EditProfileViewModel {
    private let user: User
    let option: EditProfileOption
    
    var shouldHideTextField: Bool {
        return option == .bio
    }
    
    var shouldHideTextView: Bool {
        return option != .bio
    }
    
    init(user: User, option: EditProfileOption) {
        self.user = user
        self.option = option
    }
}

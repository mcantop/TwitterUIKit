//
//  EditProfileFooter.swift
//  TwitterUIKit
//
//  Created by Maciej on 14/11/2022.
//

import UIKit

protocol EditProfileFooterDelegate: AnyObject {
 func handleLogout()
}

final class EditProfileFooter: UIView {
    // MARK: - Properties
    weak var delegate: EditProfileFooterDelegate?
    
    private lazy var logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.setImage(UIImage(systemName: "door.left.hand.open"), for: .normal)
        button.tintColor = .white
        button.setTitle(" Logout", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .twitterBlue
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(handleLogout), for: .touchUpInside)
       return button
    }()
    
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(logoutButton)
        
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            logoutButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            logoutButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            logoutButton.heightAnchor.constraint(equalToConstant: 50),
            logoutButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32),
            logoutButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Selectors
    @objc
    private func handleLogout() {
        delegate?.handleLogout()
    }
}

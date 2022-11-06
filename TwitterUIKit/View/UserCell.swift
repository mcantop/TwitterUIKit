//
//  UserCell.swift
//  TwitterUIKit
//
//  Created by Maciej on 05/11/2022.
//

import UIKit

final class UserCell: UITableViewCell {
    // MARK: - Properties
    static let reuseIdentifier = "UserCell"
    
    var user: User? {
        didSet {
            configure()
        }
    }
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 40 / 2
        imageView.backgroundColor = .twitterBlue
        return imageView
    }()
    
    private let nameStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 2
        return stack
    }()
    
    private let fullnameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.numberOfLines = 0
        label.text = "Fullname"
        return label
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.systemGray
        label.numberOfLines = 0
        label.text = "@username"
        return label
    }()
    
    // MARK: - Lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupUI()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
    
    private func setupUI() {
        addSubview(profileImageView)
        addSubview(nameStack)
        
        nameStack.addArrangedSubview(fullnameLabel)
        nameStack.addArrangedSubview(usernameLabel)
    }
    
    private func setupLayout() {
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        nameStack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            profileImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            profileImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            profileImageView.heightAnchor.constraint(equalToConstant: 40),
            profileImageView.widthAnchor.constraint(equalToConstant: 40),
            nameStack.centerYAnchor.constraint(equalTo: centerYAnchor),
            nameStack.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 8),
            nameStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
        ])
    }
    
    private func configure() {
        guard let user = user else { return }
        
        profileImageView.sd_setImage(with: user.profileImageUrl)
        fullnameLabel.text = user.fullname
        usernameLabel.text = "@\(user.username)"
    }
}

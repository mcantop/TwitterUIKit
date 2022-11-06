//
//  TweetHeader.swift
//  TwitterUIKit
//
//  Created by Maciej on 06/11/2022.
//

import UIKit

final class TweetHeader: UICollectionReusableView {
    // MARK: - Properties
    static let reuseIdentifier = "TweetHeader"
    
    private lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.setDimensions(width: 48, height: 48)
        imageView.layer.cornerRadius = 48 / 2
        imageView.backgroundColor = .twitterBlue
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleProfileImageTapped))
        imageView.addGestureRecognizer(tap)
        imageView.isUserInteractionEnabled = true
        
        return imageView
    }()
    
    private let userDetailsStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        stackView.spacing = -4
        return stackView
    }()
    
    private let fullnameLabel: UILabel = {
        let label = UILabel()
        label.text = "FUTURE HENDRIX"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.text = "@future"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .lightGray
        return label
    }()
    
    private let captionLabel: UILabel = {
        let label = UILabel()
        label.text = "She belong to the streets"
        label.font = UIFont.systemFont(ofSize: 20)
        label.numberOfLines = 0
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.text = "6:33 PM - 1/28/2020"
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .left
        return label
    }()
    
    private lazy var optionsButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .lightGray
        button.setImage(UIImage.chevronDown, for: .normal)
        button.addTarget(self, action: #selector(showActionSheet), for: .touchUpInside)
        return button
    }()
    
    private let divider1: UIView = {
        let divider = UIView()
        divider.backgroundColor = .systemGroupedBackground
        divider.translatesAutoresizingMaskIntoConstraints = false
        divider.heightAnchor.constraint(equalToConstant: 1.0).isActive = true
        return divider
    }()
    
    private let statsView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        return stack
    }()
    
    private let retweetsLabel: UILabel = {
        let label = UILabel()
        label.text = "0 Retweets"
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    private let likesLabel: UILabel = {
        let label = UILabel()
        label.text = "0 Likes"
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    private let divider2: UIView = {
        let divider = UIView()
        divider.backgroundColor = .systemGroupedBackground

        divider.translatesAutoresizingMaskIntoConstraints = false
        divider.heightAnchor.constraint(equalToConstant: 1.0).isActive = true
        return divider
    }()
    
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Selectors
    private func setupUI() {
        addSubview(profileImageView)
        addSubview(userDetailsStack)
        addSubview(optionsButton)
        addSubview(captionLabel)
        addSubview(dateLabel)
        addSubview(statsView)
        
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 16
        stack.addArrangedSubview(retweetsLabel)
        stack.addArrangedSubview(likesLabel)
        stack.addArrangedSubview(UIView())
        
        statsView.addArrangedSubview(divider1)
        statsView.addArrangedSubview(stack)
        statsView.addArrangedSubview(divider2)
        
        userDetailsStack.addArrangedSubview(fullnameLabel)
        userDetailsStack.addArrangedSubview(usernameLabel)
    }
    
    private func setupLayout() {
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        userDetailsStack.translatesAutoresizingMaskIntoConstraints = false
        captionLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        optionsButton.translatesAutoresizingMaskIntoConstraints = false
        statsView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            profileImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            
            userDetailsStack.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            userDetailsStack.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 8),
            userDetailsStack.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            
            optionsButton.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            optionsButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            optionsButton.centerYAnchor.constraint(equalTo: userDetailsStack.centerYAnchor),
            
            captionLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 16),
            captionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            
            dateLabel.topAnchor.constraint(equalTo: captionLabel.bottomAnchor, constant: 16),
            dateLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            
            statsView.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 16),
            statsView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            statsView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
        ])
    }
    
    @objc
    private func handleProfileImageTapped() {
        
    }
    
    @objc
    private func showActionSheet() {
        
    }
}

//
//  TweetCell.swift
//  TwitterUIKit
//
//  Created by Maciej on 30/10/2022.
//

import UIKit

final class TweetCell: UICollectionViewCell {
    // MARK: - Properties
    static let reuseIdentifier = "TweetCell"
    
    var tweet: Tweet? {
        didSet { configure() }
    }
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.setDimensions(width: 48, height: 48)
        imageView.layer.cornerRadius = 48 / 2
        imageView.backgroundColor = .twitterBlue
        return imageView
    }()
    
    private let stack = UIStackView()
    private let infoLabel = UILabel()
    private let captionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 0
        label.text = "She belong to the streets"
        return label
    }()
    
    let actionStack = UIStackView()
    
    private lazy var commentButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "comment"), for: .normal)
        button.tintColor = .darkGray
        button.setDimensions(width: 20, height: 20)
        button.addTarget(self, action: #selector(handleCommentTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var retweetButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "retweet"), for: .normal)
        button.tintColor = .darkGray
        button.setDimensions(width: 20, height: 20)
        button.addTarget(self, action: #selector(handleRetweetTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var likeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "like"), for: .normal)
        button.tintColor = .darkGray
        button.setDimensions(width: 20, height: 20)
        button.addTarget(self, action: #selector(handleLikeTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var shareButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "share"), for: .normal)
        button.tintColor = .darkGray
        button.setDimensions(width: 20, height: 20)
        button.addTarget(self, action: #selector(handleShareTapped), for: .touchUpInside)
        return button
    }()
    
    private let underlineView = UIView()
    
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        stack.axis = .vertical
        stack.distribution = .fillProportionally
        stack.spacing = 4
        stack.addArrangedSubview(infoLabel)
        stack.addArrangedSubview(captionLabel)
        
        infoLabel.font = UIFont.systemFont(ofSize: 14)
        infoLabel.text = "KING PLUTO @future"
        
        underlineView.backgroundColor = .systemGroupedBackground
        
        actionStack.axis = .horizontal
        actionStack.distribution = .fillProportionally
        actionStack.spacing = 72
        actionStack.addArrangedSubview(commentButton)
        actionStack.addArrangedSubview(retweetButton)
        actionStack.addArrangedSubview(likeButton)
        actionStack.addArrangedSubview(shareButton)
        
        addSubview(profileImageView)
        addSubview(stack)
        addSubview(actionStack)
        addSubview(underlineView)
        
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Selectors
    private func setupLayout() {
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        underlineView.translatesAutoresizingMaskIntoConstraints = false
        stack.translatesAutoresizingMaskIntoConstraints = false
        actionStack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            profileImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            
            stack.topAnchor.constraint(equalTo: profileImageView.topAnchor),
            stack.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 8),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            actionStack.centerXAnchor.constraint(equalTo: centerXAnchor),
            actionStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            
            underlineView.leadingAnchor.constraint(equalTo: leadingAnchor),
            underlineView.trailingAnchor.constraint(equalTo: trailingAnchor),
            underlineView.bottomAnchor.constraint(equalTo: bottomAnchor),
            underlineView.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
    
    @objc
    private func handleCommentTapped() {
        
    }
    
    @objc
    private func handleRetweetTapped() {
        
    }
    
    @objc
    private func handleLikeTapped() {
        
    }
    
    @objc
    private func handleShareTapped() {
        
    }
    
    // MARK: - Helpers
    func configure() {
        guard let tweet = tweet else { return }
        
        captionLabel.text = tweet.caption
    }
}

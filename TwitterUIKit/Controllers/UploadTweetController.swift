//
//  UploadTweetController.swift
//  TwitterUIKit
//
//  Created by Maciej on 29/10/2022.
//

import UIKit

final class UploadTweetController: UIViewController {
    // MARK: - Properties
    private let user: User
    private let config: UploadTweetConfiguration
    private lazy var viewModel = UploadTweetViewModel(config: config)
    
    private lazy var actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .twitterBlue
        button.setTitle("Tweet", for: .normal)
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(.white, for: .normal)
        button.frame = CGRect(x: 0, y: 0, width: 64, height: 32)
        button.layer.cornerRadius = 32 / 2
        button.addTarget(self, action: #selector(handleUploadTweet), for: .touchUpInside)
        return button
    }()
    
    private let profileImageView: UIImageView = {
       let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.setDimensions(width: 48, height: 48)
        imageView.layer.cornerRadius = 48 / 2
        imageView.backgroundColor = .twitterBlue
        return imageView
    }()
    
    private lazy var replyLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .lightGray
        label.widthAnchor.constraint(equalToConstant: view.frame.width).isActive = true
        label.text = "replying to @future"
        return label
    }()
    
    private let captionTextView = CaptionTextView()
    
    // MARK: - Lifecycle
    init(user: User, config: UploadTweetConfiguration) {
        self.user = user
        self.config = config
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        configureLayout()
        
        switch config {
        case .tweet:
            print("DEBUG: Config is tweet")
        case .reply(let tweet):
            print("DEBUG: Replying to \(tweet.caption)")
        }
    }
    
    // MARK: - Selectors
    @objc
    private func handleCancel() {
        dismiss(animated: true)
    }
    
    @objc
    private func handleUploadTweet() {
        guard let caption = captionTextView.text else { return }
        
        TweetService.shared.uploadTweet(caption: caption) { result in
            switch result {
            case .failure(let error):
                print("DEBUG: Failed to upload a tweet with error: \(error.localizedDescription).")
            case .success:
                self.dismiss(animated: true)
            }
        }
    }
    
    // MARK: - API
    
    // MARK: - Helpers
    private func configureUI() {
        view.backgroundColor = .white
        
        configureNavigationBar()
        
        view.addSubview(replyLabel)
        view.addSubview(profileImageView)
        view.addSubview(captionTextView)
        
        profileImageView.sd_setImage(with: user.profileImageUrl)
        actionButton.setTitle(viewModel.actionButtonTitle, for: .normal)
        captionTextView.placeholderLabel.text = viewModel.placeholderText
        replyLabel.isHidden = !viewModel.shouldshowReplyLabel
        guard let replyText = viewModel.replyText else { return }
        replyLabel.text = replyText
    }
    
    private func configureLayout() {
        replyLabel.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        captionTextView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            replyLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            replyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            profileImageView.topAnchor.constraint(equalTo: replyLabel.bottomAnchor, constant: 16),
            profileImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            captionTextView.topAnchor.constraint(equalTo: replyLabel.bottomAnchor, constant: 16),
            captionTextView.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 8),
            captionTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            captionTextView.heightAnchor.constraint(equalToConstant: (UIScreen.main.bounds.height - (UIScreen.main.bounds.height / 2)))
        ])
    }
    
    private func configureNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleCancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: actionButton)
    }
}

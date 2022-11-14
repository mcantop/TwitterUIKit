//
//  UploadTweetController.swift
//  TwitterUIKit
//
//  Created by Maciej on 29/10/2022.
//

import UIKit
import ActiveLabel

protocol UploadTweetControllerDelegate: AnyObject {
    func reloadTableAfterTweetUpload()
}

final class UploadTweetController: UIViewController {
    // MARK: - Properties
    private let user: User
    private let config: UploadTweetConfiguration
    private lazy var viewModel = UploadTweetViewModel(config: config)
    
    weak var delegate: UploadTweetControllerDelegate?

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
    
    private let stack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        return stack
    }()
    
    private let imageTextViewStack: UIStackView = {
        let imageTextViewStack = UIStackView()
        imageTextViewStack.axis = .horizontal
        imageTextViewStack.alignment = .leading
        imageTextViewStack.spacing = 12
        return imageTextViewStack
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
    
    private lazy var replyLabel: ActiveLabel = {
        let label = ActiveLabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        label.widthAnchor.constraint(equalToConstant: view.frame.width).isActive = true
        label.mentionColor = .twitterBlue
        return label
    }()
    
    private let captionTextView = InputTextView()
    
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
        configureMentionHandler()
        
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
        
        TweetService.shared.uploadTweet(type: config, caption: caption) { result in
            switch result {
            case .failure(let error):
                print("DEBUG: Failed to upload a tweet with error: \(error.localizedDescription).")
            case .success:
                self.delegate?.reloadTableAfterTweetUpload()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    if case .reply(let tweet) = self.config {
                        guard let user = tweet.user else { return }
                        NotificationService.shared.uploadNotification(toUser: user, type: .reply, tweetId: tweet.id)
                    }
                    
                    self.dismiss(animated: true)
                }
            }
        }
    }
    
    // MARK: - Helpers
    private func configureUI() {
        view.backgroundColor = .white
        
        configureNavigationBar()
        
        imageTextViewStack.addArrangedSubview(profileImageView)
        imageTextViewStack.addArrangedSubview(captionTextView)
        
        stack.addArrangedSubview(replyLabel)
        stack.addArrangedSubview(imageTextViewStack)
        
        view.addSubview(stack)
        
        profileImageView.sd_setImage(with: user.profileImageUrl)
        actionButton.setTitle(viewModel.actionButtonTitle, for: .normal)
        captionTextView.placeholderLabel.text = viewModel.placeholderText
        
        replyLabel.isHidden = !viewModel.shouldshowReplyLabel
        guard let replyText = viewModel.replyText else { return }
        replyLabel.text = replyText
    }
    
    private func configureLayout() {
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
    }
    
    private func configureNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleCancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: actionButton)
    }
    
    private func configureMentionHandler() {
        replyLabel.handleMentionTap { mention in
            print("DEBUG: Mentioned user is \(mention)")
        }
    }
}



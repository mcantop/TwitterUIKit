//
//  ProfileHeader.swift
//  TwitterUIKit
//
//  Created by Maciej on 04/11/2022.
//

import UIKit

protocol ProfileHeaderDelegate: AnyObject {
    func handleDismiss()
    func handleEditProfileFollow(_ header: ProfileHeader)
}

final class ProfileHeader: UICollectionReusableView {
    // MARK: - Properties
    static let headerIdentifier = "ProfileHeader"
    
    weak var delegate: ProfileHeaderDelegate?
    
    var user: User? {
        didSet {
            configure()
        }
    }
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .twitterBlue
        view.addSubview(backButton)
        return view
    }()
    
    private var attributedString: NSAttributedString {
        let title = NSMutableAttributedString(string: " Back", attributes: [.font: UIFont.boldSystemFont(ofSize: 14)])
        
        return title
    }
    
    private lazy var backButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage.chevronLeft,for: .normal)
        button.setAttributedTitle(attributedString, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        return button
    }()
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .lightGray
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = 4
        return imageView
    }()
    
    lazy var editProfileFollowButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Loading", for: .normal)
        button.layer.borderColor = UIColor.twitterBlue.cgColor
        button.layer.borderWidth = 1.25
        button.setTitleColor(.twitterBlue, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(handleEditProfileFollow), for: .touchUpInside)
        return button
    }()
    
    private let userDetailsStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        stackView.spacing = 4
        return stackView
    }()
    
    private let fullnameLabel: UILabel = {
        let label = UILabel()
        label.text = "FUTURE HENDRIX"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        return label
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.text = "@future"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .lightGray
        return label
    }()
    
    private let bioLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 3
        label.text = "This is a user bio that will span more than one line for test purposes"
        return label
    }()
    
    private let followStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    private lazy var followingLabel: UILabel = {
        let label = UILabel()
        label.text = "0 Following"
        let followTap = UITapGestureRecognizer(target: self, action: #selector(handleFollowingTapped))
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(followTap)
        return label
    }()
    
    private lazy var followersLabel: UILabel = {
        let label = UILabel()
        label.text = "0 Followers"
        let followTap = UITapGestureRecognizer(target: self, action: #selector(handleFollowersTapped))
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(followTap)
        return label
    }()
    
    private let filterBar = ProfileFilterView()
    
    private let underlineView: UIView = {
        let view = UIView()
        view.backgroundColor = .twitterBlue
        return view
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
    @objc
    private func handleDismiss() {
        delegate?.handleDismiss()
    }
    
    @objc
    private func handleEditProfileFollow() {
        delegate?.handleEditProfileFollow(self)
    }
    
    @objc
    private func handleFollowingTapped() {
        
    }
    
    @objc
    private func handleFollowersTapped() {
        
    }
    
    // MARK: - Helpers
    private func configure() {
        guard let user = user else { return }
        
        let viewModel = ProfileHeaderViewModel(user: user)
        
        profileImageView.sd_setImage(with: user.profileImageUrl)
        
        editProfileFollowButton.setTitle(viewModel.actionButtonTitle, for: .normal)
        
        fullnameLabel.text = user.fullname
        usernameLabel.text = viewModel.username
        
        followingLabel.attributedText = viewModel.followingString
        followersLabel.attributedText = viewModel.followersString
    }
    
    private func setupUI() {
        addSubview(containerView)
        addSubview(profileImageView)
        addSubview(editProfileFollowButton)
        addSubview(userDetailsStack)
        addSubview(followStack)
        addSubview(filterBar)
        addSubview(underlineView)
        
        userDetailsStack.addArrangedSubview(fullnameLabel)
        userDetailsStack.addArrangedSubview(usernameLabel)
        userDetailsStack.addArrangedSubview(bioLabel)
        
        followStack.addArrangedSubview(followingLabel)
        followStack.addArrangedSubview(followersLabel)
        
        profileImageView.layer.cornerRadius = 80 / 2
        editProfileFollowButton.layer.cornerRadius = 36 / 2
        
        filterBar.delegate = self
    }
    
    private func setupLayout() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        backButton.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        editProfileFollowButton.translatesAutoresizingMaskIntoConstraints = false
        userDetailsStack.translatesAutoresizingMaskIntoConstraints = false
        filterBar.translatesAutoresizingMaskIntoConstraints = false
        underlineView.translatesAutoresizingMaskIntoConstraints = false
        followStack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 124),
            
            backButton.topAnchor.constraint(equalTo: topAnchor, constant: 58),
            backButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            
            profileImageView.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -24),
            profileImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            profileImageView.heightAnchor.constraint(equalToConstant: 80),
            profileImageView.widthAnchor.constraint(equalToConstant: 80),
            
            editProfileFollowButton.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 16),
            editProfileFollowButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            editProfileFollowButton.heightAnchor.constraint(equalToConstant: 36),
            editProfileFollowButton.widthAnchor.constraint(equalToConstant: 100),
            
            userDetailsStack.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 8),
            userDetailsStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            userDetailsStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            followStack.topAnchor.constraint(equalTo: userDetailsStack.bottomAnchor, constant: 8),
            followStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            
            filterBar.leadingAnchor.constraint(equalTo: leadingAnchor),
            filterBar.trailingAnchor.constraint(equalTo: trailingAnchor),
            filterBar.bottomAnchor.constraint(equalTo: bottomAnchor),
            filterBar.heightAnchor.constraint(equalToConstant: 50),
            
            underlineView.leadingAnchor.constraint(equalTo: leadingAnchor),
            underlineView.bottomAnchor.constraint(equalTo: bottomAnchor),
            underlineView.heightAnchor.constraint(equalToConstant: 2),
            underlineView.widthAnchor.constraint(equalToConstant: frame.width / 3)
        ])
    }
}

// MARK: - ProfileFilterViewDelegate
extension ProfileHeader: ProfileFilterViewDelegate {
    func filterView(_ view: ProfileFilterView, didSelect indexPath: IndexPath) {
        guard let cell = view.collectionView.cellForItem(at: indexPath) as? ProfileFilterCell else { return }
        
        let xPosition = cell.frame.origin.x
        UIView.animate(withDuration: 0.3) {
            self.underlineView.frame.origin.x = xPosition
        }
    }
}

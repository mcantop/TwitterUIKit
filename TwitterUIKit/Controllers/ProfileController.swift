//
//  ProfileController.swift
//  TwitterUIKit
//
//  Created by Maciej on 03/11/2022.
//

import UIKit

final class ProfileController: UICollectionViewController {
    // MARK: - Properties
    private var user: User
    
    private var tweets = [Tweet]()
    private var replies = [Tweet]()
    private var likes = [Tweet]()
    
    private var currentDataSource: [Tweet] {
        switch selectedFilter {
        case .tweets: return tweets
        case .replies: return replies
        case .likes: return likes
        }
    }
    
    private var selectedFilter: ProfileFilterOption = .tweets {
        didSet { collectionView.reloadData() }
    }
    
    // MARK: - Lifecycle
    init(user: User) {
        self.user = user
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchUserTweets()
        fetchUserReplies()
        fetchUserLikedTweets()
        configureCollectionView()
        checkIfUserIsFollowed()
        checkFollowingFollowers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    // MARK: - API
    private func fetchUserTweets() {
        guard let uid = user.id else { return }
                
        TweetService.shared.fetchTweets(forUid: uid) { tweets in
            self.tweets = tweets
            self.collectionView.reloadData()
        }
    }
    
    private func fetchUserReplies() {        
        TweetService.shared.fetchUserTweetReplies(forUser: user) { tweets in
            self.replies = tweets
            
            self.replies.forEach { reply in
                print("DEBUG: Replying to \(reply.replyingTo)")
            }
        }
    }
    
    private func fetchUserLikedTweets() {
        TweetService.shared.fetchLikedTweets(forUser: user) { tweets in
            self.likes = tweets
        }
    }
    
    private func checkIfUserIsFollowed() {
        guard let uid = user.id else { return }
        
        UserService.shared.checkIfUserIsFollowed(uid: uid) { isFollowed in
            if isFollowed {
                self.user.isFollowed = true
                self.collectionView.reloadData()

            } else {
                self.user.isFollowed = false
                self.collectionView.reloadData()

            }
            self.collectionView.reloadData()
        }
    }
    
    private func checkFollowingFollowers() {
        guard let uid = user.id else { return }
        
        UserService.shared.fetchUserStats(uid: uid) { stats in
            self.user.stats = stats
            self.collectionView.reloadData()
        }
    }
    
    // MARK: - Selectors
    private func configureCollectionView() {
        collectionView.backgroundColor = .white
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.register(TweetCell.self, forCellWithReuseIdentifier: TweetCell.reuseIdentifier)
        collectionView.register(ProfileHeader.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: ProfileHeader.headerIdentifier)
        
        guard let tabHeight = tabBarController?.tabBar.frame.height else { return }
        collectionView.contentInset.bottom = tabHeight
    }
}

// MARK: - UICollectionViewDataSource 
extension ProfileController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentDataSource.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TweetCell.reuseIdentifier, for: indexPath) as! TweetCell
        
        cell.tweet = currentDataSource[indexPath.row]
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension ProfileController {
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: ProfileHeader.headerIdentifier, for: indexPath) as! ProfileHeader
        header.user = user
        header.delegate = self
        return header
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ProfileController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 370)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let viewModel = TweetViewModel(tweet: currentDataSource[indexPath.row])
        let height = viewModel.size(forWidth: view.frame.width).height
        
        return CGSize(width: view.frame.width,
                      height: height > 100 ? height + 55 : height + 90)
    }
}

// MARK: - ProfileHeaderDelegate
extension ProfileController: ProfileHeaderDelegate {
    func didSelect(filter: ProfileFilterOption) {
        self.selectedFilter = filter
    }
    
    func handleEditProfileFollow(_ header: ProfileHeader) {
        guard let uid = user.id else { return }
        guard let isFollowed = user.isFollowed else { return }
        
        if user.isCurrentUser {
            print("DEBUG: Handle edit profile here.")
            return
        }
        
        if isFollowed {
            UserService.shared.unfollowUser(uid: uid) { result in
                switch result {
                case .failure(let error):
                    print("DEBUG: An error occured while trying to unfollow a user with error: \(error.localizedDescription)")
                case .success:
                    print("DEBUG: Successfully unfollowed a user.")
                    self.user.isFollowed = false
                    header.editProfileFollowButton.setTitle("Follow", for: .normal)
                    self.checkFollowingFollowers()
                }
            }
        } else {
            UserService.shared.followUser(uid: uid) { result in
                switch result {
                case .failure(let error):
                    print("DEBUG: An error occured while trying to follow a user with error: \(error.localizedDescription)")
                case .success():
                    print("DEBUG: Successfully followed a user.")
                    self.user.isFollowed = true
                    header.editProfileFollowButton.setTitle("Unfollow", for: .normal)
                    NotificationService.shared.uploadNotification(type: .follow, user: self.user)
                    self.checkFollowingFollowers()
                }
            }
        }
        
    }
    
    func handleDismiss() {
        navigationController?.popViewController(animated: true)
    }
}

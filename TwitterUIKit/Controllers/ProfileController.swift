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
    
    private var tweets = [Tweet]() {
        didSet {
            collectionView.reloadData()
        }
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
        configureCollectionView()
        checkIfUserIsFollowed()
        checkFollowingFollowers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    // MARK: - Selectors
    private func configureCollectionView() {
        collectionView.backgroundColor = .white
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.register(TweetCell.self, forCellWithReuseIdentifier: TweetCell.reuseIdentifier)
        collectionView.register(ProfileHeader.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: ProfileHeader.headerIdentifier)
    }
    
    // MARK: - API
    private func fetchUserTweets() {
        guard let uid = user.id else { return }
                
        TweetService.shared.fetchTweets(forUid: uid) { tweets in
            self.tweets = tweets
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
}

// MARK: - UICollectionViewDataSource 
extension ProfileController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tweets.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TweetCell.reuseIdentifier, for: indexPath) as! TweetCell
        
        cell.tweet = tweets[indexPath.row]
        
        return cell
    }
}

// MARK: UICollectionViewDelegate
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
        let viewModel = TweetViewModel(tweet: tweets[indexPath.row])
        let height = viewModel.size(forWidth: view.frame.width).height
        
        return CGSize(width: view.frame.width,
                      height: height > 100 ? height + 55 : height + 90)
    }
}

extension ProfileController: ProfileHeaderDelegate {
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
                    self.checkFollowingFollowers()
                }
            }
        }
    }
    
    func handleDismiss() {
        navigationController?.popViewController(animated: true)
    }
}

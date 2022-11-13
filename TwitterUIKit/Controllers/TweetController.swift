//
//  TweetController.swift
//  TwitterUIKit
//
//  Created by Maciej on 06/11/2022.
//

import UIKit

final class TweetController: UICollectionViewController {
    // MARK: - Properties
    private let tweet: Tweet
    private var actionSheetLauncher: ActionSheetLauncher?
    private var replies = [Tweet]() {
        didSet { collectionView.reloadData() }
    }
    
    // MARK: - Lifecycle
    init(tweet: Tweet) {
        self.tweet = tweet
//        self.actionSheetLauncher = ActionSheetLauncher(user: tweet.user!)
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureCollectionView()
        fetchReplies()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.barStyle = .default
    }
    
    // MARK: - Helpers
    private func configureCollectionView() {
        collectionView.backgroundColor = .white
        
        collectionView.register(TweetCell.self, forCellWithReuseIdentifier: TweetCell.reuseIdentifier)
        collectionView.register(TweetHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TweetHeader.reuseIdentifier)
    }
    
    private func showActionSheet(forUser user: User) {
        actionSheetLauncher = ActionSheetLauncher(user: user)
        actionSheetLauncher?.delegate = self
        actionSheetLauncher?.show()
    }
    
    // MARK: - API
    private func fetchReplies() {        
        TweetService.shared.fetchReplies(forTweet: tweet) { replies in
            self.replies = replies
        }
    }
}

// MARK: - UICollectionViewDataSource
extension TweetController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return replies.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TweetCell.reuseIdentifier, for: indexPath) as! TweetCell
        
        cell.tweet = replies[indexPath.row]
        
        return cell
    }
}

// MARK: UICollectionViewDelegate
extension TweetController {
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TweetHeader.reuseIdentifier, for: indexPath) as! TweetHeader
        
        header.tweet = tweet
        header.delegate = self
        
        return header
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension TweetController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let viewModel = TweetViewModel(tweet: tweet)
        let height = viewModel.size(forWidth: view.frame.width).height
        
        return CGSize(width: view.frame.width,
                      height: height > 100 ? height + 270 : height + 230)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 120)
    }
}

// MARK: - TweetHeaderDelegate
extension TweetController: TweetHeaderDelegate {
    func showActionSheet() {
        guard let tweetUser = tweet.user else { return }
        guard let tweetUserId = tweetUser.id else { return }
        
        if tweetUser.isCurrentUser {
            showActionSheet(forUser: tweetUser)
        } else {
            UserService.shared.checkIfUserIsFollowed(uid: tweetUserId) { isFollowed in
                var user = self.tweet.user
                user?.isFollowed = isFollowed
                
                if let user = user {
                    self.showActionSheet(forUser: user)
                }
            }
        }
    }
}

// MARK: - ActionSheetLauncherDelegate
extension TweetController: ActionSheetLauncherDelegate {
    func didSelectOption(option: ActionSheetOptions) {
        switch option {
        case .follow(let user):
            guard let uid = user.id else { return }
            UserService.shared.followUser(uid: uid) { result in
                switch result {
                case .success:
                    print("DEBUG: Now following user: \(user.username)")
                case .failure(let error):
                    print("DEBUG: An error occured while trying to follow a user with error: \(error.localizedDescription)")
                }
            }
        case .unfollow(let user):
            guard let uid = user.id else { return }
            UserService.shared.unfollowUser(uid: uid) { result in
                switch result {
                case .success:
                    print("DEBUG: Now unfollowing user: \(user.username)")
                case .failure(let error):
                    print("DEBUG: An error occured while trying to unfollow a user with error: \(error.localizedDescription)")
                }
            }
        case .report:
            print("DEBUG: Report tweet..")
        case .delete:
            print("DEBUG: delete tweet 1")
            TweetService.shared.deleteTweet(tweet) {
                print("DEBUG: Tweet with caption: \(self.tweet.caption) has been deleted.")
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
}

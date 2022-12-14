//
//  FeedController.swift
//  TwitterUIKit
//
//  Created by Maciej on 24/10/2022.
//

import UIKit
import SDWebImage

final class FeedController: UICollectionViewController {
    // MARK: - Properties
    var user: User? {
        didSet { configureProfileButton() }
    }
    
    private var tweets = [Tweet]() {
        didSet { collectionView.reloadData() }
    }
        
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
//        fetchTweets()
        fetchUserFollowedTweets()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barStyle = .default
        navigationController?.navigationBar.isHidden = false
    }
    
    // MARK: - API
    private func fetchUserFollowedTweets() {
        collectionView.refreshControl?.beginRefreshing()
        
        TweetService.shared.fetchUserFeed { tweets in
            self.tweets = tweets
            self.checkIfUserLikedTweets()
            self.collectionView.refreshControl?.endRefreshing()
        }
    }
    
//    private func fetchTweets() {
//        collectionView.refreshControl?.beginRefreshing()
//
//        TweetService.shared.fetchTweets { tweets in
//            self.collectionView.refreshControl?.endRefreshing()
//            self.tweets = tweets
//            self.checkIfUserLikedTweets(tweets)
//        }
//    }
    
    private func checkIfUserLikedTweets() {
        self.tweets.forEach { tweet in
            TweetService.shared.checkIfUserLikedTweet(tweet) { isLiked in
                guard isLiked == true else {
                    if let index = self.tweets.firstIndex(where: { $0.id == tweet.id }) {
                        self.tweets[index].isLiked = false
                    }
                    return
                }
                
                if let index = self.tweets.firstIndex(where: { $0.id == tweet.id }) {
                    self.tweets[index].isLiked = true
                }
            }
        }
    }
    
    // MARK: - Selectors
    @objc
    private func handleUserOwnProfileTapped() {
        guard let user = user else { return }
        let controller = ProfileController(user: user)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc
    private func refreshTweets() {
        fetchUserFollowedTweets()
    }
    
    // MARK: - Helpers
    private func configureUI() {
        view.backgroundColor = .white
        
        let imageView = UIImageView()
        imageView.image = UIImage.twitterLogoBlue
        imageView.contentMode = .scaleAspectFit
        imageView.setDimensions(width: 44, height: 44)
        
        collectionView.register(TweetCell.self, forCellWithReuseIdentifier: TweetCell.reuseIdentifier)
        collectionView.backgroundColor = .white
        
        let refreshControl = UIRefreshControl()
        collectionView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshTweets), for: .valueChanged)
        
        navigationItem.titleView = imageView
    }
    
    private func configureProfileButton() {
        guard let user = user else { return }
        
        let profileImageView = UIImageView()
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.setDimensions(width: 32, height: 32)
        profileImageView.layer.cornerRadius = 32 / 2
        profileImageView.layer.masksToBounds = true
        profileImageView.sd_setImage(with: user.profileImageUrl)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleUserOwnProfileTapped))
        profileImageView.addGestureRecognizer(tap)
        profileImageView.isUserInteractionEnabled = true
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: profileImageView)
    }
}

// MARK: - UICollectionViewDelegate/DataSource
extension FeedController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tweets.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TweetCell.reuseIdentifier, for: indexPath) as! TweetCell
        
        cell.delegate = self
        cell.tweet = tweets[indexPath.row]
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let controller = TweetController(tweet: tweets[indexPath.row])
        navigationController?.pushViewController(controller, animated: true)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension FeedController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let viewModel = TweetViewModel(tweet: tweets[indexPath.row])
        let height = viewModel.size(forWidth: view.frame.width).height
        
        return CGSize(width: view.frame.width,
                      height: height > 100 ? height + 55 : height + 90)
    }
}

// MARK: - TweetCellDelegate
extension FeedController: TweetCellDelegate {
    func handleFetchUser(withUsername username: String) {
        UserService.shared.fetchUser(withUsername: username) { user in
            let controller = ProfileController(user: user)
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func handleLikeTapped(_ cell: TweetCell) {
        guard let tweet = cell.tweet else { return }

            TweetService.shared.likeTweet(tweet) { result in
                switch result {
                case .failure(let error):
                    print("DEBUG: An error occured while trying to like a tweet with error: \(error.localizedDescription)")
                case .success:
                    guard let isLiked = tweet.isLiked else { return }
                    cell.tweet?.isLiked?.toggle()
                    let likes = isLiked ? tweet.likes - 1 : tweet.likes + 1
                    cell.tweet?.likes = likes
                    self.checkIfUserLikedTweets()
                                        
                    guard !isLiked else { return }
                    guard let user = tweet.user else { return }
                    NotificationService.shared.uploadNotification(toUser: user, type: .like, tweetId: tweet.id)
                }
            }
    }
    
    func handleReplyTapped(_ cell: TweetCell) {
        guard let tweet = cell.tweet else { return }
        guard let user = user else { return }
        let controller = UploadTweetController(user: user, config: .reply(tweet))
        let nav = UINavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }
    
    func handleProfileImageTapped(_ cell: TweetCell) {
        guard let user = cell.tweet?.user else { return }
        let controller = ProfileController(user: user)
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension FeedController: UploadTweetControllerDelegate {
    func reloadTableAfterTweetUpload() {
        fetchUserFollowedTweets()
    }
}

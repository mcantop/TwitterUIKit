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
        fetchTweets()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barStyle = .default
        navigationController?.navigationBar.isHidden = false
    }
    
    // MARK: - API
    private func fetchTweets() {
        TweetService.shared.fetchTweets { tweets in
            self.tweets = tweets
        }
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
    
    @objc private func handleUserOwnProfileTapped() {
        guard let user = user else { return }
        let controller = ProfileController(user: user)
        navigationController?.pushViewController(controller, animated: true)
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
        return CGSize(width: view.frame.width, height: 120)
    }
}

extension FeedController: TweetCellDelegate {
    func handleProfileImageTapped(_ cell: TweetCell) {
        guard let user = cell.tweet?.user else { return }
        let controller = ProfileController(user: user)
        navigationController?.pushViewController(controller, animated: true)
    }
}

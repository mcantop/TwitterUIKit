//
//  NotificationsController.swift
//  TwitterUIKit
//
//  Created by Maciej on 24/10/2022.
//

import UIKit

final class NotificationsController: UITableViewController {
    // MARK: - Properties
    private var notifications = [Notification]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        fetchNotifications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.barStyle = .default
    }
    
    // MARK: - Selectors
    @objc
    private func handleRefresh() {
        fetchNotifications()
    }
    
    // MARK: - Helpers
    private func configureUI() {
        view.backgroundColor = .white
        
        navigationItem.title = "Notifications"
        tableView.register(NotificationCell.self, forCellReuseIdentifier: NotificationCell.reuseIdentifier)
        tableView.rowHeight = 60
        tableView.separatorStyle = .none
        
        let refreshControl = UIRefreshControl()
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
    }
    
    // MARK: - API
    private func fetchNotifications() {
        refreshControl?.beginRefreshing()
        
        NotificationService.shared.fetchNotifications { notifications in
            self.refreshControl?.endRefreshing()
            self.notifications = notifications
            self.checkIfUserIsFollowed(notifications: notifications)
        }
    }
    
    private func checkIfUserIsFollowed(notifications: [Notification]) {
        for (index, notification) in notifications.enumerated() {
            if case .follow = notification.type {
                guard let uid = notification.user?.id else { return }
                
                UserService.shared.checkIfUserIsFollowed(uid: uid) { isFollowed in
                    self.notifications[index].user?.isFollowed = isFollowed
                }
            }
        }
    }
}

// MARK: - UITableViewDataSource
extension NotificationsController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NotificationCell.reuseIdentifier, for: indexPath) as! NotificationCell
        cell.notification = notifications[indexPath.row]
        cell.delegate = self
        return cell
    }
}

extension NotificationsController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let notification = notifications[indexPath.row]
        guard let tweetId = notification.tweetId else { return }
        
        TweetService.shared.fetchTweet(forTweetId: tweetId) { tweet in
            let controller = TweetController(tweet: tweet)
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
}

// MARK: - NotificationCellDelegate
extension NotificationsController: NotificationCellDelegate {
    func didTapProfileImage(_ cell: NotificationCell) {
        guard let user = cell.notification?.user else { return }
        
        let controller = ProfileController(user: user)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func didTapFollow(_ cell: NotificationCell) {
        guard let user = cell.notification?.user else { return }
        guard let uid = user.id else { return }
        guard let isFollowed = user.isFollowed else { return }
                
        if isFollowed {
            UserService.shared.unfollowUser(uid: uid) { result in
                switch result {
                case .success:
                    print("DEBUG: Now unfollowing user: \(user.username)")
                    cell.notification?.user?.isFollowed = false
                case .failure(let error):
                    print("DEBUG: An error occured while trying to unfollow a user with error: \(error.localizedDescription)")
                }
            }
        } else {
            UserService.shared.followUser(uid: uid) { result in
                switch result {
                case .success:
                    print("DEBUG: Now following user: \(user.username)")
                    cell.notification?.user?.isFollowed = true
                case .failure(let error):
                    print("DEBUG: An error occured while trying to follow a user with error: \(error.localizedDescription)")
                }
            }
        }
    }
}

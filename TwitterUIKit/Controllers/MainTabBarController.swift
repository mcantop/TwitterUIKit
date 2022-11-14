//
//  MainTabBarController.swift
//  TwitterUIKit
//
//  Created by Maciej on 24/10/2022.
//

import UIKit
import FirebaseAuth

enum ActionButtonConfiguration {
    case tweet
    case message
}

final class MainTabBarController: UITabBarController {
    // MARK: - Properties
    private var buttonConfig: ActionButtonConfiguration = .tweet
    private let buttonSize: CGFloat = 56
    private var user: User? {
        didSet {
            guard let nav = viewControllers?[0] as? UINavigationController else { return }
            guard let feed = nav.viewControllers[0] as? FeedController else { return }
            
            feed.user = user
        }
    }
    
    private let feed = FeedController(collectionViewLayout: UICollectionViewFlowLayout())
    
    lazy var actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .white
        button.backgroundColor = .twitterBlue
        button.setImage(UIImage.newTweet, for: .normal)
        button.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .twitterBlue
        authenticateUserAndConfigureUI()
    }
    
    // MARK: - API
    func authenticateUserAndConfigureUI() {
        if Auth.auth().currentUser == nil {
            DispatchQueue.main.async {
                let nav = UINavigationController(rootViewController: LoginController())
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true)
            }
        } else {
            configureUI()
            configureViewControllers()
            configureNavigationBar()
            configureTabBarBackground()
            fetchUser()
        }
    }
    
    private func fetchUser() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        UserService.shared.fetchUser(withUid: uid) { user in
            self.user = user
        }
    }
    
    // MARK: - Selectors
    @objc
    private func actionButtonTapped() {
        let controller: UIViewController
        
        switch buttonConfig {
        case .tweet:
            guard let user = user else { return }
//            controller.delegate = feed
            controller = UploadTweetController(user: user, config: .tweet)
        case .message:
            controller = SearchController(config: .message)

        }
        
        let nav = UINavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }
    
    // MARK: - Helpers
    private func configureUI() {
        view.addSubview(actionButton)
        self.delegate = self
    
        actionButton.layer.cornerRadius = buttonSize / 2
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            actionButton.heightAnchor.constraint(equalToConstant: buttonSize),
            actionButton.widthAnchor.constraint(equalToConstant: buttonSize),
            actionButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -64),
            actionButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16),
        ])
    }
    
    private func configureViewControllers() {
        let feedNavigation = templateNavigationController(image: UIImage.feed, rootViewController: feed)

        let explore = SearchController(config: .search)
        let exploreNavigation = templateNavigationController(image: UIImage.explore, rootViewController: explore)
        
        let notifications = NotificationsController()
        let notificationsNavigation = templateNavigationController(image: UIImage.notification, rootViewController: notifications)
        
        let messages = MessagesController()
        let messagesNavigation = templateNavigationController(image: UIImage.message, rootViewController: messages)
        
        viewControllers = [feedNavigation, exploreNavigation, notificationsNavigation, messagesNavigation]
    }
    
    private func configureNavigationBar() {
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithDefaultBackground()
        
        UINavigationBar.appearance().standardAppearance = navigationBarAppearance
        UINavigationBar.appearance().compactAppearance = navigationBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
    }
    
    private func configureTabBarBackground() {
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithDefaultBackground()

        UITabBar.appearance().tintColor = .twitterBlue
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
    }
    
    private func templateNavigationController(image: UIImage?, rootViewController: UIViewController) -> UINavigationController {
        let nav = UINavigationController(rootViewController: rootViewController)
        nav.tabBarItem.image = image
        
        return nav
    }
}

extension MainTabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        let index = viewControllers?.firstIndex(of: viewController)
        let image = index == 3 ? "mail" : "new_tweet"
        self.actionButton.setImage(UIImage(named: image), for: .normal)
        buttonConfig = index == 3 ? .message : .tweet
    }
}

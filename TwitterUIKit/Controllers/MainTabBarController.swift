//
//  MainTabBarController.swift
//  TwitterUIKit
//
//  Created by Maciej on 24/10/2022.
//

import UIKit
import FirebaseAuth

final class MainTabBarController: UITabBarController {
    // MARK: - Properties
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
        
//        logoutUser()
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
    
    private func logoutUser() {
        do {
            try Auth.auth().signOut()
        } catch let error {
            print("DEBUG: Failed to sign out with error: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Selectors
    @objc
    private func actionButtonTapped() {
        guard let user = user else { return }
        let controller = UploadTweetController(user: user, config: .tweet)
        controller.delegate = feed
        let nav = UINavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }
    
    // MARK: - Helpers
    private func configureUI() {
        view.addSubview(actionButton)
    
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

        let explore = ExploreController()
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

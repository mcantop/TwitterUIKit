//
//  MainTabBarController.swift
//  TwitterUIKit
//
//  Created by Maciej on 24/10/2022.
//

import UIKit

final class MainTabBarController: UITabBarController {
    // MARK: - Properties
    let buttonSize: CGFloat = 56
    
    let actionButton: UIButton = {
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
        
        configureUI()
        configureViewControllers()
        configureNavigationBar()
        configureTabBarBackground()
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
        
//        actionButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingBottom: 64, paddingRight: 16, width: buttonSize, height: buttonSize)
    }
    
    // MARK: - Selectors
    
    @objc
    private func actionButtonTapped() {
        print("123")
    }
    
    private func configureViewControllers() {
        let feed = FeedController()
        let feedNavigation = templateNavigationController(image: UIImage.feed, rootViewController: feed)

        let explore = ExploreController()
        let exploreNavigation = templateNavigationController(image: UIImage.explore, rootViewController: explore)
        
        let notifications = NotificationsController()
        let notificationsNavigation = templateNavigationController(image: UIImage.notifications, rootViewController: notifications)
        
        let messages = MessagesController()
        let messagesNavigation = templateNavigationController(image: UIImage.messages, rootViewController: messages)
        
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

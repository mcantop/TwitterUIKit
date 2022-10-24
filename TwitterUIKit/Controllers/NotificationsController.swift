//
//  NotificationsController.swift
//  TwitterUIKit
//
//  Created by Maciej on 24/10/2022.
//

import UIKit

final class NotificationsController: UIViewController {
    // MARK: - Properties
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }
    
    // MARK: - Helpers
    private func configureUI() {
        view.backgroundColor = .white
        
        navigationItem.title = "Notifications"
    }
}

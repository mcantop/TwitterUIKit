//
//  FeedController.swift
//  TwitterUIKit
//
//  Created by Maciej on 24/10/2022.
//

import UIKit
import SDWebImage

final class FeedController: UIViewController {
    // MARK: - Properties
    var user: User? {
        didSet {
            print("DEBUG: Did set user in feed controller..")
            configureProfileButton()
        }
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }
    
    // MARK: - Helpers
    private func configureUI() {
        view.backgroundColor = .white
        
        let imageView = UIImageView()
        imageView.image = UIImage.twitterLogoBlue
        imageView.contentMode = .scaleAspectFit
        imageView.setDimensions(width: 44, height: 44)
        
        navigationItem.titleView = imageView
    }
    
    private func configureProfileButton() {
        guard let user = user else { return }
        
        let profileImageView = UIImageView()
        profileImageView.setDimensions(width: 32, height: 32)
        profileImageView.layer.cornerRadius = 32 / 2
        profileImageView.layer.masksToBounds = true
        profileImageView.sd_setImage(with: user.profileImageUrl)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: profileImageView)
    }
}

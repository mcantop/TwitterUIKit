//
//  EditProfileHeader.swift
//  TwitterUIKit
//
//  Created by Maciej on 13/11/2022.
//

import UIKit

protocol EditProfileHeaderDelegate: AnyObject {
    func didTapChangeProfilePhoto()
}

final class EditProfileHeader: UIView {
    // MARK: - Properties
    weak var delegate: EditProfileHeaderDelegate?
    
    private let user: User

    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .lightGray
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = 3.0
        imageView.layer.cornerRadius = 100 / 2
        return imageView
    }()

    private lazy var changePhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Change Profile Photo", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.addTarget(self, action: #selector(handleChangeProfilePhoto), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    init(user: User) {
        self.user = user
        super.init(frame: .zero)
        
        setupUI()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Selectors
    @objc
    private func handleChangeProfilePhoto() {
        delegate?.didTapChangeProfilePhoto()
    }
    
    // MARK: - Helpers
    private func setupUI() {
        backgroundColor = .twitterBlue
        
        addSubview(profileImageView)
        addSubview(changePhotoButton)
        
        profileImageView.sd_setImage(with: user.profileImageUrl)
    }
    
    private func setupLayout() {
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        changePhotoButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            profileImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            profileImageView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -16),
            profileImageView.heightAnchor.constraint(equalToConstant: 100),
            profileImageView.widthAnchor.constraint(equalToConstant: 100),
            
            changePhotoButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            changePhotoButton.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 8)
        ])
    }
}


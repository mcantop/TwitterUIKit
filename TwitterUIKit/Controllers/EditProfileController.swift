//
//  EditProfileController.swift
//  TwitterUIKit
//
//  Created by Maciej on 13/11/2022.
//

import UIKit

protocol EditProfileControllerDelegate: AnyObject {
    func controller(_ controller: EditProfileController, wantsToUpdate user: User)
}

final class EditProfileController: UITableViewController {
    // MARK: - Properties
    weak var delegate: EditProfileControllerDelegate?
    
    private var user: User
    private var userInfoChanged = false
    private var imageChanged: Bool {
        return selectedImage != nil
    }
    private lazy var headerView = EditProfileHeader(user: user)
    private let imagePicker = UIImagePickerController()
    private var selectedImage: UIImage? {
        didSet { headerView.profileImageView.image = selectedImage }
    }
    
    // MARK: - Lifecycle
    init(user: User) {
        self.user = user
        super.init(style: .plain)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavigationBar()
        configureTableView()
        configureImagePicker()
    }
    
    // MARK: - API
    private func updateUserData() {
        if imageChanged && !userInfoChanged {
            print("DEBUG: Changed profile image..")
            updateProfileImage()
        }
        
        if userInfoChanged && !imageChanged {
            print("DEBUG: Changed user info..")
            UserService.shared.saveUserData(user: user) {
                self.delegate?.controller(self, wantsToUpdate: self.user)
            }
        }
        
        if userInfoChanged && imageChanged {
            print("DEBUG: Changed both..")
            UserService.shared.saveUserData(user: user) {
                self.updateProfileImage()
            }
        }
    }
    
    private func updateProfileImage() {
        guard let image = selectedImage else { return }
        
        UserService.shared.updateProfileImage(image: image) { profileImageUrl in
            guard let profileImageUrl = profileImageUrl else { return }
            self.user.profileImageUrl = profileImageUrl
            self.delegate?.controller(self, wantsToUpdate: self.user)
        }
    }
    
    // MARK: - Selectors
    @objc
    private func handleCancel() {
        dismiss(animated: true)
    }
        
    @objc
    private func handleDone() {
        view.endEditing(true)
        updateUserData()
    }
    
    // MARK: - Helpers
    private func configureNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .twitterBlue
        appearance.titleTextAttributes = [.font: UIFont.boldSystemFont(ofSize: 16),
                                          .foregroundColor: UIColor.white]
        
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        navigationItem.title = "Edit Profile"
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleCancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(handleDone))
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    private func configureTableView() {
        tableView.tableHeaderView = headerView
        headerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 180)
        tableView.tableFooterView = UIView()
        headerView.delegate = self
        tableView.register(EditProfileCell.self, forCellReuseIdentifier: EditProfileCell.reuseIdentifier)
    }
    
    private func configureImagePicker() {
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
    }
}

// MARK: - UITableViewDataSource
extension EditProfileController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return EditProfileOption.allCases.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: EditProfileCell.reuseIdentifier, for: indexPath) as! EditProfileCell
        
        guard let option = EditProfileOption(rawValue: indexPath.row) else { return cell }
        cell.viewModel = EditProfileViewModel(user: user, option: option)
        cell.delegate = self
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension EditProfileController {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let option = EditProfileOption(rawValue: indexPath.row) else { return 0 }
        
        return option == .bio ? 100 : 48
    }
}

// MARK: - EditProfileHeaderDelegate
extension EditProfileController: EditProfileHeaderDelegate {
    func didTapChangeProfilePhoto() {
        present(imagePicker, animated: true)
    }
}

// MARK: - UIImagePickerControllerDelegate
extension EditProfileController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        
        self.selectedImage = image
        
        dismiss(animated: true)
    }
}

// MARK: - EditProfileCellDelegate
extension EditProfileController: EditProfileCellDelegate {
    func updateUserInfo(_ cell: EditProfileCell) {
        guard let viewModel = cell.viewModel else { return }
        
        userInfoChanged = true
        navigationItem.rightBarButtonItem?.isEnabled = true
        
        switch viewModel.option {
        case .fullname:
            guard let fullname = cell.infoTextField.text else { return }
            user.fullname = fullname
        case .username:
            guard let username = cell.infoTextField.text else { return }
            user.username = username
        case .bio:
            user.bio = cell.bioTextView.text
        }
    }
}

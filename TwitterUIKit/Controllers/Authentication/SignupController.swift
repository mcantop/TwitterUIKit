//
//  RegistrationController.swift
//  TwitterUIKit
//
//  Created by Maciej on 24/10/2022.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

final class SignupController: UIViewController {
    // MARK: - Properties
    private let imagePicker = UIImagePickerController()
    private var profileImage: UIImage?
    
    lazy var addPhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage.plusPhoto, for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(handleAddProfilePhoto), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var emailView: UIView = {
        let view = Utilities().inputContainerView(with: UIImage.mail, textField: emailTextField)
        return view
    }()
    
    private lazy var passwordView: UIView = {
        let view = Utilities().inputContainerView(with: UIImage.lock, textField: passwordTextField)
        return view
    }()
    
    private lazy var fullnameView: UIView = {
        let view = Utilities().inputContainerView(with: UIImage.person, textField: fullnameTextField)
        return view
    }()
    
    private lazy var usernameView: UIView = {
        let view = Utilities().inputContainerView(with: UIImage.person, textField: usernameTextField)
        return view
    }()
    
    private let emailTextField: UITextField = {
        let tf = Utilities().textField(withPlaceholder: "Email")
        return tf
    }()
    
    private let passwordTextField: UITextField = {
        let tf = Utilities().textField(withPlaceholder: "Password")
        tf.isSecureTextEntry = true
        return tf
    }()
    
    private let fullnameTextField: UITextField = {
        let tf = Utilities().textField(withPlaceholder: "Full name")
        return tf
    }()
    
    private let usernameTextField: UITextField = {
        let tf = Utilities().textField(withPlaceholder: "Username")
        return tf
    }()
    
    lazy var signupButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.setTitle("Sign Up", for: .normal)
        button.setTitleColor(.twitterBlue, for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(handleSignup), for: .touchUpInside)
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return button
    }()
    
    lazy var alreadyHaveAccountButton: UIButton = {
        let button = Utilities().attributedButton("Already have an account? ", "Log In!")
        button.addTarget(self, action: #selector(navigateLogin), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }
    
    // MARK: - Selectors
    @objc
    private func handleAddProfilePhoto() {
        present(imagePicker, animated: true, completion: nil)
    }
    
    @objc
    private func handleSignup() {
        guard let profileImage = profileImage else {
            print("DEBUG: Please select a profile image")
            return
        }
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        guard let fullname = fullnameTextField.text else { return }
        guard let username = usernameTextField.text?.lowercased() else { return }
        
        let credentials = AuthCredentials(email: email, password: password, fullname: fullname, username: username, profileImage: profileImage)
        
        AuthService.shared.registerUser(credentials: credentials) { result in
            switch result {
            case .failure(let error):
                print("DEBUG: Error while registering user with error: \(error.localizedDescription).")
            case .success:
                let scenes = UIApplication.shared.connectedScenes
                let windowScene = scenes.first as? UIWindowScene
                guard let window = windowScene?.windows.first(where: { $0.isKeyWindow }) else { return }
                
                guard let tab = window.rootViewController as? MainTabBarController else { return }
                
                tab.authenticateUserAndConfigureUI()
                
                self.dismiss(animated: true)
            }
        }
    }
    
    @objc
    private func navigateLogin() {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Helpers
    private func configureUI() {
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        view.backgroundColor = .twitterBlue
        view.addSubview(addPhotoButton)
        view.addSubview(stackView)
        view.addSubview(alreadyHaveAccountButton)
        
        stackView.axis = .vertical
        stackView.spacing = 20
        
        stackView.addArrangedSubview(emailView)
        stackView.addArrangedSubview(passwordView)
        stackView.addArrangedSubview(fullnameView)
        stackView.addArrangedSubview(usernameView)
        stackView.addArrangedSubview(signupButton)
        
        NSLayoutConstraint.activate([
            alreadyHaveAccountButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            alreadyHaveAccountButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            alreadyHaveAccountButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            addPhotoButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            addPhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addPhotoButton.widthAnchor.constraint(equalToConstant: 128),
            addPhotoButton.heightAnchor.constraint(equalToConstant: 128),
            stackView.topAnchor.constraint(equalTo: addPhotoButton.bottomAnchor, constant: 32),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
        ])
    }
}

extension SignupController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let profileImage = info[.editedImage] as? UIImage else { return }
        self.profileImage = profileImage
        
        addPhotoButton.layer.cornerRadius = 128 / 2
        addPhotoButton.layer.masksToBounds = true
        addPhotoButton.imageView?.contentMode = .scaleAspectFill
        addPhotoButton.imageView?.clipsToBounds = true
        addPhotoButton.layer.borderColor = UIColor.white.cgColor
        addPhotoButton.layer.borderWidth = 3
        
        self.addPhotoButton.setImage(profileImage.withRenderingMode(.alwaysOriginal), for: .normal)
        
        dismiss(animated: true)
    }
}

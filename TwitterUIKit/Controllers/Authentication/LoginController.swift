//
//  LoginController.swift
//  TwitterUIKit
//
//  Created by Maciej on 24/10/2022.
//

import UIKit

final class LoginController: UIViewController {
    // MARK: - Properties
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.image = UIImage.twitterLogoWhite
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
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
    
    private let emailTextField: UITextField = {
        let tf = Utilities().textField(withPlaceholder: "Email")
        return tf
    }()
    
    private let passwordTextField: UITextField = {
        let tf = Utilities().textField(withPlaceholder: "Password")
        tf.isSecureTextEntry = true
        return tf
    }()
    
    lazy var loginButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.setTitle("Log In", for: .normal)
        button.setTitleColor(.twitterBlue, for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return button
    }()
    
    lazy var dontHaveAccountButton: UIButton = {
        let button = Utilities().attributedButton("Don't have an account? ", "Sign Up!")
        button.addTarget(self, action: #selector(navigateToSignup), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        conifgureLayout()
    }
    
    // MARK: - Selectors
    @objc
    private func handleLogin() {
        print("handle login")
    }
    
    @objc
    private func navigateToSignup() {
        let signup = SignupController()
        navigationController?.pushViewController(signup, animated: true)
    }
    
    // MARK: - Helpers
    private func configureUI() {
        view.backgroundColor = .twitterBlue
        
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.isHidden = true
        
        view.addSubview(logoImageView)
        view.addSubview(stackView)
        view.addSubview(dontHaveAccountButton)
        
        stackView.addArrangedSubview(emailView)
        stackView.addArrangedSubview(passwordView)
        stackView.addArrangedSubview(loginButton)
        stackView.axis = .vertical
        stackView.spacing = 20
    }
    
    private func conifgureLayout() {
        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 150),
            logoImageView.heightAnchor.constraint(equalToConstant: 150),
            stackView.topAnchor.constraint(equalTo: logoImageView.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            dontHaveAccountButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            dontHaveAccountButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            dontHaveAccountButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}

//
//  EditProfileCell.swift
//  TwitterUIKit
//
//  Created by Maciej on 13/11/2022.
//

import UIKit

final class EditProfileCell: UITableViewCell {
    // MARK: - Properties
    static let reuseIdentifier = "EditProfileCell"
    
    var viewModel: EditProfileViewModel? {
        didSet { configure() }
    }
    
    private let titleLabel: UILabel = {
       let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = "Test title"
        return label
    }()
    
    private lazy var infoTextField: UITextField = {
       let textField = UITextField()
        textField.borderStyle = .none
        textField.font = UIFont.systemFont(ofSize: 14)
        textField.textAlignment = .left
        textField.textColor = .twitterBlue
        textField.addTarget(self, action: #selector(handleUpdateUserInfo), for: .editingDidEnd)
        textField.text = "Test user"
        return textField
    }()
    
    private let bioTextView: InputTextView = {
        let textView = InputTextView()
        textView.font = UIFont.systemFont(ofSize: 14)
        textView.textColor = .twitterBlue
        textView.placeholderLabel.text = "Bio"
        return textView
    }()
    
    // MARK: - Lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupUI()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Selectors
    @objc
    private func handleUpdateUserInfo() {
        
    }
    
    // MARK: Helpers
    private func setupUI() {
        selectionStyle = .none
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(infoTextField)
        contentView.addSubview(bioTextView)
    }
    
    private func setupLayout() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        infoTextField.translatesAutoresizingMaskIntoConstraints = false
        bioTextView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.widthAnchor.constraint(equalToConstant: 100),
            
            infoTextField.topAnchor.constraint(equalTo: topAnchor, constant: 6),
            infoTextField.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 16),
            infoTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -1616),
            infoTextField.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            bioTextView.topAnchor.constraint(equalTo: topAnchor, constant: 6),
            bioTextView.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 16),
            bioTextView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            bioTextView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    private func configure() {
        guard let viewModel = viewModel else { return }
        
        infoTextField.isHidden = viewModel.shouldHideTextField
        bioTextView.isHidden = viewModel.shouldHideTextView
    }
}

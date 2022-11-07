//
//  ActionSheetCell.swift
//  TwitterUIKit
//
//  Created by Maciej on 06/11/2022.
//

import UIKit

final class ActionSheetCell: UITableViewCell {
    // MARK: - Properties
    static let reuseIdentifier = "ActionSheetCell"
    
    var option: ActionSheetOptions? {
        didSet { configure() }
    }
    
    private let optionImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.image = UIImage.twitterLogoBlue
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.text = "Test Option"
        return label
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
    
    // MARK: - Helpers
    private func setupUI() {
        addSubview(optionImageView)
        addSubview(titleLabel)
    }
    
    private func setupLayout() {
        optionImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            optionImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            optionImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            optionImageView.heightAnchor.constraint(equalToConstant: 36),
            optionImageView.widthAnchor.constraint(equalToConstant: 36),
            
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: optionImageView.trailingAnchor, constant: 8)
        ])
    }
    
    private func configure() {
        titleLabel.text = option?.description
    }
}

//
//  Utilities.swift
//  TwitterUIKit
//
//  Created by Maciej on 25/10/2022.
//

import UIKit

final class Utilities {
    func inputContainerView(with image: UIImage?, textField: UITextField) -> UIView {
        let view = UIView()
        let imageView = UIImageView()
        let dividerView = UIView()
        
        view.addSubview(imageView)
        view.addSubview(textField)
        view.addSubview(dividerView)
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        imageView.image = image
        imageView.tintColor = .white
        
        dividerView.backgroundColor = .white
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        textField.translatesAutoresizingMaskIntoConstraints = false
        dividerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8),
            imageView.heightAnchor.constraint(equalToConstant: 24),
            imageView.widthAnchor.constraint(equalToConstant: 24),
            textField.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 8),
            textField.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            dividerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dividerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dividerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            dividerView.heightAnchor.constraint(equalToConstant: 0.75)
        ])
        
        return view
    }
    
    func textField(withPlaceholder placeholder: String) -> UITextField {
        let tf = UITextField()
        
        tf.textColor = .white
        tf.font = UIFont.systemFont(ofSize: 16)
        tf.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        
        return tf
    }
    
    func attributedButton(_ firstPart: String, _ secondPart: String) -> UIButton {
        let button = UIButton(type: .system)
        
        let attributedTitle = NSMutableAttributedString(string: firstPart, attributes:
                                                            [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16),
                                                             NSAttributedString.Key.foregroundColor: UIColor.white])
        
        attributedTitle.append(NSAttributedString(string: secondPart, attributes:
                                                    [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16),
                                                     NSAttributedString.Key.foregroundColor: UIColor.white]))
        
        button.setAttributedTitle(attributedTitle, for: .normal)
        
        return button
    }
    
//    func 
}

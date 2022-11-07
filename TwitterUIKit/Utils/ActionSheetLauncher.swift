//
//  ActionSheetLauncher.swift
//  TwitterUIKit
//
//  Created by Maciej on 06/11/2022.
//

import UIKit

protocol ActionSheetLauncherDelegate: AnyObject {
    func didSelectOption(option: ActionSheetOptions)
}

final class ActionSheetLauncher: NSObject {
    // MARK: - Properties
    private let user: User
    private let tableView = UITableView()
    private var window: UIWindow?
    private lazy var viewModel = ActionSheetViewModel(user: user)
    private var tableViewHeight: CGFloat?
    
    weak var delegate: ActionSheetLauncherDelegate?
    
    private lazy var blackView: UIView = {
        let view = UIView()
        view.alpha = 0
        view.backgroundColor = UIColor(white: 0, alpha: 0.5)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleDismissal))
        view.addGestureRecognizer(tap)
        
        return view
    }()
    
    private lazy var footerView: UIView = {
       let view = UIView()
        view.addSubview(cancelButton)
        
        cancelButton.layer.cornerRadius = 50 / 2
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cancelButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            cancelButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            cancelButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        return view
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Cancel", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .systemGroupedBackground
        button.addTarget(self, action: #selector(handleDismissal), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    init(user: User) {
        self.user = user
        super.init()
        
        configureTableView()
    }
    
    // MARK: - Helpers
    func showTableView(_ shouldShow: Bool) {
        guard let window = window else { return }
        guard let height = tableViewHeight else { return }
        
        let y = shouldShow ? window.frame.height - height : window.frame.height
        
        tableView.frame.origin.y = y
    }
    
    func show() {
        print("DEBUG: Show action sheet for use \(user.username)")
        
        //        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow } ) else { return }
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        guard let window = windowScene?.windows.first(where: { $0.isKeyWindow } ) else { return }
        self.window = window
        
        window.addSubview(blackView)
        blackView.frame = window.frame
        
        window.addSubview(tableView)
        
        let height = CGFloat(viewModel.options.count * 60) + 100
        self.tableViewHeight = height
        tableView.frame = CGRect(x: 0, y: window.frame.height, width: window.frame.width, height: height)
        
        UIView.animate(withDuration: 0.35) {
            self.blackView.alpha = 1
            self.showTableView(true)
        }
    }
    
    private func configureTableView() {
        tableView.backgroundColor = .white
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 60
        tableView.separatorStyle = .none
        tableView.layer.cornerRadius = 20
        tableView.isScrollEnabled = false
        tableView.register(ActionSheetCell.self, forCellReuseIdentifier: ActionSheetCell.reuseIdentifier)
    }
    
    //MARK: - Selectors
    @objc
    private func handleDismissal() {
        UIView.animate(withDuration: 0.35) {
            self.blackView.alpha = 0
            self.tableView.frame.origin.y += 300
        }
    }
}

// MARK: - UITableViewDataSource
extension ActionSheetLauncher: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ActionSheetCell.reuseIdentifier, for: indexPath) as! ActionSheetCell
        
        cell.option = viewModel.options[indexPath.row]
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ActionSheetLauncher: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return footerView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let option = viewModel.options[indexPath.row]
        
        UIView.animate(withDuration: 0.35) {
            self.blackView.alpha = 0
            self.showTableView(false)
        } completion: { _ in
            self.delegate?.didSelectOption(option: option)
        }
    }
}

//
//  ModalBoardsViewController.swift
//  MailPlug
//
//  Created by 진태영 on 2023/08/04.
//

import UIKit
import Combine

class ModalBoardsViewController: UIViewController {
    
    // MARK: - Properties
    let cellIdentifier: String = "ModalBoardCell"
    
    var viewModel: ModalBoardsViewModel
    var cancellable = Set<AnyCancellable>()
    weak var delegate: ModalBoardsDelegate?
    
    var tableView: UITableView = {
       let tableView = UITableView()
        
        return tableView
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        
        configureUI()
        configureTableView()
    }
    
    init(viewModel: ModalBoardsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Selector
    @objc func handleDismiss() {
        self.dismiss(animated: true)
    }
    
    // MARK: - Helpers
    func configureUI() {
        view.backgroundColor = .systemBackground
        let headerLabel = UILabel()
        headerLabel.text = "게시판"
        headerLabel.font = UIFont.systemFont(ofSize: 15, weight: .light)
        
        let underLine = UIView()
        underLine.backgroundColor = .systemGroupedBackground
        
        view.addSubview(headerLabel)
        view.addSubview(underLine)
        headerLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        headerLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                           left: view.leftAnchor,
                           paddingTop: 20,
                           paddingLeft: 16)
        underLine.anchor(top: headerLabel.bottomAnchor,
                         left: view.leftAnchor,
                         right: view.rightAnchor,
                         paddingTop: 15,
                         paddingLeft: 0,
                         paddingRight: 0,
                         height: 2)
        
        view.addSubview(tableView)
        tableView.anchor(top: underLine.bottomAnchor,
                         left: view.leftAnchor,
                         bottom: view.bottomAnchor,
                         right: view.rightAnchor,
                         paddingTop: 5,
                         paddingLeft: 16,
                         paddingBottom: 0,
                         paddingRight: 0)
        
    }
    
    func configureNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .stop,
                                                           target: self, action: #selector(handleDismiss))
        navigationItem.leftBarButtonItem?.tintColor = .black
    }
    
    func configureTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ModalBoardsTableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
    }
}

extension ModalBoardsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate?.didSelectedBoard(viewModel.boards.board[indexPath.row])
        dismiss(animated: true)
    }
}

extension ModalBoardsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.boards.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier,
                                                 for: indexPath) as? ModalBoardsTableViewCell
        
        guard let cell = cell else { fatalError("DEBUG ModalBoardsView Cell Error") }
        
        cell.titleLabel.text = viewModel.boards.board[indexPath.row].displayName
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}

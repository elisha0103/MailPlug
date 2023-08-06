//
//  BoardViewController.swift
//  MailPlug
//
//  Created by 진태영 on 2023/08/04.
//

import UIKit
import Combine

class BoardViewController: UITableViewController {
    
    // MARK: - Properties
    let cellIdentifier: String = "BoardTableViewCellIdentifier"
    let viewModel = BoardViewModel()
    var cancelBag = Set<AnyCancellable>()
    
    weak var delegate: ModalBoardsDelegate?
    
    var emptyStackView: UIStackView {
        let noneResultImageView = UIImageView()
        let noneResultLabel = UILabel()
        noneResultLabel.text = "등록된 게시글이 없습니다."
        noneResultLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        noneResultLabel.textColor = .gray
        noneResultImageView.image = UIImage(named: "NoneBoardResultImage")

        let noneResultStack = UIStackView(arrangedSubviews: [noneResultImageView, noneResultLabel])
        noneResultStack.axis = .vertical
        noneResultStack.spacing = 10
        noneResultStack.alignment = .center

        return noneResultStack
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        viewModel.fetchBoards()
        configureNavigationBar()
        bind()
    }
    
    // MARK: - Selectors
    @objc func handleLeftNavigationItemTapped() {
        viewModel.$boards
            .sink { boards in
                let modalViewModel = ModalBoardsViewModel(boards: boards)
                let controller = ModalBoardsViewController(viewModel: modalViewModel)
                controller.delegate = self
                let navigation = UINavigationController(rootViewController: controller)
                navigation.modalPresentationStyle = .formSheet
                self.present(navigation, animated: true)
            }
            .store(in: &cancelBag)
        
    }
    
    @objc func handleRightNavigationItemTapped() {
        let controller = PostSearchController(viewModel: SearchPostViewModel(board: viewModel.selectedBoard))
    
        self.navigationController?.pushViewController(controller, animated: true)
        
    }
    
    // MARK: - Helpers
        func configureNavigationBar() {
        let menuImageView = UIImageView()
        menuImageView.image = UIImage(named: "hamburger menu")
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleLeftNavigationItemTapped))
        menuImageView.addGestureRecognizer(tap)
        menuImageView.isUserInteractionEnabled = true
        
        let searchButton = UIBarButtonItem(barButtonSystemItem: .search,
                                           target: self,
                                           action: #selector(handleRightNavigationItemTapped))
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: menuImageView)
        navigationItem.rightBarButtonItem = searchButton
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        
        let attributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 20)]
        appearance.titleTextAttributes = attributes
        appearance.titlePositionAdjustment = UIOffset(horizontal: -(.greatestFiniteMagnitude), vertical: 0)
        self.navigationController?.navigationBar.standardAppearance = appearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
        self.navigationController?.navigationBar.tintColor = .black

    }
    
    func configureTableView() {
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        tableView.register(BoardTableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.rowHeight = 74
        tableView.backgroundColor = .systemGroupedBackground
        
        tableView.backgroundView = emptyStackView
        tableView.backgroundView?.setDimensions(width: 153, height: 180)
        tableView.backgroundView?.centerX(inView: tableView, topAnchor: tableView.topAnchor, paddingTop: 200)
    }
    
    func bind() {
        self.viewModel.$selectedBoard
            .receive(on: DispatchQueue.main)
            .sink { [weak self] board in
                self?.navigationItem.title = board.displayName
                
            }
            .store(in: &cancelBag)

        self.viewModel.$currentPosts
            .receive(on: DispatchQueue.main)
            .sink { [weak self] currentPosts in
                currentPosts.isEmpty ?
                (self?.tableView.backgroundView?.isHidden = false) :
                (self?.tableView.backgroundView?.isHidden = true)
                
                self?.tableView.reloadData()

            }
            .store(in: &cancelBag)
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentOffsetY = tableView.contentOffset.y
        let tableViewContentSize = tableView.contentSize.height
        
        if viewModel.posts.post.isEmpty && viewModel.offset == 0 { return }
        
        if contentOffsetY > (tableViewContentSize - tableView.bounds.size.height),
           viewModel.isPaginationFetching, contentOffsetY > 0 {
            viewModel.isPaginationFetching = false
            viewModel.offset += 30
        }
    }
    
}

extension BoardViewController {
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? BoardTableViewCell
        guard let cell = cell else { fatalError("DEBUG BoardView Cell Error") }
        let post = viewModel.currentPosts[indexPath.row]
        cell.viewModel = BoardTableCellViewModel(post: post)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.currentPosts.count
    }
}

extension BoardViewController: ModalBoardsDelegate {
    func didSelectedBoard(_ board: Board) {
        self.viewModel.selectedBoard = board
        self.viewModel.offset = 0
    }
}

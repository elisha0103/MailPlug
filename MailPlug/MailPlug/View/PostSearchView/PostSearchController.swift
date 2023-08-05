//
//  PostSearchController.swift
//  MailPlug
//
//  Created by 진태영 on 2023/08/06.
//

import UIKit
import Combine

class PostSearchController: UIViewController {
    
    let viewModel: SearchPostViewModel
    let postSearchTableViewCell: String = "postSearchTableViewCell"
    let searchResultTableViewCell: String = "searchResultTableViewCell"
    var searchString: String = ""
    var cancelBag = Set<AnyCancellable>()
    
    var tableView: UITableView = {
       let tableView = UITableView()
        
        return tableView
    }()
    
    var noneHistoryStackView: UIStackView {
        let noneResultImageView = UIImageView()
        let noneResultLabel = UILabel()
        noneResultLabel.text = "게시글의 제목, 내용 또는 작성자에 포함된\n단어 또는 문장을 검색해 주세요."
        noneResultLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        noneResultLabel.textColor = .gray
        noneResultLabel.textAlignment = .center
        noneResultLabel.numberOfLines = 0
        noneResultLabel.setDimensions(width: 240, height: 45)
        noneResultImageView.image = UIImage(named: "NoneSearchImage")

        let noneResultStack = UIStackView(arrangedSubviews: [noneResultImageView, noneResultLabel])
        noneResultStack.axis = .vertical
        noneResultStack.spacing = 10
        noneResultStack.alignment = .center

        return noneResultStack
    }
    
    var noneSearchStackView: UIStackView {
        let noneSearchImageView = UIImageView()
        let noneSearchLabel = UILabel()
        noneSearchLabel.text = "검색 결과가 없습니다.\n다른 검색어를 입력해 보세요."
        noneSearchLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        noneSearchLabel.textColor = .gray
        noneSearchLabel.textAlignment = .center
        noneSearchLabel.numberOfLines = 0
        noneSearchLabel.setDimensions(width: 240, height: 45)

        noneSearchImageView.image = UIImage(named: "NoneSearchResultImage")

        let noneResultStack = UIStackView(arrangedSubviews: [noneSearchImageView, noneSearchLabel])
        noneResultStack.axis = .vertical
        noneResultStack.spacing = 10
        noneResultStack.alignment = .center

        return noneResultStack
    }

    // MARK: - Lifecycle
    init(viewModel: SearchPostViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        
        configureSearchController()
        configureTableView()
        bind()
    }
    
    // MARK: - Helpers
    func configureSearchController() {
        let searchController = UISearchController(searchResultsController: nil)
        let placeholder: String = "\(viewModel.board.displayName)에서 검색"
        
        searchController.searchBar.placeholder = placeholder
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = true
        
        if let button = searchController.searchBar.searchTextField.value(forKey: "_clearButton") as? UIButton {
            button.isHidden = true
        }
        searchController.searchBar.setValue("취소", forKey: "cancelButtonText")
        
        self.navigationItem.searchController = searchController
        self.navigationItem.hidesSearchBarWhenScrolling = false
        
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
    }
    
    func configureTableView() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        tableView.register(PostSearchTableViewCell.self, forCellReuseIdentifier: postSearchTableViewCell)
        tableView.register(BoardTableViewCell.self, forCellReuseIdentifier: searchResultTableViewCell)
        
        view.addSubview(tableView)
        tableView.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                         left: view.leftAnchor,
                         bottom: view.bottomAnchor,
                         right: view.rightAnchor,
                         paddingTop: 5,
                         paddingLeft: 16,
                         paddingBottom: 0,
                         paddingRight: 0)
    }
    
    func bind() {
        self.viewModel.$searchResults
            .receive(on: DispatchQueue.main)
            .sink { [weak self] searchResults in
                if searchResults.searchResult.isEmpty {
                    self?.tableView.rowHeight = 45
                    self?.tableView.separatorStyle = .singleLine
                    
                    self?.tableView.backgroundView = self?.noneHistoryStackView
                    self?.tableView.backgroundView?.setDimensions(width: 250, height: 240)
                    self?.tableView.backgroundView?.centerX(inView: (self?.tableView)!,
                                                            topAnchor: (self?.tableView)!.topAnchor, paddingTop: 200)

                    self?.searchString.isEmpty ?? true ?
                    (self?.tableView.backgroundView?.isHidden = false) :
                    (self?.tableView.backgroundView?.isHidden = true)
                    
                } else {
                    self?.tableView.rowHeight = 74
                    self?.tableView.separatorStyle = .none
                    
                }
                
                self?.tableView.reloadData()
            }
            .store(in: &cancelBag)
        
        self.viewModel.$isEmptyData
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isEmpty in
                if isEmpty {
                    self?.tableView.backgroundView = self?.noneSearchStackView
                    self?.tableView.backgroundView?.setDimensions(width: 250, height: 240)
                    self?.tableView.backgroundView?.centerX(inView: (self?.tableView)!,
                                                            topAnchor: (self?.tableView)!.topAnchor, paddingTop: 200)
                    
                    self?.tableView.backgroundView?.isHidden = false
                } else {
//                    self?.tableView.backgroundView?.isHidden = true
                }
            }
            .store(in: &cancelBag)
    }

}

extension PostSearchController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as? PostSearchTableViewCell
        guard let cell = cell else { return }
        guard let category = cell.category else { return }
        viewModel.searchString = searchString
        viewModel.fetchSearchResults(searchCategory: category)
    }
}

extension PostSearchController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if viewModel.searchResults.searchResult.isEmpty && searchString.isEmpty {
            return 0
//            return searchString.isEmpty ? 0 : SearchCategory.allCases.count
        }
        if viewModel.isEmptyData && viewModel.searchResults.searchResult.isEmpty {
            return 0
        }
        
        return viewModel.searchResults.searchResult.isEmpty ?
        SearchCategory.allCases.count : viewModel.searchResults.count
//        return viewModel.searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if viewModel.searchResults.searchResult.isEmpty {
            let cell = tableView.dequeueReusableCell(withIdentifier: postSearchTableViewCell,
                                                     for: indexPath) as? PostSearchTableViewCell
            
            guard let cell = cell else { fatalError("PostSearchTableView Cell Error") }
            let category = SearchCategory(rawValue: indexPath.row)
            guard let category = category else { fatalError("PostSearchTableView Cell Error") }
            
            cell.category = category
            cell.searchStringLabel.text = self.searchString
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: searchResultTableViewCell,
                                                 for: indexPath) as? BoardTableViewCell
        
        guard let cell = cell else { fatalError("searchResultTableViewCell Cell Error") }

        let post = viewModel.searchResults.searchResult[indexPath.row]
        cell.viewModel = BoardTableCellViewModel(post: post, searchString: searchString)
        print("CELL RETURN")
        return cell
    }
    
}

extension PostSearchController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        self.searchString = text
        viewModel.searchResults = SearchResults(searchResult: [], count: 0, offset: 0, limit: 0, total: 0)
        viewModel.isEmptyData = false

        self.tableView.reloadData()
    }
}

extension PostSearchController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        viewModel.searchResults = SearchResults(searchResult: [], count: 0, offset: 0, limit: 0, total: 0)
        viewModel.isEmptyData = false
        
    }
}

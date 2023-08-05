//
//  SearchPostViewModel.swift
//  MailPlug
//
//  Created by 진태영 on 2023/08/06.
//

import Foundation
import Combine

class SearchPostViewModel {
    
    // MARK: - Properties
    @Published var searchResults = SearchResults(searchResult: [], count: 0, offset: 0, limit: 0, total: 0)
    @Published var isEmptyData: Bool = false
    
    var cancelBag = Set<AnyCancellable>()
    var searchString: String = ""
    var searchCategory: SearchCategory?
    let board: Board
    
    // MARK: - Lifecycle
    init(board: Board) {
        self.board = board
    }
    
    // MARK: - API
    func fetchSearchResults(searchCategory: SearchCategory) {
        NetworkService.shared.fetchSearchResults(boardsId: board.boardID,
                                                 search: searchString,
                                                 searchTarget: searchCategory) { response in
            response.result.publisher.replaceError(with: SearchResults(searchResult: [],
                                                                       count: 0, offset: 0, limit: 0, total: 0))
            .assign(to: \.searchResults, on: self)
            .store(in: &self.cancelBag)
            self.searchResults.searchResult.isEmpty ? (self.isEmptyData = true) : (self.isEmptyData = false)
        }
    }
}

enum SearchCategory: Int, CaseIterable {
    case all
    case title
    case contents
    case writer
    
    var description: String {
        switch self {
        case .all:
            return "전체"
        case .title:
            return "제목"
        case .contents:
            return "내용"
        case .writer:
            return "작성자"
        }
    }
    
}

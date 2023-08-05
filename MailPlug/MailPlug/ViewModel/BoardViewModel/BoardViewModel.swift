//
//  BoardViewModel.swift
//  MailPlug
//
//  Created by 진태영 on 2023/08/04.
//

import Foundation
import Combine

final class BoardViewModel {
    
    // MARK: - Properties
    @Published var boards: Boards = Boards(board: [], count: 0, offset: 0, limit: 0, total: 0)
    @Published var selectedBoard: Board = Board(boardID: 0, displayName: "")
    
    @Published var posts: Posts = Posts(post: [], count: 0, offset: 0, limit: 0, total: 0)
    @Published var currentPosts: [Post] = []
    @Published var offset = 0
    
    var cancelBag = Set<AnyCancellable>()
    var isPaginationFetching = false
    
    // MARK: - API
    func fetchBoards() {
        NetworkService.shared.fetchBoards { response in
            response.result.publisher.replaceError(with: Boards(board: [], count: 0, offset: 0, limit: 0, total: 0))
                .assign(to: \.boards, on: self)
                .store(in: &self.cancelBag)
            self.bind()
        }
    }
    
    func fetchPosts(_ boardsId: Int, offset: Int) {
        NetworkService.shared.fetchPosts(boardsId: boardsId, offSet: offset) { response in
            response.result.publisher.replaceError(with: Posts(post: [], count: 0, offset: 0, limit: 0, total: 0))
                .assign(to: \.posts, on: self)
                .store(in: &self.cancelBag)
            
            if self.posts.post.isEmpty { self.isPaginationFetching = false } else { self.isPaginationFetching = true }

        }
    }

    // MARK: - Properties
    func bind() {
        self.$boards
            .sink { [weak self] boards in
                guard let board = boards.board.first else { return }
                self?.selectedBoard = board
                
            }
            .store(in: &self.cancelBag)
        
        self.$offset
            .sink { [weak self] offset in
                self?.fetchPosts(self?.selectedBoard.boardID ?? 0, offset: offset)
            }
            .store(in: &cancelBag)
        
        self.$posts
            .sink { [weak self] posts in
                if self?.offset == 0 {
                    self?.currentPosts = posts.post
                } else {
                    self?.currentPosts.append(contentsOf: posts.post)
                }
            }
            .store(in: &self.cancelBag)

    }
    
}

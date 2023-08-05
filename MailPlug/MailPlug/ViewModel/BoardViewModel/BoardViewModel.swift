//
//  BoardViewModel.swift
//  MailPlug
//
//  Created by 진태영 on 2023/08/04.
//

import Foundation
import Combine

final class BoardViewModel {
    
    @Published var boards: Boards = Boards(board: [], count: 0, offset: 0, limit: 0, total: 0)
    @Published var selectedBoard: Board = Board(boardID: 0, displayName: "")
    
    @Published var posts: Posts = Posts(post: [], count: 0, offset: 0, limit: 0, total: 0)
    @Published var currentPosts: [Post] = []
    @Published var offset = 0
    
    var cancelBag = Set<AnyCancellable>()
    var isPaginationFetching = false
    
    func fetchBoards() {
        NetworkService.shared.fetchBoards { response in
            print("DEBUG Boards URLResponse State: \(String(describing: response.response?.statusCode))")
            response.result.publisher.replaceError(with: Boards(board: [], count: 0, offset: 0, limit: 0, total: 0))
                .assign(to: \.boards, on: self)
                .store(in: &self.cancelBag)
//        https://mp-dev.mail-server.kr/api/v2/boards/{boards_id}/posts?offset=0&limit=30
            self.bind()
        }
    }
    
    func bind() {
        self.$boards
            .sink { [weak self] boards in
                guard let board = boards.board.first else { return }
                self?.selectedBoard = board
                
                print("DEBUG: BOARDS")
            }
            .store(in: &self.cancelBag)
        
        self.$offset
            .sink { [weak self] offset in
                self?.fetchPosts(self?.selectedBoard.boardID ?? 0, offset: offset)
            }
            .store(in: &cancelBag)
        
        self.$posts
            .sink { [weak self] posts in
                print("DEBUG: Change posts and will change current data")
                if self?.offset == 0 {
                    self?.currentPosts = posts.post
                    print("DEBUG First fetch")
                } else {
                    self?.currentPosts.append(contentsOf: posts.post)
                    print("DEBUG \(String(describing: self?.offset)) FETCH")
                }
            }
            .store(in: &self.cancelBag)

    }
    
    func fetchPosts(_ boardsId: Int, offset: Int) {
        print("DEBUG: CALL FETCHPOSTS")
        NetworkService.shared.fetchPosts(boardsId: boardsId, offSet: offset) { response in
            print("DEBUG Posts URLResponse State \(String(describing: response.response?.statusCode))")
            print("DEBUG Posts URL: \(String(describing: response.response?.url))")
            response.result.publisher.replaceError(with: Posts(post: [], count: 0, offset: 0, limit: 0, total: 0))
                .assign(to: \.posts, on: self)
                .store(in: &self.cancelBag)
            if !self.posts.post.isEmpty { print("DEBUG: one post: \(self.posts.post[0])") }
            
            if self.posts.post.isEmpty { self.isPaginationFetching = false } else { self.isPaginationFetching = true }

        }
    }

}

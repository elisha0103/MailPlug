//
//  ModalBoardsViewModel.swift
//  MailPlug
//
//  Created by 진태영 on 2023/08/04.
//

import UIKit

class ModalBoardsViewModel {
    
    // MARK: - Properties
    @Published var boards: Boards
    
    // MARK: - Lifecycle
    init(boards: Boards) {
        self.boards = boards
    }
    
}

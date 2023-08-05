//
//  Boards.swift
//  MailPlug
//
//  Created by 진태영 on 2023/08/04.
//

import Foundation

// MARK: - Boards
struct Boards: Codable, Equatable {
    let board: [Board]
    let count, offset, limit, total: Int

    enum CodingKeys: String, CodingKey {
        case board = "value"
        case count, offset, limit, total
    }
}

// MARK: - Board
struct Board: Codable, Equatable {
    let boardID: Int
    let displayName: String

    enum CodingKeys: String, CodingKey {
        case boardID = "boardId"
        case displayName
    }
}

//
//  SearchResults.swift
//  MailPlug
//
//  Created by 진태영 on 2023/08/04.
//

import Foundation

// MARK: - SearchResults
struct SearchResults: Codable {
    let searchResult: [Post]
    let count, offset, limit, total: Int
    
    enum CodingKeys: String, CodingKey {
        case searchResult = "value"
        case count, offset, limit, total
    }

}

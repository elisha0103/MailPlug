//
//  NetworkAPI.swift
//  MailPlug
//
//  Created by 진태영 on 2023/08/04.
//

import Foundation
import Alamofire

class NetworkService {
    static let shared = NetworkService()
    
    func fetchBoards(completion: @escaping (DataResponse<Boards, AFError>) -> Void) {
        AF.request(BOARDS_URLSTRING,
                   method: .get,
        parameters: nil,
                   encoding: URLEncoding.default,
                   headers: HTTPHeaders(API_AUTHORIZATION))
        .validate(statusCode: 200 ..< 300)
        .responseDecodable(of: Boards.self, completionHandler: completion)
        
    }
// https://mp-dev.mail-server.kr/api/v2/boards/{boards_id}/posts?offset=0&limit=30
    func fetchPosts(boardsId: Int, offSet: Int, completion: @escaping (DataResponse<Posts, AFError>) -> Void) {
        let limit: Int = 30
        AF.request(BOARDS_URLSTRING + "/\(boardsId)/posts",
                   method: .get,
                   parameters: ["offset": offSet, "limit": limit],
                   encoding: URLEncoding(destination: .queryString),
        headers: HTTPHeaders(API_AUTHORIZATION))
        .validate(statusCode: 200 ..< 300)
        .responseDecodable(of: Posts.self, completionHandler: completion)
        
    }
    
    func fetchSearchResults(boardsId: Int,
                            search: String,
                            searchTarget: SearchCategory,
                            completion: @escaping (DataResponse<SearchResults, AFError>) -> Void) {
        AF.request(BOARDS_URLSTRING + "/\(boardsId)/posts",
                   method: .get,
                   parameters: ["search": search, "searchTarget": "\(searchTarget)"],
                   encoding: URLEncoding(destination: .queryString),
                   headers: HTTPHeaders(API_AUTHORIZATION))
        .validate(statusCode: 200 ..< 300)
        .responseDecodable(of: SearchResults.self, completionHandler: completion)
    }
}

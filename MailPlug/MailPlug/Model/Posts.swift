//
//  Posts.swift
//  MailPlug
//
//  Created by 진태영 on 2023/08/04.
//

import Foundation

// MARK: - Boards
struct Posts: Codable {
    var post: [Post]
    var count, offset, limit, total: Int

    enum CodingKeys: String, CodingKey {
        case post = "value"
        case count, offset, limit, total
    }
}

// MARK: - Post
struct Post: Codable {
    
    let postID: Int
    let title: String
    let boardID: Int
    let boardDisplayName: String
    let writer: Writer
    let contents: String
    let createdDateTime: String
    let viewCount: Int
    let postType: String
    let isNewPost, hasInlineImage: Bool
    let commentsCount, attachmentsCount: Int
    let isAnonymous, isOwner, hasReply: Bool

    enum CodingKeys: String, CodingKey {
        case postID = "postId"
        case title
        case boardID = "boardId"
        case boardDisplayName, writer, contents, createdDateTime, viewCount, postType, isNewPost,
             hasInlineImage, commentsCount, attachmentsCount, isAnonymous, isOwner, hasReply
    }
}

// MARK: - Writer
struct Writer: Codable {
    let displayName, emailAddress: String
}

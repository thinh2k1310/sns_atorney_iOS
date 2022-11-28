//
//  Comment.swift
//  Attorney
//
//  Created by ThinhTCQ on 11/28/22.
//

import Foundation

struct Comment: Codable {
    let _id: String?
    let userId: ShortUser?
    let postId: String?
    let content: String?
}

struct PostCommentsResponse: Codable {
    let success: Bool?
    let message: String?
    let data: [Comment]?
}

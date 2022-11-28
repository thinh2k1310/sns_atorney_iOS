//
//  Post.swift
//  Attorney
//
//  Created by ThinhTCQ on 11/19/22.
//

import Foundation

struct Post: Codable {
    let _id : String?
    let user: ShortUser?
    let content: String?
    let mediaUrl: String?
    let mediaHeight: Float?
    let mediaWidth: Float?
    let type: String?
    let totalLikes: Int?
    let totalComments: Int?
    var isLikePost: Bool?
    
    init(byDefaultValue: Bool) {
        _id = ""
        user = ShortUser(_id: "", firstName: "", lastName: "", avatar: "", role: "")
        content = ""
        mediaUrl = ""
        mediaHeight = 1
        mediaWidth = 1
        type = ""
        totalLikes = 0
        totalComments = 0
        isLikePost = false
    }
}

enum PostType: String {
    case REQUESTING
    case DISCUSSING
}

extension PostType: Equatable {
    public static func == (lhs: PostType, rhs: PostType) -> Bool {
        switch (lhs, rhs) {
        case (.REQUESTING, .REQUESTING), (.DISCUSSING, .DISCUSSING): return true
        default: return false
        }
    }
}

struct PostDetail: Codable {
    let _id : String?
    let user: ShortUser?
    let content: String?
    let mediaUrl: String?
    let mediaHeight: Float?
    let mediaWidth: Float?
    let type: String?
    let totalLikes: Int?
    let totalComments: Int?
    var isLikePost: Bool?
}

struct PostDetailResponse: Codable {
    let success: Bool?
    let data: PostDetail?
    let message: String?
}

//
//  PostList.swift
//  Attorney
//
//  Created by ThinhTCQ on 11/19/22.
//

import Foundation

struct PostsResponse: Codable {
    let success: Bool?
    let data: [Post]?
    let metadata: MetaData?
}

struct MetaData: Codable {
    let page: Int?
    let pages: Int?
    let total: Int?

    var hasNextPage: Bool {
        guard let page = page, let pages = pages else {
            return false
        }
        return page < pages
    }

    enum CodingKeys: String, CodingKey {
        case page
        case pages
        case total
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        page = try values.decodeIfPresent(Int.self, forKey: .page)
        pages = try values.decodeIfPresent(Int.self, forKey: .pages)
        total = try values.decodeIfPresent(Int.self, forKey: .total)
    }
}

struct PostsRequest: Codable {
    let sortOrder: SortOrder
    let type: String?
    let page: Int?
}

struct UserPostsRequest: Codable {
    let profileId: String?
    let page: Int?
}

struct SortOrder: Codable {
    let created: Int?
    let totalReactions: Int?
}

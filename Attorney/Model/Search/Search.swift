//
//  Search.swift
//  Attorney
//
//  Created by ThinhTCQ on 12/9/22.
//

import Foundation

struct SearchAllRequest: Codable {
    var searchText: String
}

struct SearchAllResponse: Codable {
    let success: Bool?
    let posts: [Post]?
    let users: [User]?
    
    init() {
        success = false
        posts = []
        users = []
    }
}

struct SearchUsersRequest: Codable {
    var searchText: String
    var pageNumber: Int
}

struct SearchPostsRequest: Codable {
    var searchText: String
    var pageNumber: Int
}

struct SearchMetaData: Codable {
    let page: Int?
    let pages: Int?
    let total: Int?
}

struct SearchPostsResponse: Codable {
    let success: Bool?
    let metadata: SearchMetaData?
    let data: [Post]?
}

struct SearchUsersResponse: Codable {
    let success: Bool?
    let metadata: SearchMetaData?
    let data: [User]?
}

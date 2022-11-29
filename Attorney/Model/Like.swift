//
//  Like.swift
//  Attorney
//
//  Created by Truong Thinh on 29/11/2022.
//

import Foundation

struct LikeRequest: Codable {
    let userId: String
    let postId: String
}

struct LikeResponse : Codable {
    let success: Bool?
    let like: Bool?
    let message: String?
}

//
//  Category.swift
//  Attorney
//
//  Created by ThinhTCQ on 12/8/22.
//

import Foundation


struct ListAttorneyRequest: Codable {
    var category: String?
}

struct ListAttorneyResponse: Codable {
    let success: Bool?
    let message: String?
    let data: [Attorney]?
}

struct Attorney: Codable {
    let _id: String?
    let firstName: String?
    let lastName: String?
    let avatar: String?
    let totalReviews: Int?
    let rating: Float?
}

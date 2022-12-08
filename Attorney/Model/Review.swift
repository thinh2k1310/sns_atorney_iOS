//
//  Review.swift
//  Attorney
//
//  Created by ThinhTCQ on 12/8/22.
//

import Foundation


struct Review: Codable {
    let client: String?
    let attorney: String?
    let cases: String?
    let point: Int?
    let content: String?
}

struct ReviewRequest: Codable {
    var cases: String
    var point: Int
    var content: String
}

struct ReviewResponse: Codable {
    let success: Bool?
    let message: Bool?
    let total: Int?
    let rating: Float?
    let reviews: [Review]?
}

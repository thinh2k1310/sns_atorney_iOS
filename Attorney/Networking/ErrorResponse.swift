//
//  ErrorResponse.swift
//  Attorney
//
//  Created by ThinhTCQ on 10/29/22.
//

import Foundation

struct ErrorResponse: Codable {
    let success: Bool?
    let code: String?
    let message: String

    enum CodingKeys: String, CodingKey {
        case success
        case code
        case message
    }
}

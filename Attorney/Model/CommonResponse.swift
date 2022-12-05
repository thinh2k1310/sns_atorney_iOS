//
//  CommonResponse.swift
//  Attorney
//
//  Created by Truong Thinh on 29/11/2022.
//

import Foundation

struct CommonReponse: Codable {
    let success: Bool?
    let message: String?
}

struct ChangeImageResponse: Codable {
    let success: Bool?
    let message: String?
    let data: User?
}

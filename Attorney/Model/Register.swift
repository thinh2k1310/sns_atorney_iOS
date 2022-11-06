//
//  Register.swift
//  Attorney
//
//  Created by ThinhTCQ on 10/23/22.
//

import Foundation

struct RegisterRequest: Codable {
    let address: String?
    let dob: String
    let password: String
    let email: String
    let firstName: String
    let lastName: String?
    let phoneNumber: String?
    let role: String?
}

struct RegisterResponse: Codable {
    let success: Bool?
    let message: String?
    let isUniqueEmail: Bool?

    enum CodingKeys: String, CodingKey {
        case success
        case message
        case isUniqueEmail
    }
}

struct ValidateEmailRequest: Codable {
    let email: String?
    let OTP: String?
    let isUser: Bool?
}

struct ValidateEmailResponse: Codable {
    let success: Bool?
    let message: String?

    enum CodingKeys: String, CodingKey {
        case success
        case message
    }
}

struct SendOTPRequest: Codable {
    let email: String?
}

struct SendOTPResponse: Codable {
    let success: Bool?
    let message: String?
}

extension RegisterRequest {
    func convertArrayToString<T: Codable>(_ input: T?) -> String {
        guard let jsonData = try? JSONEncoder().encode(input) else { return "" }
        let jsonString = String(data: jsonData, encoding: .utf8)!
        return jsonString
    }
}

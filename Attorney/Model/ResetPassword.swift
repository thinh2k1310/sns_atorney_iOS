//
//  ResetPassword.swift
//  Attorney
//
//  Created by ThinhTCQ on 11/5/22.
//

import Foundation

struct ResetPasswordRequest: Codable {
    let email: String?
    let password: String?
}

struct ResetPasswordResponse: Codable {
    let success: Bool?
    let message: String?
}

struct ChangePasswordRequest: Codable {
    let password: String?
    let newPassword: String?
}

struct ChangePasswordResponse: Codable {
    let success: Bool?
    let message: String?
}

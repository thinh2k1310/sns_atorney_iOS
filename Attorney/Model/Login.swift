//
//  Login.swift
//  Attorney
//
//  Created by ThinhTCQ on 10/29/22.
//

import Foundation

struct LoginRequest: Codable {
    let email: String
    let password: String
}

struct LoginResponse: Codable {
    let success: Bool?
    let message: String?
    let token: String?
    let data: User?
}

struct User: Codable {
    var id: String?
    var email: String?
    var phoneNumber: String?
    var firstName: String?
    var lastName: String?
    var password: String?
    var verified : Bool?
    var dob: String?
    var gender: String?
    var role: String?
    var avatar: String?
    var cover: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case email
        case firstName
        case lastName
        case password
        case verified
        case dob
        case gender
        case role
        case avatar
        case cover
    }
}

extension LoginResponse: Equatable {
    static func == (lhs: LoginResponse, rhs: LoginResponse) -> Bool {
        return lhs.success == rhs.success &&
        lhs.message == rhs.message &&
        lhs.token == rhs.token &&
        lhs.data?.id == rhs.data?.id &&
        lhs.data?.email == rhs.data?.email &&
        lhs.data?.phoneNumber == rhs.data?.phoneNumber &&
        lhs.data?.firstName == rhs.data?.firstName &&
        lhs.data?.lastName == rhs.data?.lastName &&
        lhs.data?.password == rhs.data?.password &&
        lhs.data?.verified == rhs.data?.verified &&
        lhs.data?.dob == rhs.data?.dob &&
        lhs.data?.gender == rhs.data?.gender &&
        lhs.data?.role == rhs.data?.role &&
        lhs.data?.avatar == rhs.data?.avatar &&
        lhs.data?.cover == rhs.data?.cover
    }
}

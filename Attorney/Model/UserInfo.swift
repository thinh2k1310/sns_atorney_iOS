//
//  UserInfo.swift
//  Attorney
//
//  Created by Truong Thinh on 10/10/2022.
//

import UIKit

struct UserInfo: Codable {
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
    
    init(loginResponse: LoginResponse) {
        self.id = loginResponse.data?.id
        self.email = loginResponse.data?.email
        self.phoneNumber = loginResponse.data?.phoneNumber
        self.firstName = loginResponse.data?.firstName
        self.lastName = loginResponse.data?.lastName
        self.password = loginResponse.data?.password
        self.dob = loginResponse.data?.dob
        self.gender = loginResponse.data?.gender
        self.role = loginResponse.data?.role
        self.avatar = loginResponse.data?.avatar
        self.cover = loginResponse.data?.cover
    }
}

struct ShortUser: Codable {
    let _id: String?
    let firstName: String?
    let lastName : String?
    let avatar: String?
    let role: String?
}

enum UserRole: String {
    case user = "ROLE_USER"
    case attorney = "ROLE_ATTORNEY"
}

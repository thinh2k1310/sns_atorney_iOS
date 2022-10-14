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
    var dob: Date?
    var gender: String?
    var role: String?
    var avatar: String?
    var cover: String?
}

//
//  Case.swift
//  Attorney
//
//  Created by Truong Thinh on 29/11/2022.
//

import Foundation

struct Case: Codable {
    let _id: String?
    let attorney: String?
    let customer: String?
    let post: String?
    let status: String?
    let startingTime: String?
    let endingTime: String?
}

struct DefenceRequest: Codable {
    let attorneyId: String?
    let postId: String?
    let customerId: String?
}

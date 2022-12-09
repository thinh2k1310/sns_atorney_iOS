//
//  Case.swift
//  Attorney
//
//  Created by Truong Thinh on 29/11/2022.
//

import Foundation

struct Case: Codable {
    let _id: String?
    let attorney: ShortUser?
    let customer: ShortUser?
    let post: ShortPost?
    let status: String?
    let attorneyStatus: String?
    let customerStatus: String?
    let startingTime: String?
    let endingTime: String?
}

struct DefenceRequest: Codable {
    let attorneyId: String?
    let postId: String?
    let customerId: String?
}

struct DefenceRequestResponse: Codable {
    let success: Bool?
    let message: String?
    let data: [Case]?
}

struct CaseDetailResponse: Codable {
    let success: Bool?
    let message: String?
    let data: Case?
}

struct CasesResponse: Codable {
    let success: Bool?
    let message: String?
    let inProgressCases: [Case]?
    let completedCases: [Case]?
    let cancelledCases: [Case]?
}

//
//  Report.swift
//  Attorney
//
//  Created by ThinhTCQ on 12/26/22.
//

import Foundation

struct ReportRequest: Codable {
    let reportingUser: String
    let reportedUser: String
    let type: String
    let post: String?
    let comment: String?
    let problem: String
}

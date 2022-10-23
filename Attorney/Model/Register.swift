//
//  Register.swift
//  Attorney
//
//  Created by ThinhTCQ on 10/23/22.
//

import Foundation

struct RegisterRequest: Codable {
    let address: String?
    let birthDate: String
    let customerPassword: String
    let email: String
    let familyName: String
    let givenName: String?
    let phoneNumber: String?
    let otpValidationRequest: String?
}

struct RegisterResponse: Codable {
    let status: String?
    let code: String?
    let response: ResponseRegister?

    enum CodingKeys: String, CodingKey {
        case status
        case code
        case response
    }

    struct ResponseRegister: Codable {
        let customerId: String?
        let isUniqueEmail: String?
        let isPartnerEnrolSuccess: String?
        let errorCode: String?
        let errorDescription: String?

        enum CodingKeys: String, CodingKey {
            case customerId
            case isUniqueEmail
            case isPartnerEnrolSuccess
            case errorCode
            case errorDescription
        }
    }
}

struct RegisterOTPRequest: Codable {
    let apiVersion: Int?
    let clientID: String?
    let clientUUID: String?
    let request: RequestOTP?
    struct RequestOTP: Codable {
        let deviceID: String?
        let deviceType: String?
        let contactOS: String?
        let customerID: String?
        let customerType: String?
        let customerIP: String?
        let contactMode: String?
        let customerContact: String?
        let customerFamilyName: String?
        let senderEmail: String?
        let customerSalutation: String?
    }
}

struct RegisterOTPResponse: Codable {
    let status: String?
    let code: String?
    let message: String?
    let clientUUID: String?
    let response: ResponseRegisterOTP?
    let displayMessage: String?

    enum CodingKeys: String, CodingKey {
        case status
        case code
        case message
        case clientUUID
        case response
        case displayMessage
    }
    struct ResponseRegisterOTP: Codable {
        let otp: String?
        let expiryDateTime: String?

        enum CodingKeys: String, CodingKey {
            case otp
            case expiryDateTime
        }
    }
}

extension RegisterRequest {
    func convertArrayToString<T: Codable>(_ input: T?) -> String {
        guard let jsonData = try? JSONEncoder().encode(input) else { return "" }
        let jsonString = String(data: jsonData, encoding: .utf8)!
        return jsonString
    }
}

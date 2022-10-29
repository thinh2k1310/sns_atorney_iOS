//
//  AttorneyAPI.swift
//  Attorney
//
//  Created by Truong Thinh on 10/10/2022.
//

import Foundation
import Moya
import RxSwift

enum AttorneySNSAPI {
    // MARK: - Auth
    case loginOTP(loginOTPRequest: LoginRequest)
}

extension AttorneySNSAPI: TargetType {
    var baseURL: URL {
        let url = Bundle.main.object(forInfoDictionaryKey: "BaseURL") as? String
        return URL(string: url ?? "")!
    }
    
    var path: String {
        switch self {
        case .loginOTP:
            return "auth/login"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .loginOTP:
            return .post
        default:
            return .get
        }
    }
    
    var parameters: [String: Any]? {
        return nil
    }

    var parameterEncoding: ParameterEncoding {
        return JSONEncoding.default
    }

    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        switch self {
        case .loginOTP(let loginOTPRequest):
            return .requestJSONEncodable(loginOTPRequest)
        }
    }
    
    var headers: [String : String]? {
        var headersValue: [String: String] = [:]
        guard let token = UserService.shared.accessToken else { return headersValue }
        headersValue = ["Authorization" : "Bearer \(token)"]
        return headersValue
    }
    
    
}

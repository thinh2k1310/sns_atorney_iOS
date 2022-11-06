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
    case register(registerRequest: RegisterRequest)
    case validateEmail(validateEmailRequest: ValidateEmailRequest)
    case sendOTP(sendOTPRequest: SendOTPRequest)
    case resetPassword(resetPasswordRequest: ResetPasswordRequest)
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
        
        case .register:
            return "auth/register"
            
        case .validateEmail:
            return "auth/validate"
            
        case .sendOTP:
            return "auth/sendOTP"
            
        case .resetPassword:
            return "auth/password/reset"
        }
        
    }
    
    var method: Moya.Method {
        switch self {
        case .loginOTP, .register:
            return .post
        
        case .validateEmail, .sendOTP, .resetPassword:
            return .put
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
        case .register(let registerRequest):
            return .requestJSONEncodable(registerRequest)
        case .validateEmail(let validateEmailRequest):
            return .requestJSONEncodable(validateEmailRequest)
        case .sendOTP(let sendOTPRequest):
            return .requestJSONEncodable(sendOTPRequest)
        case .resetPassword(let resetPasswordRequest):
            return .requestJSONEncodable(resetPasswordRequest)
        }
    }
    
    var headers: [String : String]? {
        var headersValue: [String: String] = [:]
        guard let token = UserService.shared.accessToken else { return headersValue }
        headersValue = ["Authorization" : "Bearer \(token)"]
        return headersValue
    }
    
    
}

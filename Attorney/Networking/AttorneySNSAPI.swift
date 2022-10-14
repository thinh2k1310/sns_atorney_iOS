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
    
}

extension AttorneySNSAPI: TargetType {
    var baseURL: URL {
        return URL(string: "")!
    }
    
    var path: String {
        return ""
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
    
    var method: Moya.Method {
        return .post
    }
    
    var task: Task {
        return .requestPlain
    }
    
    var headers: [String : String]? {
        var headersValue = ["Authorization" : "Bearer"] 
        return headersValue
    }
    
    
}

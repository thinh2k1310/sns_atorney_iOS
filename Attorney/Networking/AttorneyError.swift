//
//  AttorneyError.swift
//  Attorney
//
//  Created by ThinhTCQ on 10/29/22.
//

import Foundation
import Moya

protocol URLResponseErrorInformation {
    var urlString: String { get }
    var responseDescription: String { get }
    var statusCode: Int { get }
}

// MARK: - URLResponseErrorInformation
extension Response: URLResponseErrorInformation {
    var urlString: String {
        return (response?.url?.absoluteString ?? "unknown request url")
    }
    
    var responseDescription: String {
        return "\(statusCode): \(description)"
    }
}

enum AttorneyError: Error {
    /// Network error
    case disconnect(response: URLResponseErrorInformation, description: String)
    case timeOut(response: URLResponseErrorInformation, description: String)
    ///
    case serverError(response: URLResponseErrorInformation, description: String)
    case silentError(response: URLResponseErrorInformation, description: String)
    
    case information(errorCode: String, description: String)
    
    var urlString: String {
        switch self {
        case .disconnect(let response, _):
            return response.urlString
            
        case .timeOut(let response, _):
            return response.urlString
            
        case .silentError(let response, _):
            return response.urlString
            
        case .serverError(let response, _):
            return response.urlString
        default:
            return ""
        }
    }
    
    var code: Int {
        switch self {
        case .disconnect:
            return NSURLErrorNetworkConnectionLost
            
        case .timeOut:
            return NSURLErrorTimedOut
            
        case .silentError(let response, _):
            return response.statusCode
            
        case .serverError(let response, _):
            return response.statusCode
        
        case .information:
            return AttorneyError.server
        }
    }
    
    var description: String {
        switch self {
        case .disconnect(_, let description):
            return description
            
        case .timeOut(_, let description):
            return description
            
        case .serverError(_, let description):
            return description
            
        case .silentError(_, let description):
            return description
        
        case .information(_,let description):
            return description
        }
    }
    
    var errorCodeString: String {
        return ""
    }
    
    var response: URLResponseErrorInformation? {
        switch self {
        case .disconnect(let response, _):
            return response
            
        case .timeOut(let response, _):
            return response
            
        case .serverError(let response, _):
            return response
            
        case .silentError(let response, _):
            return response
        
        default:
            return nil
        }
    }
    static let server: Int = 900
}

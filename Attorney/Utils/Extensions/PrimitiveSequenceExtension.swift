//
//  PrimitiveSequenceExtension.swift
//  Attorney
//
//  Created by ThinhTCQ on 10/29/22.
//

import Foundation
import Moya
import RxSwift

extension PrimitiveSequence where Trait == SingleTrait, Element == Response {
    
    func catchAttorneyError() -> Single<Element> {
        return flatMap { response in
            if response.statusCode == NSURLErrorTimedOut {
                // Handle timeout
                throw AttorneyError.timeOut(response: response, description: StringConstants.string_generic_error(preferredLanguages: preferredLanguages))
            }
            if response.statusCode == NSURLErrorNetworkConnectionLost {
                throw AttorneyError.disconnect(response: response, description: StringConstants.string_generic_error(preferredLanguages: preferredLanguages))
            }
            if (200...299).contains(response.statusCode) {
                let errorResponse = try? ErrorResponse.decode(from: response.data)
                
                if errorResponse != nil && errorResponse?.code != nil && errorResponse?.success != true {
                    let errorCode: String = (errorResponse?.code ?? "")
                    let description: String = (errorResponse?.message ?? "")
                    throw AttorneyError.information(errorCode: errorCode, description: description)
                } else {
                    return .just(response)
                }
            } else {
                throw AttorneyError.serverError(response: response, description: StringConstants.string_generic_error(preferredLanguages: preferredLanguages))
            }
        }
    }

    func excuteError() -> Single<Element> {
        return observe(on: MainScheduler.instance).do(onError: { error in
            if let error = error as? AttorneyError {
                switch error {
                case .disconnect, .timeOut, .serverError:
                    ErrorViewController.showErrorVC()

                case .information(let _, let message):
                    log.debug(message)
                
                default:
                    break
                }
            }
        })
    }
}

extension PrimitiveSequenceType where Trait == SingleTrait {
    func `do`(on observer: @escaping (SingleEvent<Element>) -> Void) -> Single<Element> {
        return self.do { element in
            observer(.success(element))
        } onError: { error in
            observer(.failure(error))
        }
    }
}

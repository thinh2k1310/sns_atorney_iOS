//
//  RestAPI.swift
//  Attorney
//
//  Created by Truong Thinh on 10/10/2022.
//

import Alamofire
import Foundation
import Moya
import RxCocoa
import RxSwift

class RestAPI: AttorneyAPI {
    let attorneyProvider: AttorneyNetworking
    
    init(attorneyProvider: AttorneyNetworking) {
        self.attorneyProvider = attorneyProvider
    }
}

extension RestAPI {
    func login(email: String, password: String) -> Single<LoginResponse> {
        let loginRequest = LoginRequest(email: email, password: password)
        return requestObject(.loginOTP(loginOTPRequest: loginRequest), type: LoginResponse.self)
    }
}

extension RestAPI {
    private func requestObject<T: Codable>(_ target: AttorneySNSAPI, type: T.Type) -> Single<T> {
        return attorneyProvider.request(target)
            .mapObject(type)
            .observe(on: MainScheduler.instance)
            .asSingle()
    }
}

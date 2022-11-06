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
    
    func register(registerRequest: RegisterRequest) -> Single<RegisterResponse> {
        return requestObject(.register(registerRequest: registerRequest), type: RegisterResponse.self)
    }
    
    func validateEmail(validateEmailRequest: ValidateEmailRequest) -> Single<ValidateEmailResponse> {
        return requestObject(.validateEmail(validateEmailRequest: validateEmailRequest), type: ValidateEmailResponse.self)
    }
    
    func sendOTP(sendOTPRequest: SendOTPRequest) -> Single<SendOTPResponse> {
        return requestObject(.sendOTP(sendOTPRequest: sendOTPRequest), type: SendOTPResponse.self)
    }
    
    func resetPassword(resetPasswordRequest: ResetPasswordRequest) -> Single<ResetPasswordResponse> {
        return requestObject(.resetPassword(resetPasswordRequest: resetPasswordRequest), type: ResetPasswordResponse.self)
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

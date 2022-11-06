//
//  RequestOTPViewModel.swift
//  Attorney
//
//  Created by ThinhTCQ on 11/4/22.
//

import Foundation
import RxSwift

final class RequestOTPViewModel: ViewModel {
    
    var email: String?
    public var timeRequestOTP: TimeInterval?
    let eventRequestOTP = PublishSubject<RequestOTPEvent>()
    
    override init(provider: AttorneyAPI) {
        super.init(provider: provider)
    }

    public func excuteSendOTP() {
        guard let email = email else { return }
        self.timeRequestOTP = Date().timeIntervalSince1970
        self.provider
            .sendOTP(sendOTPRequest: SendOTPRequest(email: email))
            .trackActivity(self.bodyLoading).asSingle()
            .subscribe(onSuccess: { [weak self] response in
                guard let self = self else { return }
                if response.success == true {
                    self.eventRequestOTP.onNext(.successRequestOTP(response: response))
                } else {
                    self.eventRequestOTP.onNext(.errorRequestOTP(errorMessage: response.message))
                }
            })
            .disposed(by: disposeBag)
    }
}

enum RequestOTPEvent {
    case successRequestOTP(response: SendOTPResponse)
    case errorRequestOTP(errorMessage: String?)
}

//
//  File.swift
//  Attorney
//
//  Created by ThinhTCQ on 11/2/22.
//

import Foundation
import RxSwift

final class VerifyOTPViewModel: ViewModel {
    public var timeRequestOTP: TimeInterval?
    public var email: String?
    public var isUser: Bool?

    let eventVerifyOTP = PublishSubject<VerifyOTPEvent>()

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
                    self.eventVerifyOTP.onNext(.successSendOTP(response: response))
                } else {
                    self.eventVerifyOTP.onNext(.errorSendOTP(errorMessage: response.message))
                }
            })
            .disposed(by: disposeBag)
    }

    public func excuteValidateEmail(otp: String) {
        guard let email = email, let isUser = isUser else { return }
        self.timeRequestOTP = Date().timeIntervalSince1970
        self.provider
            .validateEmail(validateEmailRequest: ValidateEmailRequest(email: email, OTP: otp, isUser: isUser))
            .trackActivity(self.bodyLoading).asSingle()
            .subscribe(onSuccess: { [weak self] response in
                if response.success == true {
                    self?.eventVerifyOTP.onNext(.successValidateEmail(response: response))
                } else {
                    self?.eventVerifyOTP.onNext(.errorValidateEmail(errorMessage: response.message))
                }
            }, onFailure: { [weak self] (error) in
                if let attorneyError = error as? AttorneyError {
                    self?.eventVerifyOTP.onNext(.errorValidateEmail(errorMessage: attorneyError.description))
                } else {
                    self?.eventVerifyOTP.onNext(.errorValidateEmail(errorMessage: error.localizedDescription))
                }
            })
            .disposed(by: disposeBag)
    }

    public func displayMessage() -> String? {
        guard let email = email else { return "" }
        return "Enter the 6-digit OTP sent to \(email) within 3 minutes. Remember to check your spam/junk folder!"
    }

    private func storeRegisterEmail() {
        guard let email = self.email else { return }
        UserDefaults.standard.set(email, forKey: "storedEmail")
    }
}

enum VerifyOTPEvent {
    case successSendOTP(response: SendOTPResponse)
    case errorSendOTP(errorMessage: String?)
    case successValidateEmail(response: ValidateEmailResponse)
    case errorValidateEmail(errorMessage: String?)
}

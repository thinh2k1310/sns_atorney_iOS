//
//  LoginViewModel.swift
//  Attorney
//
//  Created by ThinhTCQ on 10/29/22.
//

import Foundation
import RxSwift

class LoginViewModel: ViewModel {
    let events = PublishSubject<ResponseLoginViewModelEvent>()

    override init(provider: AttorneyAPI) {
        super.init(provider: provider)
    }

    func loginUser(email: String, password: String) {
        self.provider
            .login(email: email, password: password)
            .trackActivity(self.bodyLoading).asSingle()
            .subscribe(onSuccess: { [weak self] (response) in
                if response.success == false {
                    self?.events.onNext(.errorLogin(error: response.message ?? MessageError.genericError))
                    return
                }
                guard let this = self else { return }

                UserService.shared.setLoginResponse(response)

                // Save user infor
                UserService.saveLastEmail(email: email.isValidEmail() ? email : "")

                let userInfo = UserInfo(loginResponse: response)
                UserService.shared.setUserInfo(info: userInfo)
                UserService.shared.saveAccessToken(token: response.token ?? "")
                
                guard let verified = response.data?.verified else {
                    this.loginSuccess(userInfo: userInfo,
                                      response: response)
                    return
                }

                if verified == true {
                        this.loginSuccess(userInfo: userInfo,
                                          response: response,
                                          email: email,
                                          password: password)
                } else {
                    this.events.onNext(.errorLogin(error: MessageError.unVerified))
                }
            })
            .disposed(by: disposeBag)
    }
    
    func performLogin(email: String, password: String) {
        self.events.onNext(.performLogin(email: email, password: password))
    }

    private func loginSuccess(userInfo: UserInfo?,
                              response: LoginResponse,
                              email: String = "",
                              password: String = "") {
        UserService.shared.setUserInfo(info: userInfo)

        let userLogin = UserKey.kUserInfoLogin + email
        UserService.shared.saveInfoNameKey(nameKey: userLogin)
        self.events.onNext(.successLogin(response: response))
    }
}

enum ResponseLoginViewModelEvent {
    case performLogin(email: String, password: String)
    case successLogin(response: LoginResponse)
    case errorLogin(error: String)
}

extension ResponseLoginViewModelEvent: Equatable {
    static func == (lhs: ResponseLoginViewModelEvent, rhs: ResponseLoginViewModelEvent) -> Bool {
        switch (lhs, rhs) {
        case (.successLogin(let responseA),
              .successLogin(let responseB)):
            return responseA == responseB

        case (.errorLogin, .errorLogin),
            (.performLogin, .performLogin):
            return true

        default:
            return false
        }
    }
}

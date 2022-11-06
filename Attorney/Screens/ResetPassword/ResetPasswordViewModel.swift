//
//  ResetPasswordViewModel.swift
//  Attorney
//
//  Created by ThinhTCQ on 11/5/22.
//

import Foundation
import RxCocoa
import RxSwift

enum ResetPasswordEvent {
    case resetPasswordSuccess
    case resetPasswordError(errorMessage: String?)
}

final class ResetPasswordViewModel: ViewModel {
    var email: String?
    var password: String?
    let events = PublishSubject<ResetPasswordEvent>()
    
    override init(provider: AttorneyAPI) {
        super.init(provider: provider)
    }
    
    func resetPassword() {
        guard let email = self.email, let password = self.password else {
            return
        }
        self.provider.resetPassword(resetPasswordRequest: ResetPasswordRequest(email: email, password: password))
            .trackActivity(self.bodyLoading).asSingle()
            .subscribe(onSuccess: { [weak self] response in
                if response.success == true {
                    self?.events.onNext(.resetPasswordSuccess)
                }  else {
                    self?.events.onNext(.resetPasswordError(errorMessage: response.message))
                }
            })
            .disposed(by: disposeBag)
    }
}

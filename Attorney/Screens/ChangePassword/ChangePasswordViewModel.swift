//
//  ChangePasswordViewModel.swift
//  Attorney
//
//  Created by ThinhTCQ on 12/6/22.
//

import Foundation
import RxSwift

enum ChangePasswordEvent {
    case changePasswordSuccess
    case incorrectOldPassword(errorMessage: String?)
}

final class ChangePasswordViewModel: ViewModel {
    var oldPassword: String?
    var newPassword: String?
    let events = PublishSubject<ChangePasswordEvent>()
    
    override init(provider: AttorneyAPI) {
        super.init(provider: provider)
    }
    
    func changePassword() {
        guard let oldPassword = self.oldPassword, let newPassword = self.newPassword else {
            return
        }
        self.provider.changePassword(request: ChangePasswordRequest(password: oldPassword, newPassword: newPassword))
            .trackActivity(self.bodyLoading).asSingle()
            .subscribe(onSuccess: { [weak self] response in
                if response.success == true {
                    self?.events.onNext(.changePasswordSuccess)
                }  else {
                    self?.events.onNext(.incorrectOldPassword(errorMessage: response.message))
                }
            })
            .disposed(by: disposeBag)
    }
}

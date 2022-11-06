//
//  RegistrasionViewModel.swift
//  Attorney
//
//  Created by ThinhTCQ on 10/23/22.
//

import Foundation
import RxCocoa
import RxSwift

enum RegistrationEvent {
    case registerSuccess(response: RegisterResponse, registerBody: RegisterRequest)
    case registerFailure(errorMessage: String?)
    case errorDuplicateEmail
}

extension RegistrationEvent: Equatable {
    static func == (lhs: RegistrationEvent, rhs: RegistrationEvent) -> Bool {
        switch (lhs, rhs) {
        case (.registerSuccess, .registerSuccess),
             (.registerFailure, .registerFailure):
            return true

        default:
            return false
        }
    }
}

extension Array where Element: Hashable {
    func removingDuplicates() -> [Element] {
        var addedDict = [Element: Bool]()

        return filter {
            addedDict.updateValue(true, forKey: $0) == nil
        }
    }

    mutating func removeDuplicates() {
        self = self.removingDuplicates()
    }
}

final class RegistrationViewModel: ViewModel {
    let events = PublishSubject<RegistrationEvent>()

    let eventChooseCountry = PublishSubject<String?>()
    let eventChooseState = PublishSubject<String?>()
    let dateToFocus = BehaviorRelay<String?>(value: "DD/MM/YYYY")

    var registerBody: RegisterRequest?
    // MARK: - Submit check box term & conditions and privacy policy variable
    var isAttorney: Bool = false
   
    override init(provider: AttorneyAPI) {
        super.init(provider: provider)
    }

}

extension RegistrationViewModel {
    func handleRegister(with validationForm: ValidationRegistrationForm) {
        registerBody = mergeData(from: validationForm)
        register()
    }

    private func mergeData(from validationForm: ValidationRegistrationForm) -> RegisterRequest? {
        var role = "ROLE_USER"
        if validationForm.isAttorney {
            role = "ROLE_ATTORNEY"
        }
        return RegisterRequest(address: validationForm.address ?? "",
                               dob: validationForm.dateOfBirth,
                               password: validationForm.password,
                               email: validationForm.email,
                               firstName: validationForm.firstName,
                               lastName: validationForm.lastName,
                               phoneNumber: validationForm.mobile,
                               role: role)
    }

    private func register() {
        guard let registerBody = registerBody else { return }
        self.provider.register(registerRequest: registerBody)
            .trackActivity(self.bodyLoading).asSingle()
            .subscribe(onSuccess: { [weak self] regResponse in
                if regResponse.success == true {
                    self?.events.onNext(.registerSuccess(response: regResponse, registerBody: registerBody))
                } else if regResponse.isUniqueEmail == false {
                    self?.events.onNext(.errorDuplicateEmail)
                } else {
                    self?.events.onNext(.registerFailure(errorMessage: regResponse.message))
                }
            }, onFailure: { [weak self] error in
                if let attorneyError = error as? AttorneyError {
                    self?.events.onNext(.registerFailure(errorMessage: attorneyError.description))
                } else {
                    self?.events.onNext(.registerFailure(errorMessage: error.localizedDescription))
                }
            })
            .disposed(by: disposeBag)
    }
}

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

class RegistrationViewModel: ViewModel {
    var listMobileNumber: [String] = []
    var countryCode: String!

    let events = PublishSubject<RegistrationEvent>()

    let eventChooseCountry = PublishSubject<String?>()
    let eventChooseState = PublishSubject<String?>()
    let dateToFocus = BehaviorRelay<String?>(value: "DD/MM/YYYY")

    var registerBody: RegisterRequest?
    var referralCode: String?
    // MARK: - Submit check box term & conditions and privacy policy variable
    var receiveKrisFlyerAndSIASelected = false
    var receiveSIAPromotionSelected = false
    var bySubmitPrivacyAndTermSelected = false
    var bySubmitTurkeyPrivacySelected = false
    var bySubmitKoreanTermAndConditionSelected = false
    var bySubmitKoreanPrivacyPolicySelected = false

    override init(provider: AttorneyAPI) {
        super.init(provider: provider)
    }

    func getValidationStatusTaCAndPrivacy() -> Bool {
        return self.bySubmitPrivacyAndTermSelected
    }
}

extension RegistrationViewModel {
    func handleRegister(with validationForm: ValidationRegistrationForm) {
        registerBody = mergeData(from: validationForm)
//        register()
    }

    private func mergeData(from validationForm: ValidationRegistrationForm) -> RegisterRequest? {
        let address = ""
        let phoneNumber = ""
        let otpValidationRequest = ""

        return RegisterRequest(address: address,
                               birthDate: validationForm.dateOfBirth.formatDateMappingAPI(),
                               customerPassword: validationForm.password,
                               email: validationForm.email,
                               familyName: validationForm.lastName,
                               givenName: validationForm.isSelectedHideFirstNameButton ? "" : validationForm.firstName,
                               phoneNumber: phoneNumber,
                               otpValidationRequest: otpValidationRequest)
    }

//    private func register() {
//        guard let registerBody = registerBody else { return }
//        self.provider.register(registerRequest: registerBody)
//            .trackActivity(self.bodyLoading).asSingle()
//            .subscribe(onSuccess: { [weak self] regResponse in
//                if regResponse.status == "SUCCESS" && regResponse.response?.isUniqueEmail == "true" {
//                    RealmServiceRegister.shared.resetDBRegister()
//                    RealmServiceRegister.shared.saveRegister(register: registerBody)
//                    self?.events.onNext(.registerSuccess(response: regResponse, registerBody: registerBody))
//                } else if regResponse.status == "SUCCESS" && regResponse.response?.isUniqueEmail == "false" {
//                    self?.events.onNext(.errorDuplicateEmail)
//                } else if regResponse.status == "FAILURE" {
//                    let params: [String: Any] = [
//                        "error_code": regResponse.response?.errorCode ?? "",
//                        "error_message": regResponse.response?.errorDescription ?? ""
//                    ]
//                    FirebaseService.shared.reportLogEventToFireBase(eventName: "sign_up_failure", params: params)
//                    self?.events.onNext(.registerFailure(errorMessage: regResponse.response?.errorDescription))
//                }
//            }, onFailure: { [weak self] error in
//                if let krisPayError = error as? KrisPayError {
//                    let params: [String: Any] = [
//                        "error_code": krisPayError.errorCodeString,
//                        "error_message": krisPayError.description
//                    ]
//                    FirebaseService.shared.reportLogEventToFireBase(eventName: "sign_up_failure", params: params)
//                    self?.events.onNext(.registerFailure(errorMessage: krisPayError.description))
//                } else {
//                    self?.events.onNext(.registerFailure(errorMessage: error.localizedDescription))
//                }
//            })
//            .disposed(by: disposeBag)
//    }
}

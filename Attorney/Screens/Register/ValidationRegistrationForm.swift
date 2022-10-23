//
//  ValidationRegistrationForm.swift
//  Attorney
//
//  Created by ThinhTCQ on 10/23/22.
//

import Foundation
import RxSwift


class ValidationRegistrationForm {
    public private(set) var firstName: String?
    public private(set) var isSelectedHideFirstNameButton: Bool = false

    public private(set) var lastName: String!
    public private(set) var dateOfBirth: String!
    public private(set) var email: String!
    public private(set) var mobile: String!
    public private(set) var address: String!

    public private(set) var password: String!
    public private(set) var confirmPasword: String?

    public var isBetweenTwoAndSixteen: Bool = false

    private var bySubmitPrivacyAndTermSelected = false

    let valueFirstName = PublishSubject<String?>()
    let valueLastName = PublishSubject<String?>()
    let valueEmail = PublishSubject<String?>()
    let valueMobileNumber = PublishSubject<String?>()
    let valuePassword = PublishSubject<String?>()
    let valueConfirmPassword = PublishSubject<String?>()
    let valueDatePicker = PublishSubject<String?>()
    let valueTermsAndPrivacyCheckboxSelected = PublishSubject<Bool>()

    // Need validation form
    let validationStatusFirstName = PublishSubject<StatusField>()
    let validationStatusLastName = PublishSubject<StatusField>()
    let validationStatusDate = PublishSubject<StatusField>()
    let validationStatusEmail = PublishSubject<StatusField>()
    let validationStatusMobi = PublishSubject<StatusField>()
    let validationStatusPassword = PublishSubject<StatusField>()
    let validationStatusConfirmPassword = PublishSubject<StatusField>()
    let validationStatusTermsAndPrivacyCheckboxSelected = PublishSubject<StatusField>()
    // This property handle for disable or enable button register
    let validtionForm = PublishSubject<Bool>()

    let disposeBag = DisposeBag()

    init() {
        self.recieveEventNeedToValidationForm()
        self.handleValidationAllForm()
    }

    // swiftlint:disable function_body_length
    // swiftlint:disable cyclomatic_complexity
    private func recieveEventNeedToValidationForm() {
        self.valueFirstName
            .subscribe(onNext: { [weak self] firstName in
                guard let this = self else { return }
                if firstName == nil {
                    this.validationStatusFirstName.onNext(.invalid)
                    return
                }
                this.firstName = firstName
                if !this.isSelectedHideFirstNameButton {
                    let validation = this.executeValidationFirstName()
                    this.validationStatusFirstName.onNext(validation ? .valid : .invalid)
                }
            })
            .disposed(by: disposeBag)

        self.valueLastName
            .subscribe(onNext: { [weak self] lastName in
                guard let this = self else { return }
                if lastName == nil {
                    this.validationStatusLastName.onNext(.invalid)
                    return
                }
                this.lastName = lastName
                let validation = this.executeValidationLastName()
                this.validationStatusLastName.onNext(validation ? .valid : .invalid)
            })
            .disposed(by: disposeBag)

        self.valueDatePicker
            .subscribe(onNext: { [weak self] touchDatePicker in
                guard let this = self, let touchDatePicker = touchDatePicker else { return }
                this.dateOfBirth = touchDatePicker
                let validation = this.executeValidationDate()
                this.validationStatusDate.onNext(validation ? .valid : .invalid)
            })
            .disposed(by: disposeBag)

        self.valueEmail
            .subscribe(onNext: { [weak self] email in
                guard let this = self else { return }
                this.email = email
                let validation = this.executeValidationEmail()
                if this.confirmPasword != nil && (this.password == "" || this.confirmPasword != "") {
                    let validation = this.excuteValidationConfirmPassword()
                    this.validationStatusConfirmPassword.onNext(validation ? .valid : .invalid)
                }
                this.validationStatusEmail.onNext(validation ? .valid : .invalid)
            })
            .disposed(by: disposeBag)

        self.valueConfirmPassword
            .subscribe(onNext: { [weak self] confirmPasword in
                guard let this = self else { return }
                this.confirmPasword = confirmPasword
                let validation = this.excuteValidationConfirmPassword()
                this.validationStatusConfirmPassword.onNext(validation ? .valid : .invalid)
            })
            .disposed(by: disposeBag)

        self.valueMobileNumber
            .subscribe(onNext: { [weak self] mobile in
                guard let this = self else { return }
                this.mobile = mobile
                let validation = this.executeValidationMobile()
                this.validationStatusMobi.onNext(validation ? .valid : .invalid)
            })
            .disposed(by: disposeBag)

        self.valuePassword
            .subscribe(onNext: { [weak self] password in
                guard let this = self else { return }
                this.password = password
                let validation = this.executeValidationPassword()
                this.validationStatusPassword.onNext(validation ? .valid : .invalid)
            })
            .disposed(by: disposeBag)

        self.valueTermsAndPrivacyCheckboxSelected
            .subscribe(onNext: { [weak self] status in
                guard let this = self else { return }
                this.bySubmitPrivacyAndTermSelected = status
                let validation = this.excuteValidationTaCAndPrivacySelected()
                this.validationStatusTermsAndPrivacyCheckboxSelected.onNext(validation ? .valid : .invalid)
            }).disposed(by: disposeBag)
    }

    private func handleValidationAllForm() {
        Observable.merge(validationStatusFirstName,
                         validationStatusLastName,
                         validationStatusDate,
                         validationStatusEmail,
                         validationStatusConfirmPassword,
                         validationStatusMobi,
                         validationStatusPassword,
                         validationStatusTermsAndPrivacyCheckboxSelected
                         )
            .subscribe(onNext: { [weak self] _ in
                guard let this = self else { return }
                var valid = this.executeValidationLastName() &&
                this.executeValidationDate() &&
                this.executeValidationEmail() &&
                this.excuteValidationConfirmPassword() &&
                this.executeValidationMobile() &&
                this.executeValidationPassword() &&
                this.excuteValidationTaCAndPrivacySelected()

                log.debug("validForm:--\(valid)")
                this.validtionForm.onNext(valid)
            })
            .disposed(by: disposeBag)
    }
}
// MARK: Validation bussiness
extension ValidationRegistrationForm {
    private func executeValidationFirstName() -> Bool {
        guard let firstName = self.firstName, firstName.isValidTextOnlyEnglish(), !firstName.isEmpty else { return false }
        return true
    }

    private func executeValidationLastName() -> Bool {
        guard lastName != nil, !lastName.isEmpty, lastName.isValidTextOnlyEnglish(), lastName.count > 1 else { return false }
        return true
    }

    private func executeValidationDate() -> Bool {
        guard dateOfBirth != nil, dateOfBirth != "DD/MM/YYYY" else {
            return false
        }
        let date = dateOfBirth.convertStringToDate(fortmat: Configurations.Format.dateOfBirth)
        let components = Calendar.current.dateComponents([.month], from: date, to: Date().toDateLocalTime())
        let isLargerSixteenYear = components.month ?? 0 >= 192 ? true : false
//        self.isBetweenTwoAndSixteen = (components.month ?? 0 >= 24 && components.month ?? 0 < 192) ? true: false
        return isLargerSixteenYear
    }

    private func executeValidationEmail() -> Bool {
        guard email != nil, email.isValidEmailRegister() else { return false }
        return true
    }

    private func excuteValidationConfirmPassword() -> Bool {
        guard confirmPasword != nil, confirmPasword?.lowercased() == password?.lowercased() || (confirmPasword == "" && password == nil) else { return false }
        return true
    }

    private func executeValidationMobile() -> Bool {
        guard mobile != nil, !mobile.isEmpty, !(mobile.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) != nil), mobile.count >= 7, mobile.isValidNumberPhoneRepeat(), mobile.isValidNumberPhoneSequential() else { return false }
        return true
    }

    private func executeValidationPassword() -> Bool {
        guard password != nil, !password.isEmpty, password.isValidPassword() else {
            return false
        }
        return true
    }
    private func excuteValidationTaCAndPrivacySelected() -> Bool {
        return self.bySubmitPrivacyAndTermSelected
    }
}

// MARK: Enum
public enum StatusField {
    case valid
    case invalid
}
extension StatusField: Equatable {
    public static func == (lhs: StatusField, rhs: StatusField) -> Bool {
        switch (lhs, rhs) {
        case (.valid, .valid),
             (.invalid, .invalid):
            return true

        default:
            return false
        }
    }
}

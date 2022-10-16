//
//  AttorneyFormatter.swift
//  Attorney
//
//  Created by ThinhTCQ on 10/15/22.
//

import Foundation
import PassKit

final class AttorneyFormatter {
    static let shared = AttorneyFormatter()

    var passRegEx: String?
    var phoneNumberRegEx: String?
    var applePaySupportedCard: [String]?

    func getPassRegEx() -> String {
        return passRegEx ?? "^(?=.*\\d)(?=.*[a-z])(?=.*[A-Z])[\\w~@#$%^&*+=/|{}:;!.?\\()\\[\\] -]{8,16}$"
    }

    func getPhoneNumberRegEx() -> String {
        return phoneNumberRegEx ?? "^(\\d)(?!\\1+$)(?!(\\d)\\1+$|(?:0(?=1)|1(?=2)|2(?=3)|3(?=4)|4(?=5)|5(?=6)|6(?=7)|7(?=8)|8(?=9)|9(?=0)){6,13}\\d$|(?:0(?=9)|1(?=0)|2(?=1)|3(?=2)|4(?=3)|5(?=4)|6(?=5)|7(?=6)|8(?=7)|9(?=8)){6,13}\\d$)\\d{7,14}$"
    }
}

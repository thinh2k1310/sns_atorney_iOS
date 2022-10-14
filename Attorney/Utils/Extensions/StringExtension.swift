//
//  StringExtension.swift
//  Attorney
//
//  Created by Truong Thinh on 12/10/2022.
//

import UIKit
extension String {
    func trim() -> String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func safelyLimitedTo(length num: Int) -> String {
        if self.count <= num {
            return self
        }
        return String( Array(self).prefix(upTo: num) )
    }
    
    func toBase64String() -> String {
        let utf8str = self.data(using: String.Encoding.utf8)

        if let base64Encoded = utf8str?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0)) {
            return base64Encoded
        }
        return self
    }
}

extension String {
    public func isValidLoginPassword() -> Bool {
        if self.count <= 6 {
            return self.isValidOldPassword()
        }

        return self.isValidPassword()
    }

    public func isValidPassword() -> Bool {
        let pwdRegex = KrisPayFormatter.shared.getPassRegEx()
        return NSPredicate(format: "SELF MATCHES %@", pwdRegex).evaluate(with: self)
    }

    public func isValidOldPassword() -> Bool {
        let pwdRegex = "^[0-9]{6}$"
        return NSPredicate(format: "SELF MATCHES %@", pwdRegex).evaluate(with: self)
    }

    public func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9_]+(\\.[A-Za-z0-9_]{2,64}){1,2}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegEx).evaluate(with: self)
    }

    public func isValidEmailRegister() -> Bool {
        let emailRegisterRegEx = "(^[A-Z0-9a-z]((\\.|\\_|\\%|\\+|\\-)?[A-Z0-9a-z]){1,})+@([A-Za-z0-9_])+(\\.(?=.*[A-Za-z])[A-Za-z0-9_]{1,64}){1,2}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegisterRegEx).evaluate(with: self)
    }
    
    public func isValidPasswordRegister() -> Bool {
        let pwdRegex = KrisPayFormatter.shared.getPassRegEx()
        return NSPredicate(format: "SELF MATCHES %@", pwdRegex).evaluate(with: self)
    }

    public func isValidNumberPhoneRepeat() -> Bool {
        let numberPhoneRepeat = "^(\\d)(?!\\1+$)\\d*$"
        return NSPredicate(format: "SELF MATCHES %@", numberPhoneRepeat).evaluate(with: self)
    }

    public func isValidNumberPhoneSequential() -> Bool {
        let numberPhoneSequential = KrisPayFormatter.shared.getPhoneNumberRegEx()
        return NSPredicate(format: "SELF MATCHES %@", numberPhoneSequential).evaluate(with: self)
    }

    public func isValidNumberPhoneRegister() -> Bool {
        let numberPhoneRegex = KrisPayFormatter.shared.getPhoneNumberRegEx()
        return NSPredicate(format: "SELF MATCHES %@", numberPhoneRegex).evaluate(with: self)
    }
}

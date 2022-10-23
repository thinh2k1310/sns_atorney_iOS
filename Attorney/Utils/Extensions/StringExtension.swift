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
        let pwdRegex = AttorneyFormatter.shared.getPassRegEx()
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

    public func isValidKrisFlyerNumber() -> Bool {
        let krisFlyerNumber = "^[0-9]{10}$"
        return NSPredicate(format: "SELF MATCHES %@", krisFlyerNumber).evaluate(with: self)
    }

    public func isValidTextOnlyEnglish() -> Bool {
        let textRegEx = "^([A-Za-z ])*$"
        return NSPredicate(format: "SELF MATCHES %@", textRegEx).evaluate(with: self)
    }

    public func isValidPasswordRegister() -> Bool {
        let pwdRegex = AttorneyFormatter.shared.getPassRegEx()
        return NSPredicate(format: "SELF MATCHES %@", pwdRegex).evaluate(with: self)
    }

    public func isValidNumberPhoneRepeat() -> Bool {
        let numberPhoneRepeat = "^(\\d)(?!\\1+$)\\d*$"
        return NSPredicate(format: "SELF MATCHES %@", numberPhoneRepeat).evaluate(with: self)
    }

    public func isValidNumberPhoneSequential() -> Bool {
        let numberPhoneSequential = AttorneyFormatter.shared.getPhoneNumberRegEx()
        return NSPredicate(format: "SELF MATCHES %@", numberPhoneSequential).evaluate(with: self)
    }

    public func isValidNumberPhoneRegister() -> Bool {
        let numberPhoneRegex = AttorneyFormatter.shared.getPhoneNumberRegEx()
        return NSPredicate(format: "SELF MATCHES %@", numberPhoneRegex).evaluate(with: self)
    }

    public func isValidTextIsNumberAndEnglishCharacter() -> Bool {
        let textIsNumberAndEnglishRegEx = "^([A-Za-z0-9])*$"
        return NSPredicate(format: "SELF MATCHES %@", textIsNumberAndEnglishRegEx).evaluate(with: self)
    }

    public func isContainingNumber() -> Bool {
        let containingNumberRegex = "(?=.*[\\d]).{1,}"
        return NSPredicate(format: "SELF MATCHES %@", containingNumberRegex).evaluate(with: self)
    }

    public func isContainingLowercase() -> Bool {
        let containingLowercaseRegex = "(?=.*[a-z]).{1,}"
        return NSPredicate(format: "SELF MATCHES %@", containingLowercaseRegex).evaluate(with: self)
    }

    public func isContainingUppercase() -> Bool {
        let containingUppercaseRegex = "(?=.*[A-Z]).{1,}"
        return NSPredicate(format: "SELF MATCHES %@", containingUppercaseRegex).evaluate(with: self)
    }

    public func isContainingSpecial() -> Bool {
        let containingSpecialRegex = "^[\\w~@#$%^&*+=/|{}:;!.?\\()\\[\\] -]{1,}$"
        return NSPredicate(format: "SELF MATCHES %@", containingSpecialRegex).evaluate(with: self)
    }
}

// MARK: - Get heigt/width of text
extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)

        return ceil(boundingBox.height)
    }

    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)

        return ceil(boundingBox.width)
    }

    func heightAsLabel(withConstrainedWidth width: CGFloat, font: UIFont, numberOfLines: Int) -> CGFloat {
        let label: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = numberOfLines
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = self

        label.sizeToFit()
        return label.frame.height
    }
}

extension String {
    func convertStringToDate(fortmat: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = fortmat
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        let date = dateFormatter.date(from: self)!
        return date
    }
}

extension String {
    func formatDateMappingAPI() -> String {
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "dd/MM/yyyyy"
        let dateFormat: NSDate? = dateFormatterGet.date(from: self) as NSDate?

        dateFormatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatterGet.string(from: dateFormat as Date? ?? Date())
    }
}


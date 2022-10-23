//
//  CoachmarkType.swift
//  Attorney
//
//  Created by ThinhTCQ on 10/20/22.
//

import UIKit

enum CoachmarkType {
    case dateOfBirth
    case password
    case email

    // MARK: Coachmark contents
    var contents: CoachmarkContent {
        let contents: CoachmarkContent
        switch self {
        case .password:
            let contentText: String = """
            \(StringConstants.string_tooltip_password_warning(preferredLanguages: preferredLanguages))
            \(StringConstants.string_tooltip_password_warning_first_line(preferredLanguages: preferredLanguages))
            \(StringConstants.string_tooltip_password_warning_second_line(preferredLanguages: preferredLanguages))
            \(StringConstants.string_tooltip_password_warning_third_line(preferredLanguages: preferredLanguages))
            \(StringConstants.string_tooltip_password_warning_fourth_line(preferredLanguages: preferredLanguages))
   """
            let fullNSString: NSString = contentText as NSString
            let attributedContent = NSMutableAttributedString(string: contentText,
                                                              attributes: [
                                                                .font: R.font.proximaNovaRegular(size: 14)!,
                                                                .foregroundColor: UIColor.white
                                                              ])
            _ = ["8", "16", "(0-9)", "(a-z)", "(A-Z)"].map { item in
                let partialRange = fullNSString.range(of: item)
                attributedContent.addAttribute(.font, value: R.font.proximaNovaBold(size: 14)!, range: partialRange)
            }
            contents = .attributedText(attributedContent)

        case .dateOfBirth:
            contents = .text(StringConstants.string_tooltip_date_of_birth(preferredLanguages: preferredLanguages))

        case .email:
            contents = .text(StringConstants.string_tooltip_email_warning(preferredLanguages: preferredLanguages))
        }
        return contents
    }
    // MARK: Coachmark UI preferences
    var preferences: CoachmarkPreferences {
        var preferences: CoachmarkPreferences = CoachmarkPreferences()
        //  Drawing
        preferences.drawing.font = R.font.proximaNovaRegular(size: 14)!
        preferences.drawing.foregroundColor = .white
        preferences.drawing.textAlignment = .left
        preferences.drawing.backgroundColor = Color.colorPopver
        preferences.drawing.cornerRadius = 4
        preferences.drawing.arrowPosition = .any
        switch self {
        case .email, .dateOfBirth, .password:

            // Positioning
            preferences.positioning.bubbleInsets = UIEdgeInsets(top: 1.0, left: 24.0, bottom: 1.0, right: 24.0)
        }

        preferences.positioning.maxWidth = UIScreen.main.bounds.width
        - preferences.positioning.bubbleInsets.left
        - preferences.positioning.bubbleInsets.right
        - preferences.positioning.contentInsets.left
        - preferences.positioning.contentInsets.right
        return preferences
    }
}

// MARK: - Equatable
extension CoachmarkType: Equatable {
    public static func == (lhs: CoachmarkType, rhs: CoachmarkType) -> Bool {
        switch (lhs, rhs) {
        case (.dateOfBirth, .dateOfBirth),
            (.password, .password),
            (.email, .email) :
            return true
            
        default:
            return false
        }
    }
}

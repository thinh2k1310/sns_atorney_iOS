//
//  NSAttributedStringExtension.swift
//  Attorney
//
//  Created by ThinhTCQ on 11/21/22.
//

import Foundation

extension NSAttributedString {
    func trimmedAttributedString() -> NSAttributedString {
        let nonNewlines = CharacterSet.whitespacesAndNewlines.inverted
        // 1
        let startRange = string.rangeOfCharacter(from: nonNewlines)
        // 2
        let endRange = string.rangeOfCharacter(from: nonNewlines, options: .backwards)
        guard let startLocation = startRange?.lowerBound, let endLocation = endRange?.lowerBound else {
            return self
        }
        // 3
        let range = NSRange(startLocation...endLocation, in: string)
        return attributedSubstring(from: range)
    }

    func trimmedNewlines() -> NSAttributedString {
        let nonNewlines = CharacterSet.newlines.inverted
        // 1
        let startRange = string.rangeOfCharacter(from: nonNewlines)
        // 2
        let endRange = string.rangeOfCharacter(from: nonNewlines, options: .backwards)
        guard let startLocation = startRange?.lowerBound, let endLocation = endRange?.lowerBound else {
            return self
        }
        // 3
        let range = NSRange(startLocation...endLocation, in: string)
        return attributedSubstring(from: range)
    }
}

//
//  CoachmarkContent.swift
//  Attorney
//
//  Created by ThinhTCQ on 10/20/22.
//

import UIKit

public enum CoachmarkContent: CustomStringConvertible {
    case text(String)
    case attributedText(NSAttributedString)
    case view(UIView)

    public var description: String {
        switch self {
        case .text(let text):
            return "text : '\(text)'"
        case .attributedText(let text):
            return "attributed text : '\(text)'"
        case .view(let contentView):
            return "view : \(contentView)"
        }
    }
}


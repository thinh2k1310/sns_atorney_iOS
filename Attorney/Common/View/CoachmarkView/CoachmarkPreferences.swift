//
//  CoachmarkPreferences.swift
//  Attorney
//
//  Created by ThinhTCQ on 10/20/22.
//

import UIKit

public enum CoachmarkArrowPosition: CaseIterable {
    case any
    case bottom
    case top
    case right
    case left
}

public struct CoachmarkPreferences {
    public struct Drawing {
        public var cornerRadius        = CGFloat(5)
        public var arrowHeight         = CGFloat(5)
        public var arrowWidth          = CGFloat(10)
        public var foregroundColor     = UIColor.white
        public var backgroundColor     = UIColor.red
        public var arrowPosition       = CoachmarkArrowPosition.any
        public var textAlignment       = NSTextAlignment.center
        public var borderWidth         = CGFloat(0)
        public var borderColor         = UIColor.clear
        public var font                = UIFont.systemFont(ofSize: 15)
        public var shadowColor         = UIColor.clear
        public var shadowOffset        = CGSize(width: 0.0, height: 0.0)
        public var shadowRadius        = CGFloat(0)
        public var shadowOpacity       = CGFloat(0)
    }

    public struct Positioning {
        public var bubbleInsets         = UIEdgeInsets(top: 1.0, left: 1.0, bottom: 1.0, right: 1.0)
        public var contentInsets        = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
        public var maxWidth             = CGFloat(200)
    }

    public struct Animating {
        public var dismissTransform     = CGAffineTransform(scaleX: 0.1, y: 0.1)
        public var showInitialTransform = CGAffineTransform(scaleX: 0, y: 0)
        public var showFinalTransform   = CGAffineTransform.identity
        public var springDamping        = CGFloat(0.7)
        public var springVelocity       = CGFloat(0.7)
        public var showInitialAlpha     = CGFloat(0)
        public var dismissFinalAlpha    = CGFloat(0)
        public var showDuration         = 0.7
        public var dismissDuration      = 0.7
        public var dismissOnTap         = true
    }

    public var drawing      = Drawing()
    public var positioning  = Positioning()
    public var animating    = Animating()

    public var hasBorder: Bool {
        return drawing.borderWidth > 0 && drawing.borderColor != UIColor.clear
    }

    public var hasShadow: Bool {
        return drawing.shadowOpacity > 0 && drawing.shadowColor != UIColor.clear
    }

    public init() {}
}


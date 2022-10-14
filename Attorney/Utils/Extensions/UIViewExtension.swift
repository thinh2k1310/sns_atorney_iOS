//
//  UIViewExtension.swift
//  Attorney
//
//  Created by Truong Thinh on 10/10/2022.
//

import UIKit

@IBDesignable extension UIView {
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }

    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }

    @IBInspectable var borderColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }

    @IBInspectable var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.shadowRadius = newValue
            layer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1).cgColor
            if newValue == 0 {
                layer.shadowOffset = CGSize(width: 0, height: 0)
                layer.shadowOpacity = 0
            } else {
                layer.shadowOffset = CGSize(width: 0, height: 2)
                layer.shadowOpacity = 0.3
            }

            layer.masksToBounds = false
        }
    }
}

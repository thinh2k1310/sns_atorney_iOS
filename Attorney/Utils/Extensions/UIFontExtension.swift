//
//  UIFontExtension.swift
//  Attorney
//
//  Created by ThinhTCQ on 10/16/22.
//

import UIKit

extension UIFont {
    static func appFont(size: CGFloat) -> UIFont {
        return R.font.proximaNovaRegular(size: size) ?? UIFont.systemFont(ofSize: 14)
    }

    static func appBoldFont(size: CGFloat) -> UIFont {
        return R.font.proximaNovaBold(size: size) ?? UIFont.boldSystemFont(ofSize: 14)
    }

    static func appSemiBoldFont(size: CGFloat) -> UIFont {
        return R.font.proximaNovaSemibold(size: size) ?? UIFont.boldSystemFont(ofSize: 14)
    }
}

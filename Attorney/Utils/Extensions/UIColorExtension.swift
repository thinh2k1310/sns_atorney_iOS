//
//  UIColorExtension.swift
//  Attorney
//
//  Created by Truong Thinh on 09/10/2022.
//

import UIKit

extension UIColor {
    convenience init(rgb: Int, alpha: CGFloat = 1.0) {
        let red = CGFloat((rgb & 0xff0000) >> 16) / 255
        let green = CGFloat((rgb & 0x00ff00) >> 8) / 255
        let blue = CGFloat((rgb & 0x0000ff)      ) / 255

        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    var hexString: String? {
        if let components = self.cgColor.components {
            let red = components[0]
            let green = components[1]
            let blue = components[2]
            return  String(format: "%02X%02X%02X", (Int)(red * 255), (Int)(green * 255), (Int)(blue * 255))
        }
        return nil
    }

    static func rgb(_ red: Int, _ green: Int, _ blue: Int, alpha: CGFloat = 1.0) -> UIColor {
        return UIColor(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: alpha)
    }
}


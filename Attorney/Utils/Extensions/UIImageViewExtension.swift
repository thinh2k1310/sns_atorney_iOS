//
//  UIImageViewExtension.swift
//  Attorney
//
//  Created by ThinhTCQ on 11/19/22.
//

import UIKit

extension UIView {
    func roundToCircle() {
        self.layer.borderWidth = 1.0
        self.layer.masksToBounds = false
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.cornerRadius = self.frame.size.width/2
        self.clipsToBounds = true
    }
}

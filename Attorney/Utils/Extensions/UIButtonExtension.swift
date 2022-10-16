//
//  UIButtonExtension.swift
//  Attorney
//
//  Created by Truong Thinh on 10/10/2022.
//

import UIKit

extension UIButton {
    func applyGradient() {
        let colors: [CGColor] = [Color.appTintColor.cgColor, Color.appLightTintColor.cgColor]
            self.backgroundColor = nil
            self.layoutIfNeeded()
            let gradientLayer = CAGradientLayer()
            gradientLayer.colors = colors
            gradientLayer.startPoint = CGPoint(x: 0, y: 0)
            gradientLayer.endPoint = CGPoint(x: 1, y: 0)
            gradientLayer.frame = self.bounds
            gradientLayer.cornerRadius = self.frame.height/2

            gradientLayer.shadowColor = UIColor.darkGray.cgColor
            gradientLayer.shadowOffset = CGSize(width: 2.5, height: 2.5)
            gradientLayer.shadowRadius = 5.0
            gradientLayer.shadowOpacity = 0.3
            gradientLayer.masksToBounds = false

            self.layer.insertSublayer(gradientLayer, at: 0)
            self.contentVerticalAlignment = .center
        }
    
    @objc public func activate() {
        applyGradient()
        self.setTitleColor(UIColor.white, for: .normal)
        self.isEnabled = true
    }
    @objc public func deactivate() {
        self.layer.backgroundColor = Color.deactivatedButton.cgColor
        self.setTitleColor(UIColor.white, for: .normal)
        self.isEnabled = false
    }
}

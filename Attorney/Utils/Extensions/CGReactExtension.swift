//
//  CGReactExtension.swift
//  Attorney
//
//  Created by ThinhTCQ on 10/20/22.
//

import UIKit

// MARK: - UIBarItem extension -
extension UIBarItem {
    var view: UIView? {
        if let item = self as? UIBarButtonItem, let customView = item.customView {
            return customView
        }
        return self.value(forKey: "view") as? UIView
    }
}

extension CGRect {
    var x: CGFloat {
        get {
            return self.origin.x
        }
        set {
            self.origin.x = newValue
        }
    }

    var y: CGFloat {
        get {
            return self.origin.y
        }

        set {
            self.origin.y = newValue
        }
    }

    var center: CGPoint {
        return CGPoint(x: self.x + self.width / 2, y: self.y + self.height / 2)
    }
}


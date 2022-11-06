//
//  UIViewControllerExtension.swift
//  Attorney
//
//  Created by ThinhTCQ on 11/2/22.
//

import UIKit

extension UIViewController {
    func isScreenHasAlreadyPresentedViewController(kindOf kind: AnyClass) -> Bool {
        if let presetedVc = self.navigationController?.presentedViewController,
            presetedVc.isKind(of: kind) {
            return true
        } else {
            return false
        }
    }
}

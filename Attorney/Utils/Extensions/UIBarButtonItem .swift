//
//  UIBarButtonItem .swift
//  Attorney
//
//  Created by Truong Thinh on 02/12/2022.
//

import UIKit

extension UIBarButtonItem {
    private struct AssociatedObject {
        static var key = "action_closure_key"
    }

    var actionClosure: (() -> Void)? {
        get {
            return objc_getAssociatedObject(self, &AssociatedObject.key) as? () -> Void
        }
        set {
            objc_setAssociatedObject(self, &AssociatedObject.key, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            target = self
            action = #selector(didTapButton(sender:))
        }
    }

    @objc func didTapButton(sender: Any) {
        actionClosure?()
    }

    func getFrame() -> CGRect {
          guard let view = self.value(forKey: "view") as? UIView else {
              return CGRect.zero
          }
          return view.frame
      }
}

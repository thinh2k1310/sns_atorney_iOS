//
//  AttorneyTransition.swift
//  Attorney
//
//  Created by ThinhTCQ on 11/3/22.
//

import RxCocoa
import RxSwift
import UIKit

class AttorneyTransition: ReactiveCompatible {
    static let sharedInstance = AttorneyTransition()

    var loadedTransitionViewController: TinyLoadingViewController?
    var tinyTransitionViewController: TinyLoadingViewController?
    var loading: Bool = false
    var loadingMessage: String = "Logging in..."

    let window: UIWindow = (UIApplication.shared.delegate as! AppDelegate).window!

    public func stopAllLoading() {
        self.stopLoading()
    }

    public func showLoading() {
        if self.loadedTransitionViewController == nil {
            self.loadedTransitionViewController = R.storyboard.transitions.tinyLoadingViewController()
        }
//        self.loadedTransitionViewController?.assignedLoadingMessage = loadingMessage
        window.addSubview(self.loadedTransitionViewController!.view)
    }

    public func stopLoading() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if self.loadedTransitionViewController != nil {
                self.loadedTransitionViewController?.view.removeFromSuperview()
                self.loadedTransitionViewController = nil
            }
        }
    }

    public func showTinyLoading() {
        if self.tinyTransitionViewController == nil {
            self.tinyTransitionViewController = R.storyboard.transitions.tinyLoadingViewController()
        }
        window.addSubview(self.tinyTransitionViewController!.view)
    }

    public func stopTinyLoading() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if self.tinyTransitionViewController != nil {
                self.tinyTransitionViewController?.view.removeFromSuperview()
                self.tinyTransitionViewController = nil
            }
        }
    }
}

extension Reactive where Base: AttorneyTransition {
    /// Bindable sink for `show()`, `hide()` methods.
    internal static var isAnimating: Binder<Bool> {
        return Binder(UIApplication.shared) { _, isVisible in
            if isVisible {
                AttorneyTransition.sharedInstance.showLoading()
            } else {
                AttorneyTransition.sharedInstance.stopLoading()
            }
        }
    }

    internal static var isJustAnimating: Binder<Bool> {
        return Binder(UIApplication.shared) { _, isVisible in
            if isVisible {
                AttorneyTransition.sharedInstance.loadingMessage = ""
                AttorneyTransition.sharedInstance.showLoading()
            } else {
                AttorneyTransition.sharedInstance.stopLoading()
            }
        }
    }

    internal static var isTinyAnimating: Binder<Bool> {
        return Binder(UIApplication.shared) { _, isVisible in
            if isVisible {
                AttorneyTransition.sharedInstance.showTinyLoading()
            } else {
                AttorneyTransition.sharedInstance.stopTinyLoading()
            }
        }
    }
}

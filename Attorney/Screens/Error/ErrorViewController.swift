//
//  ErrorViewController.swift
//  Attorney
//
//  Created by ThinhTCQ on 11/2/22.
//

import UIKit
import RxSwift

final class ErrorViewController: ViewController {
    @IBOutlet private weak var tryAgainButton: UIButton!
    @IBOutlet private weak var goBackButton: UIButton!
    
    static let shared = R.storyboard.error.errorViewController()!
    static var isShowing: Bool = false
    
    static func showErrorVC() {
        guard let topViewController = AppDelegate.shared()?.topViewController() else { return }

        if ErrorViewController.isShowing || topViewController is ErrorViewController {
            return
        }

        ErrorViewController.isShowing = true
        ErrorViewController.shared.modalPresentationStyle = .fullScreen
        // Check if ErrorViewController has already presented
        if topViewController.isScreenHasAlreadyPresentedViewController(kindOf: ErrorViewController.self) {
            return
        }
        topViewController.present(ErrorViewController.shared, animated: false, completion: nil)
    }
    
    @IBAction private func didTapTryAgain(_ sender: UIButton) {
        ErrorViewController.isShowing = false
        self.dismiss(animated: true)
    }
    
    @IBAction private func didTapGoBack(_ sender: UIButton) {
        ErrorViewController.isShowing = false
        self.dismiss(animated: true)
    }
    
    
}

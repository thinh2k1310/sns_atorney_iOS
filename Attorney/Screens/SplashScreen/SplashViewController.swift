//
//  LaunchScreenViewController.swift
//  Attorney
//
//  Created by Truong Thinh on 07/10/2022.
//

import UIKit
import Lottie

protocol SplashViewControllerDelegate: AnyObject {
    func didFinishInitApplication(isLoggedin: Bool)
}

class SplashViewController: UIViewController {

    @IBOutlet private weak var animationView: AnimationView!
    weak var delegate: SplashViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.animationSpeed = 1.0
        animationView.play()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            if UserService.shared.isSignedIn {
                self.delegate?.didFinishInitApplication(isLoggedin: true)
            } else {
                self.delegate?.didFinishInitApplication(isLoggedin: false)
            }
        }
    }
}

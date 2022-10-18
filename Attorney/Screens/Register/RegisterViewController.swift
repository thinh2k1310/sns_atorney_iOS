//
//  RegisterViewController.swift
//  Attorney
//
//  Created by Truong Thinh on 01/10/2022.
//

import UIKit

final class RegisterViewController: ViewController {
    @IBOutlet private weak var adView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        adView.applyGradientBG()
    }
}

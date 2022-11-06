//
//  SuccessViewController.swift
//  Attorney
//
//  Created by ThinhTCQ on 11/4/22.
//

import UIKit

final class SuccessViewController: ViewController {
    @IBOutlet private weak var messageLabel: UILabel!
    var message: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMessageLabel()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    private func setupMessageLabel() {
        guard let message = message else {
            return
        }
        messageLabel.text = message
    }
    
    @IBAction private func proceedToLoginDidTap(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: true)
    }
}

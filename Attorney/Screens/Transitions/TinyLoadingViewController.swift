//
//  TinyLoadingViewController.swift
//  Attorney
//
//  Created by ThinhTCQ on 11/3/22.
//

import UIKit

class TinyLoadingViewController: UIViewController {
    @IBOutlet var loadingIndicator: UIActivityIndicatorView!
    override func viewDidLoad() {
        super.viewDidLoad()
        loadingIndicator.startAnimating()
    }
}


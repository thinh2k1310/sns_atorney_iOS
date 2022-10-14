//
//  ViewController.swift
//  Attorney
//
//  Created by Truong Thinh on 01/10/2022.
//

import UIKit
import RxSwift

class ViewController: UIViewController, UITabBarControllerDelegate {
    var popupWindow: UIWindow?
    var overlayWindow: UIWindow?

    var viewModel: ViewModel?
    var provider: AttorneyAPI?
    let disposeBag = DisposeBag()
    var backgroundTask: UIBackgroundTaskIdentifier = UIBackgroundTaskIdentifier.invalid

    deinit {
        log.info("deinit: \(self)")
    }

    func bindViewModel() {}

    func setupUI() {}
    func setupData() {}
    func updateUI() {}
    func setupDelegate() {}

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupDataInViewWillAppear()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = Color.background
        self.tabBarController?.delegate = self
        bindViewModel()
        setupDataInViewDidLoad()
        setupUI()
        setupDelegate()
    }

    func setupDataInViewDidLoad() {
        guard let viewModel = self.viewModel else { return }
        viewModel.viewDidLoad()
    }

    func setupDataInViewWillAppear() {
        guard let viewModel = self.viewModel else { return }
        viewModel.viewWillAppear()
    }

    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        self.navigationController?.popToRootViewController(animated: true)
    }
}

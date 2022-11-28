//
//  HomeCoordinator.swift
//  Attorney
//
//  Created by Truong Thinh on 07/10/2022.
//

import UIKit
import RxSwift

class HomeCoordinator: Coordinator {
    public var homeNavigationViewController: UINavigationController!
    public var homeViewModel: HomeViewModel!
    let disposeBag = DisposeBag()
    
    public init (provider: AttorneyAPI) {
        self.homeViewModel = HomeViewModel(provider: provider)
        self.setupViewController()
    }
}

// MARK: - Setup tabbar
extension HomeCoordinator {
    func setupViewController() {
        let homeVC = R.storyboard.home.homeViewController()!
        homeVC.viewModel = self.homeViewModel
        homeNavigationViewController = UINavigationController(rootViewController: homeVC)
        let itemHome = UITabBarItem(title: "Home", image: R.image.homeTab_icon()!, selectedImage: R.image.homeTab_icon_selected()!)
        itemHome.tag = IndexTabbar.home.rawValue
        homeNavigationViewController.tabBarItem = itemHome
    }
}

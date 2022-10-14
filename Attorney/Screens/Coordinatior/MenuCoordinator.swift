//
//  MenuCoordinator.swift
//  Attorney
//
//  Created by Truong Thinh on 07/10/2022.
//

import UIKit
import RxSwift

class MenuCoordinator: Coordinator {
    public var menuNavigationViewController: UINavigationController!
    
    let disposeBag = DisposeBag()
    
    public init (provider: AttorneyAPI) {
        self.setupViewController()
    }
}

extension MenuCoordinator {
    func setupViewController() {
        let menuVC = R.storyboard.menu.menuViewController()!
        menuNavigationViewController = UINavigationController(rootViewController: menuVC)
        let itemMenu = UITabBarItem(title: "Menu", image: R.image.menuTab_icon()!, selectedImage: R.image.menuTab_icon_selected()!)
        itemMenu.tag = IndexTabbar.menu.rawValue
        menuNavigationViewController.tabBarItem = itemMenu
    }
    
    func receiveEventTransition() {
        
    }
}

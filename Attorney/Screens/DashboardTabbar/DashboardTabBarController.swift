//
//  DashboardTabbarController.swift
//  Attorney
//
//  Created by Truong Thinh on 01/10/2022.
//

import UIKit

final class DashboardTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    var previousController: UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTabBar()
        self.delegate = self
    }
    
    private func configureTabBar() {
        UITabBarItem.appearance().titlePositionAdjustment = UIOffset(horizontal: 0.0, vertical: -10.0)
        self.tabBar.tintColor = UIColor.clear
        tabBar.backgroundColor = .white
        tabBar.layer.shadowOffset = CGSize(width: 0, height: 5)
        tabBar.layer.shadowRadius = 5
        tabBar.layer.shadowColor = UIColor.black.cgColor
        tabBar.layer.shadowOpacity = 0.2
    }
    
    private func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) {
        if previousController == viewController {
            if let nav = viewController as? UINavigationController, let vc = nav.viewControllers[0] as? HomeViewController {
                if vc.isViewLoaded && (vc.view.window != nil) {
                    vc.didReselectTab()
                }
            }else if let nav = viewController as? UINavigationController, let vc = nav.viewControllers[0] as? HomeViewController {
                if vc.isViewLoaded && (vc.view.window != nil) {
                    vc.didReselectTab()
                }
            }else{
                
            }
        }
        previousController = viewController
    }
}


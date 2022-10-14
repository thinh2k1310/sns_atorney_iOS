//
//  DashboardTabbarController.swift
//  Attorney
//
//  Created by Truong Thinh on 01/10/2022.
//

import UIKit

final class DashboardTabBarController: UITabBarController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTabBar()
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
}

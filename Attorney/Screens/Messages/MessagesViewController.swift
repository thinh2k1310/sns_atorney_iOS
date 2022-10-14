//
//  MessagesViewController.swift
//  Attorney
//
//  Created by Truong Thinh on 01/10/2022.
//

import UIKit

final class  MessagesViewController: ViewController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func setupUI() {
        super.setupUI()
        configureTabBar()
    }
    
    private func configureTabBar() {
        tabBarController?.selectedIndex = 1
        tabBarController?.tabBar.barTintColor = Color.backgroundTabbar
        tabBarController?.tabBar.unselectedItemTintColor = Color.unselectedTabbar // color for unselected item on TabBar
        tabBarController?.tabBar.tintColor = Color.selectedTabBar // color for selected item on TabBar
        tabBarController?.tabBar.isTranslucent = false
        tabBarController?.tabBar.isOpaque = false
    }
}

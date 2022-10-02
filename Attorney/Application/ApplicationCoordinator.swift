//
//  ApplicationCoordinator.swift
//  Attorney
//
//  Created by Truong Thinh on 01/10/2022.
//

import UIKit

class ApplicationCoordinator {
    let window: UIWindow?
    var rootViewController: UIViewController
    
    init(window: UIWindow?) {
        self.window = window
        rootViewController = UIViewController()
        
    }
}

extension ApplicationCoordinator {
    func start(data: Any? = nil) {
        let loginViewController = R.storyboard.login.loginViewController()!
        
        rootViewController = loginViewController
        
        window?.rootViewController = rootViewController
        window?.makeKeyAndVisible()
    }
}

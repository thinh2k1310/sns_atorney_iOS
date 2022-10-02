//
//  AppDelegate.swift
//  Attorney
//
//  Created by Truong Thinh on 01/10/2022.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    private var appCoordinator: ApplicationCoordinator?
    
    class func sharedInstance() -> AppDelegate? {
        return UIApplication.shared.delegate as? AppDelegate
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        
        guard let window = window else {
            log.debug("Unexpected result when app's main window is nil")
            return false
        }
        
        appCoordinator = ApplicationCoordinator(window: window)
        appCoordinator?.start()
        
        if #available(iOS 15.0, *) {
            UITableView.appearance().sectionHeaderTopPadding = 0
        }
        return true
    }
}


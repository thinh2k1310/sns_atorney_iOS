//
//  AppDelegate.swift
//  Attorney
//
//  Created by Truong Thinh on 01/10/2022.
//

import UIKit
import RxSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    private var appCoordinator: ApplicationCoordinator?
    
    class func shared() -> AppDelegate? {
        return UIApplication.shared.delegate as? AppDelegate
    }
    
    let disposeBag = DisposeBag()

    override init() {
        super.init()
        configApplicationProvider()
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
    
    private func configApplicationProvider() {
        let provider: AttorneyAPI!
        
        let attorneyNetworking = AttorneyNetworking.attorneyNetworking()
        provider = RestAPI(attorneyProvider: attorneyNetworking)
        
        Application.shared.setProvider(provider: provider)
    }
    
    func getCurrentViewController() -> UIViewController? {
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            if let loginViewController = topController as? LoginViewController {
                return loginViewController
            } else if let dashboardTabBarController = topController as? DashboardTabBarController {
                return dashboardTabBarController
            } else {
                return topController
            }
        }
        return nil
    }

    func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}


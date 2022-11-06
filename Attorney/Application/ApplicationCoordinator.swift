//
//  ApplicationCoordinator.swift
//  Attorney
//
//  Created by Truong Thinh on 01/10/2022.
//

import UIKit
import RxSwift

protocol Coordinator {
    func setupViewController()
    func receiveEventTransition()
}

class ApplicationCoordinator {
    let window: UIWindow?
    var rootViewController: UIViewController
    private var previousIndex: Int = 0
    var homeCoordinator: HomeCoordinator!
    var messageCoordinator: MessageCoordinator!
    var notificationCoordinator: NotificationCoordinator!
    var menuCoordinator: MenuCoordinator!
    var defaultControllers: [UIViewController] = []
    let currentIndexTabbarEvent = PublishSubject<Int>()
    let previousIndexTabbarEvent = PublishSubject<Int>()
    let disposeBag = DisposeBag()
    
    init(window: UIWindow?) {
        self.window = window
        rootViewController = UIViewController()
        
    }
    
    private func initTabbar(tabBarController: UITabBarController, provider: AttorneyAPI){
        
        self.homeCoordinator = HomeCoordinator(provider: provider)
        self.messageCoordinator = MessageCoordinator(provider: provider)
        self.notificationCoordinator = NotificationCoordinator(provider: provider)
        self.menuCoordinator = MenuCoordinator(provider: provider)

        defaultControllers = [
            homeCoordinator.homeNavigationViewController,
            messageCoordinator.messageNavigationViewController,
            notificationCoordinator.notificationNavigationViewController,
            menuCoordinator.menuNavigationViewController
        ]
        
        tabBarController.viewControllers = defaultControllers
        
        self.currentIndexTabbarEvent
            .subscribe(onNext: { [weak self] index in
                guard let this = self else { return }
                if index != this.previousIndex {
                    this.previousIndex = index
                }
            })
            .disposed(by: disposeBag)
    }
    
    func initDashboard() {
        let tabBarController = DashboardTabBarController()
        guard let provider = Application.shared.provider else { return }
        initTabbar(tabBarController: tabBarController, provider: provider)
        rootViewController = tabBarController
        currentIndexTabbarEvent.onNext(0)
        window?.rootViewController = rootViewController
    }
    
    func popToLogin() {
        guard let provider = Application.shared.provider else { return }
        let loginViewModel = LoginViewModel(provider: provider)
        let loginViewController = R.storyboard.login.loginViewController()!
        loginViewController.viewModel = loginViewModel
        let navigationController = UINavigationController(rootViewController: loginViewController)
        rootViewController = navigationController
        window?.rootViewController = rootViewController
    }
    

    public func getPreviousIndex() -> Int {
        return self.previousIndex
    }

    public func setPreviousIndex(index: Int) {
        self.previousIndex = index
    }

    public func getCurrentCoordinator() -> Coordinator {
        guard let currentViewController = AppDelegate.shared()?.getCurrentViewController() else { return self.homeCoordinator }
        if let dashboardTabBarController = currentViewController as? DashboardTabBarController {
            switch IndexTabbar(rawValue: dashboardTabBarController.selectedIndex) {
            case .home:
                return self.homeCoordinator

            case .message:
                return self.messageCoordinator

            case .notification:
                return self.notificationCoordinator

            case .menu:
                return self.menuCoordinator

            default:
                return self.homeCoordinator
            }
        }
        return self.homeCoordinator
    }
}

extension ApplicationCoordinator {
    func start(data: Any? = nil) {
        let splashViewController = R.storyboard.splashScreen.splashScreenViewController()!
        splashViewController.delegate = self
        
        rootViewController = splashViewController
        
        window?.rootViewController = rootViewController
        window?.makeKeyAndVisible()
    }
}

extension ApplicationCoordinator: SplashViewControllerDelegate {
    func didFinishInitApplication(isLoggedin: Bool) {
        if let splashScreenViewController = rootViewController as? SplashViewController {
            splashScreenViewController.delegate = nil
        }
        guard let provider = Application.shared.provider else { return }
        
        if isLoggedin {
            let tabBarController = DashboardTabBarController()
            initTabbar(tabBarController: tabBarController, provider: provider)
            rootViewController = tabBarController
            currentIndexTabbarEvent.onNext(0)
        } else {
            // Replace Window Root View controller with Login view controller
            let loginViewModel = LoginViewModel(provider: provider)
            let loginViewController = R.storyboard.login.loginViewController()!
            loginViewController.viewModel = loginViewModel
            let navigationController = UINavigationController(rootViewController: loginViewController)
            rootViewController = navigationController
        }
        window?.rootViewController = rootViewController
    }
}

public enum IndexTabbar: Int {
    case home = 0, message, notification, menu
}

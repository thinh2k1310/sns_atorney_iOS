//
//  NotificationCoordinator.swift
//  Attorney
//
//  Created by Truong Thinh on 07/10/2022.
//

import UIKit
import RxSwift

class NotificationCoordinator: Coordinator {
    public var notificationNavigationViewController: UINavigationController!
    
    let disposeBag = DisposeBag()
    
    public init (provider: AttorneyAPI) {
        self.setupViewController()
    }
}

extension NotificationCoordinator {
    func setupViewController() {
        let notiVC = R.storyboard.notifications.notificationsViewController()!
        notificationNavigationViewController = UINavigationController(rootViewController: notiVC)
        let itemNoti = UITabBarItem(title: "Notifications", image: R.image.notiTab_icon()!, selectedImage: R.image.notiTab_icon_selected()!)
        itemNoti.tag = IndexTabbar.notification.rawValue
        notificationNavigationViewController.tabBarItem = itemNoti
    }
    
    func receiveEventTransition() {
        
    }
}

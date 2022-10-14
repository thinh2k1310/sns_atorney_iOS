//
//  MessageCoordinator.swift
//  Attorney
//
//  Created by Truong Thinh on 07/10/2022.
//

import UIKit
import RxSwift

class MessageCoordinator: Coordinator {
    public var messageNavigationViewController: UINavigationController!
    
    let disposeBag = DisposeBag()
    
    public init (provider: AttorneyAPI) {
        self.setupViewController()
    }
}

extension MessageCoordinator {
    func setupViewController() {
        let messagesVC = R.storyboard.messages.messagesViewController()!
        messageNavigationViewController = UINavigationController(rootViewController: messagesVC)
        let itemMsg = UITabBarItem(title: "Messages", image: R.image.msgTab_icon()!, selectedImage: R.image.msgTab_icon_selected()!)
        itemMsg.tag = IndexTabbar.message.rawValue
        messageNavigationViewController.tabBarItem = itemMsg
    }
    
    func receiveEventTransition() {
        
    }
}

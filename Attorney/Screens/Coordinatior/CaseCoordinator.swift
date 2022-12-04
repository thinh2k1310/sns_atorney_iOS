//
//  MessageCoordinator.swift
//  Attorney
//
//  Created by Truong Thinh on 07/10/2022.
//

import UIKit
import RxSwift

class CaseCoordinator: Coordinator {
    public var caseNavigationViewController: UINavigationController!
    public var caseViewModel: CaseViewModel!
    
    let disposeBag = DisposeBag()
    
    public init (provider: AttorneyAPI) {
        self.caseViewModel = CaseViewModel(provider: provider)
        self.setupViewController()
    }
}

extension CaseCoordinator {
    func setupViewController() {
        let caseVC = R.storyboard.case.caseViewController()!
        caseNavigationViewController = UINavigationController(rootViewController: caseVC)
        let itemMsg = UITabBarItem(title: "Cases", image: R.image.msgTab_icon()!, selectedImage: R.image.msgTab_icon_selected()!)
        itemMsg.tag = IndexTabbar.message.rawValue
        caseNavigationViewController.tabBarItem = itemMsg
    }
    
    func receiveEventTransition() {
        
    }
}

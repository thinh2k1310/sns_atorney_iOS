//
//  UINavigationControllerExtension.swift
//  Attorney
//
//  Created by Truong Thinh on 02/12/2022.
//

import UIKit

extension UINavigationItem {
    public func showLeftBarItem(isShowLogo: Bool, viewController: UIViewController, backAction: (() -> Void)?) {
        weak var vc = viewController
        var iconBack = R.image.backIcon()
        iconBack = iconBack?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        let backButtonItem = UIBarButtonItem(image: iconBack, style: UIBarButtonItem.Style.plain, target: nil, action: nil)
        vc?.navigationItem.leftBarButtonItem = backButtonItem
        backButtonItem.actionClosure = backAction
        
    }
}

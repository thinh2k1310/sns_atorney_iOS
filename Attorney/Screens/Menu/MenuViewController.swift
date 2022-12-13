//
//  MenuViewController.swift
//  Attorney
//
//  Created by Truong Thinh on 01/10/2022.
//

import UIKit
import Kingfisher

final class MenuViewController: ViewController {
    @IBOutlet private weak var userImageView: UIImageView!
    @IBOutlet private weak var userNameLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupProfileView()
    }
    
    override func setupUI() {
        super.setupUI()
        configureTabBar()
    }
    
    private func configureTabBar() {
        tabBarController?.selectedIndex = 3
        tabBarController?.tabBar.barTintColor = Color.backgroundTabbar
        tabBarController?.tabBar.unselectedItemTintColor = Color.unselectedTabbar // color for unselected item on TabBar
        tabBarController?.tabBar.tintColor = Color.selectedTabBar // color for selected item on TabBar
        tabBarController?.tabBar.isTranslucent = false
        tabBarController?.tabBar.isOpaque = false
    }
    
    private func setupProfileView() {
        if let userInfo : UserInfo = UserDefaults.standard.retrieveObject(forKey: UserKey.kUserInfo) {
            // Avatar
            let processor = DownsamplingImageProcessor(size: userImageView.bounds.size)
            userImageView.kf.setImage(
                with: URL(string: userInfo.avatar ?? ""),
                placeholder: R.image.placeholderAvatar(),
                options: [
                        .processor(processor),
                        .scaleFactor(UIScreen.main.scale),
                        .transition(.fade(1)),
                        .cacheOriginalImage
                ])
            userImageView.roundToCircle()
            
            // Name
            let userName = "\(userInfo.firstName ?? "") \(userInfo.lastName ?? "User")"
            userNameLabel.text = userName
        }
    }
    
    @IBAction private func didTapLogOut(_ sender: UIButton) {
        UserService.shared.removeAccessToken()
        guard let window = AppDelegate.shared()?.window else {
            return
        }
        let appCoordinator = ApplicationCoordinator(window: window)
        appCoordinator.popToLogin()
    }
    
    @IBAction private func didTapProfileControl(_ sender: Any) {
        if let userInfo : UserInfo = UserDefaults.standard.retrieveObject(forKey: UserKey.kUserInfo) {
            let profileVC = R.storyboard.profile.profileViewController()!
            guard let provider = Application.shared.provider else { return }
            let profileVM = ProfileViewModel(provider: provider)
            profileVM.profileId = userInfo.id
            profileVC.viewModel = profileVM
            self.navigationController?.pushViewController(profileVC, animated: true)
        }
    }
    
    @IBAction private func didTapEmailControl(_ sender: Any) {
        
    }
    
    @IBAction private func didTapPasswordControl(_ sender: Any) {
        let changePasswordViewController = R.storyboard.resetPassword.changePasswordViewController()!
        guard let provider = Application.shared.provider else { return }
        let changePasswordViewModel = ChangePasswordViewModel(provider: provider)
        changePasswordViewController.viewModel = changePasswordViewModel
        self.navigationController?.pushViewController(changePasswordViewController, animated: true)
    }
    
    @IBAction private func didTapDocuments(_ sender: Any) {
        let documentsVC = R.storyboard.documents.webViewController()!
        self.navigationController?.pushViewController(documentsVC, animated: true)
    }
    
    @IBAction private func didTapAbout(_ sender: Any) {
        let categoryVC = R.storyboard.listAttorney.categoryViewController()!
        guard let provider = Application.shared.provider else { return }
        let categoryVM = CategoryViewModel(provider: provider)
        categoryVC.viewModel = categoryVM
        self.navigationController?.pushViewController(categoryVC, animated: true)
    }
    
    @IBAction private func didTapTerm(_ sender: Any) {
        
    }
}

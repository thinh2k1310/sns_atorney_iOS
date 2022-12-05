//
//  ChangeImageViewController.swift
//  Attorney
//
//  Created by ThinhTCQ on 12/5/22.
//

import UIKit
import RxSwift
import RxCocoa
import YPImagePicker
import RealmSwift

final class ChangeImageViewController: ViewController {
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var changeButton: UIButton!
    
    let picker = YPImagePicker()

// MARK: - Licycle View
    override func viewDidLoad() {
        super.viewDidLoad()
        configPicker()
        configTitle()
        imageView.isHidden = true
        changeButton.deactivate()
        present(picker, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
// MARK: - Binding
    
    override func bindViewModel() {
        super.bindViewModel()
        
        guard let viewModel = viewModel as? ChangeImageViewModel else { return }
        viewModel.bodyLoading.asObservable()
            .bind(to: AttorneyTransition.rx.isTinyAnimating)
            .disposed(by: disposeBag)
        
        viewModel.changeImageSuccess
            .subscribe(onNext: { [weak self] user in
                if let userInfo : UserInfo = UserDefaults.standard.retrieveObject(forKey: UserKey.kUserInfo) {
                    if userInfo.id == user.id {
                        UserService.shared.saveUserInfor(user: user)
                    }
                }
                self?.dismiss(animated: true)
            }).disposed(by: disposeBag)
    }

// MARK: - Functions
    
    private func configPicker() {
        var config = YPImagePickerConfiguration()
        config.isScrollToChangeModesEnabled = true
        config.onlySquareImagesFromCamera = true
        config.usesFrontCamera = true
        config.showsPhotoFilters = true
        config.showsVideoTrimmer = true
        config.shouldSaveNewPicturesToAlbum = true
        config.albumName = "DefaultYPImagePickerAlbumName"
        config.startOnScreen = YPPickerScreen.library
        config.screens = [.library, .photo]
        config.showsCrop = .none
        config.targetImageSize = YPImageSize.original
        config.overlayView = UIView()
        config.hidesStatusBar = false
        config.hidesBottomBar = false
        config.hidesCancelButton = false
        config.preferredStatusBarStyle = UIStatusBarStyle.lightContent
        config.maxCameraZoomFactor = 1.0
        config.library.options = nil
        config.library.onlySquare = false
        config.library.isSquareByDefault = true
        config.library.minWidthForItem = nil
        config.library.mediaType = YPlibraryMediaType.photo
        config.library.defaultMultipleSelection = false
        config.library.maxNumberOfItems = 1
        config.library.minNumberOfItems = 1
        config.library.numberOfItemsInRow = 4
        config.library.spacingBetweenItems = 1.0
        config.library.skipSelectionsGallery = false
        config.library.preselectedItems = nil
        YPImagePickerConfiguration.shared = config
        picker.navigationBar.backgroundColor = UIColor.white
        
        guard let viewModel = viewModel as? ChangeImageViewModel else { return }
        picker.didFinishPicking { [unowned picker, weak self] items, _ in
            guard let self = self else { return }
            if let photo = items.singlePhoto {
                self.imageView.isHidden = false
                self.imageView.image = photo.image
                viewModel.media = photo.image
            }
            picker.dismiss(animated: true, completion: nil)
            UIView.transition(with: self.changeButton, duration: 0.4, options: .transitionCrossDissolve, animations: {
                self.changeButton.activate()
            })
        }
    }

    private func configTitle() {
        guard let viewModel = viewModel as? ChangeImageViewModel else { return }
        switch viewModel.imageType {
        case .avatar:
            self.titleLabel.text = ImageType.avatar.rawValue
        case .cover:
            self.titleLabel.text = ImageType.cover.rawValue
        }
    }



// MARK: - IBActions

    @IBAction private func didTapBackControl(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction private func didTapPostButton(_ sender: Any) {
        guard let viewModel = viewModel as? ChangeImageViewModel else { return }
        viewModel.changeImage()
    }
    
    @IBAction private func addPhoto(_ sender: Any) {
        present(picker, animated: true, completion: nil)
    }
}




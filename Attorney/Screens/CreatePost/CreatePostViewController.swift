//
//  CreatePostViewController.swift
//  Attorney
//
//  Created by Truong Thinh on 01/12/2022.
//

import UIKit
import GrowingTextView
import YPImagePicker

final class CreatePostViewController: ViewController {
// MARK: - IBOutlets
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var imageSuperView: UIView!
    @IBOutlet private weak var textView: GrowingTextView!
    @IBOutlet private weak var postButton: UIButton!
    @IBOutlet private weak var imageView: UIImageView!
    
// MARK: - Variables
    let picker = YPImagePicker()
    var isHideImage: Bool = true {
        didSet {
            imageSuperView.isHidden = isHideImage
        }
    }

// MARK: - Licycle View
    override func viewDidLoad() {
        super.viewDidLoad()
        configPicker()
        imageSuperView.isHidden = true
        postButton.deactivate()
        addGestures()
        textView.delegate = self
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
        
        guard let viewModel = viewModel as? CreatePostViewModel else { return }
        viewModel.bodyLoading.asObservable()
            .bind(to: AttorneyTransition.rx.isTinyAnimating)
            .disposed(by: disposeBag)
        
        viewModel.createPostSuccess
            .subscribe(onNext: { [weak self] in
                self?.dismiss(animated: true)
            })
    }

// MARK: - Functions
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func addGestures() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        scrollView.addGestureRecognizer(tap)
    }
    
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
        
        guard let viewModel = viewModel as? CreatePostViewModel else { return }
        picker.didFinishPicking { [unowned picker, weak self] items, _ in
            if let photo = items.singlePhoto {
                self?.isHideImage = false
                self?.imageView.image = photo.image
                viewModel.media = photo.image
            }
            picker.dismiss(animated: true, completion: nil)
        }
    }




// MARK: - IBActions

    @IBAction private func didTapBackControl(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction private func didTapPostButton(_ sender: Any) {
        guard let viewModel = viewModel as? CreatePostViewModel else { return }
        viewModel.content = textView.text
        viewModel.createPost()
    }
    
    @IBAction private func addPhoto(_ sender: Any) {
        present(picker, animated: true, completion: nil)
    }
    
    @IBAction private func didTapRemoveImage(_ sender: Any) {
        self.isHideImage = true
        guard let viewModel = viewModel as? CreatePostViewModel else { return }
        viewModel.media = nil
        
    }
}

// MARK: - ScrollView

extension CreatePostViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
}

// MARK: - TextViewDelegate

extension CreatePostViewController: GrowingTextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let text = textView.text.trim()
        if text.isEmpty {
            postButton.deactivate()
        } else {
            UIView.transition(with: postButton, duration: 0.4, options: .transitionCrossDissolve, animations: {
                self.postButton.activate()
            })
        }
    }
}

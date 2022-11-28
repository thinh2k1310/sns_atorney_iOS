//
//  PostDetailViewController.swift
//  Attorney
//
//  Created by ThinhTCQ on 11/25/22.
//

import UIKit
import GrowingTextView
import RxCocoa
import RxSwift
import Kingfisher

final class PostDetailViewController: ViewController {
    @IBOutlet private weak var navigationBackControl: UIControl!
    @IBOutlet private weak var repotControl: UIControl!
    @IBOutlet private weak var userImageView: UIImageView!
    @IBOutlet private weak var userNameLabel: UILabel!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var commentTextView: GrowingTextView!
    @IBOutlet private weak var sendButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func bindViewModel() {
        super.bindViewModel()
        
        guard let viewModel = viewModel as? PostDetailViewModel else {
            return
        }
        
        viewModel.postDetailEvent
            .subscribe(onNext: { [weak self] event in
                guard let self = self else { return }
                switch event {
                case .successAPI(let post):
                    self.bindingUI(post: post)

                case .errorAPI(let message):
                    log.debug(message)
                }
            }).disposed(by: disposeBag)
        
        viewModel.postCommentsEvent
            .subscribe(onNext: { [weak self] comments in
                guard let self = self else { return }
               
            }).disposed(by: disposeBag)
    }
    
    private func bindingUI(post: PostDetail) {
        guard let user = post.user else { return }
        setupUserView(user: user)
    }
    
    private func setupUserView(user: ShortUser) {
        // Avatar
        let processor = DownsamplingImageProcessor(size: userImageView.bounds.size)
        userImageView.kf.setImage(
            with: URL(string: user.avatar ?? ""),
            placeholder: R.image.placeholderAvatar(),
            options: [
                    .processor(processor),
                    .scaleFactor(UIScreen.main.scale),
                    .transition(.fade(1)),
                    .cacheOriginalImage
            ])
        userImageView.roundToCircle()
        
        // Name
        let userName = "\(user.firstName ?? "") \(user.lastName ?? "User")"
        userNameLabel.text = userName
    }
    
    
    @IBAction private func didTapBackControl(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}

extension PostDetailViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    
}

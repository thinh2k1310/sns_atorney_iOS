//
//  PostDetailHeaderView.swift
//  Attorney
//
//  Created by Truong Thinh on 28/11/2022.
//

import UIKit
import Kingfisher

protocol PostDetailHeaderViewDelegate: AnyObject {
    func commetPost(_ post : PostDetail?)
    func likePost(_ post: PostDetail?, user: String?)
    func requestPost(_ post: PostDetail?, user: String?)
}

final class PostDetailHeaderView: UITableViewHeaderFooterView {
    @IBOutlet private weak var contentTextView: UITextView!
    @IBOutlet private weak var postImageView: UIImageView!
    @IBOutlet private weak var likeButton: UIButton!
    @IBOutlet private weak var numberOfLikesLabel: UILabel!
    @IBOutlet private weak var numberOfCommentsLabel: UILabel!
    @IBOutlet private weak var defendButton: UIButton!
    @IBOutlet private weak var imageViewHeight: NSLayoutConstraint!
    @IBOutlet private weak var imageViewWidth: NSLayoutConstraint!
    @IBOutlet private weak var contentViewHeight: NSLayoutConstraint!
    
    private var post: PostDetail?
    private var currentLikes: Int = 0
    private var isLikePost: Bool = false
    
    weak var delegate: PostDetailHeaderViewDelegate?
    
    func configureHeaderView(post: PostDetail) {
        self.post = post
        setupContentView(with: post)
        setupPostImage(with: post)
        setupNumberOfLikesLabel(with: post)
        setupNumberOfCommentLabel(with: post)
        setupDefenceButton(with: post)
        setupLayout()
    }
    
    func setupLayout() {
        guard let post = post else {
            return
        }
        let width = UIScreen.main.bounds.width
        var imageHeight: CGFloat = 0
        if let _ = post.mediaUrl {
            imageHeight = width * CGFloat ((post.mediaHeight ?? 1) / (post.mediaWidth ?? 1))
        }
        imageViewHeight.constant = imageHeight
        imageViewWidth.constant = width
        let textviewHeight = contentTextView.frame.size.height
        contentViewHeight.constant = textviewHeight + imageHeight + 10
    }
    
    private func setupContentView(with post: PostDetail) {
        self.contentTextView.text = post.content
        self.contentTextView.textContainerInset = UIEdgeInsets.zero
        self.contentTextView.textContainer.lineFragmentPadding = 0
        self.contentTextView.translatesAutoresizingMaskIntoConstraints = false
        self.contentTextView.textContainer.maximumNumberOfLines = 0
        self.contentTextView.isScrollEnabled = false
        self.contentTextView.sizeToFit()
    
    }
    
    private func setupPostImage(with post: PostDetail){
        if let imageUrl = post.mediaUrl {
            let processor = DownsamplingImageProcessor(size: postImageView.bounds.size)
            postImageView.kf.setImage(
                with: URL(string: imageUrl),
                placeholder: R.image.mockupImage(),
                options: [
                        .processor(processor),
                        .scaleFactor(UIScreen.main.scale),
                        .transition(.fade(1)),
                        .cacheOriginalImage
                ])
        } else {
            postImageView.isHidden = true
        }
    }
    
    private func setupNumberOfLikesLabel(with post: PostDetail) {
        if let numberOfLikes = post.totalLikes, let isLike = post.isLikePost {
            self.currentLikes = numberOfLikes
            self.isLikePost = isLike
            var text = ""
            if numberOfLikes <= 1 {
                text = "\(numberOfLikes) like"
            } else {
                text = "\(numberOfLikes) likes"
            }
            numberOfLikesLabel.text = text
        }
        if let like = post.isLikePost {
            likeButton.isSelected = like
        }
    }
    
    private func setupNumberOfCommentLabel(with post: PostDetail){
        if let numberOfComments = post.totalComments {
            var text = ""
            if numberOfComments <= 1 {
                text = "\(numberOfComments) comment"
            } else {
                text = "\(numberOfComments) comments"
            }
            numberOfCommentsLabel.text = text
        }
    }
    
    private func setupDefenceButton(with post: PostDetail) {
        if let userInfo : UserInfo = UserDefaults.standard.retrieveObject(forKey: UserKey.kUserInfo) {
            defendButton.isHidden = (post.user?._id == userInfo.id || post.type == PostType.DISCUSSING.rawValue || userInfo.role != UserRole.attorney.rawValue)
        }
    }
    
    private func updateLikeNumber() {
        if self.isLikePost {
            currentLikes -= 1
        } else {
            currentLikes += 1
        }
        var text = ""
        if currentLikes <= 1 {
            text = "\(currentLikes) like"
        } else {
            text = "\(currentLikes) likes"
        }
        numberOfLikesLabel.text = text
        
    }
    
    @IBAction private func likeButtonDidTap(_ sender: Any) {
        self.likeButton.isSelected.toggle()
        updateLikeNumber()
        self.isLikePost.toggle()
        if let userInfo : UserInfo = UserDefaults.standard.retrieveObject(forKey: UserKey.kUserInfo) {
            self.delegate?.likePost(self.post, user: userInfo.id)
        }
    }
    
    @IBAction private func commentButtonDidTap(_ sender: Any) {
        self.delegate?.commetPost(self.post)
    }
    
    @IBAction private func defendButtonDidTap(_ sender: Any) {
        self.defendButton.isSelected.toggle()
        if let userInfo : UserInfo = UserDefaults.standard.retrieveObject(forKey: UserKey.kUserInfo) {
            self.delegate?.requestPost(self.post, user: userInfo.id)
        }
    }
    
}

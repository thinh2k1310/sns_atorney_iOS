//
//  PostTableViewCell.swift
//  Attorney
//
//  Created by ThinhTCQ on 11/17/22.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher
import ReadMoreTextView

protocol NewsFeedCollectionViewCellDelegate: AnyObject {
    func viewDetailPost(_ post : String?)
    func likePost(_ post: String?)
    func requestPost(_ post: Post?)
    func viewProfile(userId: String?)
}

final class NewsFeedCollectionViewCell: UICollectionViewCell {
    @IBOutlet private weak var userAvatarImageView: UIImageView!
    @IBOutlet private weak var userNameLabel: UILabel!
    @IBOutlet private weak var postContentTextView: UITextView!
    @IBOutlet private weak var postImageView: UIImageView!
    @IBOutlet private weak var likeButton : UIButton!
    @IBOutlet private weak var commentButton: UIButton!
    @IBOutlet private weak var defendButton: UIButton!
    @IBOutlet private weak var numberOfLikesLabel : UILabel!
    @IBOutlet private weak var numberOfCommentsLabel : UILabel!
    @IBOutlet private weak var contentViewHeight: NSLayoutConstraint!
    @IBOutlet private weak var textViewHeight: NSLayoutConstraint!
    @IBOutlet private weak var showMoreContentButton: UIButton!
    @IBOutlet private weak var imageViewHeight: NSLayoutConstraint!
    @IBOutlet private weak var imageViewWidth: NSLayoutConstraint!
    @IBOutlet private weak var postTextViewBottomConstraint: NSLayoutConstraint!
    
    private var post: Post?
    private var currentLikes: Int = 0
    private var isLikePost: Bool = false
    
    private var lineHeight: CGFloat {
        (self.postContentTextView.font?.lineHeight ?? 1).rounded(.up)
    }
    
    
    private var numberLineTextView: Int = 0
    private var maxLine = 5
    private var textViewBottomConstraint: CGFloat = 40
    var isShowMore: Bool = true
    
    private var extendedHeightRelay = PublishRelay<CGFloat>()

    var extendedHeightDriver: Driver<CGFloat> { extendedHeightRelay.asDriverOnErrorJustComplete() }

    var showMoreDriver: Driver<Void> { self.showMoreContentButton.rx.tap.asDriverOnErrorJustComplete() }
    
    static var identifier: String {
         return String(describing: self)
     }

     static var nib: UINib {
         return UINib(nibName: identifier, bundle: nil)
     }
    
    weak var delegate: NewsFeedCollectionViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addGesture()
    }
    
    func bindingData(with post: Post) {
        self.post = post
        setupUserView(with: post)
        setupContentView(with: post)
        setupPostImage(with: post)
        setupNumberOfLikesLabel(with: post)
        setupNumberOfCommentLabel(with: post)
        setupDefenceButton(with: post)
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
        let textviewHeight = CGFloat(min(self.numberLineTextView,maxLine)) * lineHeight
        let showMoreButtonHeight : CGFloat = self.numberLineTextView > 4 ? 30 : 0
        contentViewHeight.constant = textviewHeight + imageHeight + showMoreButtonHeight + 10
    }
    
    private func setupUserView(with post: Post){
        // Avatar
        let processor = DownsamplingImageProcessor(size: userAvatarImageView.bounds.size)
        userAvatarImageView.kf.setImage(
            with: URL(string: post.user?.avatar ?? ""),
            placeholder: R.image.placeholderAvatar(),
            options: [
                    .processor(processor),
                    .scaleFactor(UIScreen.main.scale),
                    .transition(.fade(1)),
                    .cacheOriginalImage
            ])
        userAvatarImageView.roundToCircle()
        
        // Name
        let userName = "\(post.user?.firstName ?? "") \(post.user?.lastName ?? "User")"
        userNameLabel.text = userName
        
    }
    
    private func setupPostImage(with post: Post){
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
    
    private func setupNumberOfLikesLabel(with post: Post) {
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
    
    private func setupNumberOfCommentLabel(with post: Post){
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
    
    private func setupDefenceButton(with post: Post) {
        if let userInfo : UserInfo = UserDefaults.standard.retrieveObject(forKey: UserKey.kUserInfo) {
            defendButton.isHidden = (post.user?._id == userInfo.id || post.type == PostType.DISCUSSING.rawValue || userInfo.role != UserRole.attorney.rawValue || post.isBlock == true)
        }
        if let isDenfendPost = post.isDefendPost {
            self.defendButton.isSelected = isDenfendPost
        }
    }
    
    private func addGesture() {
        let imageTapGesture = UITapGestureRecognizer(target: self, action: #selector(seeDetailPost))
        let likeLabelTapGesture = UITapGestureRecognizer(target: self, action: #selector(seeDetailPost))
        let commentLabelTapGesture = UITapGestureRecognizer(target: self, action: #selector(seeDetailPost))
        
        postImageView.isUserInteractionEnabled = true
        numberOfLikesLabel.isUserInteractionEnabled = true
        numberOfCommentsLabel.isUserInteractionEnabled = true
        
        postImageView.addGestureRecognizer(imageTapGesture)
        numberOfLikesLabel.addGestureRecognizer(likeLabelTapGesture)
        numberOfCommentsLabel.addGestureRecognizer(commentLabelTapGesture)
    }
    
    @IBAction private func didTapReadMoreButton(_ sender: Any) {
        delegate?.viewDetailPost(post?._id)
    }
    
    @IBAction private func didTapLikeButton(_ sender: Any) {
        self.likeButton.isSelected.toggle()
        updateLikeNumber()
        self.isLikePost.toggle()
        self.delegate?.likePost(self.post?._id)
    }
    
    @IBAction private func didTapCommentButton(_ sender: Any) {
        delegate?.viewDetailPost(self.post?._id)
    }
    
    @IBAction private func didTapDefendButton(_ sender: Any) {
        self.defendButton.isSelected.toggle()
        delegate?.requestPost(self.post)
    }
    
    @IBAction func didTapUserView(_ sender: Any) {
        delegate?.viewProfile(userId: self.post?.user?._id)
    }
    
    @objc private func seeDetailPost() {
        delegate?.viewDetailPost(self.post?._id)
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
}

private extension NewsFeedCollectionViewCell {
    func setupContentView(with post: Post) {
        let content = post.content ?? ""

        let attributedTextToDisplay = NSAttributedString(string: content, attributes: [.font: UIFont.appFont(size: 14),
                                                                                       .foregroundColor: UIColor.black])
        self.postContentTextView.attributedText = attributedTextToDisplay.trimmedAttributedString()
        
        self.postContentTextView.textContainerInset = UIEdgeInsets.zero
        self.postContentTextView.textContainer.lineFragmentPadding = 0
        self.numberLineTextView = self.postContentTextView.getNumberOfLines()
        self.postContentTextView.translatesAutoresizingMaskIntoConstraints = false
        self.showMoreContentButton.isHidden = self.numberLineTextView <= maxLine
        if self.numberLineTextView > maxLine {
            self.postContentTextView.textContainer.maximumNumberOfLines = maxLine
            self.postContentTextView.textContainer.lineBreakMode = .byTruncatingTail
            self.postTextViewBottomConstraint.constant = textViewBottomConstraint
        } else {
            self.postContentTextView.textContainer.maximumNumberOfLines = 0
            self.postTextViewBottomConstraint.constant = 16
        }
        self.postContentTextView.isScrollEnabled = false
        self.postContentTextView.sizeToFit()
    }
}

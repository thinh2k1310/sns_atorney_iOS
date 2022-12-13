//
//  PostCell.swift
//  Attorney
//
//  Created by ThinhTCQ on 12/9/22.
//

import UIKit
import Kingfisher

class PostCell: UITableViewCell {
    @IBOutlet private weak var userAvatarImageView: UIImageView!
    @IBOutlet private weak var userNameLabel: UILabel!
    @IBOutlet private weak var postContentTextView: UITextView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureCell(with post: Post) {
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
        
        let content = post.content ?? ""

        let attributedTextToDisplay = NSAttributedString(string: content, attributes: [.font: UIFont.appFont(size: 14),
                                                                                       .foregroundColor: UIColor.black])
        self.postContentTextView.attributedText = attributedTextToDisplay.trimmedAttributedString()
        
        self.postContentTextView.textContainerInset = UIEdgeInsets.zero
        self.postContentTextView.textContainer.lineFragmentPadding = 0
        self.postContentTextView.textContainer.maximumNumberOfLines = 3
        self.postContentTextView.textContainer.lineBreakMode = .byTruncatingTail
        self.postContentTextView.isScrollEnabled = false
        self.postContentTextView.sizeToFit()
    }
}

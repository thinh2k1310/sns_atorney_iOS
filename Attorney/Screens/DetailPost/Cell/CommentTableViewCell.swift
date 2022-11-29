//
//  CommentTableViewCell.swift
//  Attorney
//
//  Created by Truong Thinh on 28/11/2022.
//

import UIKit
import Kingfisher

protocol CommentTableViewCellDelegate: AnyObject {
    func deleteComment(_ commentId: String?)
}

final class CommentTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var avatarImageView: UIImageView!
    @IBOutlet private weak var userNameLabel: UILabel!
    @IBOutlet private weak var contentCommentLabel: UILabel!
    @IBOutlet private weak var timeLabel: UILabel!
    @IBOutlet private weak var deleteButton: UIButton!
    
    private var comment: Comment?
    
    weak var delegate: CommentTableViewCellDelegate?
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureCell(with comment: Comment) {
        self.comment = comment
        // Avatar
        let processor = DownsamplingImageProcessor(size: avatarImageView.bounds.size)
        avatarImageView.kf.setImage(
            with: URL(string: comment.userId?.avatar ?? ""),
            placeholder: R.image.placeholderAvatar(),
            options: [
                    .processor(processor),
                    .scaleFactor(UIScreen.main.scale),
                    .transition(.fade(1)),
                    .cacheOriginalImage
            ])
        avatarImageView.roundToCircle()
        
        // Name
        let userName = "\(comment.userId?.firstName ?? "") \(comment.userId?.lastName ?? "User")"
        userNameLabel.text = userName
        
        //Comment
        contentCommentLabel.text = comment.content ?? ""
        
        //Time
        if let time = comment.created {
            let dateTime = time.convertStringToDate(fortmat: "yyyy-MM-dd'T'HH:mm:ssZ")
            timeLabel.text = dateTime.timeAgoDisplay()
        }
        
        if let userInfo : UserInfo = UserDefaults.standard.retrieveObject(forKey: UserKey.kUserInfo) {
            deleteButton.isHidden = (comment.userId?._id != userInfo.id) && (comment.postId?.user != userInfo.id )
        }
    }
    
    @IBAction private func deleteButtonDidTap(_ sender: Any) {
        guard let comment = comment, let id = comment._id else {
            return
        }
        self.delegate?.deleteComment(id)
    }
}

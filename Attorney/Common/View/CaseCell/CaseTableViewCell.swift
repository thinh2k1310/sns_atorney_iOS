//
//  CaseTableViewCell.swift
//  Attorney
//
//  Created by Truong Thinh on 03/12/2022.
//

import UIKit
import Kingfisher

class CaseTableViewCell: UITableViewCell {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var userImageView: UIImageView!
    @IBOutlet private weak var userNameLabel: UILabel!
    @IBOutlet private weak var postImageView: UIImageView!
    @IBOutlet private weak var postImageSuperView: UIView!
    @IBOutlet private weak var postContentLabel: UILabel!
    @IBOutlet private weak var startingTimeLabel: UILabel!
    @IBOutlet private weak var endingTimeLabel: UILabel!
    @IBOutlet private weak var statusLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
    }
    
    func configureCell(with cases: Case) {
        if let userInfo : UserInfo = UserDefaults.standard.retrieveObject(forKey: UserKey.kUserInfo) {
            if userInfo.role == UserRole.attorney.rawValue {
                setupUserView(user: cases.customer!, isAttorney: true)
            } else {
                setupUserView(user: cases.attorney!, isAttorney: false)
            }
        }
        setupPostView(post: cases.post!)
        setupInfoView(with: cases)
        
    }
    
    private func setupUserView(user: ShortUser, isAttorney: Bool) {
        //Title
        titleLabel.text = isAttorney ? "Client" : "Attorney"
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
    
    private func setupPostView(post: ShortPost) {
        // Image
        if let image = post.mediaUrl, !image.isEmpty {
            let processor = DownsamplingImageProcessor(size: postImageView.bounds.size)
            postImageView.kf.setImage(
                with: URL(string: image),
                placeholder: R.image.mockupImage(),
                options: [
                        .processor(processor),
                        .scaleFactor(UIScreen.main.scale),
                        .transition(.fade(1)),
                        .cacheOriginalImage
                ])
        } else {
            postImageSuperView.isHidden = true
        }
        
        // Content
        postContentLabel.text = post.content ?? ""
    }
    
    private func setupInfoView(with cases: Case) {
        startingTimeLabel.text = cases.startingTime ?? "N/A"
        endingTimeLabel.text = cases.endingTime ?? "N/A"
        statusLabel.text = cases.status
        setupContentView(with: cases.status!)
    }
    
    private func setupContentView(with status: String) {
        if status == CaseStatus.inProgress.rawValue {
            contentView.borderWidth = 1.0
            contentView.borderColor = Color.appTintColor
            contentView.backgroundColor = Color.F1F1FE
        } else if status == CaseStatus.cancel.rawValue {
            contentView.borderWidth = 1.0
            contentView.borderColor = Color.colorError
            contentView.backgroundColor = Color.lightRed
        } else if status == CaseStatus.complete.rawValue {
            contentView.borderWidth = 1.0
            contentView.borderColor = Color.green
            contentView.backgroundColor = Color.lightGreen
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

enum CaseStatus: String{
    case inProgress = "IN-PROGRESS"
    case complete = "COMPLETED"
    case cancel = "CANCELLED"
}

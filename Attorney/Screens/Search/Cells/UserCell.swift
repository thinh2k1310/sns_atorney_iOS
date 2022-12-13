//
//  UserCell.swift
//  Attorney
//
//  Created by ThinhTCQ on 12/9/22.
//

import UIKit
import Kingfisher

class UserCell: UITableViewCell {
    
    @IBOutlet private weak var avatarImageView: UIImageView!
    @IBOutlet private weak var userNameLabel: UILabel!
    @IBOutlet private weak var addressLabel: UILabel!
    @IBOutlet private weak var workLabel: UILabel!
    @IBOutlet private weak var categoryLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureCelll(with user: User) {
        // Avatar
        let processor = DownsamplingImageProcessor(size: avatarImageView.bounds.size)
        avatarImageView.kf.setImage(
            with: URL(string: user.avatar ?? ""),
            placeholder: R.image.placeholderAvatar(),
            options: [
                    .processor(processor),
                    .scaleFactor(UIScreen.main.scale),
                    .transition(.fade(1)),
                    .cacheOriginalImage
            ])
        avatarImageView.roundToCircle()
        
        // Name
        let userName = "\(user.firstName ?? "") \(user.lastName ?? "User")"
        userNameLabel.text = userName
        
        if let address = user.address {
            addressLabel.text = StringConstants.string_lives_in(address)
        } else {
            addressLabel.isHidden = true
        }
        
        if let work = user.work {
            workLabel.text = StringConstants.string_works_at(work)
        } else {
            workLabel.isHidden = true
        }
        
        if let categories = user.categories, !categories.isEmpty {
            var text = ""
            for category in categories {
                text += "\(category) ,"
            }
            if !text.isEmpty {
                text.removeLast()
            }
            categoryLabel.text = StringConstants.string_specializes_in(text)
        } else {
            categoryLabel.isHidden = true
        }
    }
    
}

//
//  ReviewTableViewCell.swift
//  Attorney
//
//  Created by ThinhTCQ on 12/13/22.
//

import UIKit
import Kingfisher

class ReviewTableViewCell: UITableViewCell {
    @IBOutlet private weak var avatarImageView: UIImageView!
    @IBOutlet private weak var userNameLabel: UILabel!
    @IBOutlet private weak var contentLabel: UILabel!
    @IBOutlet private weak var oneStar: UIImageView!
    @IBOutlet private weak var twoStar: UIImageView!
    @IBOutlet private weak var threeStar: UIImageView!
    @IBOutlet private weak var fourStar: UIImageView!
    @IBOutlet private weak var fiveStar: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configureCell(with review: Review) {
        // Avatar
        let processor = DownsamplingImageProcessor(size: avatarImageView.bounds.size)
        avatarImageView.kf.setImage(
            with: URL(string: review.client?.avatar ?? ""),
            placeholder: R.image.placeholderAvatar(),
            options: [
                    .processor(processor),
                    .scaleFactor(UIScreen.main.scale),
                    .transition(.fade(1)),
                    .cacheOriginalImage
            ])
        avatarImageView.roundToCircle()
        
        // Name
        let userName = "\(review.client?.firstName ?? "") \(review.client?.lastName ?? "User")"
        userNameLabel.text = userName
        
        //Comment
        contentLabel.text = review.content ?? ""
        
        //Rating
        if let rating = review.point {
            if rating == 1 {
                oneStar.image = R.image.iconStarFill()
                twoStar.image = R.image.iconStar()
                threeStar.image = R.image.iconStar()
                fourStar.image = R.image.iconStar()
                fiveStar.image = R.image.iconStar()
            } else if rating == 2 {
                oneStar.image = R.image.iconStarFill()
                twoStar.image = R.image.iconStarFill()
                threeStar.image = R.image.iconStar()
                fourStar.image = R.image.iconStar()
                fiveStar.image = R.image.iconStar()
            } else if rating == 3 {
                oneStar.image = R.image.iconStarFill()
                twoStar.image = R.image.iconStarFill()
                threeStar.image = R.image.iconStarFill()
                fourStar.image = R.image.iconStar()
                fiveStar.image = R.image.iconStar()
            } else if rating == 4 {
                oneStar.image = R.image.iconStarFill()
                twoStar.image = R.image.iconStarFill()
                threeStar.image = R.image.iconStarFill()
                fourStar.image = R.image.iconStarFill()
                fiveStar.image = R.image.iconStar()
            } else if rating == 5 {
                oneStar.image = R.image.iconStarFill()
                twoStar.image = R.image.iconStarFill()
                threeStar.image = R.image.iconStarFill()
                fourStar.image = R.image.iconStarFill()
                fiveStar.image = R.image.iconStarFill()
            }
        }
    }
    
}

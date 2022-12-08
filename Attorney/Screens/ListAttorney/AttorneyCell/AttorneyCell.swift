//
//  AttorneyCell.swift
//  Attorney
//
//  Created by ThinhTCQ on 12/8/22.
//

import UIKit
import Kingfisher

final class AttorneyCell: UITableViewCell {
    
    @IBOutlet private weak var avatarImageView: UIImageView!
    @IBOutlet private weak var userNameLabel: UILabel!
    @IBOutlet private weak var totalCaseLabel: UILabel!
    @IBOutlet private weak var ratingLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureCell(with model: Attorney) {
        // Avatar
        let processor = DownsamplingImageProcessor(size: avatarImageView.bounds.size)
        avatarImageView.kf.setImage(
            with: URL(string: model.avatar ?? ""),
            placeholder: R.image.placeholderAvatar(),
            options: [
                    .processor(processor),
                    .scaleFactor(UIScreen.main.scale),
                    .transition(.fade(1)),
                    .cacheOriginalImage
            ])
        avatarImageView.roundToCircle()
        
        // Name
        let userName = "\(model.firstName ?? "") \(model.lastName ?? "User")"
        userNameLabel.text = userName
        // Content
        if let totalReviews = model.totalReviews {
            totalCaseLabel.text = StringConstants.string_total_cases(String(totalReviews))
        } else {
            totalCaseLabel.text = StringConstants.string_total_cases("N/A")
        }
        
        if let rating = model.rating {
            ratingLabel.text = StringConstants.string_rating(String(format: "%.1f", rating))
        } else {
            ratingLabel.text = StringConstants.string_rating("N/A")
        }
    }

    
    
}

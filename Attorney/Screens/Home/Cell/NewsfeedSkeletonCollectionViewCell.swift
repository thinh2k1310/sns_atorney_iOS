//
//  NewsfeedSkeletonCollectionViewCell.swift
//  Attorney
//
//  Created by ThinhTCQ on 11/19/22.
//

import UIKit
import SkeletonView

final class NewsfeedSkeletonCollectionViewCell: UICollectionViewCell {

    static let identifier = "NewsfeedSkeletonCollectionViewCell"
    static let contentHeight: CGFloat = 430.0

    @IBOutlet private weak var skeletonContentView: UIView!
    @IBOutlet private weak var avatarSkeletonView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        avatarSkeletonView.roundToCircle()
        showAnimatedGradientSkeleton()
    }
}

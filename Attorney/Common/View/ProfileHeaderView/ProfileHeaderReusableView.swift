//
//  ProfileHeaderReusableView.swift
//  Attorney
//
//  Created by Truong Thinh on 04/12/2022.
//

import UIKit

final class ProfileHeaderReusableView: UICollectionReusableView {
    static let identifier = "ProfileHeaderReusableView"
    @IBOutlet private weak var coverImageView: UIImageView!
    @IBOutlet private weak var changeCoverControl: UIControl!
    @IBOutlet private weak var avatarImageView: UIImageView!
    @IBOutlet private weak var changeAvatarControl: UIControl!
    @IBOutlet private weak var userNameLabel: UILabel!
    @IBOutlet private weak var editProfileControl: UIControl!
    @IBOutlet private weak var addressView: UIView!
    @IBOutlet private weak var addressLabel: UILabel!
    @IBOutlet private weak var birthdayView: UIView!
    @IBOutlet private weak var birthdayLabel: UIView!
    @IBOutlet private weak var workView: UIView!
    @IBOutlet private weak var workLabel: UIView!
    @IBOutlet private weak var miniAvatarImageView: UIImageView!
    @IBOutlet private weak var postControl: UIControl!
    @IBOutlet private weak var buttonStackView: UIView!
    @IBOutlet private weak var postsButton: UIButton!
    @IBOutlet private weak var reviewsButton: UIButton!
}

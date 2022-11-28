//
//  File.swift
//  Attorney
//
//  Created by ThinhTCQ on 11/17/22.
//

import UIKit
import Kingfisher

final class HeaderHomeReusableView: UICollectionReusableView {
    static let identifier = "HeaderHomeReusableView"
    @IBOutlet private weak var avatarImageView: UIImageView!
    @IBOutlet private weak var createPostPlaceHolder: UILabel!
    
    func configureHeader(with userInfo: UserInfo) {
        setupAvatar(with: userInfo)
        setUpUserName(with: userInfo)
    }
    
    private func setUpUserName(with userInfo: UserInfo) {
        createPostPlaceHolder.text = StringConstants.string_what_on_your_mid(userInfo.firstName ?? "user")
    }
    
    private func setupAvatar(with userInfo: UserInfo) {
        let processor = DownsamplingImageProcessor(size: avatarImageView.bounds.size)
        avatarImageView.kf.setImage(
            with: URL(string: userInfo.avatar ?? ""),
            placeholder: R.image.placeholderAvatar(),
            options: [
                    .processor(processor),
                    .scaleFactor(UIScreen.main.scale),
                    .transition(.fade(1)),
                    .cacheOriginalImage
            ])
        avatarImageView.roundToCircle()
    }
    
    @IBAction private func didTapSearchBar(_ sender: Any) {
        
    }
    
    @IBAction private func didTapCreatePost(_ sender: Any) {
        
    }
}

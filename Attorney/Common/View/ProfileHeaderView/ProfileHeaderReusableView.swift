//
//  ProfileHeaderReusableView.swift
//  Attorney
//
//  Created by Truong Thinh on 04/12/2022.
//

import UIKit
import Kingfisher

protocol ProfileHeaderReusableViewDelegate: AnyObject {
    func filterProfile(filter: ProfileFilter?)
    func changeAvatar()
    func changeCover()
    func editProfile()
    func createPost()
}

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
    @IBOutlet private weak var birthdayLabel: UILabel!
    @IBOutlet private weak var workView: UIView!
    @IBOutlet private weak var workLabel: UILabel!
    @IBOutlet private weak var miniAvatarImageView: UIImageView!
    @IBOutlet private weak var postControl: UIControl!
    @IBOutlet private weak var buttonStackView: UIView!
    @IBOutlet private weak var postsButton: UIButton!
    @IBOutlet private weak var reviewsButton: UIButton!
    
    weak var delegate: ProfileHeaderReusableViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        filterBy()
    }
    
    func configureHeader(with user: User) {
        setupAvatar(with: user)
        setupCover(with: user)
        setupDetailView(with: user)
        setupVisibility(with: user)
    }
    
    func setupAvatar(with user: User) {
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
        
        let processor1 = DownsamplingImageProcessor(size: miniAvatarImageView.bounds.size)
        miniAvatarImageView.kf.setImage(
            with: URL(string: user.avatar ?? ""),
            placeholder: R.image.placeholderAvatar(),
            options: [
                    .processor(processor1),
                    .scaleFactor(UIScreen.main.scale),
                    .transition(.fade(1)),
                    .cacheOriginalImage
            ])
        miniAvatarImageView.roundToCircle()
    }
    
    func setupCover(with user: User) {
        // Avatar
        let processor = DownsamplingImageProcessor(size: coverImageView.bounds.size)
        coverImageView.kf.setImage(
            with: URL(string: user.cover ?? ""),
            placeholder: R.image.mockupImage(),
            options: [
                    .processor(processor),
                    .scaleFactor(UIScreen.main.scale),
                    .transition(.fade(1)),
                    .cacheOriginalImage
            ])
        avatarImageView.roundToCircle()
    }
    
    func setupUserName(with user: User) {
        // Name
        let userName = "\(user.firstName ?? "") \(user.lastName ?? "User")"
        userNameLabel.text = userName
    }
    
    func setupDetailView(with user: User) {
        if let address = user.address {
            addressLabel.text = StringConstants.string_lives_in(address)
        } else {
            addressView.isHidden = true
        }
        
        if let birthday = user.dob {
            birthdayLabel.text = birthday
        } else {
            birthdayView.isHidden = true
        }
        
        if let work = user.work {
            workLabel.text = StringConstants.string_works_at(work)
        } else {
            workView.isHidden = true
        }
    }
    
    func setupVisibility(with user: User) {
        if let role = user.role {
            if role == UserRole.attorney.rawValue {
                buttonStackView.isHidden = false
            } else {
                buttonStackView.isHidden = true
            }
        }
        if let userInfo : UserInfo = UserDefaults.standard.retrieveObject(forKey: UserKey.kUserInfo) {
            if userInfo.id == user.id {
                changeCoverControl.isHidden = false
                changeAvatarControl.isHidden = false
                editProfileControl.isHidden = false
            } else {
                changeCoverControl.isHidden = false
                changeAvatarControl.isHidden = false
                editProfileControl.isHidden = false
            }
        }
    }
    
    private func filterBy(_ option: Int = 0) {
        postsButton.isSelected = option == 0
        postsButton.backgroundColor = option == 0 ? Color.F1F1FE : UIColor.white
        reviewsButton.isSelected = option == 1
        reviewsButton.backgroundColor = option == 1 ? Color.F1F1FE : UIColor.white
    }
    
    @IBAction private func didTapFilterButton(_ sender: Any) {
        guard let tag = (sender as? UIButton)?.tag else {
            return
        }
        self.filterBy(tag)
        self.delegate?.filterProfile(filter: ProfileFilter.allCases[tag])
    }
    
    @IBAction private func didTapChangeCover (_ sender: Any) {
        self.delegate?.changeCover()
    }
    
    @IBAction private func didTapChangeAvatar (_ sender: Any) {
        self.delegate?.changeAvatar()
    }
    
    @IBAction private func didTapEditProfile (_ sender: Any) {
        self.delegate?.editProfile()
    }
    
    @IBAction private func didTapCreatePost (_ sender: Any) {
        self.delegate?.createPost()
    }
    
}

enum ProfileFilter: String, CaseIterable {
    case posts
    case reviews 
}

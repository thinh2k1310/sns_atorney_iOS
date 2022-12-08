//
//  File.swift
//  Attorney
//
//  Created by ThinhTCQ on 11/17/22.
//

import UIKit
import Kingfisher
import DropDown

enum SortItem: Int, CaseIterable {
    case newest
    case popular
    case nearest
}

protocol HeaderHomeReusableViewDelegate: AnyObject {
    func createPost()
    func goToSearchView()
    func showFilter()
}
final class HeaderHomeReusableView: UICollectionReusableView {
    static let identifier = "HeaderHomeReusableView"
    @IBOutlet private weak var avatarImageView: UIImageView!
    @IBOutlet private weak var createPostPlaceHolder: UILabel!
    @IBOutlet private weak var newestButton: UIButton!
    @IBOutlet private weak var popularButton: UIButton!
    @IBOutlet private weak var nearestButton: UIButton!
    @IBOutlet private weak var filterControl: UIControl!
    
    var didSelectSortItem: ((SortItem) -> Void)?
    
    weak var delegate: HeaderHomeReusableViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        sortBy()
    }
    
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
    
    private func sortBy(_ option: Int = 0) {
        newestButton.isSelected = option == 0
        newestButton.backgroundColor = option == 0 ? Color.F1F1FE : UIColor.white
        popularButton.isSelected = option == 1
        popularButton.backgroundColor = option == 1 ? Color.F1F1FE : UIColor.white
        nearestButton.isSelected = option == 2
        nearestButton.backgroundColor = option == 2 ? Color.F1F1FE : UIColor.white
    }
    
    @IBAction private func didTapSearchBar(_ sender: Any) {
        delegate?.goToSearchView()
    }
    
    @IBAction private func didTapCreatePost(_ sender: Any) {
        delegate?.createPost()
    }
    
    @IBAction private func didTapSortButton(_ sender: AnyObject) {
        guard let tag = (sender as? UIButton)?.tag else {
            return
        }
        self.sortBy(tag)
        self.didSelectSortItem?(SortItem.allCases[tag])
    }
    
    @IBAction private func didTapFilterControl(_ sender: Any) {
        delegate?.showFilter()
        
    }
}

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

enum FilterItem: String, CaseIterable {
    case all = "All"
    case discussing = "DISCUSSING"
    case requesting = "REQUESTING"
}

protocol HeaderHomeReusableViewDelegate: AnyObject {
    func createPost()
    func goToSearchView()
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
    var didSelectFilterItem: ((FilterItem) -> Void)?
    let dropdown = DropDown()
    
    weak var delegate: HeaderHomeReusableViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        sortBy()
        configureDropdown()
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
    
    private func configureDropdown() {
        dropdown.anchorView = filterControl
        dropdown.dataSource = [FilterItem.all.rawValue, FilterItem.discussing.rawValue, FilterItem.requesting.rawValue]
        dropdown.direction = .bottom
        dropdown.bottomOffset = CGPoint(x: 0, y:(dropdown.anchorView?.plainView.bounds.height)!)
        dropdown.selectRow(at: 0)
        DropDown.appearance().textColor = Color.textColor
        DropDown.appearance().selectedTextColor = Color.appTintColor
        DropDown.appearance().textFont = UIFont.appFont(size: 15)
        DropDown.appearance().backgroundColor = UIColor.white
        DropDown.appearance().selectionBackgroundColor = Color.F1F1FE
        DropDown.appearance().cellHeight = 50
        dropdown.selectionAction = {[weak self] (index: Int, item: String) in
            self?.didSelectFilterItem?(FilterItem.allCases[index])
        }
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
        dropdown.show()
    }
}

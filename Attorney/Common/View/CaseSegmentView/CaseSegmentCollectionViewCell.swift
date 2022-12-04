//
//  CaseSegmentCollectionViewCell.swift
//  Attorney
//
//  Created by Truong Thinh on 02/12/2022.
//

import UIKit

class CaseSegmentCollectionViewCell: UICollectionViewCell {
    @IBOutlet private weak var menuLabel: UILabel!
    @IBOutlet private weak var highlightView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        menuLabel.textColor = Color.unselectedTabbar
        highlightView.backgroundColor = .white
    }

    func setupUI(menu: String) {
        menuLabel.text = menu
    }

    override var isSelected: Bool {
        didSet {
            menuLabel.textColor = isSelected ? Color.textColor : Color.unselectedTabbar
            highlightView.backgroundColor = isSelected ? Color.appTintColor : .white
        }
    }

}

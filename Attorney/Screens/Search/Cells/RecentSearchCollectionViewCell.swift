//
//  RecentSearchCollectionViewCell.swift
//  Attorney
//
//  Created by ThinhTCQ on 12/9/22.
//

import UIKit

class RecentSearchCollectionViewCell: UICollectionViewCell {
    static let recentSearchCellHeight = CGFloat(50)
    @IBOutlet private weak var searchKeywordLabel: UILabel!
    @IBOutlet weak var searchKeywordLabelWidthCons: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    var removeKeywordAction: ((String) -> Void)?

    private func configureLayout() {
        searchKeywordLabelWidthCons.constant = UIScreen.main.bounds.width - 78
    }

    func configureCell(keyword: String) {
        searchKeywordLabel.text = keyword
    }

    @IBAction func removeButtonDidTap(_ sender: Any) {
        removeKeywordAction?(searchKeywordLabel.text ?? "")
        UserService.shared.removeRecentSearchKeyword(keyword: searchKeywordLabel.text ?? "")
    }

    static func cellSize(withText: String? = nil) -> CGSize {
        let screenWidth = UIScreen.main.bounds.width
        return CGSize(width: screenWidth - 48, height: recentSearchCellHeight)
    }
}

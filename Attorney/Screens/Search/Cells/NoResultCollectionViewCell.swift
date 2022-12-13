//
//  NoResultCollectionViewCell.swift
//  Attorney
//
//  Created by ThinhTCQ on 12/9/22.
//

import UIKit

final class NoResultCollectionViewCell: UICollectionViewCell {
    @IBOutlet private weak var allTitleView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    static func cellSize(withText: String? = nil, searchType: SearchScreenType) -> CGSize {
        let screenWidth = UIScreen.main.bounds.width
        let cellHeight = [.searchPosts, .searchUsers].contains(searchType) ? Configs.specificTabNoResultCellHeight : Configs.allNoResultCellHeight
        return CGSize(width: screenWidth, height: cellHeight)
    }
    
    func setupDataFor(_ searchType: SearchScreenType) {
        allTitleView.isHidden = [.searchPosts, .searchUsers].contains(searchType)
    }
}

extension NoResultCollectionViewCell {
    struct Configs {
        static let allNoResultCellHeight = CGFloat(115)
        static let specificTabNoResultCellHeight = CGFloat(100)
    }
}

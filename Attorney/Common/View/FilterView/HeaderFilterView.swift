//
//  HeaderFilterView.swift
//  Attorney
//
//  Created by ThinhTCQ on 12/8/22.
//

import UIKit

class HeaderFilterView: UICollectionReusableView {
    static let identifier = "HeaderFilterView"
    @IBOutlet private weak var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureHeader(title: String) {
        titleLabel.text = title
    }
    
}

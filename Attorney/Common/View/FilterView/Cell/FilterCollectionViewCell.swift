//
//  FilterCollectionViewCell.swift
//  Attorney
//
//  Created by ThinhTCQ on 12/8/22.
//

import UIKit

class FilterCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet private weak var radioImageView: UIImageView!
    @IBOutlet private weak var categoryLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    func configureCell(title: String, isSelected: Bool) {
        if isSelected {
            radioImageView.image = R.image.checkRadio()!
        } else {
            radioImageView.image = R.image.uncheckRadio()!
        }
        
        categoryLabel.text = title
    }
}

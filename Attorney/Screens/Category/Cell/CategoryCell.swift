//
//  File.swift
//  Attorney
//
//  Created by ThinhTCQ on 12/8/22.
//

import UIKit

final class CategoryCell: UITableViewCell {
    @IBOutlet private weak var categoryNameLabel: UILabel!
    
    func configureCell(with name: String) {
        categoryNameLabel.text = name
    }
}

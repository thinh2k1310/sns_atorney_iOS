//
//  SearchFooterView.swift
//  Attorney
//
//  Created by ThinhTCQ on 12/9/22.
//

import UIKit

class SearchFooterView: UITableViewHeaderFooterView {
    @IBOutlet private weak var viewAllButton: UIButton!

    var viewAllButtonDidTap: (() -> Void)?

    func configureTitle(title: String?) {
        viewAllButton.setTitle(title, for: .normal)
    }

    @IBAction private func showAllButtonDidTap(_ sender: UIButton) {
        self.viewAllButtonDidTap?()
    }

}

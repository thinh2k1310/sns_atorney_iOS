//
//  LoadMoreIndicatorFooterView.swift
//  Attorney
//
//  Created by ThinhTCQ on 12/9/22.
//

import UIKit

final class LoadMoreIndicatorFooterView: UITableViewHeaderFooterView {
    @IBOutlet private weak var loadingIndicator: UIActivityIndicatorView!

    override func prepareForReuse() {
        super.awakeFromNib()
        DispatchQueue.main.async {
            self.loadingIndicator.startAnimating()
        }
    }
}

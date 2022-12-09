//
//  CaseHeaderView.swift
//  Attorney
//
//  Created by ThinhTCQ on 12/9/22.
//

import UIKit

class CaseHeaderView: UITableViewHeaderFooterView {
    static let reuseIdentifier = "CaseHeaderView"
    @IBOutlet private weak var headerLabel: UILabel!
    @IBOutlet private weak var viewAllButton: UIButton!
    
    var didTapViewAll: ( ([Case]) -> Void )?
    
    var cases: [Case] = []
    
    func configureHeader(title: String, cases: [Case]){
        headerLabel.text = title
        if cases.count > 2 {
            self.cases = cases
            viewAllButton.setTitle("View all (\(cases.count))", for: .normal)
            viewAllButton.isHidden = false
        }
        else {
            viewAllButton.isHidden = true
        }
        
    }
    
    @IBAction private func viewAllDidTap(_ sender: Any) {
        didTapViewAll?(cases)
    }

}

//
//  FilterViewController.swift
//  Attorney
//
//  Created by ThinhTCQ on 12/8/22.
//

import UIKit

final class FilterViewController: ViewController {
    @IBOutlet private weak var filterView: FilterView!
    @IBOutlet private weak var outsideView: UIView!
    
    
    var tappedCreatePost : ((PostAction, Category) -> Void)?
    override func viewDidLoad() {
        super.viewDidLoad()
        addGestures()
        view.backgroundColor = UIColor.clear
        filterView.didTapCreatePost = { [weak self] (action, category) in
            self?.dismiss(animated: true)
            self?.tappedCreatePost?(action,category)
        }
    }
    
    private func addGestures() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(closeFilter))
        tap.cancelsTouchesInView = false
        outsideView.addGestureRecognizer(tap)
    }

    @objc func closeFilter() {
        self.dismiss(animated: true)
    }
    
}

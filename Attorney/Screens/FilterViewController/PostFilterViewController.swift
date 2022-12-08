//
//  PostFilterViewController.swift
//  Attorney
//
//  Created by ThinhTCQ on 12/9/22.
//

import UIKit

final class PostFilterViewController: ViewController {
    @IBOutlet private weak var postFilterView: PostFilterView!
    var showResults : ((FilterAction, [Category]) -> Void)?
    override func viewDidLoad() {
        super.viewDidLoad()
//        addGestures()
        view.backgroundColor = UIColor.clear
        postFilterView.didTapShowResults = { [weak self] (action, categories) in
            self?.dismiss(animated: true)
            self?.showResults?(action,categories)
        }
    }
    
//    private func addGestures() {
//        let tap = UITapGestureRecognizer(target: self, action: #selector(closeFilter))
//        tap.cancelsTouchesInView = false
//        outsideView.addGestureRecognizer(tap)
//    }
//
//    @objc func closeFilter() {
//        self.dismiss(animated: true)
//    }
    
}

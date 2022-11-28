//
//  BaseCustomView.swift
//  Attorney
//
//  Created by ThinhTCQ on 11/17/22.
//

import UIKit

class BaseCustomView: UIView {
    @IBOutlet var contentView: UIView!
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.xibSetup()
    }

    required init?(coder aDecoder: NSCoder) { // for using CustomView in IB
        super.init(coder: aDecoder)
        if self.subviews.isEmpty {
            self.xibSetup()
        }
    }

    private func xibSetup() {
        Bundle.main.loadNibNamed(self.typeName, owner: self, options: nil)
        guard let content = contentView else { return }
        self.addSubview(content)
        content.translatesAutoresizingMaskIntoConstraints = false
        content.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        content.topAnchor.constraint(equalTo: topAnchor).isActive = true
        content.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        content.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        setupUI()
        setupData()
    }

    func setupUI() {
    }

    func setupData() {
    }

    func showInWindow() {
        guard let windowFrame = UIApplication.shared.keyWindow?.frame, let window = UIApplication.shared.keyWindow  else { return }
        frame = windowFrame
        window.addSubview(self)
    }

    func dismissFromWindow() {
        removeFromSuperview()
    }
}


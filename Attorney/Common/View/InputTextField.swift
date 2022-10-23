//
//  InputTextField.swift
//  Attorney
//
//  Created by ThinhTCQ on 10/19/22.
//

import UIKit

final class InputTextField: UITextField {
    let padding = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)

    @IBInspectable var placeholderColor: UIColor? {
        get {
            return self.placeholderColor
        }
        set {
            let attributes: [NSAttributedString.Key: Any] = [
                .font: R.font.proximaNovaRegular(size: 14)!,
                .foregroundColor: newValue!
            ]
            self.attributedPlaceholder = NSAttributedString(string: self.placeholder ?? "",
                                                            attributes: attributes)
        }
    }

    public var status: String = "normal" {
        didSet {
            if status == "normal" {
                self.layer.borderWidth = 1.0
                self.layer.borderColor = Color.colorBorderTextField.cgColor
                self.layer.backgroundColor = Color.backgroundTabbar.cgColor
                self.layer.cornerRadius = 2
            } else {
                self.layer.borderWidth = 1.0
                self.layer.borderColor = Color.colorError.cgColor
                self.layer.backgroundColor = Color.FEEDEE.cgColor
                self.layer.cornerRadius = 2
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupUI()
    }

    func setupUI() {
        self.textColor = Color.textColor
        self.layer.borderWidth = 1.0
        self.layer.borderColor = Color.colorBorderTextField.cgColor
        self.layer.backgroundColor = Color.backgroundTabbar.cgColor
        self.layer.cornerRadius = 2
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
      return bounds.inset(by: padding)
    }

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
      return bounds.inset(by: padding)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
      return bounds.inset(by: padding)
    }
}

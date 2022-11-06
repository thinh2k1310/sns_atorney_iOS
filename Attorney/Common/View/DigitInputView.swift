//
//  DigitInputView.swift
//  Attorney
//
//  Created by ThinhTCQ on 11/3/22.
//

import UIKit

// swiftlint:disable empty_count for_where
public enum DigitInputViewAnimationType: Int {
    case none, dissolve, spring
}

public protocol DigitInputViewDelegate: AnyObject {
    func digitsDidChange(digitInputView: DigitInputView)
}

open class DigitInputView: UIView {
    /**
     The number of digits to show, which will be the maximum length of the final string
     */
    open var numberOfDigits: Int = 6 {
        didSet {
            setup()
        }
    }

    /**
     The color of the digits
     */
    open var textColor: UIColor = .black {
        didSet {
            setup()
        }
    }

    /**
     If not nil, only the characters in this string are acceptable. The rest will be ignored.
     */
    open var acceptableCharacters: String?

    /**
     The keyboard type that shows up when entering characters
     */
    open var keyboardType: UIKeyboardType = .numberPad {
        didSet {
            setup()
        }
    }

    /// The animatino to use to show new digits
    open var animationType: DigitInputViewAnimationType = .none

    /**
     The font of the digits. Although font size will be calculated automatically.
     */
    open var font: UIFont?

    /**
     The string that the user has entered
     */
    open var text: String {
            guard let textField = textField else { return "" }
            return textField.text ?? ""
    }

    open weak var delegate: DigitInputViewDelegate?

    fileprivate var labels = [DigitInputLabel]()
    fileprivate var textField: UITextField?
    fileprivate var tapGestureRecognizer: UITapGestureRecognizer?
    fileprivate var spacing: CGFloat = 12

    var isCheckColor = false {
        willSet(newValue) {
            for label in labels {
                label.backgroundColor = newValue ? .white : Color.warningBackground
            }
        }
    }

    override open var canBecomeFirstResponder: Bool {
            return true
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    override open func becomeFirstResponder() -> Bool {
        guard let textField = textField else { return false }
        textField.becomeFirstResponder()
        return true
    }

    override open func resignFirstResponder() -> Bool {
        guard let textField = textField else { return true }
        textField.resignFirstResponder()
        return true
    }

    override open func layoutSubviews() {
        super.layoutSubviews()

        // width to height ratio
        let ratio: CGFloat = 0.76

        // Now we find the optimal font size based on the view size
        // and set the frame for the labels
        var characterWidth = frame.height * ratio
        var characterHeight = frame.height

        // if using the current width, the digits go off the view, recalculate
        // based on width instead of height
        if (characterWidth + spacing) * CGFloat(numberOfDigits) + spacing > frame.width {
            characterWidth = (frame.width - spacing * CGFloat(numberOfDigits + 1)) / CGFloat(numberOfDigits)
            characterHeight = characterWidth / ratio
        }

        let extraSpace: CGFloat = frame.width - CGFloat(numberOfDigits - 1) * spacing - CGFloat(numberOfDigits) * characterWidth

        // font size should be less than the available vertical space
        let fontSize = characterHeight * 1.5// 0.8

        let y = (frame.height - characterHeight) / 2
        for (index, label) in labels.enumerated() {
            let x = extraSpace / 2 + (characterWidth + spacing) * CGFloat(index)
            label.frame = CGRect(x: x, y: y, width: characterWidth, height: characterHeight)
            label.padding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            label.backgroundColor = isCheckColor ? .white : Color.FEEDEE
            label.layer.borderColor = isCheckColor ? Color.colorBorderTextField.cgColor : Color.colorPaymentError.cgColor
            label.layer.borderWidth = 1
            label.layer.cornerRadius = 16
            label.layer.masksToBounds = true

            if let font = font {
                label.font = font
            } else {
                label.font = label.font.withSize(fontSize)
            }
        }
    }

    /**
     Sets up the required views
     */
    fileprivate func setup() {
        isUserInteractionEnabled = true
        clipsToBounds = true

        if tapGestureRecognizer == nil {
            tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewTapped(_:)))
            addGestureRecognizer(tapGestureRecognizer!)
        }

        if textField == nil {
            textField = UITextField()
            textField?.delegate = self
            textField?.frame = CGRect(x: 0, y: -40, width: 100, height: 30)
            addSubview(textField!)
        }

        textField?.keyboardType = keyboardType

        // Since this function isn't called frequently, we just remove everything
        // and recreate them. Don't need to optimize it.

        for label in labels {
            label.removeFromSuperview()
        }
        labels.removeAll()

        for _ in 0..<numberOfDigits {
            let label = DigitInputLabel()
            label.textAlignment = .center
            label.isUserInteractionEnabled = false
            label.textColor = textColor

            addSubview(label)

            labels.append(label)
        }
    }

    /**
     Handles tap gesture on the view
     */
    @objc fileprivate func viewTapped(_ sender: UITapGestureRecognizer) {
        textField!.becomeFirstResponder()
    }

    /**
     Called when the text changes so that the labels get updated
     */
    fileprivate func didChange(_ backspaced: Bool = false) {
        guard let textField = textField, let text = textField.text else { return }

        for item in labels {
            item.text = ""
        }

        for (index, item) in text.enumerated() {
            if labels.count > index {
                let animate = index == text.count - 1 && !backspaced
                changeText(of: labels[index], newText: String(item), animate)
            }
        }

        let nextIndex = text.count + 1
        if labels.count > 0, nextIndex < labels.count + 1 {
            // set the next digit bottom border color
            //            underlines[nextIndex - 1].backgroundColor = nextDigitBottomBorderColor
        }

        delegate?.digitsDidChange(digitInputView: self)
    }

    /// Changes the text of a UILabel with animation
    ///
    /// - parameter label: The label to change text of
    /// - parameter newText: The new string for the label
    private func changeText(of label: UILabel, newText: String, _ animated: Bool = false) {
        if !animated || animationType == .none {
            label.text = newText
            return
        }

        if animationType == .spring {
            label.frame.origin.y = frame.height
            label.text = newText

            UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.1, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
                label.frame.origin.y = self.frame.height - label.frame.height
            }, completion: nil)
        } else if animationType == .dissolve {
            UIView.transition(with: label,
                              duration: 0.4,
                              options: .transitionCrossDissolve,
                              animations: {
                                label.text = newText
            }, completion: nil)
        }
    }

    func resetTextField() {
        self.textField?.text = ""
        self.labels.forEach { $0.text = "" }
//        self.didChange(true)
    }
}

// MARK: TextField Delegate
extension DigitInputView: UITextFieldDelegate {
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Auto populate OTP SMS
        if #available(iOS 12.0, *) {
            // textField.textContentType = UITextContentType.oneTimeCode

            let char = string.cString(using: .utf8)
            let isBackSpace = strcmp(char, "\\b")
            if isBackSpace == -92, let text = textField.text {
                if text.count <= 6 && text.count > 0 {
                    textField.text = String(text[..<text.index(text.endIndex, offsetBy: -1)])
                }

                didChange(true)
                return false
            }
        } else {
            // Fallback on earlier versions

            let char = string.cString(using: .utf8)
            let isBackSpace = strcmp(char, "\\b")
            if isBackSpace == -92, let text = textField.text {
//                textField.text = text.substring(to: text.index(text.endIndex, offsetBy: -1))
                textField.text = String(text[..<text.index(text.endIndex, offsetBy: -1)])
                didChange(true)
                return false
            }
        }

        if textField.text?.count ?? 0 >= numberOfDigits {
            return false
        }

        guard let acceptableCharacters = acceptableCharacters else {
            textField.text = (textField.text ?? "") + string
            didChange()
            return false
        }

        if acceptableCharacters.contains(string) {
            textField.text = (textField.text ?? "") + string
            didChange()
            return false
        }

        return false
    }
}

class DigitInputLabel: UILabel {
    private struct AssociatedKeys {
        static var padding = UIEdgeInsets()
    }

    public var padding: UIEdgeInsets? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.padding) as? UIEdgeInsets
        }
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(self, &AssociatedKeys.padding, newValue as UIEdgeInsets?, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }

    override open func draw(_ rect: CGRect) {
        if let insets = padding {
//            self.drawText(in: UIEdgeInsetsInsetRect(rect, insets))
            self.drawText(in: rect.inset(by: insets))
        } else {
            self.drawText(in: rect)
        }
    }

    override open var intrinsicContentSize: CGSize {
        guard let text = self.text else { return super.intrinsicContentSize }

        var contentSize = super.intrinsicContentSize
        var textWidth: CGFloat = frame.size.width
        var insetsHeight: CGFloat = 0.0

        if let insets = padding {
            textWidth -= insets.left + insets.right
            insetsHeight += insets.top + insets.bottom
        }

        let newSize = text.boundingRect(with: CGSize(width: textWidth, height: CGFloat.greatestFiniteMagnitude),
                                        options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                        attributes: [NSAttributedString.Key.font: self.font!],
                                        context: nil)

        contentSize.height = ceil(newSize.size.height) + insetsHeight

        return contentSize
    }
}

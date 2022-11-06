//
//  UITextViewExtension.swift
//  Attorney
//
//  Created by ThinhTCQ on 10/31/22.
//

import UIKit

extension UITextView {
    func centerVertically() {
           let fittingSize = CGSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude)
           let size = sizeThatFits(fittingSize)
           let topOffset = (bounds.size.height - size.height * zoomScale) / 2
           let positiveTopOffset = max(1, topOffset)
           contentOffset.y = -positiveTopOffset
       }   
}

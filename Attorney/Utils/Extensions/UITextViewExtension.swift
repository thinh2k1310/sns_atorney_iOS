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
    
    func sizeFit(width: CGFloat) -> CGSize {
        let fixedWidth = width
        let newSize = sizeThatFits(CGSize(width: fixedWidth, height: .greatestFiniteMagnitude))
        return CGSize(width: fixedWidth, height: newSize.height)
    }

    func numberOfLine() -> Int {
        let size = self.sizeFit(width: self.bounds.width)
        let numLines = Int((size.height / (self.font?.lineHeight ?? 1.0)).rounded())
        return numLines - 1
    }

    func getNumberOfLines() -> Int {
        /// An empty string's array
        var linesArray = [String]()
        guard let text = self.text, let font = self.font else {return linesArray.count}
        let rect = self.frame
        let myFont = CTFontCreateWithFontDescriptor(font.fontDescriptor, 0, nil)
        let attStr = NSMutableAttributedString(string: text)
        attStr.addAttribute(kCTFontAttributeName as NSAttributedString.Key, value: myFont, range: NSRange(location: 0, length: attStr.length))
        let frameSetter: CTFramesetter = CTFramesetterCreateWithAttributedString(attStr as CFAttributedString)
        let path: CGMutablePath = CGMutablePath()
        path.addRect(CGRect(x: 0, y: 0, width: rect.size.width, height: 100000), transform: .identity)
        let frame: CTFrame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, 0), path, nil)
        guard let lines = CTFrameGetLines(frame) as? [Any] else {return linesArray.count}
        for (index, line) in lines.enumerated() {
            let lineRef = line as! CTLine
            let lineRange: CFRange = CTLineGetStringRange(lineRef)
            let range = NSRange(location: lineRange.location, length: lineRange.length)
            var lineString: String = (text as NSString).substring(with: range)
            if lineString.contains("\n") && index != (lines.count - 1) {
                lineString = lineString.replace(string: "\n", replacement: "")
                linesArray.append("\n")
            }
            linesArray.append(lineString)
        }

        return linesArray.count
    }
}

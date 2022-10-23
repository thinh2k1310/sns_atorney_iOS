//
//  CoachMarkView.swift
//  Attorney
//
//  Created by ThinhTCQ on 10/20/22.
//

import UIKit

public protocol CoachmarkViewDelegate: AnyObject {
    func coachmarkViewDidTap(_ tipView: CoachmarkView)
    func coachmarkViewDidDismiss(_ tipView: CoachmarkView)
}

extension UIWindow {
    func removeTooltip() {
        for subview in self.subviews where subview is CoachmarkView {
            subview.removeFromSuperview()
        }
    }
}

// MARK: - Public methods extension
public extension CoachmarkView {
    // MARK: - Class methods -

    func show(animated: Bool = true, forView view: UIView, withinSuperview superview: UIView? = nil, heightNavigationBar: CGFloat = 0) {
        #if TARGET_APP_EXTENSIONS
            precondition(superview != nil, "The supplied superview parameter cannot be nil for app extensions.")
            let superview = superview!
        #else
            precondition(superview == nil || view.hasSuperview(superview!), "The supplied superview <\(superview!)> is not a direct nor an indirect superview of the supplied reference view <\(view)>. The superview passed to this method should be a direct or an indirect superview of the reference view. To display the tooltip within the main window, ignore the superview parameter.")
            let superview = superview ?? UIApplication.shared.windows.first!
        #endif

        let initialTransform = preferences.animating.showInitialTransform
        let finalTransform = preferences.animating.showFinalTransform
        let initialAlpha = preferences.animating.showInitialAlpha
        let damping = preferences.animating.springDamping
        let velocity = preferences.animating.springVelocity

        presentingView = view
        arrange(withinSuperview: superview, heightNavigationBar: heightNavigationBar)

        if isSingleShow {
            self.removeAllTooltips()
        }

        transform = initialTransform
        alpha = initialAlpha

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tap)

        superview.addSubview(self)

        let animations: () -> Void = { [weak self] in
            self?.transform = finalTransform
            self?.alpha = 1
        }

        if animated {
            UIView.animate(withDuration: preferences.animating.showDuration, delay: 0, usingSpringWithDamping: damping, initialSpringVelocity: velocity, options: [.curveEaseInOut], animations: animations, completion: nil)
        } else {
            animations()
        }
    }

    func dismiss(withCompletion completion: (() -> Void)? = nil) {
        let damping = preferences.animating.springDamping
        let velocity = preferences.animating.springVelocity

        UIView.animate(withDuration: preferences.animating.dismissDuration, delay: 0, usingSpringWithDamping: damping, initialSpringVelocity: velocity, options: [.curveEaseInOut], animations: {
            self.transform = self.preferences.animating.dismissTransform
            self.alpha = self.preferences.animating.dismissFinalAlpha
        }, completion: { _ in
            completion?()
            self.delegate?.coachmarkViewDidDismiss(self)
            self.removeFromSuperview()
            self.transform = CGAffineTransform.identity
        })
    }
}

public class CoachmarkView: UIView {
    // MARK: - Variables
    override open var backgroundColor: UIColor? {
        didSet {
            guard let color = backgroundColor, color != UIColor.clear else { return }
            preferences.drawing.backgroundColor = color
            backgroundColor = UIColor.clear
        }
    }

    override open var description: String {
        let type = "'\(String(reflecting: Swift.type(of: self)))'".components(separatedBy: ".").last!

        return "<< \(type) with \(content) >>"
    }

    private weak var presentingView: UIView?
    private weak var delegate: CoachmarkViewDelegate?
    private var arrowTip = CGPoint.zero
    open private(set) var preferences: CoachmarkPreferences
    private let content: CoachmarkContent

    // MARK: - Lazy variables -
    private lazy var contentSize: CGSize = { [unowned self] in
        switch content {
        case .text(let text):
            var textHeight = text.height(withConstrainedWidth: self.preferences.positioning.maxWidth, font: self.preferences.drawing.font)
            var textSize: CGSize = CGSize(width: ceil(self.preferences.positioning.maxWidth),
                                          height: ceil(textHeight))
            if textSize.width < self.preferences.drawing.arrowWidth {
                textSize.width = self.preferences.drawing.arrowWidth
            }

            return textSize

        case .attributedText(let attributedText):
            var textHeight = attributedText.string.height(withConstrainedWidth: self.preferences.positioning.maxWidth, font: self.preferences.drawing.font)
            var textSize: CGSize = CGSize(width: ceil(self.preferences.positioning.maxWidth),
                                          height: ceil(textHeight))
            if textSize.width < self.preferences.drawing.arrowWidth {
                textSize.width = self.preferences.drawing.arrowWidth
            }

            return textSize

        case .view(let contentView):
            return contentView.frame.size
        }
    }()

    private lazy var tipViewSize: CGSize = {
        [unowned self] in
        var tipViewSize =
            CGSize(
            width: self.contentSize.width + self.preferences.positioning.contentInsets.left + self.preferences.positioning.contentInsets.right + self.preferences.positioning.bubbleInsets.left + self.preferences.positioning.bubbleInsets.right,
            height: self.contentSize.height + self.preferences.positioning.contentInsets.top + self.preferences.positioning.contentInsets.bottom + self.preferences.positioning.bubbleInsets.top + self.preferences.positioning.bubbleInsets.bottom + self.preferences.drawing.arrowHeight)

        return tipViewSize
    }()

    // MARK: - Static variables -
    public static var globalPreferences = CoachmarkPreferences()

    // MARK: - Public variables -
    public var isSingleShow = false

    // MARK: - Initializer -
    public convenience init (text: String, preferences: CoachmarkPreferences = CoachmarkView.globalPreferences, delegate: CoachmarkViewDelegate? = nil) {
        self.init(content: .text(text), preferences: preferences, delegate: delegate)

        self.isAccessibilityElement = true
        self.accessibilityTraits = UIAccessibilityTraits.staticText
        self.accessibilityLabel = text
    }

    public convenience init(contentView: UIView, preferences: CoachmarkPreferences = CoachmarkView.globalPreferences, delegate: CoachmarkViewDelegate? = nil) {
        self.init(content: .view(contentView), preferences: preferences, delegate: delegate)
    }

    public convenience init(attributedText: NSAttributedString, preferences: CoachmarkPreferences = CoachmarkView.globalPreferences, delegate: CoachmarkViewDelegate? = nil) {
        self.init(content: .attributedText(attributedText), preferences: preferences, delegate: delegate)
    }

    public init(content: CoachmarkContent, preferences: CoachmarkPreferences = CoachmarkView.globalPreferences, delegate: CoachmarkViewDelegate? = nil) {
        self.content = content
        self.preferences = preferences
        self.delegate = delegate

        super.init(frame: CGRect.zero)
        self.backgroundColor = .clear
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    /**
     NSCoding not supported. Use init(text, preferences, delegate) instead!
     */
    public required init?(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported. Use init(text, preferences, delegate) instead!")
    }

    // MARK: - Private methods -
    private func computeFrame(arrowPosition position: CoachmarkArrowPosition, refViewFrame: CGRect, superviewFrame: CGRect) -> CGRect {
        var xOrigin: CGFloat = 0
        var yOrigin: CGFloat = 0

        switch position {
        case .top:
            xOrigin = refViewFrame.center.x - tipViewSize.width / 2
            yOrigin = refViewFrame.y + refViewFrame.height

        case .any, .bottom:
            xOrigin = refViewFrame.center.x - tipViewSize.width / 2
            yOrigin = refViewFrame.y - tipViewSize.height

        case .right:
            xOrigin = refViewFrame.x - tipViewSize.width
            yOrigin = refViewFrame.center.y - tipViewSize.height / 2

        case .left:
            xOrigin = refViewFrame.x + refViewFrame.width
            yOrigin = refViewFrame.center.y - tipViewSize.height / 2
        }

        var frame = CGRect(x: xOrigin, y: yOrigin, width: tipViewSize.width, height: tipViewSize.height)
        adjustFrame(&frame, forSuperviewFrame: superviewFrame)
        return frame
    }

    private func adjustFrame(_ frame: inout CGRect, forSuperviewFrame superviewFrame: CGRect) {
        // adjust horizontally
        if frame.x < 0 {
            frame.x = 0
        } else if frame.maxX > superviewFrame.width {
            frame.x = superviewFrame.width - frame.width
        }
        // adjust vertically
        if frame.y < 0 {
            frame.y = 0
        } else if frame.maxY > superviewFrame.maxY {
            frame.y = superviewFrame.height - frame.height
        }
    }

    private func isFrameValid(_ frame: CGRect, forRefViewFrame: CGRect, withinSuperviewFrame: CGRect, heightNavigationBar: CGFloat = 0) -> Bool {
        let not = (!)
        let refNavBarRect = CGRect(origin: .zero, size: CGSize(width: UIScreen.main.bounds.width, height: heightNavigationBar))
        return not(frame.intersects(forRefViewFrame) || frame.intersects(refNavBarRect))
    }

    private func arrange(withinSuperview superview: UIView, heightNavigationBar: CGFloat) {
        var position = preferences.drawing.arrowPosition

        let refViewFrame = presentingView!.convert(presentingView!.bounds, to: superview)

        let superviewFrame: CGRect
        if let scrollview = superview as? UIScrollView {
            superviewFrame = CGRect(origin: scrollview.frame.origin, size: scrollview.contentSize)
        } else {
            superviewFrame = superview.frame
        }

        var frame = computeFrame(arrowPosition: position, refViewFrame: refViewFrame, superviewFrame: superviewFrame)

        if !isFrameValid(frame, forRefViewFrame: refViewFrame, withinSuperviewFrame: superviewFrame, heightNavigationBar: heightNavigationBar) {
            for value in CoachmarkArrowPosition.allCases where value != position {
                let newFrame = computeFrame(arrowPosition: value, refViewFrame: refViewFrame, superviewFrame: superviewFrame)
                if isFrameValid(newFrame, forRefViewFrame: refViewFrame, withinSuperviewFrame: superviewFrame, heightNavigationBar: heightNavigationBar) {
                    if position != .any {
                        print("[CoachmarkView - Info] The arrow position you chose <\(position)> could not be applied. Instead, position <\(value)> has been applied! Please specify position <\(CoachmarkArrowPosition.any)> if you want KPCoachmarkView to choose a position for you.")
                    }

                    frame = newFrame
                    position = value
                    preferences.drawing.arrowPosition = value
                    break
                }
            }
        }

        switch position {
        case .bottom, .top, .any:
            var arrowTipXOrigin: CGFloat
            if frame.width < refViewFrame.width {
                arrowTipXOrigin = tipViewSize.width / 2
            } else {
                arrowTipXOrigin = abs(frame.x - refViewFrame.x) + refViewFrame.width / 2
            }

            arrowTip = CGPoint(x: arrowTipXOrigin, y: [.bottom, .any].contains(position) ? tipViewSize.height - preferences.positioning.bubbleInsets.bottom : preferences.positioning.bubbleInsets.top)

        case .right, .left:
            var arrowTipYOrigin: CGFloat
            if frame.height < refViewFrame.height {
                arrowTipYOrigin = tipViewSize.height / 2
            } else {
                arrowTipYOrigin = abs(frame.y - refViewFrame.y) + refViewFrame.height / 2
            }

            arrowTip = CGPoint(x: preferences.drawing.arrowPosition == .left ? preferences.positioning.bubbleInsets.left : tipViewSize.width - preferences.positioning.bubbleInsets.right, y: arrowTipYOrigin)
        }

        if case .view(let contentView) = content {
            contentView.translatesAutoresizingMaskIntoConstraints = false
            contentView.frame = getContentRect(from: getBubbleFrame())
        }

        self.frame = frame
    }

    // MARK: - Callbacks -

    @objc func handleTap() {
        self.delegate?.coachmarkViewDidTap(self)
        guard preferences.animating.dismissOnTap else { return }
        dismiss()
    }

    // MARK: - Drawing -

    private func drawBubble(_ bubbleFrame: CGRect, arrowPosition: CoachmarkArrowPosition, context: CGContext) {
        let arrowWidth = preferences.drawing.arrowWidth
        let arrowHeight = preferences.drawing.arrowHeight
        let cornerRadius = preferences.drawing.cornerRadius

        let contourPath = CGMutablePath()

        contourPath.move(to: CGPoint(x: arrowTip.x, y: arrowTip.y))
        switch arrowPosition {
        case .bottom, .top, .any:
            contourPath.addLine(to: CGPoint(x: arrowTip.x - arrowWidth / 2, y: arrowTip.y + ([.bottom, .any].contains(arrowPosition) ? -1 : 1) * arrowHeight))
            if [.bottom, .any].contains(arrowPosition) {
                drawBubbleBottomShape(bubbleFrame, cornerRadius: cornerRadius, path: contourPath)
            } else {
                drawBubbleTopShape(bubbleFrame, cornerRadius: cornerRadius, path: contourPath)
            }
            contourPath.addLine(to: CGPoint(x: arrowTip.x + arrowWidth / 2, y: arrowTip.y + ([.bottom, .any].contains(arrowPosition) ? -1 : 1) * arrowHeight))

        case .right, .left:
            contourPath.addLine(to: CGPoint(x: arrowTip.x + (arrowPosition == .right ? -1 : 1) * arrowHeight, y: arrowTip.y - arrowWidth / 2))

            if arrowPosition == .right {
                drawBubbleRightShape(bubbleFrame, cornerRadius: cornerRadius, path: contourPath)
            } else {
                drawBubbleLeftShape(bubbleFrame, cornerRadius: cornerRadius, path: contourPath)
            }

            contourPath.addLine(to: CGPoint(x: arrowTip.x + (arrowPosition == .right ? -1 : 1) * arrowHeight, y: arrowTip.y + arrowWidth / 2))
        }

        contourPath.closeSubpath()
        context.addPath(contourPath)
        context.clip()

        paintBubble(context)

        if preferences.hasBorder {
            drawBorder(contourPath, context: context)
        }
    }

    private func drawBubbleBottomShape(_ frame: CGRect, cornerRadius: CGFloat, path: CGMutablePath) {
        path.addArc(tangent1End: CGPoint(x: frame.x, y: frame.y + frame.height), tangent2End: CGPoint(x: frame.x, y: frame.y), radius: cornerRadius)
        path.addArc(tangent1End: CGPoint(x: frame.x, y: frame.y), tangent2End: CGPoint(x: frame.x + frame.width, y: frame.y), radius: cornerRadius)
        path.addArc(tangent1End: CGPoint(x: frame.x + frame.width, y: frame.y), tangent2End: CGPoint(x: frame.x + frame.width, y: frame.y + frame.height), radius: cornerRadius)
        path.addArc(tangent1End: CGPoint(x: frame.x + frame.width, y: frame.y + frame.height), tangent2End: CGPoint(x: frame.x, y: frame.y + frame.height), radius: cornerRadius)
    }

    private func drawBubbleTopShape(_ frame: CGRect, cornerRadius: CGFloat, path: CGMutablePath) {
        path.addArc(tangent1End: CGPoint(x: frame.x, y: frame.y), tangent2End: CGPoint(x: frame.x, y: frame.y + frame.height), radius: cornerRadius)
        path.addArc(tangent1End: CGPoint(x: frame.x, y: frame.y + frame.height), tangent2End: CGPoint(x: frame.x + frame.width, y: frame.y + frame.height), radius: cornerRadius)
        path.addArc(tangent1End: CGPoint(x: frame.x + frame.width, y: frame.y + frame.height), tangent2End: CGPoint(x: frame.x + frame.width, y: frame.y), radius: cornerRadius)
        path.addArc(tangent1End: CGPoint(x: frame.x + frame.width, y: frame.y), tangent2End: CGPoint(x: frame.x, y: frame.y), radius: cornerRadius)
    }

    private func drawBubbleRightShape(_ frame: CGRect, cornerRadius: CGFloat, path: CGMutablePath) {
        path.addArc(tangent1End: CGPoint(x: frame.x + frame.width, y: frame.y), tangent2End: CGPoint(x: frame.x, y: frame.y), radius: cornerRadius)
        path.addArc(tangent1End: CGPoint(x: frame.x, y: frame.y), tangent2End: CGPoint(x: frame.x, y: frame.y + frame.height), radius: cornerRadius)
        path.addArc(tangent1End: CGPoint(x: frame.x, y: frame.y + frame.height), tangent2End: CGPoint(x: frame.x + frame.width, y: frame.y + frame.height), radius: cornerRadius)
        path.addArc(tangent1End: CGPoint(x: frame.x + frame.width, y: frame.y + frame.height), tangent2End: CGPoint(x: frame.x + frame.width, y: frame.height), radius: cornerRadius)
    }

    private func drawBubbleLeftShape(_ frame: CGRect, cornerRadius: CGFloat, path: CGMutablePath) {
        path.addArc(tangent1End: CGPoint(x: frame.x, y: frame.y), tangent2End: CGPoint(x: frame.x + frame.width, y: frame.y), radius: cornerRadius)
        path.addArc(tangent1End: CGPoint(x: frame.x + frame.width, y: frame.y), tangent2End: CGPoint(x: frame.x + frame.width, y: frame.y + frame.height), radius: cornerRadius)
        path.addArc(tangent1End: CGPoint(x: frame.x + frame.width, y: frame.y + frame.height), tangent2End: CGPoint(x: frame.x, y: frame.y + frame.height), radius: cornerRadius)
        path.addArc(tangent1End: CGPoint(x: frame.x, y: frame.y + frame.height), tangent2End: CGPoint(x: frame.x, y: frame.y), radius: cornerRadius)
    }

    private func paintBubble(_ context: CGContext) {
        context.setFillColor(preferences.drawing.backgroundColor.cgColor)
        context.fill(bounds)
    }

    private func drawBorder(_ borderPath: CGPath, context: CGContext) {
        context.addPath(borderPath)
        context.setStrokeColor(preferences.drawing.borderColor.cgColor)
        context.setLineWidth(preferences.drawing.borderWidth)
        context.strokePath()
    }

    private func drawText(_ bubbleFrame: CGRect, context: CGContext) {
        guard case .text(let text) = content else { return }
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = preferences.drawing.textAlignment
        paragraphStyle.lineBreakMode = NSLineBreakMode.byWordWrapping

        let textRect = getContentRect(from: bubbleFrame)
        let attributes: [NSAttributedString.Key: Any] = [.font: preferences.drawing.font, .foregroundColor: preferences.drawing.foregroundColor, .paragraphStyle: paragraphStyle]
        text.draw(in: textRect, withAttributes: attributes)
    }

    private func drawAttributedText(_ bubbleFrame: CGRect, context: CGContext) {
        guard case .attributedText(let text) = content else { return }
        let textRect = getContentRect(from: bubbleFrame)
        text.draw(with: textRect, options: .usesLineFragmentOrigin, context: .none)
    }

    private func drawShadow() {
        if preferences.hasShadow {
            self.layer.masksToBounds = false
            self.layer.shadowColor = preferences.drawing.shadowColor.cgColor
            self.layer.shadowOffset = preferences.drawing.shadowOffset
            self.layer.shadowRadius = preferences.drawing.shadowRadius
            self.layer.shadowOpacity = Float(preferences.drawing.shadowOpacity)
        }
    }

    override open func draw(_ rect: CGRect) {
        let bubbleFrame = getBubbleFrame()
        let context = UIGraphicsGetCurrentContext()!
        context.saveGState()
        drawBubble(bubbleFrame, arrowPosition: preferences.drawing.arrowPosition, context: context)

        switch content {
        case .text:
            drawText(bubbleFrame, context: context)

        case .attributedText:
            drawAttributedText(bubbleFrame, context: context)

        case .view(let view):
            addSubview(view)
        }

        drawShadow()
        context.restoreGState()
    }

    private func getBubbleFrame() -> CGRect {
        let arrowPosition = preferences.drawing.arrowPosition
        let bubbleWidth: CGFloat
        let bubbleHeight: CGFloat
        let bubbleXOrigin: CGFloat
        let bubbleYOrigin: CGFloat
        switch arrowPosition {
        case .bottom, .top, .any:
            bubbleWidth = tipViewSize.width - preferences.positioning.bubbleInsets.left - preferences.positioning.bubbleInsets.right
            bubbleHeight = tipViewSize.height - preferences.positioning.bubbleInsets.top - preferences.positioning.bubbleInsets.bottom - preferences.drawing.arrowHeight

            bubbleXOrigin = preferences.positioning.bubbleInsets.left
            bubbleYOrigin = [.bottom, .any].contains(arrowPosition) ? preferences.positioning.bubbleInsets.top : preferences.positioning.bubbleInsets.top + preferences.drawing.arrowHeight

        case .left, .right:
            bubbleWidth = tipViewSize.width - preferences.positioning.bubbleInsets.left - preferences.positioning.bubbleInsets.right - preferences.drawing.arrowHeight
            bubbleHeight = tipViewSize.height - preferences.positioning.bubbleInsets.top - preferences.positioning.bubbleInsets.left

            bubbleXOrigin = arrowPosition == .right ? preferences.positioning.bubbleInsets.left : preferences.positioning.bubbleInsets.left + preferences.drawing.arrowHeight
            bubbleYOrigin = preferences.positioning.bubbleInsets.top
        }
        return CGRect(x: bubbleXOrigin, y: bubbleYOrigin, width: bubbleWidth, height: bubbleHeight)
    }

    private func getContentRect(from bubbleFrame: CGRect) -> CGRect {
        return CGRect(x: bubbleFrame.origin.x + preferences.positioning.contentInsets.left, y: bubbleFrame.origin.y + preferences.positioning.contentInsets.top, width: contentSize.width, height: contentSize.height)
    }

    private func removeAllTooltips() {
        guard let window: UIWindow = (UIApplication.shared.delegate as? AppDelegate)?.window else { return }
        window.removeTooltip()
    }
}

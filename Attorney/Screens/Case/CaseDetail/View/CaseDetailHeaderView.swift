//
//  CaseDetailHeaderView.swift
//  Attorney
//
//  Created by ThinhTCQ on 12/12/22.
//

import UIKit
import Kingfisher

protocol CaseDetailHeaderViewDelegate: AnyObject {
    func goToClient()
    func goToAttorney()
    func goToPostDetail()
    func completeCase()
    func cancelCase()
    func reviewCase()
}

final class CaseDetailHeaderView: UITableViewHeaderFooterView {
    // MARK: - IBOutlets
    @IBOutlet private weak var clientControl: UIControl!
    @IBOutlet private weak var clientImageView: UIImageView!
    @IBOutlet private weak var clientNameLabel: UILabel!
    @IBOutlet private weak var clientStatusLabel: UILabel!
    @IBOutlet private weak var attorneyControl: UIControl!
    @IBOutlet private weak var attorneyImageView: UIImageView!
    @IBOutlet private weak var attorneyNameLabel: UILabel!
    @IBOutlet private weak var attorneyStatusLabel: UILabel!
    @IBOutlet private weak var startingTimeLabel: UILabel!
    @IBOutlet private weak var endingTimeLabel: UILabel!
    @IBOutlet private weak var statusLabel: UILabel!
    @IBOutlet private weak var postContentLabel: UILabel!
    @IBOutlet private weak var completeButton: UIButton!
    @IBOutlet private weak var cancelButton: UIButton!
    @IBOutlet private weak var reviewButton: UIButton!
    @IBOutlet private weak var viewDetailPostButton: UIButton!
    @IBOutlet private weak var contentLabelHeightConstraint: NSLayoutConstraint!
    
    // MARK: - Variables
    
    weak var delegate: CaseDetailHeaderViewDelegate?
    
    var caseDetail: Case?
    
    private let whiteBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 1, alpha: 1)
        view.isHidden = false
        return view
    }()
    
    // MARK: - Functions
    
    func bindingUI(with caseDetail: Case) {
        self.caseDetail = caseDetail
        if let client = caseDetail.customer {
            setupClientView(user: client)
        }
        
        if let attorney = caseDetail.attorney {
            setupAttorney(user: attorney)
        }
        setupInfoView(with: caseDetail)
        
        if let post = caseDetail.post {
            setupPostView(post: post)
        }
        setupStatus(with: caseDetail)
        if let status = caseDetail.status {
            if status == CaseStatus.inProgress.rawValue {
                completeButton.isEnabled = true
                cancelButton.isEnabled = true
                reviewButton.isHidden = false
            } else {
                completeButton.isEnabled = false
                completeButton.alpha = 0.5
                cancelButton.isEnabled = false
                cancelButton.alpha = 0.5
            }
            
            if status == CaseStatus.complete.rawValue {
                reviewButton.isHidden = false
            } else {
                reviewButton.isHidden = true
            }
        }
        let attributedText = NSMutableAttributedString(string: "Leave a review",
                                                       attributes: [
                                                        .font: UIFont.appSemiBoldFont(size: 14),
                                                        .foregroundColor: Color.appTintColor,
                                                        .underlineStyle: NSUnderlineStyle.thick.rawValue,
                                                        .underlineColor: Color.appTintColor
                                                       ])
        reviewButton.titleLabel?.attributedText = attributedText
        
    }
    
    private func setupPostView(post: ShortPost) {
        // Content
        postContentLabel.text = post.content ?? ""
        let contentHeight = (post.content ?? "").heightAsTextView(withConstrainedWidth: self.frame.size.width - 20, font: UIFont.appFont(size: 14), numberOfLines: 3)
        contentLabelHeightConstraint.constant = contentHeight
        let attributedText = NSMutableAttributedString(string: "View detail post",
                                                       attributes: [
                                                        .font: UIFont.appSemiBoldFont(size: 14),
                                                        .foregroundColor: Color.appTintColor,
                                                        .underlineStyle: NSUnderlineStyle.thick.rawValue,
                                                        .underlineColor: Color.appTintColor
                                                       ])
        viewDetailPostButton.titleLabel?.attributedText = attributedText
        
    }
    
    private func setupInfoView(with cases: Case) {
        startingTimeLabel.text = cases.startingTime ?? "N/A"
        endingTimeLabel.text = cases.endingTime ?? "N/A"
        statusLabel.text = cases.status
        statusLabel.textColor = colorForStatusLabel(with: cases.status ?? "")
    }
    
    private func colorForStatusLabel(with status: String) -> UIColor {
        if status == CaseStatus.inProgress.rawValue {
            return Color.appTintColor
        } else if status == CaseStatus.cancel.rawValue {
            return Color.colorError
        } else if status == CaseStatus.complete.rawValue {
            return Color.green
        }
        return Color.textColor
    }
    
    private func setupClientView(user: ShortUser) {
        // Avatar
        let processor = DownsamplingImageProcessor(size: clientImageView.bounds.size)
        clientImageView.kf.setImage(
            with: URL(string: user.avatar ?? ""),
            placeholder: R.image.placeholderAvatar(),
            options: [
                    .processor(processor),
                    .scaleFactor(UIScreen.main.scale),
                    .transition(.fade(1)),
                    .cacheOriginalImage
            ])
        clientImageView.roundToCircle()
        
        // Name
        let userName = "\(user.firstName ?? "") \(user.lastName ?? "User")"
        clientNameLabel.text = userName
    }
    
    private func setupStatus(with cases: Case) {
        if let attorneyStatus = cases.attorneyStatus {
            attorneyStatusLabel.text = attorneyStatus
            attorneyStatusLabel.textColor = colorForStatusLabel(with: attorneyStatus)
        }
        
        if let status = cases.customerStatus {
            clientStatusLabel.text = status
            clientStatusLabel.textColor = colorForStatusLabel(with: status)
        }
    }
    
    private func setupAttorney(user: ShortUser) {
        // Avatar
        let processor = DownsamplingImageProcessor(size: attorneyImageView.bounds.size)
        attorneyImageView.kf.setImage(
            with: URL(string: user.avatar ?? ""),
            placeholder: R.image.placeholderAvatar(),
            options: [
                    .processor(processor),
                    .scaleFactor(UIScreen.main.scale),
                    .transition(.fade(1)),
                    .cacheOriginalImage
            ])
        attorneyImageView.roundToCircle()
        
        // Name
        let userName = "\(user.firstName ?? "") \(user.lastName ?? "User")"
        attorneyNameLabel.text = userName
    }
    // MARK: - IBActions
    
    @IBAction private func didTapClient(_ sender: Any) {
        delegate?.goToClient()
    }
    
    @IBAction private func didTapAttorney(_ sender: Any) {
      delegate?.goToAttorney()
    }
    
    @IBAction private func didTapPost(_ sender: Any) {
       delegate?.goToPostDetail()
    }
    
    @IBAction private func didTapCompleteButton(_ sender: Any) {
        delegate?.completeCase()
    }
    
    @IBAction private func didTapCancelButton(_ sender: Any) {
        delegate?.cancelCase()
    }
    
    @IBAction private func didTapReview(_ sender: Any) {
        delegate?.reviewCase()
    }
}

//
//  RequestTableViewCell.swift
//  Attorney
//
//  Created by Truong Thinh on 03/12/2022.
//

import UIKit
import Kingfisher

protocol RequestTableViewCellDelegate: AnyObject {
    func acceptRequest(requestId: String?)
    func cancelRequest(requestId: String?)
}

class RequestTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var userImageView: UIImageView!
    @IBOutlet private weak var userNameLabel: UILabel!
    @IBOutlet private weak var activityLabel: UILabel!
    @IBOutlet private weak var contentLabel: UILabel!
    
    var request : Case?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    weak var delegate: RequestTableViewCellDelegate?
    
    override func layoutSubviews() {
        super.layoutSubviews()

        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
    }
    
    func configureCell(with request: Case) {
        self.request = request
        guard let user = request.attorney else { return }
        setupUserView(user: user)
        contentLabel.text = request.post?.content ?? ""
        activityLabel.text = StringConstants.string_wants_to_defend()
    }
    
    private func setupUserView(user: ShortUser) {
        // Avatar
        let processor = DownsamplingImageProcessor(size: userImageView.bounds.size)
        userImageView.kf.setImage(
            with: URL(string: user.avatar ?? ""),
            placeholder: R.image.placeholderAvatar(),
            options: [
                    .processor(processor),
                    .scaleFactor(UIScreen.main.scale),
                    .transition(.fade(1)),
                    .cacheOriginalImage
            ])
        userImageView.roundToCircle()
        
        // Name
        let userName = "\(user.firstName ?? "") \(user.lastName ?? "User")"
        userNameLabel.text = userName
    }

    @IBAction private func didTapAccept(_ sender: Any) {
        guard let request = request else {
            return
        }
        delegate?.acceptRequest(requestId: request._id)
    }
    
    @IBAction private func didTapCancel(_ sender: Any) {
        guard let request = request else {
            return
        }
        delegate?.cancelRequest(requestId: request._id)
    }
    
}

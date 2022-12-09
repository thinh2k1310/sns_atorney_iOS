//
//  CaseDetailViewController.swift
//  Attorney
//
//  Created by Truong Thinh on 03/12/2022.
//

import UIKit
import RxCocoa
import Kingfisher 
final class CaseDetailViewController: ViewController {
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
    @IBOutlet private weak var postImageSuperView: UIView!
    @IBOutlet private weak var postImageView: UIImageView!
    @IBOutlet private weak var postContentLabel: UILabel!
    @IBOutlet private weak var completeButton: UIButton!
    @IBOutlet private weak var cancelButton: UIButton!
    
    // MARK: - Variables
    
    private let whiteBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 1, alpha: 1)
        view.isHidden = false
        return view
    }()
    
    // MARK: - Lifecycle VC
    override func viewDidLoad() {
        super.viewDidLoad()
        configureWhiteBackground()
        self.navigationItem.title = "Detail Case"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let yAxisValue = UIApplication.shared.statusBarFrame.height +
        (self.navigationController?.navigationBar.frame.height ?? 0)
        whiteBackgroundView.frame = CGRect(x: 0, y: yAxisValue,
                                    width: UIScreen.main.bounds.width,
                                    height: UIScreen.main.bounds.height - yAxisValue)
    }
    
    
    // MARK: - Binding, subscribe
    
    override func bindViewModel() {
        super.bindViewModel()
        
        guard let viewModel = viewModel as? CaseDetailViewModel else { return }
        
        viewModel.bodyLoading.asObservable()
            .bind(to: AttorneyTransition.rx.isTinyAnimating)
            .disposed(by: disposeBag)
        
        viewModel.getCaseDetailSuccess
            .subscribe(onNext: { [weak self] caseDetail in
                self?.whiteBackgroundView.isHidden = true
                self?.bindingUI(with: caseDetail)
            }).disposed(by: disposeBag)
    }
    
    // MARK: - Functions
    
    private func bindingUI(with caseDetail: Case) {
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
            } else {
                completeButton.isEnabled = false
                completeButton.alpha = 0.5
                cancelButton.isEnabled = false
                cancelButton.alpha = 0.5
            }
        }
        
    }
    
    private func setupPostView(post: ShortPost) {
        // Image
        if let image = post.mediaUrl {
            let processor = DownsamplingImageProcessor(size: postImageView.bounds.size)
            postImageView.kf.setImage(
                with: URL(string: image),
                placeholder: R.image.mockupImage(),
                options: [
                        .processor(processor),
                        .scaleFactor(UIScreen.main.scale),
                        .transition(.fade(1)),
                        .cacheOriginalImage
                ])
        } else {
            postImageSuperView.isHidden = true
        }
        
        // Content
        postContentLabel.text = post.content ?? ""
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
    
    private func configureWhiteBackground() {
        view.addSubview(whiteBackgroundView)
        whiteBackgroundView.isHidden = false
    }
    // MARK: - IBActions
    
    @IBAction private func didTapCompleteButton(_ sender: Any) {
        guard let viewModel = viewModel as? CaseDetailViewModel else { return }
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .alert)

        let message = StringConstants.string_complete_case()
        let customMessage = NSAttributedString(string: message, attributes: [.font: UIFont.appSemiBoldFont(size: 17), .foregroundColor: Color.textColor])
        alertController.setValue(customMessage, forKey: "attributedMessage")

        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil)
        let okAction = UIAlertAction(title: "Yes", style: UIAlertAction.Style.default) { (_) in
            viewModel.completeCase()
        }

        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction private func didTapCancelButton(_ sender: Any) {
        guard let viewModel = viewModel as? CaseDetailViewModel else { return }
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .alert)

        let message = StringConstants.string_cancel_case()
        let customMessage = NSAttributedString(string: message, attributes: [.font: UIFont.appSemiBoldFont(size: 17), .foregroundColor: Color.colorError])
        alertController.setValue(customMessage, forKey: "attributedMessage")

        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil)
        let okAction = UIAlertAction(title: "Yes", style: UIAlertAction.Style.default) { (_) in
            viewModel.cancelCase()
        }

        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction private func didTapReview(_ sender: Any) {
        guard let viewModel = viewModel as? CaseDetailViewModel else { return }
        
        let reviewVC = R.storyboard.review.reviewViewController()!
        guard let provider = Application.shared.provider else { return }
        let reviewVM = ReviewViewModel(provider: provider)
        reviewVM.caseId = viewModel.caseId
        reviewVC.viewModel = reviewVM
        reviewVC.modalPresentationStyle = .fullScreen
        present(reviewVC, animated: true)
    }
}

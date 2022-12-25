//
//  CaseDetailViewController.swift
//  Attorney
//
//  Created by Truong Thinh on 03/12/2022.
//

import UIKit
import RxCocoa
import Kingfisher
import GrowingTextView

final class CaseDetailViewController: ViewController {
    // MARK: - IBOutlets
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var commentTextView: GrowingTextView!
    @IBOutlet private weak var sendButton: UIButton!
    @IBOutlet private weak var textViewBottomConstraint: NSLayoutConstraint!
    
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
        self.navigationItem.title = "Detail Case"
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        configureTableView()
        self.configureWhiteBackground()
        
        //Gesture
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
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
                self?.tableView.reloadData()
            }).disposed(by: disposeBag)
        
        viewModel.caseCommentsEvent
            .subscribe(onNext: { [weak self] comments in
                guard let self = self else { return }
                self.tableView.reloadData()
            }).disposed(by: disposeBag)
        
        viewModel.reloadComment
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.tableView.scrollToBottom()
            }).disposed(by: disposeBag)
    }
    
    // MARK: - Functions
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let isKeyboardShowing = notification.name == UIResponder.keyboardWillShowNotification
            let tempHeight = keyboardSize.height - 34 - 49 - view.safeAreaInsets.bottom
            let keyboardHeight = isKeyboardShowing ? tempHeight : 0
            layoutTextViewWithKeyboard(notification: notification, keyboardHeight: keyboardHeight, keyboardWillShow: isKeyboardShowing)
            addContentHeightWhenShowKeyboard(isShowKeyboard: isKeyboardShowing, keyboardHeight: CGFloat(keyboardHeight))
        }
    }
    
    func layoutTextViewWithKeyboard(notification: NSNotification,keyboardHeight: CGFloat, keyboardWillShow: Bool) {
        
        // Keyboard's animation duration
        let keyboardDuration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        
        // Keyboard's animation curve
        let keyboardCurve = UIView.AnimationCurve(rawValue: notification.userInfo![UIResponder.keyboardAnimationCurveUserInfoKey] as! Int)!
        
        // Change the constant
        self.textViewBottomConstraint.constant = -keyboardHeight
        
        // Animate the view the same way the keyboard animates
        let animator = UIViewPropertyAnimator(duration: keyboardDuration, curve: keyboardCurve) { [weak self] in
            // Update Constraints
            self?.view.layoutIfNeeded()
        }
        
        // Perform the animation
        animator.startAnimation()
    }
    
    private func addContentHeightWhenShowKeyboard(isShowKeyboard: Bool, keyboardHeight: CGFloat) {
        if isShowKeyboard {
            self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
        } else {
            self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func configureTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        if #available(iOS 13.0, *) {
            tableView.automaticallyAdjustsScrollIndicatorInsets = false
        }
        tableView.registerHeaderFooterNib(CaseDetailHeaderView.self)
        tableView.register(CommentTableViewCell.self)
    }
    
    private func configureWhiteBackground() {
        view.addSubview(whiteBackgroundView)
        whiteBackgroundView.isHidden = false
    }
    // MARK: - IBActions
    
    @IBAction private func postComment(_ sender: Any) {
        guard let viewModel = viewModel as? CaseDetailViewModel,
              let caseId = viewModel.caseId else { return }
        if !commentTextView.text.isEmpty {
            let commentContent = commentTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
            viewModel.commentCase(caseId: caseId, content: commentContent)
            commentTextView.endEditing(true)
            commentTextView.text = ""
        }
    }
}

extension CaseDetailViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let viewModel = viewModel as? CaseDetailViewModel,
              !viewModel.comments.isEmpty else { return 0 }
        return viewModel.comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let viewModel = viewModel as? CaseDetailViewModel,
              !viewModel.comments.isEmpty else { return UITableViewCell() }
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CommentTableViewCell.reuseIdentifier, for: indexPath) as? CommentTableViewCell else { return UITableViewCell() }
        cell.bindingUI(with: viewModel.comments[indexPath.row])
        cell.selectionStyle = .none
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let viewModel = viewModel as? CaseDetailViewModel else { return 0 }
        return viewModel.cellSizeForComment(at: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let viewModel = viewModel as? CaseDetailViewModel, let cases = viewModel.cases else { return UIView() }
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: CaseDetailHeaderView.reuseIdentifier) as? CaseDetailHeaderView else { return UIView() }
        headerView.delegate = self
        headerView.bindingUI(with: cases)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let viewModel = viewModel as? CaseDetailViewModel else { return 0}
        return viewModel.sizeForHeaderView()
    }
    
    
}

extension CaseDetailViewController: CommentTableViewCellDelegate {
    func deleteComment(_ commentId: String?, _ content: String?) {
        guard let viewModel = viewModel as? CaseDetailViewModel,
              let commentId = commentId else {
            return
        }
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        let message = StringConstants.string_delete_comment()
        let customMessage = NSAttributedString(string: message, attributes: [.font: UIFont.appSemiBoldFont(size: 17), .foregroundColor: Color.colorError])
        alertController.setValue(customMessage, forKey: "attributedMessage")

        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil)
        let okAction = UIAlertAction(title: "Yes", style: UIAlertAction.Style.default) { (_) in
            viewModel.deleteComment(commentId: commentId)
        }

        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func viewProfile(_ userId: String?) {
        let profileVC = R.storyboard.profile.profileViewController()!
        guard let provider = Application.shared.provider,
        let id = userId else { return }
        let profileVM = ProfileViewModel(provider: provider)
        profileVM.profileId = id
        profileVC.viewModel = profileVM
        self.navigationController?.pushViewController(profileVC, animated: true)
    }
    
    
}

extension CaseDetailViewController: CaseDetailHeaderViewDelegate {
    func goToClient() {
        guard let viewModel = viewModel as? CaseDetailViewModel else { return }
        let profileVC = R.storyboard.profile.profileViewController()!
        guard let provider = Application.shared.provider,
              let id = viewModel.cases?.customer?._id else { return }
        let profileVM = ProfileViewModel(provider: provider)
        profileVM.profileId = id
        profileVC.viewModel = profileVM
        self.navigationController?.pushViewController(profileVC, animated: true)
    }
    
    func goToAttorney() {
        guard let viewModel = viewModel as? CaseDetailViewModel else { return }
        let profileVC = R.storyboard.profile.profileViewController()!
        guard let provider = Application.shared.provider,
              let id = viewModel.cases?.attorney?._id else { return }
        let profileVM = ProfileViewModel(provider: provider)
        profileVM.profileId = id
        profileVC.viewModel = profileVM
        self.navigationController?.pushViewController(profileVC, animated: true)
    }
    
    func goToPostDetail() {
        guard let viewModel = viewModel as? CaseDetailViewModel else { return }
        let postDetailVC = R.storyboard.detailPost.postDetailViewController()!
        guard let provider = Application.shared.provider else { return }
        let postDetailVM = PostDetailViewModel(provider: provider)
        postDetailVM.postId = viewModel.cases?.post?._id
        postDetailVC.viewModel = postDetailVM
        self.navigationController?.pushViewController(postDetailVC, animated: true)
    }
    
    func completeCase() {
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
    
    func cancelCase() {
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
    
    func reviewCase() {
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

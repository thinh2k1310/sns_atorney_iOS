//
//  PostDetailViewController.swift
//  Attorney
//
//  Created by ThinhTCQ on 11/25/22.
//

import UIKit
import GrowingTextView
import RxCocoa
import RxSwift
import Kingfisher

final class PostDetailViewController: ViewController {
    @IBOutlet private weak var navigationBackControl: UIControl!
    @IBOutlet private weak var repotControl: UIControl!
    @IBOutlet private weak var userImageView: UIImageView!
    @IBOutlet private weak var userNameLabel: UILabel!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var commentTextView: GrowingTextView!
    @IBOutlet private weak var sendButton: UIButton!
    @IBOutlet private weak var textViewBottomConstraint: NSLayoutConstraint!
    
    private let whiteBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 1, alpha: 1)
        view.isHidden = false
        return view
    }()
    
    let refreshControl = UIRefreshControl()

// MARK: - Licycle View
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        configureTableView()
        self.configureWhiteBackground()
        self.configureRefreshControl()
        
        //Gesture
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
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
    
    override func bindViewModel() {
        super.bindViewModel()
        
        guard let viewModel = viewModel as? PostDetailViewModel else {
            return
        }
        
        viewModel.bodyLoading.asObservable()
            .bind(to: AttorneyTransition.rx.isTinyAnimating)
            .disposed(by: disposeBag)

        viewModel.postDetailEvent
            .subscribe(onNext: { [weak self] event in
                guard let self = self else { return }
                self.whiteBackgroundView.isHidden = true
                self.refreshControl.endRefreshing()
                switch event {
                case .successAPI(let post):
                    self.bindingUI(post: post)
                    self.tableView.reloadData()

                case .errorAPI(let message):
                    log.debug(message)
                }
            }).disposed(by: disposeBag)
        
        viewModel.postCommentsEvent
            .subscribe(onNext: { [weak self] comments in
                guard let self = self else { return }
                self.tableView.reloadData()
            }).disposed(by: disposeBag)
        
        viewModel.reloadComment
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.tableView.scrollToBottom()
            }).disposed(by: disposeBag)
        
        viewModel.deletePostSuccess
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.showAlertDeleteSuccess()
            }).disposed(by: disposeBag)
            
    }
// MARK: -  Funcs
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
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func configureTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        if #available(iOS 13.0, *) {
            tableView.automaticallyAdjustsScrollIndicatorInsets = false
        } 
        tableView.registerHeaderFooterNib(PostDetailHeaderView.self)
        tableView.register(CommentTableViewCell.self)
    }
    
    private func configureWhiteBackground() {
        view.addSubview(whiteBackgroundView)
        whiteBackgroundView.isHidden = false
    }
    
    private func bindingUI(post: Post) {
        guard let user = post.user else { return }
        setupUserView(user: user)
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
    
    private func configureRefreshControl() {
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl)
    }
    
    @objc func refresh(_ sender: AnyObject) {
        guard let viewModel = viewModel as? PostDetailViewModel else {
            refreshControl.endRefreshing()
            return
        }
        viewModel.getPostDetail()
        viewModel.getPostComments()
    }
    
    @IBAction private func didTapPostButton(_ sender: Any) {
        guard let viewModel = viewModel as? PostDetailViewModel,
              let postId = viewModel.postId else { return }
        if !commentTextView.text.isEmpty {
            let commentContent = commentTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
            viewModel.commentPost(postId: postId, content: commentContent)
            commentTextView.endEditing(true)
            commentTextView.text = ""
        }
    }
    
    @IBAction private func didTapBackControl(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction private func didTapOptions(_ sender: Any) {
        guard let viewModel = viewModel as? PostDetailViewModel,
              let post = viewModel.post else { return }
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil)
        let editAction = UIAlertAction(title: "Edit", style: UIAlertAction.Style.default) { [weak self] (_) in
            self?.editPost()
        }
        let deleteAction = UIAlertAction(title: "Delete", style: UIAlertAction.Style.destructive) { [weak self] (_) in
            self?.deletePost()
        }
        
        let reportAction = UIAlertAction(title: "Report", style: UIAlertAction.Style.default) { [weak self] (_) in
            self?.reportPost()
        }
        
        alertController.addAction(cancelAction)
        guard let userInfor = UserService.shared.getUserInfor() else {
            present(alertController, animated: true, completion: nil)
            return
        }

        if userInfor.id == post.user?._id {
            alertController.addAction(editAction)
            alertController.addAction(deleteAction)
        } else {
            alertController.addAction(reportAction)
        }
        present(alertController, animated: true, completion: nil)
    }
    
    private func deletePost() {
        guard let viewModel = viewModel as? PostDetailViewModel else {
            return
        }
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        
        let message = "Are you sure want to delete this post? This action cannot be undone."
        let customMessage = NSAttributedString(string: message, attributes: [.font: UIFont.appSemiBoldFont(size: 17), .foregroundColor: Color.colorError])
        alertController.setValue(customMessage, forKey: "attributedMessage")

        let noAction = UIAlertAction(title: "No", style: UIAlertAction.Style.cancel, handler: nil)
        let yesAction = UIAlertAction(title: "Yes", style: UIAlertAction.Style.destructive) { (_) in
            viewModel.deletePost()
        }

        alertController.addAction(noAction)
        alertController.addAction(yesAction)
        present(alertController, animated: true, completion: nil)
    }
    
    private func editPost() {
        let editPostVC = R.storyboard.editPost.editPostViewController()!
        editPostVC.modalPresentationStyle = .fullScreen
        guard let provider = Application.shared.provider, let viewModel = viewModel as? PostDetailViewModel else { return }
        guard let postContent = viewModel.post?.content else { return }
        let editPostVM = EditPostViewModel(provider: provider)
        editPostVM.postId = viewModel.postId
        editPostVM.content = postContent
        editPostVM.editPostSuccess.subscribe(onNext: {
            viewModel.getPostDetail()
        }).disposed(by: disposeBag)
        editPostVC.viewModel = editPostVM
        self.present(editPostVC, animated: true)
    }
    
    private func reportPost() {
        let reportVC = R.storyboard.report.reportViewController()!
        guard let provider = Application.shared.provider, let viewModel = viewModel as? PostDetailViewModel else { return }
        let reportVM = ReportViewModel(provider: provider)
        reportVM.showAlertEvent
            .subscribe(onNext: { [weak self] in
                self?.showAlertReportSuccess()
            }).disposed(by: disposeBag)
        
        reportVM.reportedUser = viewModel.post?.user?._id
        reportVM.post = viewModel.postId
        guard let userInfor = UserService.shared.getUserInfor() else { return }
        reportVM.reportingUser = userInfor.id
        reportVM.type = .Post
        reportVC.viewModel = reportVM
        self.present(reportVC, animated: true)
    }
    
    private func showAlertReportSuccess() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        
        let title = "Thanks for letting us know."
        let customTitle = NSAttributedString(string: title, attributes: [.font: UIFont.appBoldFont(size: 17), .foregroundColor: UIColor.black])
        let message = "We'll use this information to improve out process. \n We may also use it to help us find and remove inapprotiate content."
        let customMessage = NSAttributedString(string: message, attributes: [.font: UIFont.appFont(size: 15), .foregroundColor: Color.textColor])
        alertController.setValue(customMessage, forKey: "attributedMessage")
        alertController.setValue(customTitle, forKey: "attributedTitle")

        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: { (_) in
            alertController.dismiss(animated: true)
        })

        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    private func addContentHeightWhenShowKeyboard(isShowKeyboard: Bool, keyboardHeight: CGFloat) {
        if isShowKeyboard {
            self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
        } else {
            self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
    }
}

// MARK: - TableView
extension PostDetailViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let viewModel = viewModel as? PostDetailViewModel,
              !viewModel.comments.isEmpty else { return 0 }
        return viewModel.comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let viewModel = viewModel as? PostDetailViewModel,
              !viewModel.comments.isEmpty else { return UITableViewCell() }
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CommentTableViewCell.reuseIdentifier, for: indexPath) as? CommentTableViewCell else { return UITableViewCell() }
        cell.configureCell(with: viewModel.comments[indexPath.row])
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let viewModel = viewModel as? PostDetailViewModel else { return 0 }
        return viewModel.cellSizeForComment(at: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let viewModel = viewModel as? PostDetailViewModel, let post = viewModel.post else { return UIView() }
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: PostDetailHeaderView.reuseIdentifier) as? PostDetailHeaderView else { return UIView() }
        headerView.delegate = self
        headerView.configureHeaderView(post: post)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let viewModel = viewModel as? PostDetailViewModel else { return 0}
        return viewModel.sizeForHeaderView()
    }
}

// MARK: - PostDetailHeaderViewDelegate
extension PostDetailViewController: PostDetailHeaderViewDelegate {
    func commetPost(_ post: Post?) {
        commentTextView.becomeFirstResponder()
    }
    
    func likePost(_ post: Post?, user: String?) {
        guard let viewModel = viewModel as? PostDetailViewModel else {
            return
        }
        if let post = post, let postId = post._id {
            viewModel.likePost(postId: postId)
        }
    }
    
    func requestPost(_ post: Post?, user: String?) {
        guard let viewModel = viewModel as? PostDetailViewModel else {
            return
        }
        
        if let post = post, let postId = post._id, let customerId = post.user?._id {
            viewModel.sendDefenceRequest(postId: postId, customerId: customerId)
        }
    }
    
}

// MARK: - Comment Table View Cell Delegate
extension PostDetailViewController: CommentTableViewCellDelegate {
    func viewProfile(_ userId: String?) {
        let profileVC = R.storyboard.profile.profileViewController()!
        guard let provider = Application.shared.provider,
        let id = userId else { return }
        let profileVM = ProfileViewModel(provider: provider)
        profileVM.profileId = id
        profileVC.viewModel = profileVM
        self.navigationController?.pushViewController(profileVC, animated: true)
    }
    
    func deleteComment(_ commentId: String?, _ content: String?) {
        guard let _ = viewModel as? PostDetailViewModel,
              let commentId = commentId,
              let content = content else {
            return
        }
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil)
        let deleteAction = UIAlertAction(title: "Delete", style: UIAlertAction.Style.destructive) { [weak self] (_) in
            self?.selectDelete(commentId)
        }

        let editAction = UIAlertAction(title: "Edit", style: UIAlertAction.Style.default) { [weak self] (_) in
            self?.editComment(commentId: commentId, content: content)
        }

        alertController.addAction(cancelAction)
        alertController.addAction(editAction)
        alertController.addAction(deleteAction)
        present(alertController, animated: true, completion: nil)
        
    }
    
    private func editComment(commentId: String, content: String) {
        let editCmtVC = R.storyboard.editComment.editCommentViewController()!
        editCmtVC.modalTransitionStyle = .crossDissolve
        guard let provider = Application.shared.provider, let viewModel = viewModel as? PostDetailViewModel else { return }
        let editCmtVM = EditCommentViewModel(provider: provider)
        editCmtVM.commentId = commentId
        editCmtVM.content = content
        editCmtVM.editCommentSuccess.subscribe(onNext: {
            viewModel.getPostComments()
        }).disposed(by: disposeBag)
        editCmtVC.viewModel = editCmtVM
        self.navigationController?.present(editCmtVC, animated: true)
    }
    
    private func selectDelete(_ commentId: String?) {
        guard let viewModel = viewModel as? PostDetailViewModel,
              let commentId = commentId else {
            return
        }
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        
        let message = StringConstants.string_delete_comment()
        let customMessage = NSAttributedString(string: message, attributes: [.font: UIFont.appSemiBoldFont(size: 17), .foregroundColor: Color.colorError])
        alertController.setValue(customMessage, forKey: "attributedMessage")

        let noAction = UIAlertAction(title: "No", style: UIAlertAction.Style.cancel, handler: nil)
        let yesAction = UIAlertAction(title: "Yes", style: UIAlertAction.Style.destructive) { (_) in
            viewModel.deleteComment(commentId: commentId)
        }

        alertController.addAction(noAction)
        alertController.addAction(yesAction)
        present(alertController, animated: true, completion: nil)
        
    }
    
    private func showAlertDeleteSuccess() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .alert)

        let message = "Delete post successfully!"
        let customMessage = NSAttributedString(string: message, attributes: [.font: UIFont.appSemiBoldFont(size: 17), .foregroundColor: Color.textColor])
        alertController.setValue(customMessage, forKey: "attributedMessage")

        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: { [weak self] (_) in
            self?.navigationController?.popViewController(animated: true)
        })

        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            alertController.dismiss(animated: true, completion: nil)
            self?.navigationController?.popViewController(animated: true)
        }
    }
}

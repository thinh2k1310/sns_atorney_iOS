//
//  EditCommentViewController.swift
//  Attorney
//
//  Created by ThinhTCQ on 12/25/22.
//

import UIKit

final class EditCommentViewController: ViewController {
    
    @IBOutlet private weak var textView: UITextView!
    @IBOutlet private weak var saveButton: UIButton!
    @IBOutlet private weak var textViewBottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        textView.delegate = self
        saveButton.activate()
        textViewBottomConstraint.constant = CGFloat(336.0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let viewModel = viewModel as? EditCommentViewModel else { return }
        textView.text = viewModel.content
        self.textView.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func bindViewModel() {
        super.bindViewModel()
        
        guard let viewModel = viewModel as? EditCommentViewModel else { return }
        
        viewModel.bodyLoading.asObservable()
            .bind(to: AttorneyTransition.rx.isTinyAnimating)
            .disposed(by: disposeBag)
        
        viewModel.editCommentSuccess
            .subscribe(onNext: { [weak self] in
                self?.dismiss(animated: false)
            }).disposed(by: disposeBag)
    }
    
    @IBAction private func didTapSave(_ sender: Any ) {
        guard let viewModel = viewModel as? EditCommentViewModel else { return }
        
        viewModel.content = textView.text
        viewModel.editComment()
    }
    
    @IBAction private func didTapCancel(_ sender: Any ) {
        self.dismiss(animated: true)
    }
}

// MARK: - TextViewDelegate

extension EditCommentViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let text = textView.text.trim()
        if text.isEmpty {
            saveButton.deactivate()
        } else {
            UIView.transition(with: saveButton, duration: 0.4, options: .transitionCrossDissolve, animations: {
                self.saveButton.activate()
            })
        }
    }
}

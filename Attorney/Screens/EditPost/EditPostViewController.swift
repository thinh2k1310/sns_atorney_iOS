//
//  EditPostViewController.swift
//  Attorney
//
//  Created by ThinhTCQ on 12/26/22.
//

import UIKit

final class EditPostViewController: ViewController {
    @IBOutlet private weak var textView: UITextView!
    @IBOutlet private weak var saveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addGestures()
        saveButton.activate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let viewModel = viewModel as? EditPostViewModel else { return }
        textView.text = viewModel.content
        textView.becomeFirstResponder()
        
    }
    
    override func bindViewModel() {
        super.bindViewModel()
        
        guard let viewModel = viewModel as? EditPostViewModel else { return }
        viewModel.bodyLoading.asObservable()
            .bind(to: AttorneyTransition.rx.isTinyAnimating)
            .disposed(by: disposeBag)
        
        viewModel.editPostSuccess
            .subscribe(onNext: { [weak self] in
                self?.dismiss(animated: true)
            }).disposed(by: disposeBag)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func addGestures() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @IBAction private func didTapSave(_ sender: Any) {
        guard let viewModel = viewModel as? EditPostViewModel else { return }
        viewModel.content = textView.text
        viewModel.editPost()
    }
    
    @IBAction private func didTapBackControl(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
}

extension EditPostViewController: UITextViewDelegate {
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

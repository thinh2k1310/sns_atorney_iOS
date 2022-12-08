//
//  ReviewViewController.swift
//  Attorney
//
//  Created by ThinhTCQ on 12/8/22.
//

import UIKit
import RxSwift

final class ReviewViewController: ViewController {
    
    @IBOutlet private weak var textView: UITextView!
    @IBOutlet private weak var postButton: UIButton!
    @IBOutlet private weak var oneButton: UIButton!
    @IBOutlet private weak var twoButton: UIButton!
    @IBOutlet private weak var threeButton: UIButton!
    @IBOutlet private weak var fourButton: UIButton!
    @IBOutlet private weak var fiveButton: UIButton!
    private var rating: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addGestures()
        textView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        postButton.deactivate()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true , animated: animated)
    }
    
    override func bindViewModel() {
        super.bindViewModel()
    }
    
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func setupRating(rating: Int) {
        oneButton.isSelected = false
        twoButton.isSelected = false
        threeButton.isSelected = false
        fourButton.isSelected = false
        fiveButton.isSelected = false
        if rating == 1 {
            oneButton.isSelected = true
        } else if rating == 2 {
            oneButton.isSelected = true
            twoButton.isSelected = true
        } else if rating == 3 {
            oneButton.isSelected = true
            twoButton.isSelected = true
            threeButton.isSelected = true
        } else if rating == 4 {
            oneButton.isSelected = true
            twoButton.isSelected = true
            threeButton.isSelected = true
            fourButton.isSelected = true
        } else if rating == 5 {
            oneButton.isSelected = true
            twoButton.isSelected = true
            threeButton.isSelected = true
            fourButton.isSelected = true
            fiveButton.isSelected = true
        }
    }
    
    private func addGestures() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @IBAction private func didTapRating(_ sender: UIButton) {
        rating = sender.tag
        setupRating(rating: rating)
    }
    
    @IBAction private func didTapPostButton(_ sender: UIButton) {
        guard let viewModel = viewModel as? ReviewViewModel else { return }
        
        if let content = textView.text {
            viewModel.postReview(rating: self.rating, content: content)
        }
    }
    
    @IBAction private func didTapBackControl(_ sender: UIButton) {
        guard let viewModel = viewModel as? ReviewViewModel else { return }
        
        self.dismiss(animated: true)
    }
    
}

// MARK: - TextViewDelegate

extension ReviewViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let text = textView.text.trim()
        if text.isEmpty {
            postButton.deactivate()
        } else {
            UIView.transition(with: postButton, duration: 0.4, options: .transitionCrossDissolve, animations: {
                self.postButton.activate()
            })
        }
    }
}

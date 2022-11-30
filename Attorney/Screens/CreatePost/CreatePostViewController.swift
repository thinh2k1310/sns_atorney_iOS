//
//  CreatePostViewController.swift
//  Attorney
//
//  Created by Truong Thinh on 01/12/2022.
//

import UIKit
import GrowingTextView

final class CreatePostViewController: ViewController {
// MARK: - IBOutlets
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var imageSuperView: UIView!
    @IBOutlet private weak var textView: GrowingTextView!
    
    
    
    
// MARK: - Variables
    
    

// MARK: - Licycle View
    override func viewDidLoad() {
        super.viewDidLoad()
        imageSuperView.isHidden = true
        
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
    }
// MARK: - Functions
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }



// MARK: - IBActions

    @IBAction private func didTapBackControl(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}

//
//  LoginViewController.swift
//  Attorney
//
//  Created by Truong Thinh on 01/10/2022.
//

import UIKit

final class LoginViewController: ViewController{
    // MARK: - Section 1 IBOutlet
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet private weak var forgotPasswordControl: UIControl!
    @IBOutlet private weak var showPasswordButton: UIButton!
    @IBOutlet private weak var logInButton: UIButton!
    @IBOutlet private weak var signUpControl: UIControl!
    @IBOutlet private weak var signUpLabel: UILabel!
    
    // MARK: - Section 2 - Private variable
    private var errorMessageString: String?
    private var isCheckBoxChecked: Bool = false {
        didSet {
            loginButtonShouldEnable()
        }
    }
    
    // MARK: - Section 3 - Licycle View Controller
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTextField()
        setUpLoginButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        loginButtonShouldEnable()
    }
    
    // MARK: - Section 4 - Binding, subcribe
    
    // MARK: - Section 5 - IBActions
    @IBAction private func showPasswordButtonAction(_ sender: Any) {
        self.passwordTextField.isSecureTextEntry.toggle()
        self.showPasswordButton.isSelected.toggle()
    }
    
    @IBAction private func loginByUsernameAndPassword(_ sender: UIButton) {
        self.view.endEditing(true)
        let usernameKey = UserKey.kRemindUserName + (emailTextField.text ?? "")
        let userLogin = UserService.shared.getInfoNameKey(nameKey: usernameKey)
        
        if userLogin != nil {
//            self.loginCallAPI()
        } else {
//            showPopView()
        }
    }

    @IBAction private func usernameChanged(_ sender: Any) {
        hideErrorMessageView(true)
        errorMessageString = nil
        loginButtonShouldEnable()
    }
    
    @IBAction private func passwordChanged(_ sender: Any) {
        hideErrorMessageView(true)
        errorMessageString = nil
        loginButtonShouldEnable()
    }

// MARK: - Section 6 - Private functions
    
    private func setupTextField() {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: R.font.proximaNovaRegular(size: 14)!,
            .foregroundColor: R.color.354052()!
        ]

        self.emailTextField.maxLength = 50
        self.emailTextField.keyboardType = .emailAddress
        self.emailTextField.attributedPlaceholder = NSAttributedString(string: R.string.localizable.string_username(preferredLanguages: Configurations.App.preferredLanguages),
                                                                       attributes: attributes)
        emailTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)

        self.passwordTextField.attributedPlaceholder = NSAttributedString(string: R.string.localizable.string_password(preferredLanguages: Configurations.App.preferredLanguages),
                                                                          attributes: attributes)
    }

    @objc private func textFieldDidChange(_ textField: UITextField) {
        isCheckBoxChecked = false
    }
    
    private func setUpLoginButton() {
        
    }
    
    private func setupSignUpLabel() {
         
    }
    
    private func loginButtonShouldEnable() {
        guard let username = emailTextField.text?.trim(), !username.isEmpty,
              let password = passwordTextField.text?.trim(), !password.isEmpty,
              password.isValidLoginPassword(),
              isCheckBoxChecked else {
                loginButton.deactivate()
                return
        }
        UIView.transition(with: loginButton, duration: 0.4, options: .transitionCrossDissolve, animations: {
            self.loginButton.activate()
        })
    }

    private func hideErrorMessageView(_ isHidden: Bool) {
        self.errorMessageView.isHidden = isHidden
        self.errorMessageView.clipsToBounds = true
        self.topLayoutContraintUsernameView.constant = isHidden ? 24.0 : 30.0
    }
}

// MARK: - UITextViewDelegate
extension LoginViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        if URL.absoluteString == "termCondition://" {
            let storyboard = UIStoryboard(name: "Login", bundle: nil)
            let termsAndConditionVC = storyboard.instantiateViewController(withIdentifier: "TermsOfUseViewController") as! TermsOfUseViewController
            termsAndConditionVC.nameFileHTML = "TOU"
            termsAndConditionVC.headerText = "Terms of Use for Kris+"
            termsAndConditionVC.termsOfType = .termsOfUse
            termsAndConditionVC.callback = {termsAndConditionVC.dismiss(animated: true, completion: nil)}
            termsAndConditionVC.modalTransitionStyle = .coverVertical
            self.present(termsAndConditionVC, animated: true, completion: nil)
        } else {
            let safariVC = SFSafariViewController(url: URL)
            present(safariVC, animated: true, completion: nil)
        }
        return false
    }
}

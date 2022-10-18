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
    @IBOutlet private weak var errorMessageView: UIView!
    @IBOutlet private weak var errorTextView: UITextView!
    @IBOutlet private weak var textFieldStackViewTopConstraint: NSLayoutConstraint!
    
    // MARK: - Section 2 - Private variable
    private var errorMessageString: String?

    // MARK: - Section 3 - Licycle View Controller
    override func viewDidLoad() {
        super.viewDidLoad()
        setupContentView()
        setupTextField()
        setupSignUpLabel()
        setupErrorMessageView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        loginButtonShouldEnable()
        if let email = UserService.shared.lastEmail, email.isValidEmail() {
            emailTextField.text = email
        }
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
    
    @IBAction private func didTapRegisterControl(_ sender: UIControl) {
        let registerViewController = R.storyboard.register.registerViewController()!
        navigationController?.pushViewController(registerViewController, animated: true)
    }
    
    @IBAction private func didTapForgotPasswordControl(_ sender: UIControl) {
        let forgotPasswordViewController = R.storyboard.resetPassword.enterEmailViewController()!
        navigationController?.pushViewController(forgotPasswordViewController, animated: true)
    }

// MARK: - Section 6 - Private functions
    
    private func setupErrorMessageView() {
        // Do any additional setup after loading the view.
        errorMessageView.clipsToBounds = true
        errorMessageView.layer.cornerRadius = 16
        errorMessageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        hideErrorMessageView(true)
        textFieldStackViewTopConstraint.constant = 24.0
    }
    
    private func setupTextField() {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: R.font.proximaNovaRegular(size: 14)!,
            .foregroundColor: Color.textColor
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
        
    }
    
    private func setupContentView(){
        contentView.roundCorners(corners: [.topLeft, .topRight], radius: 20)
    }
    
    private func setupSignUpLabel() {
        let centerParagraphStyle = NSMutableParagraphStyle()
        centerParagraphStyle.alignment = .center
        let text = NSMutableAttributedString(string: R.string.localizable.string_dont_have_account(),
                                             attributes: [.foregroundColor: Color.textColor,
                                                                        .font: UIFont.appFont(size: 14),
                                                                        .paragraphStyle: centerParagraphStyle])
        let singupText = NSMutableAttributedString(string: R.string.localizable.string_sign_up(),
                                                          attributes: [.foregroundColor: Color.appTintColor,
                                                                       .font: UIFont.appBoldFont(size: 14),
                                                                       .paragraphStyle: centerParagraphStyle])
        let attributedText = NSMutableAttributedString()
        attributedText.append(text)
        attributedText.append(singupText)
        signUpLabel.attributedText = attributedText
    }
    
    private func loginButtonShouldEnable() {
        guard let username = emailTextField.text?.trim(), !username.isEmpty,
              let password = passwordTextField.text?.trim(), !password.isEmpty,
              password.isValidLoginPassword() else {
                logInButton.deactivate()
                return
        }
        UIView.transition(with: logInButton, duration: 0.4, options: .transitionCrossDissolve, animations: {
            self.logInButton.activate()
        })
    }

    private func hideErrorMessageView(_ isHidden: Bool) {
        self.errorMessageView.isHidden = isHidden
        self.errorMessageView.clipsToBounds = true
    }
}

// MARK: - UITextViewDelegate
extension LoginViewController: UITextViewDelegate {

}

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
    @IBOutlet private weak var passwordView: UIView!
    @IBOutlet private weak var forgotPasswordControl: UIControl!
    @IBOutlet private weak var showPasswordButton: UIButton!
    @IBOutlet private weak var logInButton: UIButton!
    @IBOutlet private weak var signUpControl: UIControl!
    @IBOutlet private weak var signUpLabel: UILabel!
    @IBOutlet private weak var errorMessageView: UIView!
    @IBOutlet private weak var errorTextView: UITextView!
    
    // MARK: - Section 2 - Private variable
    private var errorMessageString: String?

    // MARK: - Section 3 - Licycle View Controller
    override func viewDidLoad() {
        super.viewDidLoad()
        setupContentView()
        setupTextField()
        setupSignUpLabel()
        setupErrorMessageView()
        addGestures()
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
    override func bindViewModel() {
        super.bindViewModel()
        guard let viewModel = viewModel as? LoginViewModel else { return}

        viewModel.bodyLoading.asObservable()
            .bind(to: AttorneyTransition.rx.isTinyAnimating)
            .disposed(by: disposeBag)

        viewModel.events
            .subscribe(onNext: { [weak self] event in
                guard let self = self else { return }
                switch event {
                case .successLogin:
                    if UserService.shared.userInfo?.id?.isEmpty ?? true {
                        self.errorTextView.attributedText = NSAttributedString(string: MessageError.loginError)
                        self.hideErrorMessageView(false)
                        return
                    }
                    self.errorMessageString = nil
                    self.onLoginSuccess()

                case .errorLogin(let errorMessage):
                    self.errorTextView.delegate = self
                    self.errorMessageString = errorMessage
                    self.errorTextView.text = errorMessage
                    self.hideErrorMessageView(false)
                
                case .performLogin(let email, let password):
                    self.callApiLogin(email: email, password: password)
                }
            })
            .disposed(by: disposeBag)
    }
    // MARK: - Section 5 - IBActions
    @IBAction private func showPasswordButtonAction(_ sender: Any) {
        self.passwordTextField.isSecureTextEntry.toggle()
        self.showPasswordButton.isSelected.toggle()
    }
    
    @IBAction private func loginByUsernameAndPassword(_ sender: UIButton) {
        self.view.endEditing(true)
        self.performLogin()
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
        guard let provider = Application.shared.provider else { return }
        let registerViewModel = RegistrationViewModel(provider: provider)
        registerViewController.viewModel = registerViewModel
        navigationController?.pushViewController(registerViewController, animated: true)
    }
    
    @IBAction private func didTapForgotPasswordControl(_ sender: UIControl) {
        let forgotPasswordViewController = R.storyboard.resetPassword.requestOTPViewController()!
        guard let provider = Application.shared.provider else { return }
        let requestOTPViewModel = RequestOTPViewModel(provider: provider)
        forgotPasswordViewController.viewModel = requestOTPViewModel
        navigationController?.pushViewController(forgotPasswordViewController, animated: true)
    }

// MARK: - Section 6 - Private functions
    
    private func performLogin() {
        guard let viewModel = viewModel as? LoginViewModel,
              let email = emailTextField.text, let password = passwordTextField.text else { return }
        viewModel.performLogin(email: email, password: password)
    }
    private func onLoginSuccess(){
        guard let window = AppDelegate.shared()?.window else {
            return
        }
        let appCoordinator = ApplicationCoordinator(window: window)
        appCoordinator.initDashboard()
    }
    private func callApiLogin(email: String, password: String) {
        guard let viewModel = viewModel as? LoginViewModel else { return }
        viewModel.loginUser(email: email,
                            password: password)
    }
    
    private func setupErrorMessageView() {
        // Do any additional setup after loading the view.
        errorMessageView.clipsToBounds = true
        errorMessageView.layer.cornerRadius = 16
        errorMessageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        hideErrorMessageView(true)
        errorTextView.centerVertical()
    }
    
    private func addGestures() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
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
        guard let email = emailTextField.text?.trim(), !email.isEmpty,
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
        self.passwordView.borderColor = isHidden ? Color.normalBorder : Color.warningBorder
        if !isHidden {
            self.passwordTextField.text = ""
        }
    }
}

// MARK: - UITextViewDelegate
extension LoginViewController: UITextViewDelegate {

}

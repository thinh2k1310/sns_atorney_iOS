//
//  ChangePasswordViewController.swift
//  Attorney
//
//  Created by ThinhTCQ on 12/6/22.
//

import UIKit
import RxSwift

final class ChangePasswordViewController: ViewController {
    // MARK: - Section 1 - IBOutlets
    @IBOutlet private weak var passwordView: UIView!
    @IBOutlet private weak var passwordTextField: InputTextField!
    @IBOutlet private weak var confirmPasswordView: UIView!
    @IBOutlet private weak var confirmPasswordTextField: InputTextField!
    @IBOutlet private weak var validationPasswordLabel: UILabel!
    @IBOutlet private weak var validationConfirmPasswordLabel: UILabel!
    @IBOutlet private weak var oldPasswordView: UIView!
    @IBOutlet private weak var oldPasswordTextField: InputTextField!
    @IBOutlet private weak var validationOldPasswordLabel: UILabel!
    @IBOutlet private weak var savePasswordButton: UIButton!
    @IBOutlet private weak var passwordInfoImageView: UIImageView!
    @IBOutlet private weak var showPasswordButton: UIButton!
    @IBOutlet private weak var showConfirmPasswordButton: UIButton!
    @IBOutlet private weak var showOldPasswordButton: UIButton!
    // MARK: - Section 2 - Variables
    
    private weak var hintView: CoachmarkView?
    
    public var oldPassword: String!
    public var password: String!
    public var confirmPassword: String!
    
    let valueOldPassword = PublishSubject<String?>()
    let valuePassword = PublishSubject<String?>()
    let valueConfirmPassword = PublishSubject<String?>()
    
    let validationStatusOldPassword = PublishSubject<StatusField>()
    let validationStatusPassword = PublishSubject<StatusField>()
    let validationStatusConfirmPassword = PublishSubject<StatusField>()
    
    // MARK: - Section 3 - Licycle VC
    override func viewDidLoad() {
        super.viewDidLoad()
        setupContentView()
        setupTextField()
        setupTapGestures()
        bindingEvents()
        validatePassword()
        checkPasswordStatus()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeTooltips()
    }
    
    // MARK: - Section 4 - Binding, subcribe
    
    private func bindingEvents() {
        guard let viewModel = self.viewModel as? ChangePasswordViewModel else { return }
        
        viewModel.bodyLoading.asObservable()
            .bind(to: AttorneyTransition.rx.isTinyAnimating)
            .disposed(by: disposeBag)
        
        viewModel.events
            .subscribe(onNext: { [weak self] event in
                guard let this = self else { return }
                switch event {
                case .changePasswordSuccess:
                    this.showSuccessScreen()
                    
                case .incorrectOldPassword(let errorMessage):
                    this.handleUIErrorResetPassword(errorMsg: errorMessage ?? StringConstants.string_generic_error())
                }
            })
            .disposed(by: disposeBag)
        
        self.oldPasswordTextField.rx.controlEvent([.editingDidEnd, .editingChanged])
            .asObservable()
            .subscribe(onNext: { [weak self] _ in
                guard let this = self else { return }
                this.valueOldPassword
                    .onNext(this.oldPasswordTextField.text)
            })
            .disposed(by: disposeBag)
        
        self.passwordTextField.rx.controlEvent([.editingDidEnd, .editingChanged])
            .asObservable()
            .subscribe(onNext: { [weak self] _ in
                guard let this = self else { return }
                this.valuePassword
                    .onNext(this.passwordTextField.text)
            })
            .disposed(by: disposeBag)
        
        self.confirmPasswordTextField.rx.controlEvent([.editingDidEnd, .editingChanged])
            .asObservable()
            .subscribe(onNext: { [weak self] _ in
                guard let this = self else { return }
                this.valueConfirmPassword
                    .onNext(this.confirmPasswordTextField.text)
            })
            .disposed(by: disposeBag)
    }
    // MARK: - Section 5 - IBAction
    
    @IBAction private func showOldPasswordButtonAction(_ sender: Any) {
        self.oldPasswordTextField.isSecureTextEntry.toggle()
        self.showOldPasswordButton.isSelected.toggle()
    }
    
    @IBAction private func showPasswordButtonAction(_ sender: Any) {
        self.passwordTextField.isSecureTextEntry.toggle()
        self.showPasswordButton.isSelected.toggle()
    }
    
    @IBAction private func showConfirmPasswordButtonAction(_ sender: Any) {
        self.confirmPasswordTextField.isSecureTextEntry.toggle()
        self.showConfirmPasswordButton.isSelected.toggle()
    }
    
    @IBAction private func backButtonDidTap(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction private func changePasswordDidTap(_ sender: Any) {
        guard let viewModel = self.viewModel as? ChangePasswordViewModel else { return }
        viewModel.newPassword = confirmPasswordTextField.text
        viewModel.oldPassword = oldPasswordTextField.text
        viewModel.changePassword()
    }
    
    // MARK: - Section 6 - Private function
    
    private func setupContentView() {
        savePasswordButton.deactivate()
        validationPasswordLabel.isHidden = true
        validationOldPasswordLabel.isHidden = true
        validationConfirmPasswordLabel.isHidden = true
        passwordInfoImageView.isHidden = false
    }
    
    private func setupTextField() {
        passwordTextField.layer.borderColor = UIColor.clear.cgColor
        passwordTextField.backgroundColor = Color.colorBackgroundTextField
        confirmPasswordTextField.layer.borderColor = UIColor.clear.cgColor
        confirmPasswordTextField.backgroundColor = Color.colorBackgroundTextField
        oldPasswordTextField.layer.borderColor = UIColor.clear.cgColor
        oldPasswordTextField.backgroundColor = Color.colorBackgroundTextField
    }
    
    @objc func touchEvent(recognizer: UITapGestureRecognizer) {
        if recognizer.state == .ended {
            removeTooltips()
        }
    }
    
    @objc func onOldTFPasswordClick() {
        removeTooltips()
        // fix keyboard have been hide character
        // start
        if #available(iOS 12, *) {
            // iOS 12 & 13: Not the best solution, but it works.
            oldPasswordTextField.textContentType = .oneTimeCode
        } else {
            // iOS 11: Disables the autofill accessory view.
            // For more information see the explanation below.
            oldPasswordTextField.textContentType = .init(rawValue: "")
        }
        // end
        oldPasswordTextField.becomeFirstResponder()
    }
    
    // TextField Password
    @objc func onTFPasswordClick() {
        removeTooltips()
        // fix keyboard have been hide character
        // start
        if #available(iOS 12, *) {
            // iOS 12 & 13: Not the best solution, but it works.
            passwordTextField.textContentType = .oneTimeCode
        } else {
            // iOS 11: Disables the autofill accessory view.
            // For more information see the explanation below.
            passwordTextField.textContentType = .init(rawValue: "")
        }
        // end
        passwordTextField.becomeFirstResponder()
    }
    // TextField confirm password
    @objc func onTFConfirmPasswordClick() {
        removeTooltips()
        // fix keyboard have been hide character
        // start
        if #available(iOS 12, *) {
            // iOS 12 & 13: Not the best solution, but it works.
            confirmPasswordTextField.textContentType = .oneTimeCode
        } else {
            // iOS 11: Disables the autofill accessory view.
            // For more information see the explanation below.
            confirmPasswordTextField.textContentType = .init(rawValue: "")
        }
        // end
        confirmPasswordTextField.becomeFirstResponder()
    }
    
    @objc func openToolTipPassword(_ sender: UITapGestureRecognizer) {
        self.openToolTipForImage(sender, imageView: self.passwordInfoImageView, type: CoachmarkType.password)
    }
    
    private func setupTapGestures() {
        let oldPassword: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onOldTFPasswordClick))
        let passwordTFTapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTFPasswordClick))
        let cfPasswordTFTapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTFConfirmPasswordClick))
        let tapImagePasswordInfomation: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(openToolTipPassword(_:)))
        
        self.oldPasswordTextField.addGestureRecognizer(oldPassword)
        self.passwordTextField.addGestureRecognizer(passwordTFTapGesture)
        self.confirmPasswordTextField.addGestureRecognizer(cfPasswordTFTapGesture)
        self.passwordInfoImageView.addGestureRecognizer(tapImagePasswordInfomation)
    }
    
    private func handleResetPasswordButtonButton(isEnable: Bool) {
        if isEnable {
            savePasswordButton.activate()
        } else {
            savePasswordButton.deactivate()
        }
    }
    
    private func showSuccessScreen() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .alert)

        let message = StringConstants.string_change_password()
        let customMessage = NSAttributedString(string: message, attributes: [.font: UIFont.appSemiBoldFont(size: 17), .foregroundColor: Color.green])
        alertController.setValue(customMessage, forKey: "attributedMessage")

        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) { [weak self] (_) in
            alertController.dismiss(animated: true)
            self?.navigationController?.popViewController(animated: true)
        }

        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    private func handleUIErrorResetPassword(errorMsg: String) {
        self.oldPasswordTextFieldError()
        self.validationOldPasswordLabel.text = errorMsg
        self.oldPasswordTextField.text = ""
        self.passwordTextField.text = ""
        self.confirmPasswordTextField.text = ""
    }
    
}

// MARK: - Validate password and confirm password
extension ChangePasswordViewController {
    
    func oldPasswordTextFieldError() {
        validationOldPasswordLabel.isHidden = false
        oldPasswordView.borderColor = Color.warningBorder
    }

    func oldPasswordTextFieldNormal() {
        validationOldPasswordLabel.isHidden = true
        oldPasswordView.borderColor = Color.normalBorder
    }
    
    func passwordTextFieldError() {
        validationPasswordLabel.isHidden = false
        passwordView.borderColor = Color.warningBorder
    }

    func passwordTextFieldNormal() {
        validationPasswordLabel.isHidden = true
        passwordView.borderColor = Color.normalBorder
    }
    
    func confirmPasswordTextFieldError() {
        validationConfirmPasswordLabel.isHidden = false
        confirmPasswordView.borderColor = Color.warningBorder
    }

    func confirmPasswordTextFieldNormal() {
        validationConfirmPasswordLabel.isHidden = true
        confirmPasswordView.borderColor = Color.normalBorder
    }
    
    private func handleDisplayOldPassword(status: StatusField) {
        if status == .invalid {
            self.oldPasswordTextFieldError()
            let textError = self.getStringErrorPassWord(password: passwordTextField.text ?? "")
            validationOldPasswordLabel.text = textError
        } else {
            self.oldPasswordTextFieldNormal()
        }
    }
    
    private func handleDisplayPassword(status: StatusField) {
        if status == .invalid {
            self.passwordTextFieldError()
            let textError = self.getStringErrorPassWord(password: passwordTextField.text ?? "")
            validationPasswordLabel.text = textError
        } else {
            self.passwordTextFieldNormal()
        }
    }
    
    private func handleDisplayConfirmPassword(status: StatusField) {
        if status == .invalid {
            self.confirmPasswordTextFieldError()
            self.validationConfirmPasswordLabel.text = StringConstants.string_password_does_not_match()
        } else {
            self.confirmPasswordTextFieldNormal()
        }
    }
    
    private func validatePassword() {
        self.valueOldPassword
            .subscribe(onNext: { [weak self] password in
                guard let this = self else { return }
                this.oldPassword = password
                let validation = this.executeValidationOldPassword()
                this.validationStatusOldPassword.onNext(validation ? .valid : .invalid)
            })
            .disposed(by: disposeBag)
        
        self.valuePassword
            .subscribe(onNext: { [weak self] password in
                guard let this = self else { return }
                this.password = password
                let validation = this.executeValidationPassword()
                this.validationStatusPassword.onNext(validation ? .valid : .invalid)
            })
            .disposed(by: disposeBag)
        
        self.valueConfirmPassword
            .subscribe(onNext: { [weak self] confirmPassword in
                guard let this = self else { return }
                this.confirmPassword = confirmPassword
                let validation = this.executeValidationConfirmPassword()
                this.validationStatusConfirmPassword.onNext(validation ? .valid : .invalid)
            })
            .disposed(by: disposeBag)
        
        Observable.merge(validationStatusConfirmPassword,
                         validationStatusPassword, validationStatusOldPassword)
            .subscribe(onNext: { [weak self] _ in
                guard let this = self else { return }
                let valid = this.executeValidationConfirmPassword() &&
                this.executeValidationPassword() && this.executeValidationOldPassword()
                
                this.handleResetPasswordButtonButton(isEnable: valid)
            })
            .disposed(by: disposeBag)
    }
    
    private func checkPasswordStatus() {
        // Password
        self.validationStatusOldPassword
            .subscribe(onNext: { [weak self] status in
                guard let this = self else { return }
                this.handleDisplayOldPassword(status: status)
            })
            .disposed(by: disposeBag)
        
        // Password
        self.validationStatusPassword
            .subscribe(onNext: { [weak self] status in
                guard let this = self else { return }
                this.handleDisplayPassword(status: status)
            })
            .disposed(by: disposeBag)
        
        // Confirm password
        self.validationStatusConfirmPassword
            .subscribe(onNext: { [weak self] status in
                guard let this = self else { return }
                this.handleDisplayConfirmPassword(status: status)
            })
            .disposed(by: disposeBag)
    }
    
    private func executeValidationOldPassword() -> Bool {
        guard oldPassword != nil, !oldPassword.isEmpty, oldPassword.isValidPassword() else {
            return false
        }
        return true
    }
    
    private func executeValidationPassword() -> Bool {
        guard password != nil, !password.isEmpty, password.isValidPassword() else {
            return false
        }
        return true
    }

    private func executeValidationConfirmPassword() -> Bool {
        guard self.confirmPassword != nil, confirmPassword?.lowercased() == password?.lowercased() || (confirmPassword == "" && password == nil) else { return false }
        return true
    }
}

// MARK: - Tool tip
extension ChangePasswordViewController {
    func openToolTipForImage(_ sender: UITapGestureRecognizer, imageView: UIImageView, type: CoachmarkType) {
        self.openToolTip(type: type,
                         sourceView: imageView,
                         sourceRect: CGRect(origin: CGPoint(x: imageView.bounds.midX,
                                                            y: imageView.bounds.midY),
                                            size: .zero))
    }

    func openToolTip(type: CoachmarkType, sourceView: UIView, sourceRect: CGRect) {
        if hintView != nil {
            removeTooltips()
        }
        let hint = CoachmarkView(content: type.contents, preferences: type.preferences)
        let heightNavigationBar: CGFloat = (self.navigationController?.navigationBar.frame.height ?? 0) + UIApplication.shared.statusBarFrame.height
        if let unwrappedTextView = (sourceView as? UITextView)?.convert(sourceRect, to: self.view) {
            hint.show(forView: UIView(frame: unwrappedTextView), heightNavigationBar: heightNavigationBar)
        } else {
            hint.show(forView: sourceView, heightNavigationBar: heightNavigationBar)
        }
        hintView = hint
    }
    
    private func removeTooltips() {
        guard let window: UIWindow = (UIApplication.shared.delegate as? AppDelegate)?.window else { return }
        window.removeTooltip()
    }
}

extension ChangePasswordViewController {
    func getStringErrorPassWord(password: String) -> String {
        let lenghtPasswordText = password.count
        let isContainingNumber = password.isContainingNumber()
        let isContainingLowercase = password.isContainingLowercase()
        let isContainingUppercase = password.isContainingUppercase()
        let isContainingSpecial = password.isContainingSpecial()
        var result = ""
        if lenghtPasswordText < 8 && lenghtPasswordText > 0 {
            result = "Please enter at least 8 characters."
        } else if lenghtPasswordText == 0 {
            result = "Please enter a password."
        } else if !isContainingSpecial {
            result = "Your password cannot contain the special character/symbol that you have selected."
        } else if !isContainingNumber && isContainingLowercase && isContainingUppercase {
            result = "Your password must contain a number (0–9)."
        } else if isContainingNumber && !isContainingLowercase && isContainingUppercase {
            result = "Your password must contain a lowercase character (a–z)."
        } else if isContainingNumber && isContainingLowercase && !isContainingUppercase {
            result = "Your password must contain an uppercase character (A–Z)."
        } else if isContainingNumber && !isContainingLowercase && !isContainingUppercase {
            result = "Your password must contain a lowercase character (a–z) and an uppercase character (A–Z)."
        } else if !isContainingNumber && isContainingLowercase && !isContainingUppercase {
            result = "Your password must contain a number (0–9) and an uppercase character (A–Z)."
        } else if !isContainingNumber && !isContainingLowercase && isContainingUppercase {
            result = "Your password must contain a number (0–9) and a lowercase character (a–z)."
        } else if !isContainingNumber && !isContainingLowercase && !isContainingUppercase {
            result = "Your password must contain a number (0–9), a lowercase character (a–z) and an uppercase character (A–Z)."
        }

        return result
    }
}
// MARK: - UIGestureRecognizerDelegate
extension ChangePasswordViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return true
    }
}

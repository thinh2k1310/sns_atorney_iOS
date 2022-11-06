//
//  RequestOTPViewController.swift
//  Attorney
//
//  Created by ThinhTCQ on 10/18/22.
//

import UIKit
import RxSwift
import RxCocoa

final class RequestOTPViewController: ViewController {
    // MARK: - IBOutlets
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var sendButon: UIButton!
    @IBOutlet private weak var emailTextField: InputTextField!
    @IBOutlet private weak var emailView: UIView!
    @IBOutlet private weak var errorMessageLabel: UILabel!
    
    public private(set) var email: String!
    let valueEmail = PublishSubject<String?>()
    let validationStatusEmail = PublishSubject<StatusField>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupContentView()
        setupTextField()
        bindingEvents()
        validateEmail()
        checkEmailStatus()
        emailTextField.text = "thinh2k@gmail.com"
    }
    
    // MARK: - Bindings
    
    private func bindingEvents() {
        guard let viewModel = self.viewModel as? RequestOTPViewModel else { return }
        
        viewModel.bodyLoading.asObservable()
            .bind(to: AttorneyTransition.rx.isTinyAnimating)
            .disposed(by: disposeBag)
        
        viewModel.eventRequestOTP
            .subscribe(onNext: { [weak self] event in
                guard let this = self else { return }
                switch event {
                case .successRequestOTP:
                    this.showValidateOTPScreen()
                    
                case .errorRequestOTP(let errorMessage):
                    this.textFieldError(errorMessage: errorMessage ?? "")
                }
            })
            .disposed(by: disposeBag)
        
        self.emailTextField.rx.controlEvent([.editingDidEnd, .editingChanged])
            .asObservable()
            .subscribe(onNext: { [weak self] _ in
                guard let this = self else { return }
                this.valueEmail
                    .onNext(this.emailTextField.text)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Private functions
    
    private func setupContentView() {
        contentView.roundCorners(corners: [.topLeft, .topRight], radius: 20)
        sendButon.deactivate()
        errorMessageLabel.isHidden = true
    }
    
    private func setupTextField() {
        emailTextField.layer.borderColor = UIColor.clear.cgColor
        emailTextField.backgroundColor = Color.colorBackgroundTextField
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTFEmailClick))
        self.emailTextField.addGestureRecognizer(tapGesture)
    }
    
    @objc func onTFEmailClick() {
        self.emailTextField.keyboardType = UIKeyboardType.emailAddress
        self.emailTextField.becomeFirstResponder()
    }
    
    private func handleSendOTPButton(isEnable: Bool) {
        if isEnable {
            sendButon.activate()
        } else {
            sendButon.deactivate()
        }
    }
    
    private func showValidateOTPScreen() {
        let verifyOTPViewController = R.storyboard.verifyOTP.verifyOTPViewController()!
        guard let provider = Application.shared.provider else { return }
        let verifyOTPViewModel = VerifyOTPViewModel(provider: provider)
        verifyOTPViewModel.email = emailTextField.text
        verifyOTPViewModel.isUser = true
        verifyOTPViewController.viewModel = verifyOTPViewModel
        self.navigationController?.pushViewController(verifyOTPViewController, animated: true)
    }
    
    
    // MARK: - IBActions
    
    @IBAction private func sendOTPButtonDidTap(_ sender: Any) {
        guard let viewModel = self.viewModel as? RequestOTPViewModel else { return }
        viewModel.email = emailTextField.text
        viewModel.excuteSendOTP()
    }
}


// MARK: - Validate Email
extension RequestOTPViewController {
    
    private func textFieldError(errorMessage: String = StringConstants.string_please_enter_email() ) {
        errorMessageLabel.isHidden = false
        errorMessageLabel.text = errorMessage
        emailView.borderColor = Color.colorError
        
    }

    private func textFieldNormal() {
        errorMessageLabel.isHidden = true
        emailView.borderColor = Color.colorBorderTextField
    }
    
    private func handleDisplayEmail(status: StatusField) {
        if status == .invalid {
            self.textFieldError()
        } else {
            self.textFieldNormal()
        }
    }
    
    private func checkEmailStatus() {
        self.validationStatusEmail
            .subscribe(onNext: { [weak self] status in
                guard let this = self else { return }
                this.handleDisplayEmail(status: status)
                this.handleSendOTPButton(isEnable: status == .valid)
            })
            .disposed(by: disposeBag)
    }
    
    private func validateEmail() {
        self.valueEmail
            .subscribe(onNext: { [weak self] email in
                guard let this = self else { return }
                this.email = email
                let validation = this.executeValidationEmail()
                if this.email != nil {
                    let validation = this.executeValidationEmail()
                    this.validationStatusEmail.onNext(validation ? .valid : .invalid)
                }
                this.validationStatusEmail.onNext(validation ? .valid : .invalid)
            })
            .disposed(by: disposeBag)
    }
    
    private func executeValidationEmail() -> Bool {
        guard email != nil, email.isValidEmailRegister() else { return false }
        return true
    }

    
    
}

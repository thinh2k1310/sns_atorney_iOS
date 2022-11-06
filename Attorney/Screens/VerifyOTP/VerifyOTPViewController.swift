//
//  VerifyOTPViewController.swift
//  Attorney
//
//  Created by ThinhTCQ on 10/18/22.
//

import UIKit

final class VerifyOTPViewController: ViewController {
    // MARK: - Section 1 - IBOutlet
    
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var otpInputView: DigitInputView!
    @IBOutlet private weak var sendButton: UIButton!
    @IBOutlet private weak var errorLabel: UILabel!
    @IBOutlet private weak var resendButton: UIButton!
    @IBOutlet private weak var timeLabel: UILabel!
    @IBOutlet private weak var successView: UIView!
    
    // MARK: - Section 2 - Variables
    var isDeleteMode: Bool = false
    var isVerifyFromServer: Bool = false
    private var emailHasSelected = false
    private var otpTimer: Timer?
    private var counter: TimeInterval? {
        guard let viewModel = viewModel as? VerifyOTPViewModel,
              let timeRequestOTP = viewModel.timeRequestOTP else { return nil }
        return (Date().timeIntervalSince1970 - timeRequestOTP).rounded(.down)
    }
    
    // MARK: - Section 3 - Lifecycle View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureUI()
        self.setupDigitInputView()
        self.startTimer()
        self.bindingEvents()
        
        guard let viewModel = viewModel as? VerifyOTPViewModel else { return }
        viewModel.timeRequestOTP = Date().timeIntervalSince1970
        startTimer()
    }
    
    // MARK: - Section 4 - Binding, subcribe
    private func bindingEvents() {
        guard let viewModel = self.viewModel as? VerifyOTPViewModel else { return }

        viewModel.bodyLoading.asObservable()
            .bind(to: AttorneyTransition.rx.isTinyAnimating)
            .disposed(by: disposeBag)

        viewModel.eventVerifyOTP
            .subscribe(onNext: { [weak self] event in
                guard let this = self else { return }
                switch event {
                case .successSendOTP:
                    this.showSuccesResendOTPView()

                case .errorSendOTP(let errorMessage):
                    this.errorLabel.text = errorMessage

                case .successValidateEmail:
                    guard let isUser = viewModel.isUser else { return }
                    if isUser {
                        this.showResetPasswordScreen()
                    } else {
                        this.showSuccessScreen()
                    }

                case .errorValidateEmail(let errorMessage):
                    this.clearDigitsInputAndErrorLabel(isHideError: false)
                    this.errorLabel.text = errorMessage
                }
            })
            .disposed(by: disposeBag)
    }

    
    // MARK: - Section 5 - IBAction
    @objc func beginEditing(_ sender: UITapGestureRecognizer) {
        _ = otpInputView.becomeFirstResponder()
        log.verbose(otpInputView.text)
    }
    
    @objc func updateCounter() {
        if let counter = self.counter {
            if counter > 30 {
                stopTimer()
                updateResendButtonUI(intervalHidden: true, counter: 30)
            } else {
                updateResendButtonUI(intervalHidden: false, counter: counter)
            }
        }
    }
    
    @IBAction private func sendButtonDidTap(_ sender: UIButton) {
        self.view.endEditing(true)
        guard let viewModel = viewModel as? VerifyOTPViewModel else { return }
        viewModel.excuteValidateEmail(otp: "\(otpInputView.text)")
    }
    
    @IBAction private func resendButtonDidTap(_ sender: UIButton) {
        guard let viewModel = viewModel as? VerifyOTPViewModel else { return }
        clearDigitsInputAndErrorLabel()
        viewModel.excuteSendOTP()
        startTimer()
    }
    
    // MARK: - Section 6 - Private function
    private func updateValidateButtonUI() {
        if otpInputView.text.count == otpInputView.numberOfDigits && errorLabel.isHidden {
            self.sendButton.isUserInteractionEnabled = true
            self.sendButton.activate()
        } else {
            self.sendButton.isUserInteractionEnabled = false
            self.sendButton.deactivate()
        }
    }
    private func updateResendButtonUI(intervalHidden: Bool, counter: Double) {
        self.resendButton.isUserInteractionEnabled = intervalHidden
        self.resendButton.setTitleColor(!intervalHidden ? Color.deactivatedButton : Color.appTintColor, for: .normal)
        self.timeLabel.isHidden = intervalHidden
        self.timeLabel.text = intervalHidden ? nil : String(format: "( %.fs )", 30 - counter)
    }
    private func clearDigitsInputAndErrorLabel(isHideError: Bool = true) {
        self.otpInputView.isCheckColor = isHideError
        self.otpInputView.resetTextField()
        self.otpInputView.layoutSubviews()
        self.errorLabel.isHidden = isHideError

        updateValidateButtonUI()
    }

    private func startTimer() {
        self.stopTimer()
        self.otpTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCounter), userInfo: nil, repeats: true)
    }
    
    private func stopTimer() {
        self.otpTimer?.invalidate()
        self.otpTimer = nil
    }

    private func configureUI() {
        contentView.roundCorners(corners: [.topLeft, .topRight], radius: 20)
        errorLabel.isHidden = true
        timeLabel.isHidden = true
        successView.isHidden = true
        updateValidateButtonUI()
    }
    
    private func setupDigitInputView() {
        otpInputView.numberOfDigits = 6
        otpInputView.textColor = .black
        otpInputView.acceptableCharacters = "0123456789"
        otpInputView.keyboardType = .numberPad
        otpInputView.animationType = .none
        otpInputView.font = UIFont.appFont(size: 14)

        // check ui is valid
        otpInputView.isCheckColor = true

        otpInputView.delegate = self

        let tap = UITapGestureRecognizer(target: self, action: #selector(beginEditing(_:)))
        otpInputView.addGestureRecognizer(tap)
    }
    
    private func showSuccessScreen() {
        let successViewController = R.storyboard.success.successViewController()!
        successViewController.message = StringConstants.string_register_successfully()
        self.navigationController?.pushViewController(successViewController, animated: true)
    }
    
    private func showResetPasswordScreen() {
        let resetPasswordViewController = R.storyboard.resetPassword.resetPasswordViewController()!
        guard let provider = Application.shared.provider, let viewModel = self.viewModel as? VerifyOTPViewModel  else { return }
        let resetPasswordViewModel = ResetPasswordViewModel(provider: provider)
        resetPasswordViewModel.email = viewModel.email
        resetPasswordViewController.viewModel = resetPasswordViewModel
        self.navigationController?.pushViewController(resetPasswordViewController, animated: true)
    }
    
    private func showSuccesResendOTPView() {
        successView.isHidden = false
        UIView.animate(withDuration: 5, delay: 0, options: .curveEaseInOut, animations: { [weak self] in
            self?.successView.alpha = 0
        }) { [weak self] status in
            self?.successView.isHidden = true
        }
    }
}

// MARK: - DigitInputViewDelegate
extension VerifyOTPViewController: DigitInputViewDelegate {
    func digitsDidChange(digitInputView: DigitInputView) {
        if !isVerifyFromServer {
            otpInputView.isCheckColor = true
            errorLabel.isHidden = true
            otpInputView.layoutSubviews()
            sendButton.deactivate()
            sendButton.isUserInteractionEnabled = false
            if otpInputView.text.count == otpInputView.numberOfDigits {
                sendButton.isUserInteractionEnabled = true
                sendButton.activate()
            }
        } else {
            if !isDeleteMode {
                isDeleteMode = true
            }

            errorLabel.isHidden = true
            otpInputView.isCheckColor = false
            otpInputView.layoutSubviews()

            sendButton.deactivate()
        }
    }
}

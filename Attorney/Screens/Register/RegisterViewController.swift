//
//  RegisterViewController.swift
//  Attorney
//
//  Created by Truong Thinh on 01/10/2022.
//

import UIKit
import RxSwift

final class RegisterViewController: ViewController {
    // MARK: - Section 1 - IBOutlet
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var adView: UIView!
    @IBOutlet private weak var firstNameTextField: InputTextField!
    @IBOutlet private weak var lastNameTextField: InputTextField!
    @IBOutlet private weak var emailTextField: InputTextField!
    @IBOutlet private weak var mobileTextField: InputTextField!
    @IBOutlet private weak var addressTextField: InputTextField!
    @IBOutlet private weak var passwordTextField: InputTextField!
    @IBOutlet private weak var confirmPasswordTextField: InputTextField!
    @IBOutlet private weak var dobLabel: UILabel!
    
    @IBOutlet private weak var validationFirstName: UILabel!
    @IBOutlet private weak var validationLastName: UILabel!
    @IBOutlet private weak var validationDob: UITextView!
    @IBOutlet private weak var validationEmail: UILabel!
    @IBOutlet private weak var validationMobileNumber: UILabel!
    @IBOutlet private weak var validationPassword: UILabel!
    @IBOutlet private weak var validationConfirmPassword: UILabel!
    @IBOutlet private weak var birthdayView: UIView!
    
    @IBOutlet private weak var passwordInfoImageView: UIImageView!
    @IBOutlet private weak var dobInfoImageView: UIImageView!
    @IBOutlet private weak var emailInfoImageView: UIImageView!
    
    @IBOutlet private weak var openCalendarButton: UIButton!
    @IBOutlet private weak var showPassword: UIButton!
    @IBOutlet private weak var showConfirmPassword: UIButton!
    
    @IBOutlet private weak var attorneyButton: UIButton!
    @IBOutlet private weak var attorneyCheckboxImageView: UIImageView!
    @IBOutlet private weak var privacyCheckboxButton: UIButton!
    @IBOutlet private weak var privacyCheckboxImageView: UIImageView!
    @IBOutlet private weak var registerButton: UIButton!
    @IBOutlet private weak var validationBirthdayTextViewHeightConstraint: NSLayoutConstraint!
    
    // MARK: - Section 2 - Variables
    var toolBar = UIToolbar()
    var dateOfBirthPicker = UIDatePicker()
    var isOpeningDatePicker: Bool = false
    
    private weak var hintView: CoachmarkView?
    var validationRegistrationForm: ValidationRegistrationForm!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.scrollView.delegate = self
        self.setupTapGestures()
        self.bindingEvent()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false

    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeTooltips()
    }
    
    override func setupUI() {
        super.setupUI()
        adView.applyGradientBG()
        setupButton()
        testData()
    }
    
    private func testData() {
        firstNameTextField.text = "thinh"
        lastNameTextField.text = "thinh"
        emailTextField.text = "thinh2k@gmail.com"
        mobileTextField.text = "0796844698"
        passwordTextField.text = "Thinh@1310"
        confirmPasswordTextField.text = "Thinh@1310"
    }
    
    // MARK: - Section 4 - Binding, subcribe
    override func bindViewModel() {
        super.bindViewModel()
        bindingValidationForm()
    }
    
    private func bindingEvent() {
        guard let viewModel = self.viewModel as? RegistrationViewModel else { return }
        
        viewModel.bodyLoading.asObservable()
            .bind(to: AttorneyTransition.rx.isTinyAnimating)
            .disposed(by: disposeBag)
        
        viewModel.events
            .subscribe(onNext: { [weak self] event in
                guard let strongSelf = self else { return }
                switch event {
                case .registerSuccess( _, let registerBody):
                    strongSelf.showOTPRegisterScreen(email: registerBody.email)
                    break
                        
                case .registerFailure:
                    ErrorViewController.showErrorVC()

                case .errorDuplicateEmail:
                    strongSelf.validationRegistrationForm.isUniqueEmail = false
                    strongSelf.validationRegistrationForm
                        .validationStatusEmail.onNext(.isDuplicateEmail)
                }
                })
                .disposed(by: disposeBag)
        
        viewModel.dateToFocus
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] value in
                guard let this = self,
                      let value = value else { return }
                this.dobLabel.text = value
                this.dateOfBirthPicker.date = value.toDate(format: Configurations.Format.dateOfBirth) ?? Date()
            }).disposed(by: disposeBag)
    }
    
    // MARK: - Section 5 - IBAction
    
    @objc func touchEvent(recognizer: UITapGestureRecognizer) {
        if recognizer.state == .ended {
            self.hideKeyBoardAndDatePicker()
            removeTooltips()
        }
    }
    // TextField FirstName
    @objc func onTFFirstNameClick() {
        self.closeDatePickerAndDropdown()
        firstNameTextField.becomeFirstResponder()
    }

    // TextField LastName
    @objc func onTFLastNameClick() {
        self.closeDatePickerAndDropdown()
        lastNameTextField.becomeFirstResponder()
    }

    // TextField Email
    @objc func onTFEmailClick() {
        self.closeDatePickerAndDropdown()
        self.emailTextField.keyboardType = UIKeyboardType.emailAddress
        self.emailTextField.becomeFirstResponder()
    }

    // TextField NumberPhone
    @objc func onTFNumberPhoneClick() {
        self.closeDatePickerAndDropdown()
        self.mobileTextField.keyboardType = UIKeyboardType.numberPad
        mobileTextField.becomeFirstResponder()
    }

    // TextField Password
    @objc func onTFPasswordClick() {
        self.closeDatePickerAndDropdown()
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
    
    // hideKeyBoardAndDatePicker
    @objc func hideKeyBoardAndDatePicker() {
        self.isOpeningDatePicker = false
        view.endEditing(true)
        resetDateOfBirthPicker()
        toolBar.removeFromSuperview()
        dateOfBirthPicker.removeFromSuperview()
    }

    @objc func openToolTipPassword(_ sender: UITapGestureRecognizer) {
        self.openToolTipForImage(sender, imageView: self.passwordInfoImageView, type: CoachmarkType.password)
    }

    @objc func openToolTipDateOfBirth(_ sender: UITapGestureRecognizer) {
        self.openToolTipForImage(sender, imageView: self.dobInfoImageView, type: CoachmarkType.dateOfBirth)
    }

    @objc func openToolTipEmail(_ sender: UITapGestureRecognizer) {
        self.openToolTipForImage(sender, imageView: self.emailInfoImageView, type: CoachmarkType.email)
    }
    
    @IBAction private func didTapShowPassword(_ sender: UIButton) {
        self.passwordTextField.isSecureTextEntry = !self.passwordTextField.isSecureTextEntry
        self.showPassword.isSelected = !self.showPassword.isSelected
    }
    
    @IBAction private func didTapShowConfirmPassword(_ sender: UIButton) {
        self.confirmPasswordTextField.isSecureTextEntry = !self.confirmPasswordTextField.isSecureTextEntry
        self.showConfirmPassword.isSelected = !self.showConfirmPassword.isSelected
    }
    
    @IBAction private func didTapOpenCalendar(_ sender : UIButton) {
        guard let viewModel = self.viewModel as? RegistrationViewModel else { return }
        view.endEditing(true)
        if !isOpeningDatePicker {
            self.isOpeningDatePicker = true
            // set text date of birth current
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = TimeZone.current
            dateFormatter.calendar = Calendar(identifier: .gregorian)
            let date = Date()
            dateFormatter.dateFormat = Configurations.Format.dateOfBirth

            // show screen past current is 16 years
            let calendar = Calendar(identifier: .gregorian)
            var components = DateComponents()
            components.calendar = calendar
            components.year = -16
            let selectDate = calendar.date(byAdding: components, to: date)!
            if dobLabel.text == "DD/MM/YYYY" {
                viewModel.dateToFocus.accept(selectDate.toStringLocalTime(format: Configurations.Format.dateOfBirth))
            } else {
                viewModel.dateToFocus.accept(self.dobLabel.text!)
            }

            // limited min select datePicker past 100 years
            dateFormatter.dateFormat = "yyyy"
            let year = dateFormatter.string(from: Date())
            let dateCurrent = year.convertStringToDate(fortmat: "yyyy")
            components.year = -100
            let pastDate = calendar.date(byAdding: components, to: dateCurrent)

            // setting datePicker view in screen
            dateOfBirthPicker.backgroundColor = UIColor.white
            dateOfBirthPicker.autoresizingMask = .flexibleWidth
            if #available(iOS 13.4, *) {
                dateOfBirthPicker.preferredDatePickerStyle = .wheels
                dateOfBirthPicker.backgroundColor = UIColor.white
            }
            dateOfBirthPicker.datePickerMode = .date
            dateOfBirthPicker.maximumDate = date
            dateOfBirthPicker.minimumDate = pastDate
            dateOfBirthPicker.frame = CGRect(x: 0.0,
                                             y: UIScreen.main.bounds.size.height - 300,
                                             width: UIScreen.main.bounds.size.width,
                                             height: 300)

            // When scoll viewDatePicker hide by topView
            if self.scrollView.contentOffset.y > 550 {
                UIView.animate(withDuration: 0.5, animations: {
                    self.scrollView.contentOffset = CGPoint(x: 0, y: 520)
                })
            }

            // caculator number postion can scroll need to don't hide viewDatePicker
            var position: CGFloat = 0.0
            
            position = abs(self.dateOfBirthPicker.frame.origin.y - self.birthdayView.frame.origin.y)
            

            // When dont scroll but datePicker hide viewDatePicker
            if self.scrollView.contentOffset.y == 0 && self.birthdayView.frame.origin.y + 140 > self.dateOfBirthPicker.frame.origin.y {
                UIView.animate(withDuration: 0.5, animations: {
                    self.scrollView.contentOffset = CGPoint(x: 0, y: position + 140)
                })
            }

            // When scroll but datePicker hide viewDatePicker
            if self.scrollView.contentOffset.y <= position + 140 {
                UIView.animate(withDuration: 0.5, animations: {
                    self.scrollView.contentOffset.y = position + 140
                })
            }

            self.view.addSubview(dateOfBirthPicker)

            // Create tool bar
            toolBar = UIToolbar(frame: CGRect(x: 0,
                                              y: UIScreen.main.bounds.size.height - 300,
                                              width: UIScreen.main.bounds.size.width,
                                              height: 50))
            toolBar.barStyle = .default
            toolBar.items = [UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                             target: nil,
                                             action: nil),
                             UIBarButtonItem(title: "Done",
                                             style: .done,
                                             target: self,
                                             action: #selector(self.hideKeyBoardAndDatePicker))]
            toolBar.sizeToFit()
            self.view.addSubview(toolBar)
        }
    }
    
    @IBAction private func didTapPrivacyCheckbox(_ sender: UIButton) {
        self.privacyCheckboxButton.isSelected = !self.privacyCheckboxButton.isSelected
        self.privacyCheckboxImageView.image = self.privacyCheckboxButton.isSelected ? R.image.checkBox() : R.image.uncheckBox()
        validateTaCAndPrivacyStatus(status: self.privacyCheckboxButton.isSelected)
    }
    
    @IBAction private func didTapAttorneyCheckbox(_ sender: UIButton) {
        guard let viewModel = self.viewModel as? RegistrationViewModel else { return }
        self.attorneyButton.isSelected.toggle()
        self.attorneyCheckboxImageView.image = self.attorneyButton.isSelected ? R.image.checkBox() : R.image.uncheckBox()
        viewModel.isAttorney =  self.attorneyButton.isSelected
        self.validationRegistrationForm.valueIsAttorney.onNext(self.attorneyButton.isSelected)
    }
    
    @IBAction private func didTapRegister(_ sender: UIButton) {
        guard let viewModel = self.viewModel as? RegistrationViewModel else { return }
        viewModel.handleRegister(with: self.validationRegistrationForm)
    }
    
    // MARK: - Section 6 - Private function
    func textFieldError(label: UILabel, textField: InputTextField) {
        label.isHidden = false
        textField.status = "error"
    }

    func textFieldNormal(label: UILabel, textField: InputTextField) {
        label.isHidden = true
        textField.status = "normal"
    }
    
    private func setupButton() {
        self.privacyCheckboxButton.isSelected = false
        self.attorneyButton.isSelected = false
        self.registerButton.deactivate()
    }
    
    private func showOTPRegisterScreen(email: String) {
        guard let provider = Application.shared.provider,
              let otpVc = R.storyboard.verifyOTP.verifyOTPViewController() else { return }
        let viewModel = VerifyOTPViewModel(provider: provider)
        viewModel.email = email
        viewModel.isUser = false
        otpVc.viewModel = viewModel
        self.navigationController?.pushViewController(otpVc, animated: true)
    }
    
    private func removeTooltips() {
        guard let window: UIWindow = (UIApplication.shared.delegate as? AppDelegate)?.window else { return }
        window.removeTooltip()
    }
    
    private func setupTapGestures() {
        let tapGestureRecognizer1: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTFFirstNameClick))
        let tapGestureRecognizer2: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTFLastNameClick))
        let tapGestureRecognizer3: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTFEmailClick))
        let tapGestureRecognizer4: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTFNumberPhoneClick))
        let tapGestureRecognizer5: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTFPasswordClick))
        let tapImagePasswordInfomation: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(openToolTipPassword(_:)))
        let tapViewBorderDateOfBirth: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapOpenCalendar(_:)))
        let tapImageDateOfBirthInfomation: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(openToolTipDateOfBirth))
        let tapImageEmailInfomation: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(openToolTipEmail))

        self.firstNameTextField.addGestureRecognizer(tapGestureRecognizer1)
        self.lastNameTextField.addGestureRecognizer(tapGestureRecognizer2)
        self.emailTextField.addGestureRecognizer(tapGestureRecognizer3)
        self.mobileTextField.addGestureRecognizer(tapGestureRecognizer4)
        self.passwordTextField.addGestureRecognizer(tapGestureRecognizer5)
        self.passwordInfoImageView.addGestureRecognizer(tapImagePasswordInfomation)
        self.dobInfoImageView.addGestureRecognizer(tapImageDateOfBirthInfomation)
        self.birthdayView.addGestureRecognizer(tapViewBorderDateOfBirth)
        self.emailInfoImageView.addGestureRecognizer(tapImageEmailInfomation)

        let recognizer = UITapGestureRecognizer(target: self, action: #selector(self.touchEvent))
        recognizer.numberOfTapsRequired = 1
        recognizer.numberOfTouchesRequired = 1
        recognizer.delegate = self
        self.scrollView.addGestureRecognizer(recognizer)
    }
}

// MARK: - Date Picker
extension RegisterViewController {
    func closeDatePickerAndDropdown() {
        self.isOpeningDatePicker = false
        resetDateOfBirthPicker()
        toolBar.removeFromSuperview()
        dateOfBirthPicker.removeFromSuperview()
    }
    
    func resetDateOfBirthPicker() {
        let current = Date()
        self.dateOfBirthPicker.date = current
    }
}

// MARK: - Tool tip
extension RegisterViewController {
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
}

// MARK: - UIScrollViewDelegate
extension RegisterViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        removeTooltips()
        hideKeyBoardAndDatePicker()
    }
}

// MARK: - UIGestureRecognizerDelegate
extension RegisterViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return true
    }
}

// MARK: Validation form
extension RegisterViewController {
    func bindingValidationForm() {
        self.validationRegistrationForm = ValidationRegistrationForm()
        self.validationFormInputValue()
        self.bindingUIWithValidationRule()
    }
}

// MARK: Binding Event
extension RegisterViewController {
    fileprivate func bindingUIWithValidationRule() {
        // Input firstname textfield event
        self.firstNameTextField.rx.controlEvent([.editingDidEnd, .editingChanged])
            .asObservable()
            .subscribe(onNext: { [weak self] _ in
                guard let this = self else { return }
                this.validationRegistrationForm.valueFirstName
                    .onNext(this.firstNameTextField.text)
            })
            .disposed(by: disposeBag)
        
        // Input lastname textfiled  event
        self.lastNameTextField.rx.controlEvent([.editingDidEnd, .editingChanged])
            .asObservable()
            .subscribe(onNext: { [weak self] _ in
                guard let this = self else { return }
                this.validationRegistrationForm.valueLastName
                    .onNext(this.lastNameTextField.text)
            })
            .disposed(by: disposeBag)

        // Date of birth event
        self.dateOfBirthPicker.rx.controlEvent([.valueChanged])
            .asObservable()
            .subscribe(onNext: { [weak self] _ in
                guard let this = self else { return }
                guard let viewModel = this.viewModel as? RegistrationViewModel else { return }
                viewModel.dateToFocus.accept(this.dateOfBirthPicker.date.toStringLocalTime(format: Configurations.Format.dateOfBirth))
                this.validationRegistrationForm
                    .valueDatePicker.onNext(this.dobLabel?.text ?? "DD/MM/YYYY")
            })
            .disposed(by: disposeBag)

        self.birthdayView.rx.tap()
            .asObservable()
            .subscribe(onNext: { [weak self] _ in
                guard let this = self else { return }
                this.validationRegistrationForm
                    .valueDatePicker.onNext(this.dobLabel?.text ?? "DD/MM/YYYY")
            })
            .disposed(by: disposeBag)

        self.openCalendarButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let this = self else { return }
                this.validationRegistrationForm
                    .valueDatePicker.onNext(this.dobLabel?.text ?? "DD/MM/YYYY")
            })
            .disposed(by: disposeBag)

        // Input Email textfield event
        self.emailTextField.rx.controlEvent([.editingDidEnd, .editingChanged])
            .asObservable()
            .subscribe(onNext: { [weak self] _ in
                guard let this = self else { return }
                this.validationRegistrationForm.isUniqueEmail = true
                this.validationRegistrationForm.valueEmail
                    .onNext(this.emailTextField.text)
            })
            .disposed(by: disposeBag)

        // Input mobile textfield event
        self.mobileTextField.rx.controlEvent([.editingDidEnd, .editingChanged])
            .asObservable()
            .subscribe(onNext: { [weak self] _ in
                guard let this = self else { return }
                this.validationRegistrationForm.valueMobileNumber
                    .onNext(this.mobileTextField.text)
            })
            .disposed(by: disposeBag)
        
        // Input address textfield event
        self.addressTextField.rx.controlEvent([.editingDidEnd, .editingChanged])
            .asObservable()
            .subscribe(onNext: { [weak self] _ in
                guard let this = self else { return }
                this.validationRegistrationForm.valueAddress
                    .onNext(this.addressTextField.text)
            })
            .disposed(by: disposeBag)

        // Input password event
        self.passwordTextField.rx.controlEvent([.editingDidEnd, .editingChanged])
            .asObservable()
            .subscribe(onNext: { [weak self] _ in
                guard let this = self else { return }
                this.validationRegistrationForm.valuePassword
                    .onNext(this.passwordTextField.text)
            })
            .disposed(by: disposeBag)

        // Input Confirm Password textfield event
        self.confirmPasswordTextField.rx.controlEvent([.editingDidEnd, .editingChanged])
            .asObservable()
            .subscribe(onNext: { [weak self] _ in
                guard let this = self else { return }
                this.validationRegistrationForm.valueConfirmPassword.onNext(this.confirmPasswordTextField.text)
            }).disposed(by: disposeBag)

    }
}

// MARK: Validation
extension RegisterViewController {
    fileprivate func validationFormInputValue() {
        // First name
        self.validationRegistrationForm
            .validationStatusFirstName
            .subscribe(onNext: { [weak self] status in
                guard let this = self else { return }
                this.handleDisplayFirtName(status: status)
            })
            .disposed(by: disposeBag)

        // Last name
        self.validationRegistrationForm
            .validationStatusLastName
            .subscribe(onNext: { [weak self] status in
                guard let this = self else { return }
                this.handleDisplayLastName(status: status)
            })
            .disposed(by: disposeBag)

        // Date of birth
        self.validationRegistrationForm
            .validationStatusDate
            .subscribe(onNext: { [weak self] status in
                guard let this = self else { return }
                this.handleDisplayDateOfBirth(status: status)
            })
            .disposed(by: disposeBag)

        // Email
        self.validationRegistrationForm
            .validationStatusEmail
            .subscribe(onNext: { [weak self] status in
                guard let this = self else { return }
                this.handleDisplayEmail(status: status)
            })
            .disposed(by: disposeBag)

        // Mobile
        self.validationRegistrationForm
            .validationStatusMobi
            .subscribe(onNext: { [weak self] status in
                guard let this = self else { return }
                this.handleDisplayMobile(status: status)
            })
            .disposed(by: disposeBag)

        // Password
        self.validationRegistrationForm
            .validationStatusPassword
            .subscribe(onNext: { [weak self] status in
                guard let this = self else { return }
                this.handleDisplayPassword(status: status)
            })
            .disposed(by: disposeBag)
        
        // Confirm password
        self.validationRegistrationForm
            .validationStatusConfirmPassword
            .subscribe(onNext: { [weak self] status in
                guard let this = self else { return }
                this.handleDisplayConfirmPassword(status: status)
            })
            .disposed(by: disposeBag)

        // Validation form
        self.validationRegistrationForm
            .validtionForm
            .subscribe(onNext: { [weak self] isEnable in
                guard let this = self else { return }
                this.handleRegisterButton(isEnable: isEnable)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: Hanle display
extension RegisterViewController {
    fileprivate func handleSubmitButton(status: StatusField) {

    }

    fileprivate func handleRegisterButton(isEnable: Bool) {
        if isEnable {
            registerButton.activate()
        } else {
            registerButton.deactivate()
        }

    }

    fileprivate func handleDisplayDateOfBirth(status: StatusField) {
        self.dobLabel.textColor = Color.textColor
        if status == .invalid {
            self.validationDob.isHidden = false
            self.birthdayView.layer.borderWidth = 1.0
            self.birthdayView.layer.borderColor = Color.warningBorder.cgColor
            self.birthdayView.layer.backgroundColor = Color.warningBackground.cgColor
            self.birthdayView.layer.cornerRadius = 2
            let dateOfBirth = self.dobLabel.text ?? "DD/MM/YYYY"
            if dateOfBirth == "DD/MM/YYYY" {
                self.setupUIForTermConditionTextView(content: "Please enter your date of birth")
            } else {
                self.setupUIForTermConditionTextView(content: "Member must be at least 16 years old for registration in Attorney.")
            }
        } else {
            self.validationDob.isHidden = true
            self.validationDob.text = ""
            self.birthdayView.borderWidth = 1.0
            self.birthdayView.layer.borderColor = Color.historyDetailBorder.cgColor
            self.birthdayView.layer.backgroundColor = Color.backgroundTabbar.cgColor
            self.birthdayView.cornerRadius = 2
        }
    }

    // MARK: - show error
    private func setupUIForTermConditionTextView(content: String) {
        self.validationDob.contentInset = UIEdgeInsets(top: -2.0, left: -5.0, bottom: 0.0, right: 0.0)

        let linkAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key(rawValue: NSAttributedString.Key.underlineColor.rawValue): Color.FF4052  ?? Color.DFE3E9,
            NSAttributedString.Key(rawValue: NSAttributedString.Key.underlineStyle.rawValue): NSUnderlineStyle.single.rawValue
        ]

        let attributedString = NSMutableAttributedString(string: content)

        attributedString.addAttribute(NSAttributedString.Key.foregroundColor,
                                      value: Color.FF4052  ?? Color.DFE3E9,
                                      range: NSRange(location: 0, length: content.count))

        attributedString.addAttribute(NSAttributedString.Key.font,
                                      value: R.font.proximaNovaRegular(size: 14)!,
                                      range: NSRange(location: 0, length: content.count))

        let range = attributedString.mutableString.range(of: "here")

        if range.location != NSNotFound {
            attributedString.addAttributes(linkAttributes,
                                           range: range)
        }

        validationDob.attributedText = attributedString
    }

    fileprivate func handleDisplayFirtName(status: StatusField) {
        if status == .invalid {
            self.textFieldError(label: validationFirstName, textField: firstNameTextField)
            validationFirstName.text = validateNameField(value: firstNameTextField.text ?? "", checkLastName: false)
        } else {
            self.textFieldNormal(label: validationFirstName, textField: firstNameTextField)
        }
    }

    fileprivate func handleDisplayLastName(status: StatusField) {
        if status == .invalid {
            self.textFieldError(label: validationLastName, textField: lastNameTextField)
            validationLastName.text = validateNameField(value: lastNameTextField.text ?? "", checkLastName: true)
        } else {
            self.textFieldNormal(label: validationLastName, textField: lastNameTextField)
        }
    }

    fileprivate func handleDisplayEmail(status: StatusField) {
        if status == .invalid {
            self.textFieldError(label: validationEmail, textField: emailTextField)
            validationEmail.text = "Please enter a valid email address"
        } else if status == .isDuplicateEmail {
            self.textFieldError(label: validationEmail, textField: emailTextField)
            validationEmail.text = "This email is already in use"
            self.scrollView.setContentOffset(.zero, animated: true)
        } else {
            self.textFieldNormal(label: validationEmail, textField: emailTextField)
        }
    }

    fileprivate func handleDisplayConfirmPassword(status: StatusField) {
        if status == .invalid {
            self.textFieldError(label: validationConfirmPassword, textField: confirmPasswordTextField)
        } else {
            self.textFieldNormal(label: validationConfirmPassword, textField: confirmPasswordTextField)
        }
    }

    fileprivate func handleDisplayMobile(status: StatusField) {
        if status == .invalid {
            self.textFieldError(label: validationMobileNumber, textField: mobileTextField)
        } else {
            self.textFieldNormal(label: validationMobileNumber, textField: mobileTextField)
        }
    }

    fileprivate func handleDisplayPassword(status: StatusField) {
        if status == .invalid {
            self.textFieldError(label: validationPassword, textField: passwordTextField)
            let textError = self.getStringErrorPassWord(password: passwordTextField.text ?? "")
            validationPassword.text = textError
        } else {
            self.textFieldNormal(label: validationPassword, textField: passwordTextField)
        }
    }
}

extension RegisterViewController {
    fileprivate func validateNameField(value: String, checkLastName: Bool) -> String {
        let lengthName = value.count

        if lengthName == 0 {
            if checkLastName {
                return "Please enter your last name"
            } else {
                return "Please enter your first name"
            }
        } else if lengthName < 2 && checkLastName {
            return "Please enter at least 2 characters"
        } else {
            return "Please key in only letters"
        }
    }
}

extension RegisterViewController {
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

extension RegisterViewController {
    func validateTaCAndPrivacyStatus(status: Bool) {
        self.validationRegistrationForm.valueTermsAndPrivacyCheckboxSelected.onNext(status)
    }
}

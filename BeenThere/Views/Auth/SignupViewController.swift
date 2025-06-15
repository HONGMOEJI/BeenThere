//
//  SignupViewController.swift
//  BeenThere
//
//  회원가입 화면
//

import UIKit
import FirebaseAuth

class SignupViewController: UIViewController {

    // MARK: - Constants
    private struct Layout {
        static let horizontalPadding: CGFloat = 24
        static let textFieldHeight: CGFloat = 48
        static let buttonHeight: CGFloat = 52
        static let cornerRadius: CGFloat = 8
        static let borderWidth: CGFloat = 1
        static let fieldPadding: CGFloat = 12
    }
    
    private struct Colors {
        static let textFieldNormal = UIColor(white: 0.35, alpha: 1)
        static let textFieldError = UIColor.systemRed
        static let textFieldBackground = UIColor(white: 0.18, alpha: 1)
    }

    // MARK: - UI Components
    private let nameField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "이름 (2~20자)"
        tf.font = .pretendardRegular(size: 16)
        tf.textColor = .white
        tf.backgroundColor = Colors.textFieldBackground
        tf.layer.cornerRadius = Layout.cornerRadius
        tf.layer.borderWidth = Layout.borderWidth
        tf.layer.borderColor = Colors.textFieldNormal.cgColor
        
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: Layout.fieldPadding, height: Layout.textFieldHeight))
        tf.leftViewMode = .always
        
        tf.attributedPlaceholder = NSAttributedString(
            string: "이름 (2~20자)",
            attributes: [.foregroundColor: UIColor(white: 0.6, alpha: 1)]
        )
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    private let emailField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "이메일"
        tf.font = .pretendardRegular(size: 16)
        tf.textColor = .white
        tf.autocapitalizationType = .none
        tf.keyboardType = .emailAddress
        tf.backgroundColor = Colors.textFieldBackground
        tf.layer.cornerRadius = Layout.cornerRadius
        tf.layer.borderWidth = Layout.borderWidth
        tf.layer.borderColor = Colors.textFieldNormal.cgColor
        
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: Layout.fieldPadding, height: Layout.textFieldHeight))
        tf.leftViewMode = .always
        
        tf.attributedPlaceholder = NSAttributedString(
            string: "이메일",
            attributes: [.foregroundColor: UIColor(white: 0.6, alpha: 1)]
        )
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    private let pwField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "비밀번호 (6자 이상)"
        tf.font = .pretendardRegular(size: 16)
        tf.textColor = .white
        tf.isSecureTextEntry = true
        tf.backgroundColor = Colors.textFieldBackground
        tf.layer.cornerRadius = Layout.cornerRadius
        tf.layer.borderWidth = Layout.borderWidth
        tf.layer.borderColor = Colors.textFieldNormal.cgColor
        
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: Layout.fieldPadding, height: Layout.textFieldHeight))
        tf.leftViewMode = .always
        
        tf.attributedPlaceholder = NSAttributedString(
            string: "비밀번호 (6자 이상)",
            attributes: [.foregroundColor: UIColor(white: 0.6, alpha: 1)]
        )
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    private lazy var passwordToggleButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - 오류 메시지 레이블
    private let fieldErrorLabel: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .systemRed
        lbl.font = .pretendardRegular(size: 12)
        lbl.textAlignment = .left
        lbl.numberOfLines = 2
        lbl.isHidden = true
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let signupButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("회원가입", for: .normal)
        btn.titleLabel?.font = .pretendardSemiBold(size: 18)
        btn.setTitleColor(.black, for: .normal)
        btn.backgroundColor = UIColor(white: 0.9, alpha: 1)
        btn.layer.cornerRadius = Layout.cornerRadius
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private let cancelButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("취소", for: .normal)
        btn.titleLabel?.font = .pretendardMedium(size: 16)
        btn.setTitleColor(UIColor(white: 0.9, alpha: 1), for: .normal)
        btn.backgroundColor = .clear
        btn.layer.borderColor = Colors.textFieldNormal.cgColor
        btn.layer.borderWidth = Layout.borderWidth
        btn.layer.cornerRadius = Layout.cornerRadius
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(white: 0.08, alpha: 1)
        
        setupViews()
        setupConstraints()
        configureActions()
        setupPasswordToggle()
        setupTextFieldDelegates()
    }

    // MARK: - Setup Methods
    private func setupViews() {
        [nameField, emailField, pwField, fieldErrorLabel, signupButton, cancelButton].forEach {
            view.addSubview($0)
        }
    }
    
    private func setupTextFieldDelegates() {
        nameField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        emailField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        pwField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    private func setupPasswordToggle() {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: Layout.fieldPadding, height: Layout.textFieldHeight))
        
        let container = UIStackView(arrangedSubviews: [passwordToggleButton, paddingView])
        container.axis = .horizontal
        container.alignment = .center
        container.distribution = .fill
        container.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            container.widthAnchor.constraint(equalToConstant: 36),
            container.heightAnchor.constraint(equalToConstant: 24)
        ])
        
        pwField.rightView = container
        pwField.rightViewMode = .always
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // 이름 필드
            nameField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Layout.horizontalPadding),
            nameField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Layout.horizontalPadding),
            nameField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80),
            nameField.heightAnchor.constraint(equalToConstant: Layout.textFieldHeight),

            // 이메일 필드
            emailField.leadingAnchor.constraint(equalTo: nameField.leadingAnchor),
            emailField.trailingAnchor.constraint(equalTo: nameField.trailingAnchor),
            emailField.topAnchor.constraint(equalTo: nameField.bottomAnchor, constant: 20),
            emailField.heightAnchor.constraint(equalToConstant: Layout.textFieldHeight),

            // 비밀번호 필드
            pwField.leadingAnchor.constraint(equalTo: emailField.leadingAnchor),
            pwField.trailingAnchor.constraint(equalTo: emailField.trailingAnchor),
            pwField.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: 20),
            pwField.heightAnchor.constraint(equalToConstant: Layout.textFieldHeight),

            // 필드 오류 레이블
            fieldErrorLabel.leadingAnchor.constraint(equalTo: pwField.leadingAnchor, constant: 4),
            fieldErrorLabel.trailingAnchor.constraint(equalTo: pwField.trailingAnchor, constant: -4),
            fieldErrorLabel.topAnchor.constraint(equalTo: pwField.bottomAnchor, constant: 4),

            // 회원가입 버튼
            signupButton.leadingAnchor.constraint(equalTo: pwField.leadingAnchor),
            signupButton.trailingAnchor.constraint(equalTo: pwField.trailingAnchor),
            signupButton.topAnchor.constraint(equalTo: fieldErrorLabel.bottomAnchor, constant: 32),
            signupButton.heightAnchor.constraint(equalToConstant: Layout.buttonHeight),

            // 취소 버튼
            cancelButton.leadingAnchor.constraint(equalTo: signupButton.leadingAnchor),
            cancelButton.trailingAnchor.constraint(equalTo: signupButton.trailingAnchor),
            cancelButton.topAnchor.constraint(equalTo: signupButton.bottomAnchor, constant: 16),
            cancelButton.heightAnchor.constraint(equalToConstant: Layout.buttonHeight)
        ])
    }

    private func configureActions() {
        signupButton.addTarget(self, action: #selector(signupTapped), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
    }

    // MARK: - Error Handling Methods
    private func showFieldError(_ message: String, errorFields: [UITextField] = []) {
        fieldErrorLabel.text = message
        fieldErrorLabel.isHidden = false
        
        for field in errorFields {
            field.layer.borderColor = Colors.textFieldError.cgColor
        }
        
        fieldErrorLabel.alpha = 0
        UIView.animate(withDuration: 0.3) {
            self.fieldErrorLabel.alpha = 1
        }
    }
    
    private func clearFieldErrors() {
        fieldErrorLabel.isHidden = true
        nameField.layer.borderColor = Colors.textFieldNormal.cgColor
        emailField.layer.borderColor = Colors.textFieldNormal.cgColor
        pwField.layer.borderColor = Colors.textFieldNormal.cgColor
    }

    // MARK: - Actions
    @objc private func textFieldDidChange() {
        clearFieldErrors()
    }
    
    @objc private func togglePasswordVisibility() {
        pwField.isSecureTextEntry.toggle()
        let imageName = pwField.isSecureTextEntry ? "eye.slash" : "eye"
        passwordToggleButton.setImage(UIImage(systemName: imageName), for: .normal)
    }

    @objc private func signupTapped() {
        let name = nameField.text ?? ""
        let email = emailField.text ?? ""
        let pw = pwField.text ?? ""
        clearFieldErrors()

        // 입력 값 검증
        var errorFields: [UITextField] = []
        var errorMessage = ""
        
        if !ValidationHelper.isValidName(name) {
            errorFields.append(nameField)
            errorMessage = "이름은 2~20자여야 합니다."
        }
        
        if !ValidationHelper.isValidEmail(email) {
            errorFields.append(emailField)
            if errorMessage.isEmpty {
                errorMessage = "올바른 이메일을 입력하세요."
            } else {
                errorMessage += "\n올바른 이메일을 입력하세요."
            }
        }
        
        let pwValidation = ValidationHelper.validatePassword(pw)
        if !pwValidation.isValid {
            errorFields.append(pwField)
            if errorMessage.isEmpty {
                errorMessage = pwValidation.errors.first ?? "비밀번호를 확인하세요."
            } else {
                errorMessage += "\n" + (pwValidation.errors.first ?? "비밀번호를 확인하세요.")
            }
        }
        
        if !errorFields.isEmpty {
            showFieldError(errorMessage, errorFields: errorFields)
            return
        }

        // Firebase 회원가입 (이메일 인증 포함)
        Auth.auth().createUser(withEmail: email, password: pw) { [weak self] result, error in
            DispatchQueue.main.async {
                if let error = error {
                    let errorCode = (error as NSError).code
                    var errorFields: [UITextField] = []
                    
                    switch errorCode {
                    case AuthErrorCode.emailAlreadyInUse.rawValue:
                        errorFields = [self?.emailField].compactMap { $0 }
                    case AuthErrorCode.weakPassword.rawValue:
                        errorFields = [self?.pwField].compactMap { $0 }
                    default:
                        errorFields = [self?.emailField, self?.pwField].compactMap { $0 }
                    }
                    
                    self?.showFieldError(AuthErrorHandler.getErrorMessage(from: error), errorFields: errorFields)
                } else if let user = result?.user {
                    // 사용자 프로필 업데이트
                    let change = user.createProfileChangeRequest()
                    change.displayName = name
                    change.commitChanges { _ in }
                    
                    // 인증 메일 발송
                    user.sendEmailVerification { [weak self] error in
                        DispatchQueue.main.async {
                            if let error = error {
                                self?.showFieldError(AuthErrorHandler.getErrorMessage(from: error))
                            } else {
                                self?.showVerificationAlert()
                            }
                        }
                    }
                }
            }
        }
    }

    @objc private func cancelTapped() {
        dismiss(animated: true)
    }

    // MARK: - Helper Methods
    private func showVerificationAlert() {
        let alert = UIAlertController(
            title: "회원가입 완료!",
            message: "인증 메일을 보냈습니다. 이메일을 확인하고 인증을 완료해주세요.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "확인", style: .default) { [weak self] _ in
            // 로그아웃 후 로그인 화면으로 돌아가기
            try? Auth.auth().signOut()
            self?.dismiss(animated: true)
        })
        
        present(alert, animated: true)
    }
}

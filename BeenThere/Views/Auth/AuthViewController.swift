//
//  AuthViewController.swift
//  BeenThere
//
//  로그인/회원가입/익명 로그인 진입 화면
//  (다크 그레이 테마 + 박스형 텍스트 필드 + 비밀번호 토글 버튼 + 타자 애니메이션)
//  BeenThere/Views/Auth/AuthViewController.swift
//

import UIKit
import FirebaseAuth

class AuthViewController: UIViewController {

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

    // MARK: - 감성 키워드 레이블 3개 (타자 애니메이션용)
    private let line1Label: UILabel = {
        let lbl = UILabel()
        lbl.text = ""  // 초기에는 빈 문자열
        lbl.font = .pretendardSemiBold(size: 24)
        lbl.textColor = .white
        lbl.textAlignment = .left
        lbl.backgroundColor = .black
        lbl.layer.cornerRadius = 4
        lbl.clipsToBounds = true
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    private let line2Label: UILabel = {
        let lbl = UILabel()
        lbl.text = ""
        lbl.font = .pretendardSemiBold(size: 24)
        lbl.textColor = .white
        lbl.textAlignment = .left
        lbl.backgroundColor = .black
        lbl.layer.cornerRadius = 4
        lbl.clipsToBounds = true
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    private let line3Label: UILabel = {
        let lbl = UILabel()
        lbl.text = ""
        lbl.font = .pretendardSemiBold(size: 24)
        lbl.textColor = .white
        lbl.textAlignment = .left
        lbl.backgroundColor = .black
        lbl.layer.cornerRadius = 4
        lbl.clipsToBounds = true
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    // MARK: - 텍스트 필드 (박스형 스타일, 다크 테마)
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
        
        // Left padding 설정
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
        tf.placeholder = "비밀번호"
        tf.font = .pretendardRegular(size: 16)
        tf.textColor = .white
        tf.isSecureTextEntry = true
        tf.backgroundColor = Colors.textFieldBackground
        tf.layer.cornerRadius = Layout.cornerRadius
        tf.layer.borderWidth = Layout.borderWidth
        tf.layer.borderColor = Colors.textFieldNormal.cgColor
        
        // Left padding 설정
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: Layout.fieldPadding, height: Layout.textFieldHeight))
        tf.leftViewMode = .always
        
        tf.attributedPlaceholder = NSAttributedString(
            string: "비밀번호",
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

    // MARK: - 오류 메시지 레이블 (비밀번호 필드 하단)
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

    // MARK: - 비밀번호 잊으셨나요? 버튼
    private let forgotButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("비밀번호를 잊으셨나요?", for: .normal)
        btn.setTitleColor(UIColor(white: 0.7, alpha: 1), for: .normal)
        btn.titleLabel?.font = .pretendardRegular(size: 14)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    // MARK: - 로그인 버튼
    private let loginButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("로그인", for: .normal)
        btn.titleLabel?.font = .pretendardSemiBold(size: 18)
        btn.setTitleColor(.black, for: .normal)
        btn.backgroundColor = UIColor(white: 0.9, alpha: 1)
        btn.layer.cornerRadius = Layout.cornerRadius
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    // MARK: - 계정이 없으시다면? 회원가입 구성
    private let noAccountLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "계정이 없으시다면?"
        lbl.font = .pretendardRegular(size: 14)
        lbl.textColor = UIColor(white: 0.7, alpha: 1)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    private let signupButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("회원가입", for: .normal)
        btn.titleLabel?.font = .pretendardMedium(size: 14)
        btn.setTitleColor(UIColor(white: 0.9, alpha: 1), for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    // 기존 errorLabel은 제거하고 fieldErrorLabel 사용

    // MARK: - 애니메이션 실행 여부 플래그
    private var didAnimateLines = false

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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // 한 번만 타자 애니메이션 실행
        if !didAnimateLines {
            startTypewriterAnimation()
            didAnimateLines = true
        }
    }

    // MARK: - Setup Methods
    private func setupViews() {
        [line1Label, line2Label, line3Label,
         emailField, pwField, fieldErrorLabel, forgotButton,
         loginButton, noAccountLabel, signupButton].forEach { view.addSubview($0) }
    }
    
    private func setupTextFieldDelegates() {
        emailField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        pwField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    private func setupPasswordToggle() {
        // 토글 버튼과 패딩을 위한 컨테이너 생성
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

    // MARK: - 레이아웃 제약 설정
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // 타자 애니메이션 레이블들
            line1Label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Layout.horizontalPadding),
            line1Label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 48),
            line1Label.heightAnchor.constraint(equalToConstant: 30),

            line2Label.leadingAnchor.constraint(equalTo: line1Label.leadingAnchor),
            line2Label.topAnchor.constraint(equalTo: line1Label.bottomAnchor, constant: 4),
            line2Label.heightAnchor.constraint(equalToConstant: 30),

            line3Label.leadingAnchor.constraint(equalTo: line1Label.leadingAnchor),
            line3Label.topAnchor.constraint(equalTo: line2Label.bottomAnchor, constant: 4),
            line3Label.heightAnchor.constraint(equalToConstant: 30),

            // 이메일 필드 - 레이블과 동일한 leading 정렬
            emailField.leadingAnchor.constraint(equalTo: line1Label.leadingAnchor),
            emailField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Layout.horizontalPadding),
            emailField.topAnchor.constraint(equalTo: line3Label.bottomAnchor, constant: 48),
            emailField.heightAnchor.constraint(equalToConstant: Layout.textFieldHeight),

            // 비밀번호 필드
            pwField.leadingAnchor.constraint(equalTo: emailField.leadingAnchor),
            pwField.trailingAnchor.constraint(equalTo: emailField.trailingAnchor),
            pwField.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: 20),
            pwField.heightAnchor.constraint(equalToConstant: Layout.textFieldHeight),

            // 필드 오류 레이블 (비밀번호 필드 하단)
            fieldErrorLabel.leadingAnchor.constraint(equalTo: pwField.leadingAnchor, constant: 4),
            fieldErrorLabel.trailingAnchor.constraint(equalTo: pwField.trailingAnchor, constant: -4),
            fieldErrorLabel.topAnchor.constraint(equalTo: pwField.bottomAnchor, constant: 4),

            // 비밀번호 찾기 버튼 (오류 레이블과 겹치지 않도록 조정)
            forgotButton.trailingAnchor.constraint(equalTo: pwField.trailingAnchor),
            forgotButton.topAnchor.constraint(equalTo: fieldErrorLabel.bottomAnchor, constant: 8),

            // 로그인 버튼
            loginButton.leadingAnchor.constraint(equalTo: pwField.leadingAnchor),
            loginButton.trailingAnchor.constraint(equalTo: pwField.trailingAnchor),
            loginButton.topAnchor.constraint(equalTo: forgotButton.bottomAnchor, constant: 24),
            loginButton.heightAnchor.constraint(equalToConstant: Layout.buttonHeight),

            // 계정이 없으시다면? 회원가입
            noAccountLabel.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 16),
            noAccountLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -40),
            
            signupButton.leadingAnchor.constraint(equalTo: noAccountLabel.trailingAnchor, constant: 4),
            signupButton.centerYAnchor.constraint(equalTo: noAccountLabel.centerYAnchor)
        ])
    }

    // MARK: - 버튼 액션 연결
    private func configureActions() {
        loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        signupButton.addTarget(self, action: #selector(signupTapped), for: .touchUpInside)
        forgotButton.addTarget(self, action: #selector(forgotTapped), for: .touchUpInside)
    }

    // MARK: - 타자(타이핑) 애니메이션 구현
    private func startTypewriterAnimation() {
        typeText(label: line1Label, fullText: "끄적끄적", characterDelay: 0.1) { [weak self] in
            self?.typeText(label: self?.line2Label, fullText: "한 줄로 적어보는", characterDelay: 0.1) {
                self?.typeText(label: self?.line3Label, fullText: "소소한 여행기록", characterDelay: 0.1) {
                    // 모든 애니메이션 완료
                }
            }
        }
    }

    /// 지정된 레이블에 `fullText`를 한 글자씩 `characterDelay` 간격으로 추가 후, 완료 시 `completion`.
    private func typeText(label: UILabel?, fullText: String, characterDelay: TimeInterval, completion: @escaping () -> Void) {
        guard let label = label else {
            completion()
            return
        }
        
        label.text = ""  // 레이블 초기화
        let characters = Array(fullText)
        var currentIndex = 0

        Timer.scheduledTimer(withTimeInterval: characterDelay, repeats: true) { timer in
            if currentIndex < characters.count {
                label.text! += String(characters[currentIndex])
                currentIndex += 1
            } else {
                timer.invalidate()
                completion()
            }
        }
    }

    // MARK: - Error Handling Methods
    private func showFieldError(_ message: String, errorFields: [UITextField] = []) {
        fieldErrorLabel.text = message
        fieldErrorLabel.isHidden = false
        
        // 오류가 있는 필드들을 빨간색 테두리로 표시
        for field in errorFields {
            field.layer.borderColor = Colors.textFieldError.cgColor
        }
        
        // 애니메이션으로 오류 레이블 표시
        fieldErrorLabel.alpha = 0
        UIView.animate(withDuration: 0.3) {
            self.fieldErrorLabel.alpha = 1
        }
    }
    
    private func clearFieldErrors() {
        fieldErrorLabel.isHidden = true
        emailField.layer.borderColor = Colors.textFieldNormal.cgColor
        pwField.layer.borderColor = Colors.textFieldNormal.cgColor
    }

    // MARK: - Actions
    @objc private func textFieldDidChange() {
        // 사용자가 입력을 시작하면 오류 상태 클리어
        clearFieldErrors()
    }
    
    @objc private func togglePasswordVisibility() {
        pwField.isSecureTextEntry.toggle()
        let imageName = pwField.isSecureTextEntry ? "eye.slash" : "eye"
        passwordToggleButton.setImage(UIImage(systemName: imageName), for: .normal)
    }

    @objc private func loginTapped() {
        let email = emailField.text ?? ""
        let pw = pwField.text ?? ""
        clearFieldErrors()

        var errorFields: [UITextField] = []
        var errorMessage = ""

        if email.isEmpty {
            errorFields.append(emailField)
            errorMessage = "이메일을 입력하세요."
        } else if !ValidationHelper.isValidEmail(email) {
            errorFields.append(emailField)
            errorMessage = "올바른 이메일 형식을 입력하세요."
        }

        if pw.isEmpty {
            errorFields.append(pwField)
            if errorMessage.isEmpty {
                errorMessage = "비밀번호를 입력하세요."
            } else {
                errorMessage = "이메일과 비밀번호를 입력하세요."
            }
        }

        if !errorFields.isEmpty {
            showFieldError(errorMessage, errorFields: errorFields)
            return
        }

        // ✅ Firebase 로그인 시도
        Auth.auth().signIn(withEmail: email, password: pw) { [weak self] result, error in
            DispatchQueue.main.async {
                if let error = error {
                    var errorFields: [UITextField] = []
                    let errorCode = (error as NSError).code

                    switch errorCode {
                    case AuthErrorCode.wrongPassword.rawValue:
                        errorFields = [self?.pwField].compactMap { $0 }
                    case AuthErrorCode.userNotFound.rawValue,
                         AuthErrorCode.invalidEmail.rawValue:
                        errorFields = [self?.emailField].compactMap { $0 }
                    default:
                        errorFields = [self?.emailField, self?.pwField].compactMap { $0 }
                    }

                    self?.showFieldError(AuthErrorHandler.getErrorMessage(from: error), errorFields: errorFields)
                } else if let user = result?.user {
                    if user.isEmailVerified {
                        self?.transitionToMain() // ✅ 이메일 인증 후 메인 화면 전환
                    } else {
                        self?.showEmailVerificationAlert()
                    }
                }
            }
        }
    }

    @objc private func signupTapped() {
        let signupVC = SignupViewController()
        signupVC.modalPresentationStyle = .fullScreen
        present(signupVC, animated: true)
    }

    @objc private func forgotTapped() {
        let vc = ForgotPasswordViewController()
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }

    // MARK: - Helper Methods
    private func showEmailVerificationAlert() {
        let alert = UIAlertController(
            title: "이메일 인증 필요",
            message: "이메일 인증이 완료되지 않았습니다. 인증 메일을 다시 보내시겠습니까?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "인증 메일 재발송", style: .default) { [weak self] _ in
            self?.resendVerificationEmail()
        })
        
        alert.addAction(UIAlertAction(title: "로그아웃", style: .cancel) { _ in
            try? Auth.auth().signOut()
        })
        
        present(alert, animated: true)
    }
    
    private func resendVerificationEmail() {
        guard let user = Auth.auth().currentUser else { return }
        
        user.sendEmailVerification { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.showFieldError(AuthErrorHandler.getErrorMessage(from: error))
                } else {
                    self?.showAlert("인증 메일 발송", "이메일을 확인하고 인증을 완료해주세요.")
                }
            }
        }
    }
    
    /// 로그인 성공 후 MainViewController로 전환
    private func transitionToMain() {
        let mainVC = MainViewController()
        let navVC = UINavigationController(rootViewController: mainVC)
        navVC.modalPresentationStyle = .fullScreen
        present(navVC, animated: true)
    }
    
    private func showAlert(_ title: String, _ message: String) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "닫기", style: .default))
        present(alert, animated: true)
    }
}

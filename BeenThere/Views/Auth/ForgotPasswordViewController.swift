//
//  ForgotPasswordViewController.swift
//  BeenThere
//
//  비밀번호 찾기/재설정 화면
//

import UIKit
import FirebaseAuth

class ForgotPasswordViewController: UIViewController {

    // MARK: - Constants
    private struct Layout {
        static let horizontalPadding: CGFloat = 24
        static let textFieldHeight: CGFloat = 48
        static let buttonHeight: CGFloat = 52
        static let cornerRadius: CGFloat = 8
        static let borderWidth: CGFloat = 1
        static let fieldPadding: CGFloat = 12
    }

    // MARK: - UI Components
    private let infoLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "가입하신 이메일을 입력해주세요."
        lbl.textAlignment = .left
        lbl.font = .pretendardRegular(size: 16)
        lbl.textColor = .white
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let emailField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "이메일"
        tf.font = .pretendardRegular(size: 16)
        tf.textColor = .white
        tf.autocapitalizationType = .none
        tf.keyboardType = .emailAddress
        tf.backgroundColor = UIColor(white: 0.18, alpha: 1)
        tf.layer.cornerRadius = Layout.cornerRadius
        tf.layer.borderWidth = Layout.borderWidth
        tf.layer.borderColor = UIColor(white: 0.35, alpha: 1).cgColor
        
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

    private let sendButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("재설정 메일 보내기", for: .normal)
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
        btn.layer.borderColor = UIColor(white: 0.35, alpha: 1).cgColor
        btn.layer.borderWidth = Layout.borderWidth
        btn.layer.cornerRadius = Layout.cornerRadius
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private let errorLabel: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .systemRed
        lbl.font = .pretendardRegular(size: 13)
        lbl.textAlignment = .center
        lbl.numberOfLines = 2
        lbl.isHidden = true
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(white: 0.08, alpha: 1)
        
        setupViews()
        setupConstraints()
        configureActions()
    }

    // MARK: - Setup Methods
    private func setupViews() {
        [infoLabel, emailField, sendButton, cancelButton, errorLabel].forEach {
            view.addSubview($0)
        }
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // 안내 레이블
            infoLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Layout.horizontalPadding),
            infoLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Layout.horizontalPadding),
            infoLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80),
            infoLabel.heightAnchor.constraint(equalToConstant: 20),

            // 이메일 필드
            emailField.leadingAnchor.constraint(equalTo: infoLabel.leadingAnchor),
            emailField.trailingAnchor.constraint(equalTo: infoLabel.trailingAnchor),
            emailField.topAnchor.constraint(equalTo: infoLabel.bottomAnchor, constant: 24),
            emailField.heightAnchor.constraint(equalToConstant: Layout.textFieldHeight),

            // 재설정 메일 버튼
            sendButton.leadingAnchor.constraint(equalTo: emailField.leadingAnchor),
            sendButton.trailingAnchor.constraint(equalTo: emailField.trailingAnchor),
            sendButton.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: 40),
            sendButton.heightAnchor.constraint(equalToConstant: Layout.buttonHeight),

            // 취소 버튼
            cancelButton.leadingAnchor.constraint(equalTo: sendButton.leadingAnchor),
            cancelButton.trailingAnchor.constraint(equalTo: sendButton.trailingAnchor),
            cancelButton.topAnchor.constraint(equalTo: sendButton.bottomAnchor, constant: 16),
            cancelButton.heightAnchor.constraint(equalToConstant: Layout.buttonHeight),

            // 에러 레이블
            errorLabel.topAnchor.constraint(equalTo: cancelButton.bottomAnchor, constant: 20),
            errorLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Layout.horizontalPadding),
            errorLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Layout.horizontalPadding)
        ])
    }

    private func configureActions() {
        sendButton.addTarget(self, action: #selector(sendTapped), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
    }

    // MARK: - Actions
    @objc private func sendTapped() {
        let email = emailField.text ?? ""
        errorLabel.isHidden = true

        guard ValidationHelper.isValidEmail(email) else {
            showError("올바른 이메일을 입력하세요.")
            return
        }

        Auth.auth().sendPasswordReset(withEmail: email) { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.showError(AuthErrorHandler.getErrorMessage(from: error))
                } else {
                    self?.showAlert("이메일 전송 완료", "이메일을 확인해주세요.")
                }
            }
        }
    }

    @objc private func cancelTapped() {
        dismiss(animated: true)
    }

    // MARK: - Helper Methods
    private func showError(_ message: String) {
        errorLabel.text = message
        errorLabel.isHidden = false
    }
    
    private func showAlert(_ title: String, _ message: String) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "닫기", style: .default))
        present(alert, animated: true)
    }
}

//
//  ViewFactory.swift
//  BeenThere
//
//  공통 UI 컴포넌트 팩토리
//  BeenThere/Core/Utils/ViewFactory.swift
//

import UIKit

struct ViewFactory {
    
    // MARK: - Buttons
    static func primaryButton(title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .buttonLarge
        button.backgroundColor = .primaryBlue
        button.layer.cornerRadius = AppConstants.Layout.defaultRadius
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
    
    static func secondaryButton(title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(.primaryBlue, for: .normal)
        button.titleLabel?.font = .buttonLarge
        button.backgroundColor = .clear
        button.layer.borderColor = UIColor.primaryBlue.cgColor
        button.layer.borderWidth = AppConstants.Layout.defaultBorderWidth
        button.layer.cornerRadius = AppConstants.Layout.defaultRadius
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
    
    static func iconButton(systemName: String, tintColor: UIColor = .primaryBlue) -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: systemName), for: .normal)
        button.tintColor = tintColor
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
    
    // MARK: - Text Fields
    static func textField(placeholder: String, keyboardType: UIKeyboardType = .default) -> UITextField {
        let textField = UITextField()
        textField.placeholder = placeholder
        textField.font = .textFieldMedium
        textField.textColor = .textPrimary
        textField.keyboardType = keyboardType
        textField.autocorrectionType = .no
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }
    
    static func secureTextField(placeholder: String) -> UITextField {
        let textField = textField(placeholder: placeholder)
        textField.isSecureTextEntry = true
        return textField
    }
    
    static func emailTextField(placeholder: String = "이메일") -> UITextField {
        let textField = textField(placeholder: placeholder, keyboardType: .emailAddress)
        textField.autocapitalizationType = .none
        return textField
    }
    
    // MARK: - Text Field Containers
    static func textFieldContainer() -> UIView {
        let container = UIView()
        container.backgroundColor = .backgroundSecondary
        container.layer.cornerRadius = AppConstants.Layout.defaultRadius
        container.layer.borderWidth = AppConstants.Layout.defaultBorderWidth
        container.layer.borderColor = UIColor.separatorPrimary.cgColor
        container.translatesAutoresizingMaskIntoConstraints = false
        return container
    }
    
    // MARK: - Labels
    static func titleLabel(text: String, style: TitleStyle = .large) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = .textPrimary
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        switch style {
        case .large:
            label.font = .titleLarge
        case .medium:
            label.font = .titleMedium
        case .small:
            label.font = .titleSmall
        }
        
        return label
    }
    
    static func bodyLabel(text: String, style: BodyStyle = .medium, alignment: NSTextAlignment = .left) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = .textSecondary
        label.textAlignment = alignment
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        
        switch style {
        case .large:
            label.font = .bodyLarge
        case .medium:
            label.font = .bodyMedium
        case .small:
            label.font = .bodySmall
        }
        
        return label
    }
    
    // MARK: - Image Views
    static func logoImageView(systemName: String = AppConstants.SystemImages.airplane) -> UIImageView {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: systemName)
        imageView.tintColor = .primaryBlue
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }
    
    // MARK: - Activity Indicators
    static func loadingIndicator(color: UIColor = .primaryBlue) -> UIActivityIndicatorView {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = color
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }
    
    // MARK: - Stack Views
    static func verticalStackView(spacing: CGFloat = AppConstants.Layout.defaultMargin) -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = spacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }
    
    static func horizontalStackView(spacing: CGFloat = AppConstants.Layout.smallMargin) -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = spacing
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }
}

// MARK: - Supporting Enums
extension ViewFactory {
    enum TitleStyle {
        case large, medium, small
    }
    
    enum BodyStyle {
        case large, medium, small
    }
}

//
//  ValidationHelper.swift
//  BeenThere
//
//  유효성 검사 헬퍼 클래스
//  BeenThere/Core/Utils/ValidationHelper.swift
//

import Foundation
import UIKit

struct ValidationHelper {
    
    // MARK: - Email Validation
    static func isValidEmail(_ email: String) -> Bool {
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", AppConstants.Validation.emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    // MARK: - Password Validation
    static func validatePassword(_ password: String) -> PasswordValidationResult {
        var errors: [String] = []
        
        if password.count < AppConstants.Validation.minPasswordLength {
            errors.append("비밀번호는 \(AppConstants.Validation.minPasswordLength)자 이상이어야 합니다")
        }
        
        if password.count > AppConstants.Validation.maxPasswordLength {
            errors.append("비밀번호는 \(AppConstants.Validation.maxPasswordLength)자 이하여야 합니다")
        }
        
        return PasswordValidationResult(
            isValid: errors.isEmpty,
            errors: errors,
            strength: getPasswordStrength(password)
        )
    }
    
    private static func getPasswordStrength(_ password: String) -> PasswordStrength {
        var score = 0
        
        if password.count >= 8 { score += 1 }
        if password.rangeOfCharacter(from: .lowercaseLetters) != nil { score += 1 }
        if password.rangeOfCharacter(from: .uppercaseLetters) != nil { score += 1 }
        if password.rangeOfCharacter(from: .decimalDigits) != nil { score += 1 }
        if password.rangeOfCharacter(from: CharacterSet(charactersIn: "!@#$%^&*()")) != nil { score += 1 }
        
        switch score {
        case 0...1: return .weak
        case 2...3: return .medium
        case 4...5: return .strong
        default: return .weak
        }
    }
    
    // MARK: - Name Validation
    static func isValidName(_ name: String) -> Bool {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedName.count >= AppConstants.Validation.minNameLength &&
               trimmedName.count <= AppConstants.Validation.maxNameLength
    }
}

// MARK: - Supporting Types
struct PasswordValidationResult {
    let isValid: Bool
    let errors: [String]
    let strength: PasswordStrength
}

enum PasswordStrength {
    case weak, medium, strong
    
    var message: String {
        switch self {
        case .weak: return "약한 비밀번호"
        case .medium: return "보통 비밀번호"
        case .strong: return "강한 비밀번호"
        }
    }
    
    var color: UIColor {
        switch self {
        case .weak: return .errorRed
        case .medium: return .warningOrange
        case .strong: return .successGreen
        }
    }
}

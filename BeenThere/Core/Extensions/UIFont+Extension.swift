//
//  UIFont+Pretendard.swift
//  BeenThere
//
//  Pretendard 폰트 시스템
//  BeenThere/Core/Extensions/UIFont+Pretendard.swift
//

import UIKit

extension UIFont {
    
    // MARK: - Font Factory Method
    private static func pretendard(size: CGFloat, weight: PretendardWeight) -> UIFont {
        return UIFont(name: weight.fontName, size: size) ?? .systemFont(ofSize: size, weight: weight.systemWeight)
    }
    
    // MARK: - Semantic Font Sizes
    
    // Display (가장 큰 제목)
    static let displayLarge = pretendard(size: 32, weight: .bold)
    static let displayMedium = pretendard(size: 28, weight: .bold)
    
    // Title (섹션 제목)
    static let titleLarge = pretendard(size: 24, weight: .semiBold)
    static let titleMedium = pretendard(size: 20, weight: .semiBold)
    static let titleSmall = pretendard(size: 18, weight: .medium)
    
    // Headline (강조된 본문)
    static let headlineLarge = pretendard(size: 17, weight: .semiBold)
    static let headlineMedium = pretendard(size: 16, weight: .medium)
    
    // Body (기본 본문)
    static let bodyLarge = pretendard(size: 17, weight: .regular)
    static let bodyMedium = pretendard(size: 15, weight: .regular)
    static let bodySmall = pretendard(size: 13, weight: .regular)
    
    // Label (라벨, 캡션)
    static let labelLarge = pretendard(size: 14, weight: .medium)
    static let labelMedium = pretendard(size: 12, weight: .medium)
    static let labelSmall = pretendard(size: 11, weight: .medium)
    
    // Caption (가장 작은 텍스트)
    static let captionLarge = pretendard(size: 12, weight: .regular)
    static let captionSmall = pretendard(size: 10, weight: .regular)
    
    // MARK: - Component Specific Fonts
    
    // Buttons
    static let buttonLarge = pretendard(size: 17, weight: .semiBold)
    static let buttonMedium = pretendard(size: 15, weight: .medium)
    static let buttonSmall = pretendard(size: 13, weight: .medium)
    
    // Navigation
    static let navigationTitle = pretendard(size: 17, weight: .semiBold)
    static let navigationLargeTitle = pretendard(size: 34, weight: .bold)
    
    // Tab Bar
    static let tabBarTitle = pretendard(size: 10, weight: .medium)
    
    // Text Fields
    static let textFieldLarge = pretendard(size: 17, weight: .regular)
    static let textFieldMedium = pretendard(size: 15, weight: .regular)
    
    // MARK: - Dynamic Font Sizes (Custom)
    static func pretendardRegular(size: CGFloat) -> UIFont {
        return pretendard(size: size, weight: .regular)
    }
    
    static func pretendardMedium(size: CGFloat) -> UIFont {
        return pretendard(size: size, weight: .medium)
    }
    
    static func pretendardSemiBold(size: CGFloat) -> UIFont {
        return pretendard(size: size, weight: .semiBold)
    }
    
    static func pretendardBold(size: CGFloat) -> UIFont {
        return pretendard(size: size, weight: .bold)
    }
}

// MARK: - Pretendard Weight Enum
enum PretendardWeight {
    case thin, extraLight, light, regular, medium, semiBold, bold, extraBold, black
    
    var fontName: String {
        switch self {
        case .thin: return "Pretendard-Thin"
        case .extraLight: return "Pretendard-ExtraLight"
        case .light: return "Pretendard-Light"
        case .regular: return "Pretendard-Regular"
        case .medium: return "Pretendard-Medium"
        case .semiBold: return "Pretendard-SemiBold"
        case .bold: return "Pretendard-Bold"
        case .extraBold: return "Pretendard-ExtraBold"
        case .black: return "Pretendard-Black"
        }
    }
    
    var systemWeight: UIFont.Weight {
        switch self {
        case .thin: return .thin
        case .extraLight: return .ultraLight
        case .light: return .light
        case .regular: return .regular
        case .medium: return .medium
        case .semiBold: return .semibold
        case .bold: return .bold
        case .extraBold: return .heavy
        case .black: return .black
        }
    }
}

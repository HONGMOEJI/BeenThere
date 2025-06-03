//
//  UIColor+Theme.swift
//  BeenThere
//
//  앱 테마 색상 정의 (브랜드 + 그레이스케일)
//

import UIKit

extension UIColor {
    
    // MARK: - Primary Brand Colors (기존)
    static let primaryBlue = UIColor(red: 0.2, green: 0.6, blue: 1.0, alpha: 1.0)      // #3399FF
    static let primaryDark = UIColor(red: 0.1, green: 0.3, blue: 0.6, alpha: 1.0)      // #1A4D99
    static let primaryLight = UIColor(red: 0.8, green: 0.9, blue: 1.0, alpha: 1.0)     // #CCE5FF
    
    // MARK: - Accent Colors (기존)
    static let accentOrange = UIColor(red: 1.0, green: 0.6, blue: 0.2, alpha: 1.0)     // #FF9933
    static let accentGreen = UIColor(red: 0.2, green: 0.8, blue: 0.4, alpha: 1.0)      // #33CC66
    static let accentRed = UIColor(red: 1.0, green: 0.3, blue: 0.3, alpha: 1.0)        // #FF4D4D
    
    // MARK: - Semantic Colors (시스템 적응형, 기존)
    static let textPrimary = UIColor.label
    static let textSecondary = UIColor.secondaryLabel
    static let textTertiary = UIColor.tertiaryLabel
    static let textPlaceholder = UIColor.placeholderText
    
    static let backgroundPrimary = UIColor.systemBackground
    static let backgroundSecondary = UIColor.secondarySystemBackground
    static let backgroundTertiary = UIColor.tertiarySystemBackground
    
    static let separatorPrimary = UIColor.separator
    static let separatorSecondary = UIColor.opaqueSeparator
    
    // MARK: - Custom Adaptive Colors (기존)
    static let cardBackground = UIColor { traitCollection in
        return traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1.0)
            : UIColor.white
    }
    
    static let overlayBackground = UIColor { traitCollection in
        return traitCollection.userInterfaceStyle == .dark
            ? UIColor.black.withAlphaComponent(0.7)
            : UIColor.black.withAlphaComponent(0.5)
    }
    
    // MARK: - Status Colors (기존)
    static let successGreen = UIColor.systemGreen
    static let warningOrange = UIColor.systemOrange
    static let errorRed = UIColor.systemRed
    static let infoBlue = UIColor.systemBlue
    
    // MARK: - Border Colors (기존)
    static let borderLight = UIColor.systemGray5
    static let borderMedium = UIColor.systemGray4
    static let borderDark = UIColor.systemGray3
    
    
    // ────────────────────────────────────────────────────────────────────────────
    // MARK: - Grayscale Theme Colors (추가)

    /// 전체 화면 배경 (거의 검정에 가까운 진회색)
    static let themeBackground = UIColor(white: 0.10, alpha: 1)
    
    /// 텍스트 주 컬러 (연회색, 거의 흰색)
    static let themeTextPrimary = UIColor(white: 0.95, alpha: 1)
    
    /// 텍스트 보조 컬러 (회색 톤, placeholder 및 subtitle)
    static let themeTextSecondary = UIColor(white: 0.80, alpha: 1)
    
    /// 텍스트 플레이스홀더 컬러 (밑줄 및 placeholder용 아주 연한 회색)
    static let themeTextPlaceholder = UIColor(white: 0.60, alpha: 1)
    
    /// 텍스트 필드 밑줄 색상
    static let themeFieldUnderline = UIColor(white: 0.60, alpha: 1)
    
    /// 버튼 기본 배경 (등록/로그인/회원가입 버튼)
    static let buttonPrimaryBackground = UIColor(white: 0.85, alpha: 1)
    
    /// 버튼 기본 텍스트 컬러 (버튼 위 글씨)
    static let buttonPrimaryText = UIColor(white: 0.10, alpha: 1)  // 거의 검정
    
    /// 버튼 보조 스타일(투명 + 테두리) 테두리 색상
    static let buttonSecondaryBorder = UIColor(white: 0.60, alpha: 1)
    
    /// 버튼 보조 텍스트 컬러(투명 배경 버튼 글씨)
    static let buttonSecondaryText = UIColor(white: 0.90, alpha: 1)
    
    /// 에러 메시지 컬러 (연한 레드)
    static let themeError = UIColor(red: 0.80, green: 0.20, blue: 0.20, alpha: 1)
    
    /// 뷰 오버레이(모달 뒤 흐린 배경 등)
    static let themeOverlay = UIColor.black.withAlphaComponent(0.5)
    
    /// 구분선(color) – 입력 폼과 버튼 사이를 나누는 라인 색
    static let themeSeparator = UIColor(white: 0.60, alpha: 1)
    
    // ────────────────────────────────────────────────────────────────────────────
    // MARK: - MyRecords 화면 전용 색상 (새로 추가)
    
    /// 카드 배경 색상 (MyRecords의 기록 카드들)
    static let themeCardBackground = UIColor(white: 0.12, alpha: 1)
    
    /// 카드 테두리 색상
    static let themeCardBorder = UIColor(white: 0.18, alpha: 1)
    
    /// 날짜 선택 컨테이너 배경
    static let themeDateContainer = UIColor(white: 0.08, alpha: 1)
    
    /// 활성화된 날짜 버튼 배경 (오늘 버튼 등)
    static let themeDateActive = UIColor.primaryBlue.withAlphaComponent(0.15)
    
    /// 빈 상태 아이콘 색상
    static let themeEmptyIcon = UIColor(white: 0.40, alpha: 1)
    
    /// 별점 색상 (선택됨)
    static let themeRatingSelected = UIColor.systemYellow
    
    /// 별점 색상 (선택 안됨)
    static let themeRatingUnselected = UIColor(white: 0.50, alpha: 1)
    
    /// 태그 배경 색상
    static let themeTagBackground = UIColor.primaryBlue.withAlphaComponent(0.15)
    
    /// 태그 텍스트 색상
    static let themeTagText = UIColor.primaryBlue
    
    /// 그라데이션 오버레이 (카드 이미지 위)
    static let themeGradientTop = UIColor.clear
    static let themeGradientBottom = UIColor.black.withAlphaComponent(0.7)
    
    /// 로딩 인디케이터 색상
    static let themeLoading = UIColor(white: 0.70, alpha: 1)
    
    /// 새로고침 버튼 색상
    static let themeRefresh = UIColor.themeTextSecondary
    
    // ────────────────────────────────────────────────────────────────────────────
    // MARK: - RecordDetail 화면 전용 색상 (미리 추가)
    
    /// 상세 뷰 배경
    static let themeDetailBackground = UIColor(white: 0.08, alpha: 1)
    
    /// 편집/삭제 버튼 색상
    static let themeEditButton = UIColor.primaryBlue
    static let themeDeleteButton = UIColor.systemRed
    
    /// 이미지 갤러리 배경
    static let themeImageGallery = UIColor(white: 0.05, alpha: 1)
    
    /// 메타데이터 섹션 배경 (날짜, 별점, 태그 등)
    static let themeMetaBackground = UIColor(white: 0.12, alpha: 1)
}

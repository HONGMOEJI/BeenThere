//
//  AppConstants.swift
//  BeenThere
//
//  앱 전체에서 사용할 통합 상수 정의
//

import UIKit

struct AppConstants {
    
    // MARK: - Layout & Design
    struct Layout {
        // Margins
        static let smallMargin: CGFloat = 8
        static let defaultMargin: CGFloat = 16
        static let largeMargin: CGFloat = 24
        static let extraLargeMargin: CGFloat = 32
        
        // Corner Radius
        static let smallRadius: CGFloat = 8
        static let defaultRadius: CGFloat = 12
        static let largeRadius: CGFloat = 16
        
        // Border
        static let defaultBorderWidth: CGFloat = 1
        static let thickBorderWidth: CGFloat = 2
        
        // Component Heights
        static let buttonHeight: CGFloat = 52
        static let textFieldHeight: CGFloat = 52
        static let cellHeight: CGFloat = 80
        static let tabBarHeight: CGFloat = 88
        
        // Icon Sizes
        static let smallIconSize: CGFloat = 20
        static let defaultIconSize: CGFloat = 24
        static let largeIconSize: CGFloat = 32
        static let logoSize: CGFloat = 100
    }
    
    // MARK: - Animation
    struct Animation {
        static let fast: TimeInterval = 0.2
        static let normal: TimeInterval = 0.3
        static let slow: TimeInterval = 0.5
        static let splash: TimeInterval = 2.0
    }
    
    // MARK: - UserDefaults Keys
    struct UserDefaults {
        static let isFirstLaunch = "isFirstLaunch"
        static let userEmail = "userEmail"
        static let isAutoLoginEnabled = "isAutoLoginEnabled"
        static let selectedRegion = "selectedRegion"
        static let lastAppVersion = "lastAppVersion"
    }
    
    // MARK: - Notification Names
    struct Notifications {
        static let userDidLogin = Notification.Name("userDidLogin")
        static let userDidLogout = Notification.Name("userDidLogout")
        static let recordDidUpdate = Notification.Name("recordDidUpdate")
        static let userProfileDidUpdate = Notification.Name("userProfileDidUpdate")
    }
    
    // MARK: - Cell Identifiers
    struct CellIdentifiers {
        static let tourSpot = "TourSpotCell"
        static let record = "RecordCell"
        static let setting = "SettingCell"
        static let onboarding = "OnboardingCell"
    }
    
    // MARK: - System Images
    struct SystemImages {
        static let airplane = "airplane.circle.fill"
        static let heart = "heart"
        static let heartFill = "heart.fill"
        static let location = "location"
        static let locationFill = "location.fill"
        static let eye = "eye"
        static let eyeSlash = "eye.slash"
        static let xmark = "xmark"
        static let checkmarkSquare = "checkmark.square.fill"
        static let square = "square"
        static let house = "house"
        static let book = "book"
        static let gear = "gear"
        static let map = "map.fill"
        static let person = "person.crop.circle.fill"
    }
    
    // MARK: - Validation
    struct Validation {
        static let minPasswordLength = 6
        static let maxPasswordLength = 50
        static let minNameLength = 2
        static let maxNameLength = 20
        static let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    }
}

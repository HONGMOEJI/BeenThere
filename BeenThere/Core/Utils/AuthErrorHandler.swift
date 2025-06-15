//
//  AuthErrorHandler.swift
//  BeenThere
//
//  Firebase Auth 에러 처리 헬퍼
//

import Foundation
import FirebaseAuth

struct AuthErrorHandler {
    
    static func getErrorMessage(from error: Error) -> String {
        guard let authError = error as NSError? else {
            return "알 수 없는 오류가 발생했습니다."
        }
        
        switch authError.code {
        // 로그인 관련 에러
        case AuthErrorCode.wrongPassword.rawValue:
            return "비밀번호가 올바르지 않습니다."
        case AuthErrorCode.userNotFound.rawValue:
            return "존재하지 않는 계정입니다."
        case AuthErrorCode.userDisabled.rawValue:
            return "비활성화된 계정입니다."
        case AuthErrorCode.invalidEmail.rawValue:
            return "올바르지 않은 이메일 형식입니다."
        case AuthErrorCode.tooManyRequests.rawValue:
            return "너무 많은 요청이 발생했습니다. 잠시 후 다시 시도해주세요."
            
        // 회원가입 관련 에러
        case AuthErrorCode.emailAlreadyInUse.rawValue:
            return "이미 사용 중인 이메일입니다."
        case AuthErrorCode.weakPassword.rawValue:
            return "비밀번호가 너무 약합니다."
        case AuthErrorCode.operationNotAllowed.rawValue:
            return "이메일/비밀번호 계정이 비활성화되어 있습니다."
            
        // 네트워크 관련 에러
        case AuthErrorCode.networkError.rawValue:
            return "네트워크 연결을 확인해주세요."
        case AuthErrorCode.invalidAPIKey.rawValue:
            return "API 키가 유효하지 않습니다."
        case AuthErrorCode.appNotAuthorized.rawValue:
            return "앱이 Firebase 인증을 사용할 권한이 없습니다."
            
        // 비밀번호 재설정 관련
        case AuthErrorCode.invalidSender.rawValue:
            return "이메일 전송자가 유효하지 않습니다."
        case AuthErrorCode.invalidMessagePayload.rawValue:
            return "이메일 템플릿이 유효하지 않습니다."
            
        default:
            return "오류가 발생했습니다. 다시 시도해주세요."
        }
    }
}

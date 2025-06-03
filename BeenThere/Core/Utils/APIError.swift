//
//  APIError.swift
//  BeenThere
//
//  API 및 네트워크/캐시 관련 에러 정의
//  BeenThere/Core/Network/APIError.swift
//

import Foundation

enum APIError: LocalizedError {
    case invalidURL
    case invalidParameter(String)
    case networkError(Error)
    case httpError(Int)
    case apiError(String, String)
    case decodingError(Error)
    case noData
    case offlineMode
    case serverUnreachable
    case cacheError(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "유효하지 않은 URL입니다."
        case .invalidParameter(let message):
            return "잘못된 매개변수: \(message)"
        case .networkError(let error):
            return "네트워크 오류: \(error.localizedDescription)"
        case .httpError(let statusCode):
            return "HTTP 오류: \(statusCode)"
        case .apiError(let code, let message):
            return "API 오류 (\(code)): \(message)"
        case .decodingError(let error):
            return "데이터 파싱 오류: \(error.localizedDescription)"
        case .noData:
            return "데이터가 없습니다."
        case .offlineMode:
            return "오프라인 모드입니다. 캐시된 데이터만 사용 가능합니다."
        case .serverUnreachable:
            return "서버에 연결할 수 없습니다. 나중에 다시 시도해주세요."
        case .cacheError(let message):
            return "캐시 오류: \(message)"
        }
    }
}

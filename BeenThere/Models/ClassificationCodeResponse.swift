//
//  ClassificationCode.swift
//  BeenThere
//
//  관광지 분류체계 코드 API 응답 및 모델
//

import Foundation

struct ClassificationCodeResponse: Decodable {
    let response: TourAPIResult<ClassificationCode>
}

struct ClassificationCode: Decodable {
    let code: String
    let name: String
}
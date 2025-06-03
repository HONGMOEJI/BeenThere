//
//  AreaCode.swift
//  BeenThere
//
//  시/도 및 시/군/구 지역코드 API 응답 및 모델
//

import Foundation

struct AreaCodeResponse: Decodable {
    let response: TourAPIResult<AreaCode>
}

struct AreaCode: Decodable {
    let code: String
    let name: String
    let rnum: Int?
}
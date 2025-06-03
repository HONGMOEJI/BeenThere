//
//  LegalDistrictCode.swift
//  BeenThere
//
//  법정동 코드(행정구역) API 응답 및 모델
//

import Foundation

struct LegalDistrictCodeResponse: Decodable {
    let response: TourAPIResult<LegalDistrictCode>
}

struct LegalDistrictCode: Decodable {
    let code: String
    let name: String
}
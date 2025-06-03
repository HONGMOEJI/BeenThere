//
//  DetailInfo.swift
//  BeenThere
//
//  관광지 반복정보(세부정보) API 응답 및 모델
//

import Foundation

struct DetailInfoResponse: Decodable {
    let response: TourAPIResult<DetailInfo>
}
struct DetailInfo: Decodable {
    let contentid: String
    let infoname: String?
    let infotext: String?
    // 필요시 추가
}

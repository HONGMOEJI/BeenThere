//
//  TourSiteDetail.swift
//  BeenThere
//
//  관광지 상세정보 API 응답 및 모델
//

import Foundation

struct TourSiteDetailResponse: Decodable {
    let response: TourAPIResult<TourSiteDetail>
}

struct TourSiteDetail: Decodable {
    let contentid: String
    let title: String
    let overview: String?
    // 필요시 상세 필드 추가
}
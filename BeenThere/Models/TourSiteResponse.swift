//
//  TourSiteResponse.swift
//  BeenThere
//
//  관광지 리스트 API 응답 래퍼
//

import Foundation

struct TourSiteResponse: Decodable {
    let response: TourAPIResult<TourSiteItem>
}

struct TourAPIResult<T: Decodable>: Decodable {
    let header: TourAPIHeader?
    let body: TourAPIBody<T>
}

struct TourAPIHeader: Decodable {
    let resultCode: String?
    let resultMsg: String?
}

struct TourAPIBody<T: Decodable>: Decodable {
    let items: TourAPIItems<T>
    let numOfRows: Int?
    let pageNo: Int?
    let totalCount: Int?
}

struct TourAPIItems<T: Decodable>: Decodable {
    let item: [T]
}

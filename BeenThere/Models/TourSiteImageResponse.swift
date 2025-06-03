//
//  TourSiteImage.swift
//  BeenThere
//
//  관광지 이미지 정보 API 응답 및 모델
//

import Foundation

struct TourSiteImageResponse: Decodable {
    let response: TourAPIResult<TourSiteImage>
}

struct TourSiteImage: Decodable {
    let contentid: String
    let originimgurl: String?
    let smallimageurl: String?
    let serialnum: String?
}

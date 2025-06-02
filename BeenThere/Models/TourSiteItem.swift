//
//  TourSiteItem.swift
//  BeenThere
//
//  TourAPI 응답으로 받아온 관광지 정보를 담는 모델
//  - locationBasedList2 또는 areaBasedList2 JSON 데이터를 디코딩
//  BeenThere/Models/TourSiteItem.swift
//

import Foundation

/// TourAPI locationBasedList2 / areaBasedList2 응답 모델
struct TourSiteItem: Decodable {
    /// TourAPI에서 제공하는 고유 콘텐츠 ID
    let contentid: String
    /// 관광지 제목
    let title: String
    /// 썸네일 이미지 URL (옵셔널)
    let firstimage2: String?
    /// 관광지 경도 (WGS84, 문자열 형태)
    let mapx: String?
    /// 관광지 위도 (WGS84, 문자열 형태)
    let mapy: String?
    /// 현재 위치에서 해당 관광지까지의 거리(m 단위, locationBasedList2에서만 제공)
    let dist: Double?
    /// 관광지 정보의 최종 수정 시간 (YYYYMMDDhhmmss)
    let modifiedtime: String?

    enum CodingKeys: String, CodingKey {
        case contentid
        case title
        case firstimage2
        case mapx
        case mapy
        case dist
        case modifiedtime
    }
}

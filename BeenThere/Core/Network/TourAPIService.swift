//
//  TourAPIService.swift
//  BeenThere
//
//  TourAPI (한국관광공사) 호출을 담당하는 서비스 레이어
//  - areaBasedList2 (지역/카테고리/키워드 기반 조회)
//  - locationBasedList2 (위치 기반 조회)
//  BeenThere/Core/Network/TourAPIService.swift
//

import Foundation
import CoreLocation

/// TourAPIService: TourAPI 관련 모든 요청을 처리하는 싱글톤 클래스
final class TourAPIService {
    static let shared = TourAPIService()
    private init() {}

    private let baseURL = APIConstants.TourAPI.baseURL              // "http://apis.data.go.kr/B551011/KorService2"
    private let serviceKey = APIConstants.TourAPI.serviceKey
    private let mobileOS = APIConstants.TourAPI.Values.mobileOS    // "iOS"
    private let mobileApp = APIConstants.TourAPI.Values.mobileApp  // "BeenThere"
    private let responseType = APIConstants.TourAPI.Values.responseType // "json"

    // MARK: 1) 일반(지역/카테고리/키워드) 기반 조회
    func fetchSites(
        areaCode: Int?,
        sigunguCode: Int?,
        cat1: String?,
        cat2: String?,
        cat3: String?,
        keyword: String?,
        pageNo: Int = APIConstants.TourAPI.Values.firstPage,
        numOfRows: Int = APIConstants.TourAPI.Values.defaultRows,
        contentTypeId: Int = APIConstants.ContentTypes.tourSpot,
        arrange: String = "C"  // 수정일순
    ) async throws -> [TourSiteItem] {
        guard var components = URLComponents(string: baseURL + APIConstants.TourAPI.Endpoints.areaBasedList)
        else { return [] }

        var queryItems: [URLQueryItem] = [
            .init(name: APIConstants.TourAPI.Parameters.serviceKey, value: serviceKey),
            .init(name: APIConstants.TourAPI.Parameters.mobileOS, value: mobileOS),
            .init(name: APIConstants.TourAPI.Parameters.mobileApp, value: mobileApp),
            .init(name: APIConstants.TourAPI.Parameters.type, value: responseType),
            .init(name: APIConstants.TourAPI.Parameters.contentTypeId, value: "\(contentTypeId)"),
            .init(name: "arrange", value: arrange),
            .init(name: APIConstants.TourAPI.Parameters.pageNo, value: "\(pageNo)"),
            .init(name: APIConstants.TourAPI.Parameters.numOfRows, value: "\(numOfRows)")
        ]

        if let aCode = areaCode {
            queryItems.append(.init(name: APIConstants.TourAPI.Parameters.areaCode, value: "\(aCode)"))
        }
        if let sCode = sigunguCode {
            queryItems.append(.init(name: "sigunguCode", value: "\(sCode)"))
        }
        if let c1 = cat1 {
            queryItems.append(.init(name: "cat1", value: c1))
        }
        if let c2 = cat2 {
            queryItems.append(.init(name: "cat2", value: c2))
        }
        if let c3 = cat3 {
            queryItems.append(.init(name: "cat3", value: c3))
        }
        if let kw = keyword, !kw.isEmpty {
            queryItems.append(.init(
                name: APIConstants.TourAPI.Parameters.keyword,
                value: kw.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            ))
        }

        components.queryItems = queryItems
        guard let url = components.url else { return [] }

        let (data, _) = try await URLSession.shared.data(from: url)
        let decoded = try JSONDecoder().decode(TourSiteResponse.self, from: data)
        return decoded.response.body.items.item
    }

    // MARK: 2) 위치 기반 조회 (내 주변)
    func fetchNearbySites(
        location: CLLocation,
        radius: Int,
        contentTypeId: Int = APIConstants.ContentTypes.tourSpot,
        arrange: String = "E",  // 거리순
        pageNo: Int = APIConstants.TourAPI.Values.firstPage,
        numOfRows: Int = APIConstants.TourAPI.Values.defaultRows
    ) async throws -> [TourSiteItem] {
        guard var components = URLComponents(string: baseURL + APIConstants.TourAPI.Endpoints.locationBasedList)
        else { return [] }

        let queryItems: [URLQueryItem] = [
            .init(name: APIConstants.TourAPI.Parameters.serviceKey, value: serviceKey),
            .init(name: APIConstants.TourAPI.Parameters.mobileOS, value: mobileOS),
            .init(name: APIConstants.TourAPI.Parameters.mobileApp, value: mobileApp),
            .init(name: APIConstants.TourAPI.Parameters.type, value: responseType),
            .init(name: "mapX", value: "\(location.coordinate.longitude)"),
            .init(name: "mapY", value: "\(location.coordinate.latitude)"),
            .init(name: "radius", value: "\(radius)"),
            .init(name: APIConstants.TourAPI.Parameters.contentTypeId, value: "\(contentTypeId)"),
            .init(name: "arrange", value: arrange),
            .init(name: APIConstants.TourAPI.Parameters.pageNo, value: "\(pageNo)"),
            .init(name: APIConstants.TourAPI.Parameters.numOfRows, value: "\(numOfRows)")
        ]

        components.queryItems = queryItems
        guard let url = components.url else { return [] }

        let (data, _) = try await URLSession.shared.data(from: url)
        let decoded = try JSONDecoder().decode(TourSiteResponse.self, from: data)
        return decoded.response.body.items.item
    }
}

/// TourAPI 응답 디코딩용 최상위 구조체
struct TourSiteResponse: Decodable {
    struct ResponseNested: Decodable {
        let body: Body
        struct Body: Decodable {
            struct ItemsContainer: Decodable {
                let item: [TourSiteItem]
            }
            let items: ItemsContainer
            let totalCount: Int
            let pageNo: Int
        }
    }
    let response: ResponseNested
}

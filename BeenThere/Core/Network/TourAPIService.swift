//
//  TourAPIService.swift
//  BeenThere
//
//  한국관광공사 TourAPI 호출을 담당하는 서비스 레이어
//  - 지역/위치/키워드 기반 관광지 정보 조회 (페이지네이션 메타 포함)
//  - 관광지 상세 정보 및 이미지 조회
//  - 지역/분류 코드 및 법정동 코드 조회
//  - 관광정보 동기화 기능 제공
//

import Foundation
import CoreLocation

// MARK: - Meta 포함 결과 구조체
struct TourSiteListMeta {
    let items: [TourSiteItem]
    let pageNo: Int
    let numOfRows: Int
    let totalCount: Int
}

// MARK: - TourAPIService
final class TourAPIService {
    // MARK: - Properties

    static let shared = TourAPIService()
    private let baseURL = APIConstants.TourAPI.baseURL
    private let serviceKey = APIConstants.TourAPI.serviceKey // 디코딩된(원본) 키!
    private let mobileOS = APIConstants.TourAPI.Values.mobileOS
    private let mobileApp = APIConstants.TourAPI.Values.mobileApp
    private let responseType = APIConstants.TourAPI.Values.responseType
    private let cacheService = APICache.shared

    private lazy var session: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 15.0
        config.timeoutIntervalForResource = 30.0
        config.waitsForConnectivity = true
        return URLSession(configuration: config)
    }()
    private init() {}

    // MARK: - 쿼리 조합 유틸 (serviceKey만 강제 인코딩)
    private func percentEncodedQuery(_ items: [URLQueryItem]) -> String {
        items.map { item in
            let encValue: String
            if item.name == "serviceKey" {
                encValue = (item.value ?? "").forTourAPIKey
            } else {
                encValue = item.value?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            }
            return "\(item.name)=\(encValue)"
        }
        .joined(separator: "&")
    }

    // MARK: - 1) 일반(지역/카테고리/키워드) 기반 조회 (areaBasedList2) + 메타
    func fetchSitesWithMeta(
        areaCode: Int?,
        sigunguCode: Int?,
        cat1: String? = nil,
        cat2: String? = nil,
        cat3: String? = nil,
        keyword: String? = nil,
        pageNo: Int = APIConstants.TourAPI.Values.firstPage,
        numOfRows: Int = APIConstants.TourAPI.Values.defaultRows,
        contentTypeId: Int = APIConstants.ContentTypes.tourSpot,
        arrange: String = APIConstants.TourAPI.ArrangeOptions.modifyDate,
        useCache: Bool = true
    ) async throws -> TourSiteListMeta {
        var urlComponents = try createUrlComponents(endpoint: APIConstants.TourAPI.Endpoints.areaBasedList)
        var queryItems: [URLQueryItem] = createBaseQueryItems(
            contentTypeId: contentTypeId,
            pageNo: pageNo,
            numOfRows: numOfRows
        )
        queryItems.append(contentsOf: [
            .init(name: "arrange", value: arrange),
            .init(name: "listYN", value: "Y"),
            .init(name: "defaultYN", value: "Y")
        ])
        if let aCode = areaCode {
            queryItems.append(.init(name: APIConstants.TourAPI.Parameters.areaCode, value: "\(aCode)"))
        }
        if let sCode = sigunguCode {
            queryItems.append(.init(name: APIConstants.TourAPI.Parameters.sigunguCode, value: "\(sCode)"))
        }
        if let c1 = cat1 {
            queryItems.append(.init(name: APIConstants.TourAPI.Parameters.cat1, value: c1))
        }
        if let c2 = cat2 {
            queryItems.append(.init(name: APIConstants.TourAPI.Parameters.cat2, value: c2))
        }
        if let c3 = cat3 {
            queryItems.append(.init(name: APIConstants.TourAPI.Parameters.cat3, value: c3))
        }
        if let kw = keyword, !kw.isEmpty {
            queryItems.append(.init(
                name: APIConstants.TourAPI.Parameters.keyword,
                value: kw
            ))
        }
        urlComponents.percentEncodedQuery = percentEncodedQuery(queryItems)
        guard let url = urlComponents.url else {
            throw APIError.invalidURL
        }
        return try await performRequestWithMeta(url: url, useCache: useCache)
    }

    // MARK: - 2) 위치 기반 조회 (locationBasedList2) + 메타
    func fetchNearbySitesWithMeta(
        location: CLLocation,
        radius: Int,
        contentTypeId: Int? = APIConstants.ContentTypes.tourSpot,
        arrange: String = APIConstants.TourAPI.ArrangeOptions.distance,
        pageNo: Int = APIConstants.TourAPI.Values.firstPage,
        numOfRows: Int = APIConstants.TourAPI.Values.defaultRows,
        useCache: Bool = true
    ) async throws -> TourSiteListMeta {
        var urlComponents = try createUrlComponents(endpoint: APIConstants.TourAPI.Endpoints.locationBasedList)
        var queryItems = createBaseQueryItems(
            contentTypeId: contentTypeId,
            pageNo: pageNo,
            numOfRows: numOfRows
        )
        queryItems.append(contentsOf: [
            .init(name: APIConstants.TourAPI.Parameters.mapX, value: "\(location.coordinate.longitude)"),
            .init(name: APIConstants.TourAPI.Parameters.mapY, value: "\(location.coordinate.latitude)"),
            .init(name: APIConstants.TourAPI.Parameters.radius, value: "\(radius)"),
            .init(name: "arrange", value: arrange)
        ])
        urlComponents.percentEncodedQuery = percentEncodedQuery(queryItems)
        guard let url = urlComponents.url else {
            throw APIError.invalidURL
        }
        return try await performRequestWithMeta(url: url, useCache: useCache)
    }

    // MARK: - 3) 키워드 검색 (searchKeyword2) + 메타
    func searchTourSitesWithMeta(
        keyword: String,
        areaCode: Int? = nil,
        contentTypeId: Int = APIConstants.ContentTypes.tourSpot,
        arrange: String = APIConstants.TourAPI.ArrangeOptions.popularity,
        pageNo: Int = APIConstants.TourAPI.Values.firstPage,
        numOfRows: Int = APIConstants.TourAPI.Values.defaultRows,
        useCache: Bool = true
    ) async throws -> TourSiteListMeta {
        guard !keyword.isEmpty else {
            throw APIError.invalidParameter("키워드가 필요합니다")
        }
        var urlComponents = try createUrlComponents(endpoint: APIConstants.TourAPI.Endpoints.searchKeyword)
        var queryItems = createBaseQueryItems(
            contentTypeId: contentTypeId,
            pageNo: pageNo,
            numOfRows: numOfRows
        )
        queryItems.append(contentsOf: [
            .init(name: APIConstants.TourAPI.Parameters.keyword, value: keyword),
            .init(name: "arrange", value: arrange),
            .init(name: "listYN", value: "Y"),
            .init(name: "defaultYN", value: "Y")
        ])
        if let aCode = areaCode {
            queryItems.append(.init(name: APIConstants.TourAPI.Parameters.areaCode, value: "\(aCode)"))
        }
        urlComponents.percentEncodedQuery = percentEncodedQuery(queryItems)
        guard let url = urlComponents.url else {
            throw APIError.invalidURL
        }
        return try await performRequestWithMeta(url: url, useCache: useCache)
    }

    // MARK: - 4) 상세 정보 조회
    func fetchDetailInfo(
        contentId: String,
        contentTypeId: Int = APIConstants.ContentTypes.tourSpot,
        useCache: Bool = true
    ) async throws -> TourSiteDetail? {
        var urlComponents = try createUrlComponents(endpoint: APIConstants.TourAPI.Endpoints.detailCommon)
        var queryItems = createBaseQueryItems(contentTypeId: contentTypeId)
        queryItems.append(contentsOf: [
            .init(name: APIConstants.TourAPI.Parameters.contentId, value: contentId),
            .init(name: "defaultYN", value: "Y"),
            .init(name: "firstImageYN", value: "Y"),
            .init(name: "areacodeYN", value: "Y"),
            .init(name: "catcodeYN", value: "Y"),
            .init(name: "addrinfoYN", value: "Y"),
            .init(name: "mapinfoYN", value: "Y"),
            .init(name: "overviewYN", value: "Y")
        ])
        urlComponents.percentEncodedQuery = percentEncodedQuery(queryItems)
        guard let url = urlComponents.url else {
            throw APIError.invalidURL
        }

        if useCache, let cachedData = cacheService.retrieveData(for: url.absoluteString) {
            do {
                let decoded = try JSONDecoder().decode(TourSiteDetailResponse.self, from: cachedData)
                return decoded.response.body.items.item.first
            } catch {
                print("캐시 데이터 디코딩 실패: \(error)")
            }
        }
        do {
            let (data, response) = try await retryableDataTask(for: url)
            if let httpResponse = response as? HTTPURLResponse {
                guard 200...299 ~= httpResponse.statusCode else {
                    throw APIError.httpError(httpResponse.statusCode)
                }
            }
            let decoded = try JSONDecoder().decode(TourSiteDetailResponse.self, from: data)
            if let errorCode = decoded.response.header?.resultCode, errorCode != "0000" {
                throw APIError.apiError(errorCode, decoded.response.header?.resultMsg ?? "알 수 없는 오류")
            }
            if useCache {
                cacheService.cache(data, for: url.absoluteString, cost: data.count)
            }
            return decoded.response.body.items.item.first
        } catch let error as APIError {
            throw error
        } catch {
            print("상세 정보 조회 실패: \(error)")
            throw APIError.networkError(error)
        }
    }

    // MARK: - 5) 이미지 정보 조회
    func fetchImages(
        contentId: String,
        contentTypeId: Int = APIConstants.ContentTypes.tourSpot,
        useCache: Bool = true
    ) async throws -> [TourSiteImage] {
        var urlComponents = try createUrlComponents(endpoint: APIConstants.TourAPI.Endpoints.detailImage)
        var queryItems = createBaseQueryItems(contentTypeId: contentTypeId)
        queryItems.append(contentsOf: [
            .init(name: APIConstants.TourAPI.Parameters.contentId, value: contentId),
            .init(name: "imageYN", value: "Y")
        ])
        urlComponents.percentEncodedQuery = percentEncodedQuery(queryItems)
        guard let url = urlComponents.url else {
            throw APIError.invalidURL
        }

        if useCache, let cachedData = cacheService.retrieveData(for: url.absoluteString) {
            do {
                let decoded = try JSONDecoder().decode(TourSiteImageResponse.self, from: cachedData)
                return decoded.response.body.items.item
            } catch {
                print("캐시 데이터 디코딩 실패: \(error)")
            }
        }
        do {
            let (data, response) = try await retryableDataTask(for: url)
            if let httpResponse = response as? HTTPURLResponse {
                guard 200...299 ~= httpResponse.statusCode else {
                    throw APIError.httpError(httpResponse.statusCode)
                }
            }
            let decoded = try JSONDecoder().decode(TourSiteImageResponse.self, from: data)
            if let errorCode = decoded.response.header?.resultCode, errorCode != "0000" {
                throw APIError.apiError(errorCode, decoded.response.header?.resultMsg ?? "알 수 없는 오류")
            }
            if useCache {
                cacheService.cache(data, for: url.absoluteString, cost: data.count)
            }
            return decoded.response.body.items.item
        } catch let error as APIError {
            throw error
        } catch {
            print("이미지 정보 조회 실패: \(error)")
            throw APIError.networkError(error)
        }
    }

    // MARK: - 6) 지역 코드 조회 (areaCode2)
    func fetchAreaCodes(areaCode: Int? = nil, useCache: Bool = true) async throws -> [AreaCode] {
        var urlComponents = try createUrlComponents(endpoint: APIConstants.TourAPI.Endpoints.areaCode)
        var queryItems: [URLQueryItem] = [
            .init(name: "serviceKey", value: serviceKey),
            .init(name: APIConstants.TourAPI.Parameters.mobileOS, value: mobileOS),
            .init(name: APIConstants.TourAPI.Parameters.mobileApp, value: mobileApp),
            .init(name: APIConstants.TourAPI.Parameters.type, value: responseType),
            .init(name: APIConstants.TourAPI.Parameters.numOfRows, value: "100")
        ]
        if let aCode = areaCode {
            queryItems.append(.init(name: APIConstants.TourAPI.Parameters.areaCode, value: "\(aCode)"))
        }
        urlComponents.percentEncodedQuery = percentEncodedQuery(queryItems)
        guard let url = urlComponents.url else {
            throw APIError.invalidURL
        }
        if useCache, let cachedData = cacheService.retrieveData(for: url.absoluteString) {
            do {
                let decoded = try JSONDecoder().decode(AreaCodeResponse.self, from: cachedData)
                return decoded.response.body.items.item
            } catch {
                print("캐시 데이터 디코딩 실패: \(error)")
            }
        }
        do {
            let (data, response) = try await retryableDataTask(for: url)
            if let httpResponse = response as? HTTPURLResponse {
                guard 200...299 ~= httpResponse.statusCode else {
                    throw APIError.httpError(httpResponse.statusCode)
                }
            }
            let decoded = try JSONDecoder().decode(AreaCodeResponse.self, from: data)
            if let errorCode = decoded.response.header?.resultCode, errorCode != "0000" {
                throw APIError.apiError(errorCode, decoded.response.header?.resultMsg ?? "알 수 없는 오류")
            }
            if useCache {
                cacheService.cache(data, for: url.absoluteString, cost: data.count)
            }
            return decoded.response.body.items.item
        } catch let error as APIError {
            throw error
        } catch {
            print("지역 코드 조회 실패: \(error)")
            throw APIError.networkError(error)
        }
    }

    // MARK: - 7) 반복정보 조회 (detailInfo2)
    func fetchDetailInfo2(
        contentId: String,
        contentTypeId: Int,
        useCache: Bool = true
    ) async throws -> [DetailInfo] {
        var urlComponents = try createUrlComponents(endpoint: APIConstants.TourAPI.Endpoints.detailInfo)
        var queryItems = createBaseQueryItems(contentTypeId: contentTypeId)
        queryItems.append(.init(name: APIConstants.TourAPI.Parameters.contentId, value: contentId))
        urlComponents.percentEncodedQuery = percentEncodedQuery(queryItems)
        guard let url = urlComponents.url else {
            throw APIError.invalidURL
        }
        if useCache, let cachedData = cacheService.retrieveData(for: url.absoluteString) {
            do {
                let decoded = try JSONDecoder().decode(DetailInfoResponse.self, from: cachedData)
                return decoded.response.body.items.item
            } catch {
                print("캐시 데이터 디코딩 실패: \(error)")
            }
        }
        do {
            let (data, response) = try await retryableDataTask(for: url)
            if let httpResponse = response as? HTTPURLResponse {
                guard 200...299 ~= httpResponse.statusCode else {
                    throw APIError.httpError(httpResponse.statusCode)
                }
            }
            let decoded = try JSONDecoder().decode(DetailInfoResponse.self, from: data)
            if let errorCode = decoded.response.header?.resultCode, errorCode != "0000" {
                throw APIError.apiError(errorCode, decoded.response.header?.resultMsg ?? "알 수 없는 오류")
            }
            if useCache {
                cacheService.cache(data, for: url.absoluteString, cost: data.count)
            }
            return decoded.response.body.items.item
        } catch let error as APIError {
            throw error
        } catch {
            print("반복정보 조회 실패: \(error)")
            throw APIError.networkError(error)
        }
    }

    // MARK: - 8) 분류체계 코드 조회 (lclsSystmCode2)
    func fetchClassificationCodes(dscCd: String? = nil, useCache: Bool = true) async throws -> [ClassificationCode] {
        var urlComponents = try createUrlComponents(endpoint: APIConstants.TourAPI.Endpoints.lclsSystmCode)
        var queryItems: [URLQueryItem] = [
            .init(name: "serviceKey", value: serviceKey),
            .init(name: APIConstants.TourAPI.Parameters.mobileOS, value: mobileOS),
            .init(name: APIConstants.TourAPI.Parameters.mobileApp, value: mobileApp),
            .init(name: APIConstants.TourAPI.Parameters.type, value: responseType)
        ]
        if let code = dscCd {
            queryItems.append(.init(name: "dscCd", value: code))
        }
        urlComponents.percentEncodedQuery = percentEncodedQuery(queryItems)
        guard let url = urlComponents.url else {
            throw APIError.invalidURL
        }
        if useCache, let cachedData = cacheService.retrieveData(for: url.absoluteString) {
            do {
                let decoded = try JSONDecoder().decode(ClassificationCodeResponse.self, from: cachedData)
                return decoded.response.body.items.item
            } catch {
                print("캐시 데이터 디코딩 실패: \(error)")
            }
        }
        do {
            let (data, response) = try await retryableDataTask(for: url)
            if let httpResponse = response as? HTTPURLResponse {
                guard 200...299 ~= httpResponse.statusCode else {
                    throw APIError.httpError(httpResponse.statusCode)
                }
            }
            let decoded = try JSONDecoder().decode(ClassificationCodeResponse.self, from: data)
            if let errorCode = decoded.response.header?.resultCode, errorCode != "0000" {
                throw APIError.apiError(errorCode, decoded.response.header?.resultMsg ?? "알 수 없는 오류")
            }
            if useCache {
                cacheService.cache(data, for: url.absoluteString, cost: data.count)
            }
            return decoded.response.body.items.item
        } catch let error as APIError {
            throw error
        } catch {
            print("분류체계 코드 조회 실패: \(error)")
            throw APIError.networkError(error)
        }
    }

    // MARK: - 9) 관광정보 동기화 목록 조회 (areaBasedSyncList2)
    func fetchSyncList(
        syncDate: String,
        areaCode: Int? = nil,
        contentTypeId: Int? = nil,
        modifiedTime: String? = nil,
        pageNo: Int = APIConstants.TourAPI.Values.firstPage,
        numOfRows: Int = APIConstants.TourAPI.Values.defaultRows
    ) async throws -> [TourSiteItem] {
        var urlComponents = try createUrlComponents(endpoint: APIConstants.TourAPI.Endpoints.areaBasedSyncList)
        var queryItems: [URLQueryItem] = [
            .init(name: "serviceKey", value: serviceKey),
            .init(name: APIConstants.TourAPI.Parameters.mobileOS, value: mobileOS),
            .init(name: APIConstants.TourAPI.Parameters.mobileApp, value: mobileApp),
            .init(name: APIConstants.TourAPI.Parameters.type, value: responseType),
            .init(name: "syncDate", value: syncDate),
            .init(name: APIConstants.TourAPI.Parameters.pageNo, value: "\(pageNo)"),
            .init(name: APIConstants.TourAPI.Parameters.numOfRows, value: "\(numOfRows)")
        ]
        if let code = areaCode {
            queryItems.append(.init(name: APIConstants.TourAPI.Parameters.areaCode, value: "\(code)"))
        }
        if let type = contentTypeId {
            queryItems.append(.init(name: APIConstants.TourAPI.Parameters.contentTypeId, value: "\(type)"))
        }
        if let time = modifiedTime {
            queryItems.append(.init(name: "modifiedTime", value: time))
        }
        urlComponents.percentEncodedQuery = percentEncodedQuery(queryItems)
        guard let url = urlComponents.url else {
            throw APIError.invalidURL
        }
        return try await performRequest(url: url, useCache: false)
    }

    // MARK: - 10) 법정동코드 조회 (ldongCode2)
    func fetchLegalDistrictCodes(regionCode: String? = nil, useCache: Bool = true) async throws -> [LegalDistrictCode] {
        var urlComponents = try createUrlComponents(endpoint: APIConstants.TourAPI.Endpoints.ldongCode)
        var queryItems: [URLQueryItem] = [
            .init(name: "serviceKey", value: serviceKey),
            .init(name: APIConstants.TourAPI.Parameters.mobileOS, value: mobileOS),
            .init(name: APIConstants.TourAPI.Parameters.mobileApp, value: mobileApp),
            .init(name: APIConstants.TourAPI.Parameters.type, value: responseType),
            .init(name: APIConstants.TourAPI.Parameters.numOfRows, value: "100")
        ]
        if let code = regionCode {
            queryItems.append(.init(name: "regionCode", value: code))
        }
        urlComponents.percentEncodedQuery = percentEncodedQuery(queryItems)
        guard let url = urlComponents.url else {
            throw APIError.invalidURL
        }
        if useCache, let cachedData = cacheService.retrieveData(for: url.absoluteString) {
            do {
                let decoded = try JSONDecoder().decode(LegalDistrictCodeResponse.self, from: cachedData)
                return decoded.response.body.items.item
            } catch {
                print("캐시 데이터 디코딩 실패: \(error)")
            }
        }
        do {
            let (data, response) = try await retryableDataTask(for: url)
            if let httpResponse = response as? HTTPURLResponse {
                guard 200...299 ~= httpResponse.statusCode else {
                    throw APIError.httpError(httpResponse.statusCode)
                }
            }
            let decoded = try JSONDecoder().decode(LegalDistrictCodeResponse.self, from: data)
            if let errorCode = decoded.response.header?.resultCode, errorCode != "0000" {
                throw APIError.apiError(errorCode, decoded.response.header?.resultMsg ?? "알 수 없는 오류")
            }
            if useCache {
                cacheService.cache(data, for: url.absoluteString, cost: data.count)
            }
            return decoded.response.body.items.item
        } catch let error as APIError {
            throw error
        } catch {
            print("법정동코드 조회 실패: \(error)")
            throw APIError.networkError(error)
        }
    }

    // MARK: - Private Helper Methods

    private func createUrlComponents(endpoint: String) throws -> URLComponents {
        guard let components = URLComponents(string: baseURL + endpoint) else {
            throw APIError.invalidURL
        }
        return components
    }

    /// 기본 쿼리 아이템 생성 (serviceKey는 디코딩된 원본, 인코딩은 percentEncodedQuery에서)
    private func createBaseQueryItems(
        contentTypeId: Int? = nil,
        pageNo: Int = APIConstants.TourAPI.Values.firstPage,
        numOfRows: Int = APIConstants.TourAPI.Values.defaultRows
    ) -> [URLQueryItem] {
        var queryItems: [URLQueryItem] = [
            .init(name: "serviceKey", value: serviceKey),
            .init(name: APIConstants.TourAPI.Parameters.mobileOS, value: mobileOS),
            .init(name: APIConstants.TourAPI.Parameters.mobileApp, value: mobileApp),
            .init(name: APIConstants.TourAPI.Parameters.type, value: responseType),
            .init(name: APIConstants.TourAPI.Parameters.pageNo, value: "\(pageNo)"),
            .init(name: APIConstants.TourAPI.Parameters.numOfRows, value: "\(numOfRows)")
        ]
        if let typeId = contentTypeId {
            queryItems.append(.init(name: APIConstants.TourAPI.Parameters.contentTypeId, value: "\(typeId)"))
        }
        return queryItems
    }

    private func retryableDataTask(for url: URL, retries: Int = 2) async throws -> (Data, URLResponse) {
        var currentRetry = 0
        var lastError: Error?
        let request = URLRequest(url: url)
        let startTime = Date()
        NetworkLogger.shared.logRequest(request)
        repeat {
            do {
                let (data, response) = try await session.data(for: request)
                NetworkLogger.shared.logResponse(data: data, response: response, error: nil, startTime: startTime)
                return (data, response)
            } catch {
                NetworkLogger.shared.logResponse(data: nil, response: nil, error: error, startTime: startTime)
                lastError = error
                currentRetry += 1
                if currentRetry <= retries {
                    try await Task.sleep(nanoseconds: UInt64(0.5 * Double(currentRetry) * 1_000_000_000))
                }
            }
        } while currentRetry <= retries
        throw lastError ?? APIError.networkError(NSError(domain: "TourAPIService", code: -1, userInfo: nil))
    }

    // 메타 포함 요청
    private func performRequestWithMeta(url: URL, useCache: Bool = true) async throws -> TourSiteListMeta {
        if useCache, let cachedData = cacheService.retrieveData(for: url.absoluteString) {
            do {
                let decoded = try JSONDecoder().decode(TourSiteResponse.self, from: cachedData)
                let body = decoded.response.body
                return TourSiteListMeta(
                    items: body.items.item,
                    pageNo: body.pageNo ?? 1,
                    numOfRows: body.numOfRows ?? 10,
                    totalCount: body.totalCount ?? 0
                )
            } catch {
                print("캐시 데이터 디코딩 실패: \(error)")
            }
        }
        do {
            let (data, response) = try await retryableDataTask(for: url)
            if let httpResponse = response as? HTTPURLResponse {
                guard 200...299 ~= httpResponse.statusCode else {
                    throw APIError.httpError(httpResponse.statusCode)
                }
            }
            let decoded = try JSONDecoder().decode(TourSiteResponse.self, from: data)
            if let errorCode = decoded.response.header?.resultCode,
               errorCode != "0000" {
                throw APIError.apiError(errorCode, decoded.response.header?.resultMsg ?? "알 수 없는 오류")
            }
            if useCache {
                cacheService.cache(data, for: url.absoluteString, cost: data.count)
            }
            let body = decoded.response.body
            return TourSiteListMeta(
                items: body.items.item,
                pageNo: body.pageNo ?? 1,
                numOfRows: body.numOfRows ?? 10,
                totalCount: body.totalCount ?? 0
            )
        } catch let error as APIError {
            throw error
        } catch {
            print("API 요청 실패: \(error)")
            throw APIError.networkError(error)
        }
    }

    // 기존 performRequest: 메타 필요없는 배열 반환용
    private func performRequest(url: URL, useCache: Bool = true) async throws -> [TourSiteItem] {
        if useCache, let cachedData = cacheService.retrieveData(for: url.absoluteString) {
            do {
                let decoded = try JSONDecoder().decode(TourSiteResponse.self, from: cachedData)
                return decoded.response.body.items.item
            } catch {
                print("캐시 데이터 디코딩 실패: \(error)")
            }
        }
        do {
            let (data, response) = try await retryableDataTask(for: url)
            if let httpResponse = response as? HTTPURLResponse {
                guard 200...299 ~= httpResponse.statusCode else {
                    throw APIError.httpError(httpResponse.statusCode)
                }
            }
            let decoded = try JSONDecoder().decode(TourSiteResponse.self, from: data)
            if let errorCode = decoded.response.header?.resultCode,
               errorCode != "0000" {
                throw APIError.apiError(errorCode, decoded.response.header?.resultMsg ?? "알 수 없는 오류")
            }
            if useCache {
                cacheService.cache(data, for: url.absoluteString, cost: data.count)
            }
            return decoded.response.body.items.item
        } catch let error as APIError {
            throw error
        } catch {
            print("API 요청 실패: \(error)")
            throw APIError.networkError(error)
        }
    }
}

// MARK: - TourAPIKey 인코딩용
extension String {
    var forTourAPIKey: String {
        self
            .replacingOccurrences(of: "/", with: "%2F")
            .replacingOccurrences(of: "+", with: "%2B")
            .replacingOccurrences(of: "=", with: "%3D")
    }
}

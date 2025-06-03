import Foundation

// MARK: - 상세 정보 API 최상위 응답 구조
struct TourSiteDetailResponse: Codable {
    let response: TourSiteDetailInnerResponse
}

struct TourSiteDetailInnerResponse: Codable {
    let header: TourAPIResponseHeader?
    let body: TourSiteDetailBody
}

struct TourAPIResponseHeader: Codable {
    let resultCode: String?
    let resultMsg: String?
}

struct TourSiteDetailBody: Codable {
    let items: TourSiteDetailItems
    let numOfRows: Int?
    let pageNo: Int?
    let totalCount: Int?
}

struct TourSiteDetailItems: Codable {
    let item: [TourSiteDetail]
}

// MARK: - 실제 상세 관광지 정보 모델
struct TourSiteDetail: Codable, Identifiable, Hashable {
    var id: String { contentid }
    
    // 기본 필드
    let contentid: String
    let contenttypeid: String?
    let title: String
    let createdtime: String?
    let modifiedtime: String?
    let tel: String?
    let telname: String?
    let homepage: String?
    let firstimage: String?
    let firstimage2: String?
    let cpyrhtDivCd: String?
    let areacode: String?
    let sigungucode: String?
    let lDongRegnCd: String?
    let lDongSignguCd: String?
    let lclsSystm1: String?
    let lclsSystm2: String?
    let lclsSystm3: String?
    let cat1: String?
    let cat2: String?
    let cat3: String?
    let addr1: String?
    let addr2: String?
    let zipcode: String?
    let mapx: String?
    let mapy: String?
    let mlevel: String?
    let overview: String?
    
    // MARK: - CodingKeys (필요시 맞춤형 매핑)
    enum CodingKeys: String, CodingKey {
        case contentid, contenttypeid, title, createdtime, modifiedtime, tel, telname, homepage, firstimage, firstimage2, cpyrhtDivCd
        case areacode, sigungucode, lDongRegnCd, lDongSignguCd, lclsSystm1, lclsSystm2, lclsSystm3
        case cat1, cat2, cat3, addr1, addr2, zipcode, mapx, mapy, mlevel, overview
    }
}

// MARK: - 연산 프로퍼티 (UI/셀 활용용)
extension TourSiteDetail {
    /// 위도(Double) 변환
    var latitude: Double? {
        guard let mapy = mapy, let lat = Double(mapy) else { return nil }
        return lat
    }
    /// 경도(Double) 변환
    var longitude: Double? {
        guard let mapx = mapx, let lng = Double(mapx) else { return nil }
        return lng
    }
    /// 전체 주소(지번+상세)
    var fullAddress: String? {
        if let addr1 = addr1, !addr1.isEmpty {
            if let addr2 = addr2, !addr2.isEmpty {
                return "\(addr1) \(addr2)"
            }
            return addr1
        }
        return nil
    }
    /// 썸네일 이미지 URL (firstimage2 > firstimage)
    var thumbnailURL: URL? {
        if let url = firstimage2, let u = URL(string: url) { return u }
        if let url = firstimage, let u = URL(string: url) { return u }
        return nil
    }
}

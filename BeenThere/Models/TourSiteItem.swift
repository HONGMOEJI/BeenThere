//
//  TourSiteItem.swift
//  BeenThere
//
//  관광지(여행지, 음식점, 문화시설 등) 정보 모델
//  - API 명세 및 BeenThere UI 요구사항을 모두 반영
//  프로젝트 경로: BeenThere/Core/Models/TourSiteItem.swift
//

import Foundation
import CoreLocation
import SwiftUI

// MARK: - String Extension for Clean URLs
extension String {
    var cleanImageURL: URL? {
        let trimmed = self.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        return URL(string: trimmed)
    }
}

struct TourSiteItem: Decodable, Identifiable, Hashable {
    var id: String { contentid }

    // MARK: - API 필드
    let contentid: String
    let title: String
    let contenttypeid: String?
    let firstimage: String?
    let firstimage2: String?
    let createdtime: String?
    let modifiedtime: String?
    let addr1: String?
    let addr2: String?
    let zipcode: String?
    let areacode: String?
    let sigungucode: String?
    let cat1: String?
    let cat2: String?
    let cat3: String?
    let tel: String?
    let mapx: String?
    let mapy: String?
    let mlevel: String?
    let dist: Double?
    let overview: String?

    enum CodingKeys: String, CodingKey {
        case contentid, title, contenttypeid, firstimage, firstimage2
        case createdtime, modifiedtime, addr1, addr2, zipcode
        case areacode, sigungucode, cat1, cat2, cat3, tel
        case mapx, mapy, mlevel, dist, overview
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        contentid = try c.decode(String.self, forKey: .contentid)
        title = try c.decode(String.self, forKey: .title)
        contenttypeid = try? c.decodeIfPresent(String.self, forKey: .contenttypeid)
        firstimage = try? c.decodeIfPresent(String.self, forKey: .firstimage)
        firstimage2 = try? c.decodeIfPresent(String.self, forKey: .firstimage2)
        createdtime = try? c.decodeIfPresent(String.self, forKey: .createdtime)
        modifiedtime = try? c.decodeIfPresent(String.self, forKey: .modifiedtime)
        let rawAddr1 = try? c.decodeIfPresent(String.self, forKey: .addr1)
        addr1 = (rawAddr1?.isEmpty == true) ? nil : rawAddr1
        let rawAddr2 = try? c.decodeIfPresent(String.self, forKey: .addr2)
        addr2 = (rawAddr2?.isEmpty == true) ? nil : rawAddr2
        let rawZip = try? c.decodeIfPresent(String.self, forKey: .zipcode)
        zipcode = (rawZip?.isEmpty == true) ? nil : rawZip
        areacode = try? c.decodeIfPresent(String.self, forKey: .areacode)
        sigungucode = try? c.decodeIfPresent(String.self, forKey: .sigungucode)
        cat1 = try? c.decodeIfPresent(String.self, forKey: .cat1)
        cat2 = try? c.decodeIfPresent(String.self, forKey: .cat2)
        cat3 = try? c.decodeIfPresent(String.self, forKey: .cat3)
        let rawTel = try? c.decodeIfPresent(String.self, forKey: .tel)
        tel = (rawTel?.isEmpty == true) ? nil : rawTel
        mapx = try? c.decodeIfPresent(String.self, forKey: .mapx)
        mapy = try? c.decodeIfPresent(String.self, forKey: .mapy)
        mlevel = try? c.decodeIfPresent(String.self, forKey: .mlevel)
        dist = try? c.decodeIfPresent(Double.self, forKey: .dist)
        let rawOverview = try? c.decodeIfPresent(String.self, forKey: .overview)
        overview = (rawOverview?.isEmpty == true) ? nil : rawOverview
    }
}

// MARK: - 연산 프로퍼티 확장 (UI/셀에서 사용)
extension TourSiteItem {
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
    /// 전화번호 바로 접근
    var phoneNumber: String? {
        return tel
    }
}

extension TourSiteItem {
    /// 썸네일 이미지 URL (firstimage2 > firstimage) - 개선된 버전
    var thumbnailURL: URL? {
        if let url = firstimage2?.cleanImageURL { return url }
        if let url = firstimage?.cleanImageURL { return url }
        return nil
    }

    /// 전체 주소(지번+상세)
    var fullAddress: String? {
        if let addr1 = addr1 {
            if let addr2 = addr2, !addr2.isEmpty {
                return "\(addr1) \(addr2)"
            }
            return addr1
        }
        return nil
    }

    /// 콘텐츠 타입명
    var contentTypeName: String? {
        guard let typeStr = contenttypeid, let typeId = Int(typeStr) else { return nil }
        return APIConstants.ContentTypes.name(for: typeId)
    }

    /// 거리 텍스트(m, km)
    var distanceText: String? {
        guard let distance = dist else { return nil }
        if distance < 1000 {
            return "\(Int(distance))m"
        } else {
            let km = distance / 1000
            return String(format: "%.1fkm", km)
        }
    }

    /// SF 심볼 (콘텐츠 타입별)
    var sfSymbol: String {
        guard let typeStr = contenttypeid, let typeId = Int(typeStr) else {
            return "mappin"
        }
        return APIConstants.ContentTypes.sfSymbol(for: typeId)
    }

    /// 생성일자 Date
    var creationDate: Date? {
        guard let dateStr = createdtime else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmss"
        return formatter.date(from: dateStr)
    }

    /// 수정일자 Date
    var modificationDate: Date? {
        guard let dateStr = modifiedtime else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmss"
        return formatter.date(from: dateStr)
    }
}

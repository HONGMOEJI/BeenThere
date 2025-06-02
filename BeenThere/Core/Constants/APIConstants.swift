//
//  APIConstants.swift
//  BeenThere
//
//  API 관련 상수 정의
//  BeenThere/Core/Constants/APIConstants.swift
//

import Foundation

struct APIConstants {
    
    // MARK: - 한국관광공사 API
    struct TourAPI {
        static let serviceKey = "gPKaLGTFA0zh/0Em8D6wxWQirp+FExHpgU0LZDq4n/y9YH/VPgPS0uyRKuZkwHJrdnnZtcCXyidMsLyDbSkXNQ==" // TODO: 실제 키로 교체
        static let baseURL = "http://apis.data.go.kr/B551011/KorService2"
        
        // Endpoints
        struct Endpoints {
            static let areaBasedList = "/areaBasedList2"
            static let locationBasedList = "/locationBasedList2"
            static let detailCommon = "/detailCommon2"
            static let detailImage = "/detailImage2"
            static let areaCode = "/areaCode2"
            static let searchKeyword = "/searchKeyword2"
        }
        
        // Parameters
        struct Parameters {
            static let serviceKey = "serviceKey"
            static let numOfRows = "numOfRows"
            static let pageNo = "pageNo"
            static let mobileOS = "MobileOS"
            static let mobileApp = "MobileApp"
            static let type = "_type"
            static let areaCode = "areaCode"
            static let contentTypeId = "contentTypeId"
            static let contentId = "contentId"
            static let keyword = "keyword"
        }
        
        // Default Values
        struct Values {
            static let mobileOS = "IOS"
            static let mobileApp = "BeenThere"
            static let responseType = "json"
            static let defaultRows = 20
            static let firstPage = 1
        }
    }
    
    // MARK: - Region Codes
    struct RegionCodes {
        static let seoul = 1
        static let incheon = 2
        static let daejeon = 3
        static let daegu = 4
        static let gwangju = 5
        static let busan = 6
        static let ulsan = 7
        static let sejong = 8
        static let gyeonggi = 31
        static let gangwon = 32
        static let chungbuk = 33
        static let chungnam = 34
        static let gyeongbuk = 35
        static let gyeongnam = 36
        static let jeonbuk = 37
        static let jeonnam = 38
        static let jeju = 39
        
        static let regionNames: [Int: String] = [
            1: "서울", 2: "인천", 3: "대전", 4: "대구", 5: "광주",
            6: "부산", 7: "울산", 8: "세종", 31: "경기", 32: "강원",
            33: "충북", 34: "충남", 35: "경북", 36: "경남",
            37: "전북", 38: "전남", 39: "제주"
        ]
    }
    
    // MARK: - Content Types
    struct ContentTypes {
        static let tourSpot = 12        // 관광지
        static let culture = 14         // 문화시설
        static let festival = 15        // 축제공연행사
        static let course = 25          // 여행코스
        static let leisure = 28         // 레포츠
        static let accommodation = 32   // 숙박
        static let shopping = 38        // 쇼핑
        static let restaurant = 39      // 음식점
        
        static let typeNames: [Int: String] = [
            12: "관광지", 14: "문화시설", 15: "축제공연행사",
            25: "여행코스", 28: "레포츠", 32: "숙박",
            38: "쇼핑", 39: "음식점"
        ]
    }
    
    // MARK: - Firebase Collections
    struct Firebase {
        static let users = "users"
        static let visitRecords = "visitRecords"
        static let tourSpots = "tourSpots"
        static let userProfiles = "userProfiles"
    }
}

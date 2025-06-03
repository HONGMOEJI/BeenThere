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
        static let serviceKey = "gPKaLGTFA0zh/0Em8D6wxWQirp+FExHpgU0LZDq4n/y9YH/VPgPS0uyRKuZkwHJrdnnZtcCXyidMsLyDbSkXNQ=="
        static let baseURL = "http://apis.data.go.kr/B551011/KorService2"
        
        // Endpoints
        struct Endpoints {
            static let areaBasedList = "/areaBasedList2"          // 지역기반 조회
            static let locationBasedList = "/locationBasedList2"  // 위치기반 조회
            static let searchKeyword = "/searchKeyword2"          // 키워드 검색
            static let detailCommon = "/detailCommon2"            // 공통정보 상세조회
            static let detailImage = "/detailImage2"              // 이미지정보 조회
            static let areaCode = "/areaCode2"                    // 지역코드 조회
            static let categoryCode = "/categoryCode2"            // 분류코드 조회
            static let detailIntro = "/detailIntro2"              // 소개정보 조회
            static let detailInfo = "/detailInfo2"                // 반복정보조회
            static let lclsSystmCode = "/lclsSystmCode2"          // 분류체계 코드조회
            static let areaBasedSyncList = "/areaBasedSyncList2"  // 관광정보 동기화 목록 조회
            static let ldongCode = "/ldongCode2"                  // 법정동코드조회
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
            static let sigunguCode = "sigunguCode"
            static let contentTypeId = "contentTypeId"
            static let contentId = "contentId"
            static let keyword = "keyword"
            static let cat1 = "cat1"
            static let cat2 = "cat2"
            static let cat3 = "cat3"
            static let mapX = "mapX"
            static let mapY = "mapY"
            static let radius = "radius"
            static let arrange = "arrange"
            static let listYN = "listYN"
            static let defaultYN = "defaultYN"
            static let firstImageYN = "firstImageYN"
            static let areacodeYN = "areacodeYN"
            static let catcodeYN = "catcodeYN"
            static let addrinfoYN = "addrinfoYN"
            static let mapinfoYN = "mapinfoYN"
            static let overviewYN = "overviewYN"
            static let imageYN = "imageYN"
        }
        
        // Default Values
        struct Values {
            static let mobileOS = "IOS"
            static let mobileApp = "BeenThere"
            static let responseType = "json"
            static let defaultRows = 20
            static let maxRows = 100
            static let firstPage = 1
        }
        
        // Arrange Options (정렬 옵션)
        struct ArrangeOptions {
            static let createDate = "A"      // 등록일순
            static let modifyDate = "C"      // 수정일순
            static let distance = "E"        // 거리순
            static let popularity = "P"      // 인기순 (조회수)
            static let random = "R"          // 임의순서
            static let title = "Q"           // 제목순
        }
    }
    
    // MARK: - Region Codes (지역코드)
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
            1: "서울특별시", 2: "인천광역시", 3: "대전광역시", 4: "대구광역시", 5: "광주광역시",
            6: "부산광역시", 7: "울산광역시", 8: "세종특별자치시", 31: "경기도", 32: "강원특별자치도",
            33: "충청북도", 34: "충청남도", 35: "경상북도", 36: "경상남도",
            37: "전북특별자치도", 38: "전라남도", 39: "제주특별자치도"
        ]
        
        static let shortNames: [Int: String] = [
            1: "서울", 2: "인천", 3: "대전", 4: "대구", 5: "광주",
            6: "부산", 7: "울산", 8: "세종", 31: "경기", 32: "강원",
            33: "충북", 34: "충남", 35: "경북", 36: "경남",
            37: "전북", 38: "전남", 39: "제주"
        ]
    }
    
    // MARK: - Content Types (콘텐츠 타입)
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
        
        static let typeIcons: [Int: String] = [
            12: "🏛️", 14: "🎭", 15: "🎪",
            25: "🗺️", 28: "⚽", 32: "🏨",
            38: "🛍️", 39: "🍽️"
        ]
        
        // 추가: SF 심볼 아이콘
        static let sfSymbols: [Int: String] = [
            12: "building.columns",
            14: "ticket",
            15: "music.note",
            25: "map",
            28: "figure.yoga",
            32: "bed.double",
            38: "cart",
            39: "fork.knife"
        ]
    }
    
    // MARK: - Category Codes (대분류)
    struct CategoryCodes {
        // 자연 (A01)
        struct Nature {
            static let nature = "A01"
            static let naturalTourism = "A0101"     // 자연관광지
            static let naturalRecreation = "A0102"  // 자연휴양림
        }
        
        // 인문(문화/예술/역사) (A02)
        struct Culture {
            static let culture = "A02"
            static let historic = "A0201"           // 역사관광지
            static let leisure = "A0202"            // 휴양관광지
            static let experience = "A0203"         // 체험관광지
            static let industry = "A0204"           // 산업관광지
            static let architecture = "A0205"       // 건축/조형물
            static let cultureFacility = "A0206"    // 문화시설
            static let festival = "A0207"           // 축제
            static let performance = "A0208"        // 공연/행사
        }
        
        // 레포츠 (A03)
        struct Sports {
            static let sports = "A03"
            static let land = "A0301"               // 육상레포츠
            static let water = "A0302"              // 수상레포츠
            static let air = "A0303"                // 항공레포츠
            static let composite = "A0304"          // 복합레포츠
        }
    }
    
    // MARK: - Popular Tourist Destinations (인기 관광지 좌표)
    struct PopularDestinations {
        static let destinations: [(name: String, latitude: Double, longitude: Double, areaCode: Int)] = [
            ("경복궁", 37.5796, 126.9770, 1),
            ("명동", 37.5636, 126.9834, 1),
            ("남산타워", 37.5512, 126.9882, 1),
            ("해운대해수욕장", 35.1587, 129.1603, 6),
            ("광안리해수욕장", 35.1532, 129.1188, 6),
            ("제주올레길", 33.4996, 126.5312, 39),
            ("성산일출봉", 33.4583, 126.9424, 39),
            ("설악산", 38.1195, 128.4654, 32),
            ("남이섬", 37.7913, 127.5262, 32),
            ("불국사", 35.7900, 129.3322, 35)
        ]
    }
    
    // MARK: - Search Radius Options (검색 반경 옵션)
    struct RadiusOptions {
        static let small = 1000      // 1km
        static let medium = 5000     // 5km
        static let large = 10000     // 10km
        static let extraLarge = 20000 // 20km
        
        static let options: [Int: String] = [
            1000: "1km",
            5000: "5km",
            10000: "10km",
            20000: "20km"
        ]
    }
    
    // MARK: - Firebase Collections
    struct Firebase {
        static let users = "users"
        static let visitRecords = "visitRecords"
        static let tourSpots = "tourSpots"
        static let userProfiles = "userProfiles"
        static let favorites = "favorites"
        static let reviews = "reviews"
        static let travelPlans = "travelPlans"
    }
    
    // MARK: - App Configuration
    struct AppConfig {
        static let minSearchKeywordLength = 2
        static let maxSearchResults = 100
        static let defaultImagePlaceholder = "photo.on.rectangle.angled"
        static let cacheExpirationDays = 7
        static let maxCacheSize = 100 // MB
    }
    
    // MARK: - 네트워크 설정
    struct NetworkConfig {
        static let timeoutInterval: TimeInterval = 15.0
        static let maxRetryCount = 3
        static let retryDelay: TimeInterval = 2.0
        static let cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy
        
        // 오프라인 모드에서 사용할 캐시 만료 시간 (일)
        static let offlineCacheValidDays = 30
        
        // 네트워크 상태 메시지
        static let offlineMessage = "인터넷 연결이 없습니다. 일부 기능이 제한됩니다."
        static let reconnectedMessage = "인터넷에 다시 연결되었습니다."
    }
    
    // MARK: - 맵 설정
    struct MapConfig {
        // 지도 초기 줌 레벨
        static let defaultZoomLevel = 14.0
        
        // 지도 최대/최소 줌 레벨
        static let minZoomLevel = 5.0
        static let maxZoomLevel = 18.0
        
        // 핀 클러스터링 설정
        static let clusteringDistance = 50.0
        static let clusteringThreshold = 10
        
        // 핀 색상 설정 (카테고리별)
        static let pinColors: [Int: String] = [
            12: "#0066FF", // 관광지 - 파란색
            14: "#8A2BE2", // 문화시설 - 보라색
            15: "#FF0000", // 축제 - 빨간색
            25: "#006400", // 코스 - 초록색
            28: "#FF8C00", // 레포츠 - 주황색
            32: "#4B0082", // 숙박 - 남색
            38: "#FF1493", // 쇼핑 - 핫핑크
            39: "#DAA520"  // 음식점 - 금색
        ]
        
        // 지도 스타일 설정
        static let dayModeStyle = "mapbox://styles/mapbox/streets-v11"
        static let nightModeStyle = "mapbox://styles/mapbox/dark-v10"
    }
}

// MARK: - Helper Extensions
extension APIConstants.RegionCodes {
    static func name(for code: Int) -> String {
        return regionNames[code] ?? "알 수 없는 지역"
    }
    
    static func shortName(for code: Int) -> String {
        return shortNames[code] ?? "기타"
    }
    
    static func allRegions() -> [(code: Int, name: String)] {
        return regionNames.map { (code: $0.key, name: $0.value) }.sorted { $0.code < $1.code }
    }
}

extension APIConstants.ContentTypes {
    static func name(for typeId: Int) -> String {
        return typeNames[typeId] ?? "기타"
    }
    
    static func icon(for typeId: Int) -> String {
        return typeIcons[typeId] ?? "📍"
    }
    
    static func sfSymbol(for typeId: Int) -> String {
        return sfSymbols[typeId] ?? "mappin"
    }
    
    static func allTypes() -> [(id: Int, name: String, icon: String)] {
        return typeNames.map { typeId in
            (id: typeId.key, name: typeId.value, icon: typeIcons[typeId.key] ?? "📍")
        }.sorted { $0.id < $1.id }
    }
}

// 에러 메시지 확장
extension APIConstants {
    struct ErrorMessages {
        static let networkError = "네트워크 연결에 문제가 있습니다."
        static let serverError = "서버에 일시적인 문제가 발생했습니다."
        static let parsingError = "데이터 처리 중 오류가 발생했습니다."
        static let locationError = "위치 정보를 가져올 수 없습니다."
        static let permissionDenied = "위치 권한이 필요합니다."
        static let noDataFound = "데이터를 찾을 수 없습니다."
        static let loginRequired = "로그인이 필요합니다."
        static let cacheFailed = "데이터 캐싱에 실패했습니다."
    }
}

import Foundation
import CoreLocation
import Combine

class MainViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var tourSites: [TourSiteItem] = []
    @Published var isLoading = false
    @Published var isLoadingMore = false
    @Published var hasError = false
    @Published var error: Error?
    @Published var sectionTitle = "내 주변 여행지"
    @Published var sectionSubtitle = "가까운 곳부터 찾아보세요"
    @Published var currentLocation: CLLocation?
    @Published var selectedLocation: CLLocation?
    @Published var selectedLocationName: String = "내 위치"
    
    // MARK: - Pagination Properties
    private var currentPage = 1
    private let itemsPerPage = 10
    private var canLoadMore = true
    private var totalCount = 0

    // MARK: - Search & Filter Properties
    private var currentKeyword: String?
    private var currentCategoryId: Int?
    private var isLocationBasedMode = true

    // MARK: - Dependencies
    private let apiService = TourAPIService.shared
    private let locationManager: LocationManager

    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization
    init(locationManager: LocationManager) {
        self.locationManager = locationManager
        setupBindings()
    }

    // MARK: - Setup
    private func setupBindings() {
        locationManager.$currentLocation
            .compactMap { $0 }
            .sink { [weak self] location in
                self?.currentLocation = location
                if self?.selectedLocation == nil {
                    self?.selectedLocation = location
                    Task { await self?.refreshData() }
                }
            }
            .store(in: &cancellables)
    }

    // MARK: - Public Methods

    /// 초기 데이터 로드
    func loadInitialData() {
        if locationManager.authorizationStatus == .notDetermined {
            locationManager.requestPermission()
        } else if locationManager.authorizationStatus == .authorizedWhenInUse ||
                    locationManager.authorizationStatus == .authorizedAlways {
            locationManager.startUpdating()
        } else {
            setDefaultLocation()
        }
    }

    /// 데이터 새로고침
    @MainActor
    func refreshData() async {
        print("🔄 refreshData 시작")
        currentPage = 1
        canLoadMore = true
        tourSites.removeAll()

        if isLocationBasedMode {
            await loadLocationBasedData()
        } else {
            await loadGeneralData()
        }
    }

    /// 다음 페이지 로드 (무한 스크롤) - 스크롤뷰 기반으로 안정화
    @MainActor
    func loadMoreDataIfNeeded(for index: Int) async {
        let currentCount = tourSites.count
        
        print("🔍 loadMoreDataIfNeeded 호출됨 (스크롤뷰 기반)")
        print("   - index: \(index)")
        print("   - currentCount: \(currentCount)")
        print("   - canLoadMore: \(canLoadMore)")
        print("   - isLoadingMore: \(isLoadingMore)")
        print("   - isLoading: \(isLoading)")
        print("   - currentPage: \(currentPage)")
        print("   - totalCount: \(totalCount)")
        
        // 로딩 중이거나 더 이상 로드할 데이터가 없으면 리턴
        guard canLoadMore,
              !isLoadingMore,
              !isLoading,
              currentCount > 0,
              currentCount < totalCount  // 총 개수보다 적을 때만
        else {
            print("❌ 로드 조건 불충족")
            return
        }
        
        print("✅ 다음 페이지 로드 시작")
        isLoadingMore = true
        
        currentPage += 1
        
        if isLocationBasedMode {
            await loadLocationBasedData()
        } else {
            await loadGeneralData()
        }
    }

    /// 검색 수행
    @MainActor
    func performSearch(with keyword: String) async {
        currentKeyword = keyword.isEmpty ? nil : keyword
        await refreshData()
    }

    /// 카테고리 설정
    @MainActor
    func setCategoryId(_ categoryId: Int?) async {
        currentCategoryId = categoryId
        await refreshData()
    }

    /// 위치 기반 모드 설정
    @MainActor
    func setLocationBasedMode(_ enabled: Bool) async {
        isLocationBasedMode = enabled
        updateSectionTitles()
        await refreshData()
    }

    /// 특정 위치로 설정
    @MainActor
    func setSelectedLocation(_ location: CLLocation, name: String) async {
        selectedLocation = location
        selectedLocationName = name
        isLocationBasedMode = true
        updateSectionTitles()
        await refreshData()
    }

    // MARK: - Private Methods

    private func setDefaultLocation() {
        let seoulLocation = CLLocation(latitude: 37.5665, longitude: 126.9780)
        Task { await setSelectedLocation(seoulLocation, name: "서울") }
    }

    @MainActor
    private func loadLocationBasedData() async {
        guard let location = selectedLocation else {
            setDefaultLocation()
            return
        }
        
        print("🌍 loadLocationBasedData 시작 - 페이지: \(currentPage)")
        
        if currentPage == 1 {
            isLoading = true
        } else {
            isLoadingMore = true
        }
        
        do {
            let result = try await apiService.fetchNearbySitesWithMeta(
                location: location,
                radius: 5000,
                contentTypeId: currentCategoryId,
                pageNo: currentPage,
                numOfRows: itemsPerPage
            )
            
            print("📡 API 응답 받음:")
            print("   - 페이지: \(result.pageNo)")
            print("   - 아이템 수: \(result.items.count)")
            print("   - 총 개수: \(result.totalCount)")
            
            await handleDataResult(sites: result.items, pageNo: result.pageNo, totalCount: result.totalCount)
        } catch {
            print("❌ API 에러: \(error)")
            await handleError(error)
        }
    }

    @MainActor
    private func loadGeneralData() async {
        print("🌐 loadGeneralData 시작 - 페이지: \(currentPage)")
        
        if currentPage == 1 {
            isLoading = true
        } else {
            isLoadingMore = true
        }
        
        do {
            let result = try await apiService.fetchSitesWithMeta(
                areaCode: nil,
                sigunguCode: nil,
                keyword: currentKeyword,
                pageNo: currentPage,
                numOfRows: itemsPerPage,
                contentTypeId: currentCategoryId ?? APIConstants.ContentTypes.tourSpot
            )
            
            print("📡 API 응답 받음:")
            print("   - 페이지: \(result.pageNo)")
            print("   - 아이템 수: \(result.items.count)")
            print("   - 총 개수: \(result.totalCount)")
            
            await handleDataResult(sites: result.items, pageNo: result.pageNo, totalCount: result.totalCount)
        } catch {
            print("❌ API 에러: \(error)")
            await handleError(error)
        }
    }

    @MainActor
    private func handleDataResult(sites: [TourSiteItem], pageNo: Int, totalCount: Int) async {
        print("📊 handleDataResult 시작")
        print("   - 받은 페이지: \(pageNo)")
        print("   - 받은 아이템 수: \(sites.count)")
        print("   - 총 개수: \(totalCount)")
        print("   - 현재 tourSites 수: \(tourSites.count)")
        
        isLoading = false
        isLoadingMore = false
        self.totalCount = totalCount
        
        if pageNo == 1 {
            tourSites = sites
            currentPage = 1
            print("✅ 첫 페이지 설정 완료: \(sites.count)개")
        } else {
            // 🔥 TourSiteItem의 실제 프로퍼티를 사용해서 중복 방지
            // contentId 대신 title과 위치 정보로 중복 체크
            let existingItems = Set(tourSites.map { "\($0.title)-\($0.latitude ?? 0)-\($0.longitude ?? 0)" })
            let newSites = sites.filter { site in
                let key = "\(site.title)-\(site.latitude ?? 0)-\(site.longitude ?? 0)"
                return !existingItems.contains(key)
            }
            
            tourSites.append(contentsOf: newSites)
            currentPage = pageNo
            print("✅ 페이지 \(pageNo) 추가 완료: +\(newSites.count)개, 총 \(tourSites.count)개")
            
            if newSites.count < sites.count {
                print("⚠️ 중복 아이템 \(sites.count - newSites.count)개 제외됨")
            }
        }
        
        // canLoadMore 조건은 그대로
        canLoadMore = !sites.isEmpty && tourSites.count < totalCount && sites.count == itemsPerPage
        
        print("📈 상태 업데이트:")
        print("   - canLoadMore: \(canLoadMore)")
        print("   - tourSites.count: \(tourSites.count)")
        print("   - totalCount: \(totalCount)")
        print("   - currentPage: \(currentPage)")
    }

    @MainActor
    private func handleError(_ error: Error) async {
        print("❌ handleError: \(error)")
        isLoading = false
        isLoadingMore = false
        hasError = true
        self.error = error
    }

    private func updateSectionTitles() {
        if isLocationBasedMode {
            sectionTitle = "\(selectedLocationName) 주변 여행지"
            sectionSubtitle = "가까운 곳부터 찾아보세요"
        } else {
            sectionTitle = "추천 여행지"
            sectionSubtitle = "인기 여행지를 둘러보세요"
        }
    }

    @MainActor
    func fetchNearbyPlacesFor(location: CLLocation, title: String) async {
        await setSelectedLocation(location, name: title)
    }

    // MARK: - Major Cities Presets
    static let majorCities: [(name: String, location: CLLocation)] = [
        ("서울", CLLocation(latitude: 37.5665, longitude: 126.9780)),
        ("부산", CLLocation(latitude: 35.1796, longitude: 129.0756)),
        ("제주도", CLLocation(latitude: 33.4996, longitude: 126.5312)),
        ("강릉", CLLocation(latitude: 37.7519, longitude: 128.8761)),
        ("경주", CLLocation(latitude: 35.8563, longitude: 129.2245))
    ]
}

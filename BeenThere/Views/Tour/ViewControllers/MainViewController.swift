import UIKit
import CoreLocation
import Combine
import Lottie
import FirebaseAuth

class MainViewController: UIViewController {
    
    // MARK: - Properties
    private var mainView: MainView!
    private var viewModel: MainViewModel!
    private var locationManager = LocationManager()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Lifecycle
    override func loadView() {
        mainView = MainView(frame: UIScreen.main.bounds)
        view = mainView
        viewModel = MainViewModel(locationManager: locationManager)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
        setupBindings()
        setupCategoryButtons()
        viewModel.loadInitialData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 메인 화면에서는 네비게이션 바 숨김
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        print("📐 viewDidLayoutSubviews - 컬렉션뷰 frame: \(mainView.collectionView.frame)")
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        mainView.collectionView.delegate = self
        mainView.collectionView.dataSource = self
        overrideUserInterfaceStyle = .dark
        
        // 🔥 스크롤뷰 델리게이트 추가 (무한 스크롤을 위해)
        mainView.scrollView.delegate = self
        
        // 컬렉션뷰는 스크롤 비활성화 (스크롤뷰가 담당)
        mainView.collectionView.isScrollEnabled = false
        mainView.collectionView.alwaysBounceVertical = false
        mainView.collectionView.showsVerticalScrollIndicator = false
        
        // 셀 등록
        mainView.collectionView.register(TravelPlaceCell.self, forCellWithReuseIdentifier: TravelPlaceCell.reuseIdentifier)
        mainView.collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "DefaultCell")
        
        print("🔧 setupUI 완료")
        print("   - scrollView.delegate 설정됨")
        print("   - collectionView.isScrollEnabled: \(mainView.collectionView.isScrollEnabled)")
        print("   - 셀 등록 완료")
    }
    
    private func setupActions() {
        mainView.locationButton.addTarget(self, action: #selector(locationButtonTapped), for: .touchUpInside)
        mainView.emptyStateButton.addTarget(self, action: #selector(refreshData), for: .touchUpInside)
        mainView.refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleShareNotification(_:)),
            name: NSNotification.Name("ShareTravelPlace"),
            object: nil
        )
    }
    
    private func setupBindings() {
        viewModel.$tourSites
            .receive(on: DispatchQueue.main)
            .sink { [weak self] sites in
                print("🔄 tourSites 업데이트됨: \(sites.count)개")
                self?.updateCollectionView(with: sites)
            }
            .store(in: &cancellables)
            
        viewModel.$sectionTitle
            .receive(on: DispatchQueue.main)
            .sink { [weak self] title in
                self?.mainView.sectionTitleLabel.text = title
            }
            .store(in: &cancellables)
            
        viewModel.$sectionSubtitle
            .receive(on: DispatchQueue.main)
            .sink { [weak self] subtitle in
                self?.mainView.subtitleLabel.text = subtitle
            }
            .store(in: &cancellables)
            
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                self?.handleLoadingState(isLoading)
            }
            .store(in: &cancellables)
            
        viewModel.$isLoadingMore
            .receive(on: DispatchQueue.main)
            .sink { isLoadingMore in
                print("📱 isLoadingMore 상태 변경: \(isLoadingMore)")
                // 필요시 추가 로딩 인디케이터 처리
            }
            .store(in: &cancellables)
            
        viewModel.$hasError
            .receive(on: DispatchQueue.main)
            .filter { $0 }
            .sink { [weak self] _ in
                self?.handleError()
            }
            .store(in: &cancellables)
            
        locationManager.$authorizationStatus
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                self?.handleLocationAuthorizationStatus(status)
            }
            .store(in: &cancellables)
            
        viewModel.$currentLocation
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] location in
                self?.updateLocationButtonTitle(with: location)
            }
            .store(in: &cancellables)
    }
    
    private func updateCollectionView(with sites: [TourSiteItem]) {
        print("📱 updateCollectionView 호출됨: \(sites.count)개")
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.mainView.collectionView.reloadData()
            
            // 🔥 컬렉션뷰 높이를 데이터에 맞게 조정 (원래 방식 복원)
            self.mainView.adjustCollectionViewHeight(for: sites.count)
            
            // 레이아웃 업데이트 후 정보 출력
            DispatchQueue.main.async {
                print("📐 CollectionView 정보:")
                print("   - frame: \(self.mainView.collectionView.frame)")
                print("   - contentSize: \(self.mainView.collectionView.contentSize)")
                print("   - numberOfItems: \(self.mainView.collectionView.numberOfItems(inSection: 0))")
                print("   - visibleCells: \(self.mainView.collectionView.visibleCells.count)")
                print("   - scrollView contentSize: \(self.mainView.scrollView.contentSize)")
            }
        }
        
        if sites.isEmpty && !viewModel.isLoading {
            mainView.showEmptyState()
        } else {
            mainView.hideEmptyState()
        }
    }
    
    private func handleLoadingState(_ isLoading: Bool) {
        if isLoading {
            mainView.showLoadingState()
        } else {
            mainView.hideLoadingState()
            mainView.refreshControl.endRefreshing()
        }
    }
    
    private func handleError() {
        guard let error = viewModel.error else { return }
        mainView.showEmptyState(
            message: "데이터를 불러오는데 실패했습니다",
            icon: "exclamationmark.triangle"
        )
        let alert = UIAlertController(
            title: "오류",
            message: "데이터를 불러오는데 실패했습니다.\n\(error.localizedDescription)",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Category Buttons
    private func setupCategoryButtons() {
        let allButton = mainView.createCategoryButton(title: "전체", icon: "globe", tag: 0)
        mainView.categoryStackView.addArrangedSubview(allButton)
        allButton.isSelected = true
        allButton.addTarget(self, action: #selector(categoryButtonTapped(_:)), for: .touchUpInside)
        
        let categories = APIConstants.ContentTypes.allTypes().filter { $0.id != APIConstants.ContentTypes.course }
        for category in categories {
            let button = mainView.createCategoryButton(
                title: category.name,
                icon: APIConstants.ContentTypes.sfSymbol(for: category.id),
                tag: category.id
            )
            button.addTarget(self, action: #selector(categoryButtonTapped(_:)), for: .touchUpInside)
            mainView.categoryStackView.addArrangedSubview(button)
        }
    }
    
    // MARK: - Location Methods
    private func handleLocationAuthorizationStatus(_ status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdating()
        case .denied, .restricted:
            showLocationPermissionAlert()
            updateLocationButtonTitle("위치 권한 필요")
        default:
            break
        }
    }
    
    private func updateLocationButtonTitle(_ title: String = "내 위치") {
        var config = mainView.locationButton.configuration
        config?.title = title
        mainView.locationButton.configuration = config
    }
    
    private func updateLocationButtonTitle(with location: CLLocation) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard let self = self, let placemark = placemarks?.first else {
                self?.updateLocationButtonTitle("내 위치")
                return
            }
            
            var title: String?
            if let subLocality = placemark.subLocality, !subLocality.isEmpty {
                title = subLocality
                if let subAdmin = placemark.subAdministrativeArea, !subAdmin.isEmpty {
                    title = "\(subLocality) \(subAdmin)"
                }
            } else if let subAdmin = placemark.subAdministrativeArea, !subAdmin.isEmpty {
                title = subAdmin
            } else if let locality = placemark.locality, !locality.isEmpty {
                title = locality
            }
            self.updateLocationButtonTitle(title ?? "내 위치")
        }
    }
    
    private func showLocationPermissionAlert() {
        let alert = UIAlertController(
            title: "위치 권한 필요",
            message: "내 주변 여행지를 확인하려면 위치 권한이 필요합니다.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "설정으로 이동", style: .default) { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL)
            }
        })
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        present(alert, animated: true)
    }
    
    private func showLocationSelectionAlert() {
        let alert = UIAlertController(
            title: "위치 선택",
            message: "원하시는 방법을 선택하세요",
            preferredStyle: .actionSheet
        )
        
        if viewModel.currentLocation != nil {
            alert.addAction(UIAlertAction(title: "📍 내 위치 사용", style: .default) { [weak self] _ in
                guard let self = self, let location = self.viewModel.currentLocation else { return }
                Task {
                    await self.viewModel.setSelectedLocation(location, name: "내 위치")
                    self.updateLocationButtonTitle(with: location)
                }
            })
        }
        
        alert.addAction(UIAlertAction(title: "🗺️ 지도에서 선택", style: .default) { [weak self] _ in
            self?.showLocationSelectionViewController()
        })
        
        alert.addAction(UIAlertAction(title: "🏙️ 서울", style: .default) { [weak self] _ in
            let seoulLocation = CLLocation(latitude: 37.5665, longitude: 126.9780)
            Task {
                await self?.viewModel.setSelectedLocation(seoulLocation, name: "서울")
                self?.updateLocationButtonTitle("서울")
            }
        })
        
        alert.addAction(UIAlertAction(title: "🌊 부산", style: .default) { [weak self] _ in
            let busanLocation = CLLocation(latitude: 35.1796, longitude: 129.0756)
            Task {
                await self?.viewModel.setSelectedLocation(busanLocation, name: "부산")
                self?.updateLocationButtonTitle("부산")
            }
        })
        
        alert.addAction(UIAlertAction(title: "🏝️ 제주도", style: .default) { [weak self] _ in
            let jejuLocation = CLLocation(latitude: 33.4996, longitude: 126.5312)
            Task {
                await self?.viewModel.setSelectedLocation(jejuLocation, name: "제주도")
                self?.updateLocationButtonTitle("제주도")
            }
        })
        
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        
        if let popover = alert.popoverPresentationController {
            popover.sourceView = mainView.locationButton
            popover.sourceRect = mainView.locationButton.bounds
        }
        present(alert, animated: true)
    }
    
    private func showLocationSelectionViewController() {
        let locationSelectionVC = LocationSelectionViewController()
        locationSelectionVC.delegate = self
        locationSelectionVC.modalPresentationStyle = .pageSheet
        if let sheet = locationSelectionVC.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 20
        }
        present(locationSelectionVC, animated: true)
    }
    
    // MARK: - Actions
    @objc private func locationButtonTapped() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
        showLocationSelectionAlert()
    }
    
    @objc private func categoryButtonTapped(_ sender: UIButton) {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
        
        // 모든 버튼 선택 해제
        for subview in mainView.categoryStackView.arrangedSubviews {
            if let button = subview as? UIButton {
                button.isSelected = false
            }
        }
        
        // 현재 버튼 선택
        sender.isSelected = true
        let categoryId = sender.tag == 0 ? nil : sender.tag
        Task { await viewModel.setCategoryId(categoryId) }
        
        // 애니메이션 효과
        UIView.animate(withDuration: 0.1, animations: {
            sender.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                sender.transform = .identity
            }
        }
    }
    
    @objc private func refreshData() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
        Task { await viewModel.refreshData() }
    }
    
    @objc private func handleShareNotification(_ notification: Notification) {
        guard let userInfo = notification.userInfo as? [String: Any],
              let items = userInfo["items"] as? [Any] else { return }
        
        let activityViewController = UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )
        
        if let popover = activityViewController.popoverPresentationController {
            popover.sourceView = self.view
            popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        present(activityViewController, animated: true)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - UIScrollViewDelegate (무한 스크롤)
extension MainViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // 메인 스크롤뷰가 아닌 다른 스크롤뷰(카테고리 스크롤뷰 등)는 무시
        guard scrollView == mainView.scrollView else { return }
        
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let scrollViewHeight = scrollView.frame.height
        
        // 스크롤이 거의 끝에 도달했을 때 (80% 지점)
        let threshold = contentHeight - scrollViewHeight * 1.2
        
        if offsetY > threshold && offsetY > 0 {
            // 이미 로딩 중이거나 더 이상 로드할 데이터가 없으면 리턴
            guard !viewModel.isLoadingMore && !viewModel.isLoading else { return }
            
            let currentCount = viewModel.tourSites.count
            guard currentCount >= 5 else { return } // 최소 5개 이상일 때만
            
            print("🔥 스크롤뷰 무한 스크롤 트리거!")
            print("   - offsetY: \(offsetY)")
            print("   - contentHeight: \(contentHeight)")
            print("   - threshold: \(threshold)")
            print("   - currentCount: \(currentCount)")
            
            Task {
                await viewModel.loadMoreDataIfNeeded(for: currentCount - 1)
            }
        }
    }
}

// MARK: - UICollectionViewDataSource
// MARK: - UICollectionViewDataSource
extension MainViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = viewModel.tourSites.count
        print("📱 numberOfItemsInSection: \(count)")
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("📱 cellForItemAt 호출됨: \(indexPath.item)")
        
        guard indexPath.item < viewModel.tourSites.count else {
            print("❌ 인덱스 범위 초과: \(indexPath.item) >= \(viewModel.tourSites.count)")
            let defaultCell = collectionView.dequeueReusableCell(withReuseIdentifier: "DefaultCell", for: indexPath)
            defaultCell.backgroundColor = .systemRed
            return defaultCell
        }
        
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TravelPlaceCell.reuseIdentifier,
            for: indexPath
        ) as? TravelPlaceCell else {
            print("❌ TravelPlaceCell 생성 실패 - 기본 셀 반환")
            let defaultCell = collectionView.dequeueReusableCell(withReuseIdentifier: "DefaultCell", for: indexPath)
            defaultCell.backgroundColor = .systemBlue
            
            // 디버깅용 라벨 추가
            let label = UILabel()
            label.text = "아이템 \(indexPath.item)"
            label.textColor = .white
            label.textAlignment = .center
            label.frame = defaultCell.bounds
            label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            defaultCell.contentView.subviews.forEach { $0.removeFromSuperview() }
            defaultCell.contentView.addSubview(label)
            
            return defaultCell
        }
        
        let site = viewModel.tourSites[indexPath.item]
        
        // 🆕 방문 횟수 조회하여 셀에 전달
        Task {
            do {
                let visitCount = try await FirestoreService.shared.fetchVisitCount(
                    userId: Auth.auth().currentUser?.uid ?? "",
                    contentId: site.contentid
                )
                
                DispatchQueue.main.async {
                    // 셀이 아직 화면에 보이는지 확인
                    if let visibleCell = collectionView.cellForItem(at: indexPath) as? TravelPlaceCell {
                        visibleCell.configure(
                            with: site,
                            currentLocation: self.viewModel.currentLocation,
                            visitCount: visitCount,
                            onToggle: {}
                        )
                    }
                }
            } catch {
                print("❌ 방문 횟수 조회 실패: \(error)")
                // 에러가 발생해도 기본 설정으로 셀 구성
                DispatchQueue.main.async {
                    cell.configure(
                        with: site,
                        currentLocation: self.viewModel.currentLocation,
                        visitCount: 0,
                        onToggle: {}
                    )
                }
            }
        }
        
        // 초기 설정 (방문 횟수는 나중에 업데이트됨)
        cell.configure(
            with: site,
            currentLocation: viewModel.currentLocation,
            visitCount: 0,
            onToggle: {}
        )
        
        print("✅ TravelPlaceCell 구성 완료 for index: \(indexPath.item)")
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension MainViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.item < viewModel.tourSites.count else { return }
        let site = viewModel.tourSites[indexPath.item]
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()

        if let cell = collectionView.cellForItem(at: indexPath) {
            UIView.animate(withDuration: 0.1, animations: {
                cell.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            }) { _ in
                UIView.animate(withDuration: 0.1) {
                    cell.transform = .identity
                }
            }
        }

        // 🔥 안전하게 contentTypeId 변환(기본값 12 fallback)
        let safeContentTypeId = Int(site.contenttypeid ?? "") ?? APIConstants.ContentTypes.tourSpot
        print("상세화면 이동 contentId: \(site.contentid), contentTypeId(raw): \(site.contenttypeid ?? "nil"), contentTypeId(Int): \(safeContentTypeId)")

        let detailVC = TourDetailViewController(
            contentId: site.contentid,
            contentTypeId: safeContentTypeId
        )
        
        // 부드러운 전환을 위해 네비게이션 바를 미리 보이도록 설정
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

// MARK: - UISearchBarDelegate
extension MainViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        guard let searchText = searchBar.text, !searchText.isEmpty else { return }
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
        Task { await viewModel.performSearch(with: searchText) }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                if searchBar.text?.isEmpty == true {
                    Task { await self?.viewModel.refreshData() }
                }
            }
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        Task { await viewModel.refreshData() }
    }
}

// MARK: - LocationSelectionDelegate
extension MainViewController: LocationSelectionDelegate {
    func didSelectLocation(_ location: CLLocation, name: String) {
        Task {
            await viewModel.setSelectedLocation(location, name: name)
            updateLocationButtonTitle(with: location)
            let generator = UINotificationFeedbackGenerator()
            generator.prepare()
            generator.notificationOccurred(.success)
        }
    }
}

// MARK: - Status Bar
extension MainViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

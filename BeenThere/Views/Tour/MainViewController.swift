//
//  MainViewController.swift
//  BeenThere
//
//  메인 화면: 모든 UI 요소를 코드로 생성하여 “내 주변” 기능 + 방문 체크 셀 구성
//  BeenThere/Views/Tour/MainViewController.swift
//

import UIKit
import CoreLocation
import FirebaseAuth
import Combine
import Kingfisher

class MainViewController: UIViewController {
    // MARK: - UI 컴포넌트 정의

    /// 상단에 “내 주변 보기”와 라벨
    private let locationLabel: UILabel = {
        let label = UILabel()
        label.text = "내 주변 보기"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()

    private let locationSwitch: UISwitch = {
        let sw = UISwitch()
        sw.isOn = false
        return sw
    }()

    /// 반경 선택 Segmented Control (0:500m, 1:1km, 2:2km)
    private let radiusSegmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["500m", "1km", "2km"])
        sc.selectedSegmentIndex = 1
        return sc
    }()

    /// UICollectionView (2열 Grid)
    private lazy var collectionView: UICollectionView = {
        // FlowLayout 설정
        let layout = UICollectionViewFlowLayout()
        let spacing: CGFloat = 16
        let width = (view.frame.width - spacing * 3) / 2
        layout.itemSize = CGSize(width: width, height: width * 2/3 + 60)
        layout.sectionInset = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = spacing

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .systemBackground
        cv.register(VisitCell.self, forCellWithReuseIdentifier: VisitCell.reuseIdentifier)
        return cv
    }()

    // MARK: - 데이터 & 상태 관리

    private var locationManager = LocationManager()
    private var tourSites: [TourSiteItem] = []
    private var visitedIds = Set<String>()
    private var pageNo: Int = 1
    private var isLoading = false
    private var useLocationBased: Bool = false

    /// 선택된 반경(m)
    private var searchRadius: Int {
        switch radiusSegmentedControl.selectedSegmentIndex {
        case 0: return 500
        case 1: return 1000
        case 2: return 2000
        default: return 1000
        }
    }

    private var cancellables = Set<AnyCancellable>()

    // MARK: - 뷰 생명주기

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "관광지 탐색"

        setupUI()
        setupBindings()
        loadVisitedIds()
    }

    // MARK: - UI 레이아웃 및 설정

    private func setupUI() {
        // 1) 상단 스택뷰 (UILabel + UISwitch + UISegmentedControl)
        let topStack = UIStackView(arrangedSubviews: [locationLabel, locationSwitch, radiusSegmentedControl])
        topStack.axis = .horizontal
        topStack.alignment = .center
        topStack.spacing = 12
        topStack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(topStack)
        view.addSubview(collectionView)

        // 2) AutoLayout 제약
        NSLayoutConstraint.activate([
            // topStack: safeArea의 상단에 16pt 여백
            topStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            topStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            topStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            // SegmentedControl 너비 비율 조정 (필요 시)
            radiusSegmentedControl.widthAnchor.constraint(equalToConstant: 180),

            // collectionView: topStack 아래, safeArea 하단까지 채우기
            collectionView.topAnchor.constraint(equalTo: topStack.bottomAnchor, constant: 8),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        // 3) 컬렉션 뷰 델리게이트 / 데이터소스 지정
        collectionView.delegate = self
        collectionView.dataSource = self

        // 4) UISwitch, UISegmentedControl 액션 연결
        locationSwitch.addTarget(self, action: #selector(locationSwitchChanged(_:)), for: .valueChanged)
        radiusSegmentedControl.addTarget(self, action: #selector(radiusControlChanged(_:)), for: .valueChanged)
    }

    // MARK: - Combine / CoreLocation 바인딩

    private func setupBindings() {
        // 위치 권한 상태 감지
        locationManager.$authorizationStatus
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                guard let self = self else { return }
                switch status {
                case .authorizedWhenInUse, .authorizedAlways:
                    self.locationManager.startUpdating()
                case .denied, .restricted:
                    if self.useLocationBased {
                        self.showAlert(title: "위치 권한 필요",
                                       message: "내 주변 보기 기능을 사용하려면 위치 권한을 허용해 주세요.")
                        self.locationSwitch.setOn(false, animated: true)
                        self.useLocationBased = false
                    }
                default:
                    break
                }
            }
            .store(in: &cancellables)

        // 현재 위치 받으면 TourAPI 호출
        locationManager.$currentLocation
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] location in
                guard let self = self else { return }
                if self.useLocationBased {
                    self.pageNo = 1
                    self.tourSites.removeAll()
                    self.collectionView.reloadData()
                    Task {
                        await self.fetchNearbySites(at: location)
                    }
                }
            }
            .store(in: &cancellables)
    }

    // MARK: - UISwitch / UISegmentedControl 액션

    @objc private func locationSwitchChanged(_ sender: UISwitch) {
        useLocationBased = sender.isOn
        if useLocationBased {
            switch locationManager.authorizationStatus {
            case .notDetermined:
                locationManager.requestPermission()
            case .authorizedWhenInUse, .authorizedAlways:
                locationManager.startUpdating()
            default:
                showAlert(title: "위치 권한 필요",
                          message: "내 주변 보기 기능을 사용하려면 위치 권한을 허용해 주세요.")
                sender.setOn(false, animated: true)
                useLocationBased = false
            }
        } else {
            // 일반 모드: 목록 초기화
            tourSites.removeAll()
            collectionView.reloadData()
            title = "관광지 탐색"
        }
    }

    @objc private func radiusControlChanged(_ sender: UISegmentedControl) {
        if useLocationBased, let location = locationManager.currentLocation {
            pageNo = 1
            tourSites.removeAll()
            collectionView.reloadData()
            Task {
                await fetchNearbySites(at: location)
            }
        }
    }

    // MARK: - Visit 기록 로드

    private func loadVisitedIds() {
        guard let user = Auth.auth().currentUser else { return }
        Task {
            do {
                let records = try await FirestoreService.shared.fetchAllVisitRecords(userId: user.uid)
                let ids = Set(records.map { $0.contentId })
                visitedIds = ids
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            } catch {
                print("방문 기록 불러오기 실패: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - TourAPI: 위치 기반 조회

    private func fetchNearbySites(at location: CLLocation) async {
        guard !isLoading else { return }
        isLoading = true

        do {
            let items = try await TourAPIService.shared.fetchNearbySites(
                location: location,
                radius: searchRadius,
                contentTypeId: APIConstants.ContentTypes.tourSpot,
                arrange: "E",
                pageNo: pageNo,
                numOfRows: APIConstants.TourAPI.Values.defaultRows
            )
            if pageNo == 1 {
                tourSites = items
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                    self.title = "내 주변 관광지"
                }
            } else {
                let startIndex = tourSites.count
                tourSites.append(contentsOf: items)
                let endIndex = tourSites.count
                let indexPaths = (startIndex..<endIndex).map { IndexPath(item: $0, section: 0) }
                DispatchQueue.main.async {
                    self.collectionView.insertItems(at: indexPaths)
                }
            }
        } catch {
            print("위치 기반 조회 실패: \(error.localizedDescription)")
        }

        isLoading = false
    }

    // MARK: - 방문 체크 토글

    private func toggleVisitCheck(for site: TourSiteItem) {
        guard let user = Auth.auth().currentUser else { return }
        let contentId = site.contentid

        Task {
            if visitedIds.contains(contentId) {
                // 이미 방문됨 → 삭제
                do {
                    try await FirestoreService.shared.deleteVisitRecord(userId: user.uid, contentId: contentId)
                    visitedIds.remove(contentId)
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
                } catch {
                    print("방문 기록 삭제 실패: \(error.localizedDescription)")
                }
            } else {
                // 방문 추가
                let lat = Double(site.mapy ?? "0") ?? 0
                let lng = Double(site.mapx ?? "0") ?? 0
                let record = VisitRecord(
                    contentId: contentId,
                    title: site.title,
                    visitedAt: Date(),
                    lat: lat,
                    lng: lng,
                    thumbnail: site.firstimage2
                )
                do {
                    try await FirestoreService.shared.addVisitRecord(userId: user.uid, record: record)
                    visitedIds.insert(contentId)
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
                } catch {
                    print("방문 기록 추가 실패: \(error.localizedDescription)")
                }
            }
        }
    }

    // MARK: - 유틸리티

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate

extension MainViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tourSites.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: VisitCell.reuseIdentifier,
                for: indexPath
        ) as? VisitCell else {
            return UICollectionViewCell()
        }

        let site = tourSites[indexPath.item]
        let isVisited = visitedIds.contains(site.contentid)
        cell.configure(
            with: site,
            isVisited: isVisited,
            onToggle: { [weak self] in
                self?.toggleVisitCheck(for: site)
            }
        )
        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        let threshold = tourSites.count - 1
        if indexPath.item == threshold, !isLoading, useLocationBased,
           let location = locationManager.currentLocation {
            pageNo += 1
            Task {
                await self.fetchNearbySites(at: location)
            }
        }
    }
}

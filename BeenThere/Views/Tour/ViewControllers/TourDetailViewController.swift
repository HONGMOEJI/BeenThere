//
//  TourDetailViewController.swift
//  BeenThere
//
//  관광지 상세 정보 뷰컨트롤러 (방문 횟수 표시 추가)
//

import UIKit
import FirebaseAuth

class TourDetailViewController: UIViewController {
    private let contentId: String
    private let contentTypeId: Int
    private let detailView = TourDetailView()
    private var currentDetail: TourSiteDetail?

    init(contentId: String, contentTypeId: Int) {
        self.contentId = contentId
        self.contentTypeId = (1...99).contains(contentTypeId) ? contentTypeId : APIConstants.ContentTypes.tourSpot
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = detailView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupRecordButton()
        view.backgroundColor = .themeBackground
        loadDetail()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 네비게이션 바를 다시 표시
        navigationController?.setNavigationBarHidden(false, animated: animated)
        
        // 기록 작성 후 돌아올 때 방문 횟수 다시 로드
        loadVisitCount()
    }
    
    // MARK: - Navigation Setup
    private func setupNavigationBar() {
        // 뒤로가기 버튼 설정
        let backButton = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backButtonTapped)
        )
        backButton.tintColor = .white
        navigationItem.leftBarButtonItem = backButton
        
        // 네비게이션 바 스타일 설정
        navigationController?.navigationBar.backgroundColor = .clear
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        
        // 타이틀 설정 (처음에는 비어있다가 데이터 로드 후 설정)
        navigationItem.title = ""
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 17, weight: .semibold)
        ]
        
        // 공유 버튼 추가
        let shareButton = UIBarButtonItem(
            image: UIImage(systemName: "square.and.arrow.up"),
            style: .plain,
            target: self,
            action: #selector(shareButtonTapped)
        )
        shareButton.tintColor = .white
        navigationItem.rightBarButtonItem = shareButton
    }
    
    // MARK: - Record Button Setup
    private func setupRecordButton() {
        detailView.recordButton.addTarget(self, action: #selector(recordButtonTapped), for: .touchUpInside)
    }
    
    @objc private func backButtonTapped() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func shareButtonTapped() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
        
        // 현재 장소 정보 공유
        var items: [Any] = []
        if let title = navigationItem.title, !title.isEmpty {
            items.append("📍 \(title)")
        } else {
            items.append("📍 여행지 정보")
        }
        
        let activityViewController = UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )
        
        if let popover = activityViewController.popoverPresentationController {
            popover.barButtonItem = navigationItem.rightBarButtonItem
        }
        
        present(activityViewController, animated: true)
    }
    
    @objc private func recordButtonTapped() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
        
        guard let detail = currentDetail else {
            showAlert(title: "오류", message: "장소 정보를 불러오는 중입니다.")
            return
        }
        
        let recordVC = RecordViewController(tourSite: detail)
        let navController = UINavigationController(rootViewController: recordVC)
        navController.modalPresentationStyle = .pageSheet
        
        if let sheet = navController.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 20
        }
        
        present(navController, animated: true)
    }

    private func loadDetail() {
        Task {
            // 각각 독립적으로 처리하여 일부 실패해도 나머지는 표시
            let detailData = await fetchDetailSafely()
            let imageData = await fetchImagesSafely()
            let infoData = await fetchInfosSafely()
            
            await MainActor.run {
                // 기본 정보만 필수, 나머지는 옵셔널
                if let detailData = detailData {
                    self.currentDetail = detailData
                    self.detailView.configure(with: detailData, images: imageData, infos: infoData)
                    
                    // 네비게이션 타이틀 설정
                    self.navigationItem.title = detailData.title
                    
                    // 기록 버튼 활성화
                    self.detailView.recordButton.isEnabled = true
                    self.detailView.recordButton.alpha = 1.0
                    
                    // 방문 횟수 로드
                    self.loadVisitCount()
                } else {
                    // 기본 정보도 없으면 완전한 에러 상태
                    self.detailView.showEmptyState("상세 정보를 불러올 수 없습니다.")
                    self.navigationItem.title = "정보 없음"
                    
                    // 기록 버튼 비활성화
                    self.detailView.recordButton.isEnabled = false
                    self.detailView.recordButton.alpha = 0.5
                }
            }
        }
    }
    
    // MARK: - 방문 횟수 로딩
    private func loadVisitCount() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("❌ loadVisitCount: 사용자 인증 실패")
            return
        }
        
        print("🔍 loadVisitCount 시작 - userId: \(userId), contentId: \(contentId)")
        
        Task {
            do {
                let (records, count) = try await FirestoreService.shared.fetchVisitHistory(userId: userId, contentId: contentId)
                
                print("📊 방문 기록 조회 결과 - count: \(count), records: \(records.count)")
                
                await MainActor.run {
                    if count > 0 {
                        let message = generateVisitCountMessage(count: count)
                        self.detailView.updateVisitCount(count: count, message: message)
                        print("✅ 방문 횟수 메시지 생성: \(message)")
                    } else {
                        self.detailView.updateVisitCount(count: 0, message: "")
                        print("ℹ️ 첫 방문 - 메시지 없음")
                    }
                }
                
            } catch {
                print("❌ 방문 기록 로드 실패: \(error)")
                await MainActor.run {
                    self.detailView.updateVisitCount(count: 0, message: "")
                }
            }
        }
    }
    
    private func generateVisitCountMessage(count: Int) -> String {
        switch count {
        case 1:
            return "이미 1번 다녀오신 곳이네요!\n새로운 추억을 만들어보세요."
        case 2...4:
            return "이미 \(count)번 다녀오신 곳이네요!\n좋아하시는 장소인가 봐요."
        case 5...9:
            return "이미 \(count)번 다녀오신 곳이네요!\n단골 명소가 되었네요."
        default:
            return "이미 \(count)번 다녀오신 곳이네요!\n정말 특별한 장소인 것 같아요."
        }
    }
    
    // MARK: - Safe Fetch Methods
    private func fetchDetailSafely() async -> TourSiteDetail? {
        do {
            return try await TourAPIService.shared.fetchDetailInfo(contentId: contentId)
        } catch {
            print("상세정보 로드 실패: \(error)")
            return nil
        }
    }
    
    private func fetchImagesSafely() async -> [TourSiteImage] {
        do {
            return try await TourAPIService.shared.fetchImages(contentId: contentId)
        } catch {
            print("이미지 로드 실패: \(error)")
            return []
        }
    }
    
    private func fetchInfosSafely() async -> [DetailInfo] {
        do {
            return try await TourAPIService.shared.fetchDetailInfo2(contentId: contentId, contentTypeId: contentTypeId)
        } catch {
            print("상세정보2 로드 실패: \(error)")
            return []
        }
    }
    
    // MARK: - Helper Methods
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Status Bar
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

//
//  RecordDetailViewController.swift
//  BeenThere
//
//  방문 기록 상세보기 화면
//

import UIKit
import Combine
import FirebaseAuth

class RecordDetailViewController: UIViewController {
    private var record: VisitRecord // ← var로 변경!
    private let detailView = RecordDetailView()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Init
    init(record: VisitRecord) {
        self.record = record
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Lifecycle
    override func loadView() {
        view = detailView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupActions()
        configureView()
    }
    
    // MARK: - Setup Methods
    private func setupNavigationBar() {
        title = "기록 상세"
        
        // 네비게이션 바 스타일
        if let navigationBar = navigationController?.navigationBar {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .themeBackground
            appearance.shadowColor = .clear
            
            appearance.titleTextAttributes = [
                .foregroundColor: UIColor.themeTextPrimary,
                .font: UIFont.navigationTitle
            ]
            
            navigationBar.standardAppearance = appearance
            navigationBar.scrollEdgeAppearance = appearance
            navigationBar.compactAppearance = appearance
            navigationBar.tintColor = .themeTextPrimary
        }
        
        // 수정 버튼
        let editButton = UIBarButtonItem(
            title: "수정",
            style: .plain,
            target: self,
            action: #selector(editTapped)
        )
        editButton.tintColor = .themeTextPrimary
        navigationItem.rightBarButtonItem = editButton
    }
    
    private func setupActions() {
        detailView.deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
    }
    
    private func configureView() {
        detailView.configure(with: record)
    }
    
    // MARK: - Actions
    @objc private func editTapped() {
        print("🚀 [DEBUG] editTapped 시작")
        print("🚀 [DEBUG] 현재 record: \(record.placeTitle)")
        
        let editViewModel = RecordViewModel(record: record)
        let editVC = RecordViewController(viewModel: editViewModel, mode: .edit)
        let navController = UINavigationController(rootViewController: editVC)
        
        editVC.onSaveCompletion = { [weak self] updatedRecord in
            print("🎯 [DEBUG] onSaveCompletion 콜백 호출됨!")
            print("🎯 [DEBUG] 원본 제목: \(self?.record.placeTitle ?? "nil")")
            print("🎯 [DEBUG] 새 제목: \(updatedRecord.placeTitle)")
            print("🎯 [DEBUG] 새 내용: \(updatedRecord.content)")
            print("🎯 [DEBUG] 새 평점: \(updatedRecord.rating)")
            
            guard let self = self else {
                print("❌ [DEBUG] self가 nil입니다")
                return
            }
            
            print("📱 [DEBUG] 메인 스레드로 이동 중...")
            DispatchQueue.main.async {
                print("📱 [DEBUG] 메인 스레드에서 dismiss 시작")
                navController.dismiss(animated: true) {
                    print("✅ [DEBUG] dismiss 완료")
                    
                    // UI 업데이트 전에 현재 상태 확인
                    print("🔍 [DEBUG] 업데이트 전 DetailView 상태:")
                    print("  - placeTitleLabel: \(self.detailView.placeTitleLabel.text ?? "nil")")
                    print("  - contentTextView: \(self.detailView.contentTextView.text ?? "nil")")
                    
                    self.updateDetail(with: updatedRecord)
                    
                    // UI 업데이트 후 상태 확인
                    print("🔍 [DEBUG] 업데이트 후 DetailView 상태:")
                    print("  - placeTitleLabel: \(self.detailView.placeTitleLabel.text ?? "nil")")
                    print("  - contentTextView: \(self.detailView.contentTextView.text ?? "nil")")
                    
                    // 알림 발송
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        print("🔔 [DEBUG] 알림 발송 중...")
                        NotificationCenter.default.post(
                            name: NSNotification.Name("RecordUpdated"),
                            object: updatedRecord
                        )
                        print("✅ [DEBUG] RecordUpdated 알림 발송 완료")
                    }
                }
            }
        }
        
        print("🚀 [DEBUG] 모달 present 중...")
        present(navController, animated: true) {
            print("✅ [DEBUG] 모달 present 완료")
        }
    }

    // 상세뷰 갱신 메서드
    func updateDetail(with updatedRecord: VisitRecord) {
        print("🔄 [DEBUG] updateDetail 시작")
        print("🔄 [DEBUG] 스레드: \(Thread.isMainThread ? "Main" : "Background")")
        
        let updateClosure = { [weak self] in
            guard let self = self else {
                print("❌ [DEBUG] updateDetail에서 self가 nil")
                return
            }
            
            print("📝 [DEBUG] 기록 업데이트 중...")
            print("  - 이전: \(self.record.placeTitle)")
            print("  - 새로운: \(updatedRecord.placeTitle)")
            
            // 기록 업데이트
            self.record = updatedRecord
            
            print("🖼️ [DEBUG] detailView.configure 호출 중...")
            self.detailView.configure(with: updatedRecord)
            
            print("🔧 [DEBUG] 강제 레이아웃 업데이트 중...")
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
            
            print("✅ [DEBUG] updateDetail 완료")
        }
        
        if Thread.isMainThread {
            print("📱 [DEBUG] 이미 메인 스레드에서 실행")
            updateClosure()
        } else {
            print("📱 [DEBUG] 메인 스레드로 이동")
            DispatchQueue.main.async(execute: updateClosure)
        }
    }
    
    @objc private func deleteTapped() {
        showDeleteConfirmAlert()
    }
    
    // MARK: - Alert Methods
    private func showDeleteConfirmAlert() {
        let alert = UIAlertController(
            title: "기록 삭제",
            message: "'\(record.placeTitle)' 기록을 삭제하시겠습니까?\n삭제된 기록은 복구할 수 없습니다.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "삭제", style: .destructive) { [weak self] _ in
            self?.deleteRecord()
        })
        
        present(alert, animated: true)
    }
    
    private func deleteRecord() {
        Task {
            do {
                guard let userId = Auth.auth().currentUser?.uid else {
                    showErrorAlert("로그인이 필요합니다.")
                    return
                }
                
                try await FirestoreService.shared.deleteVisitRecord(
                    userId: userId,
                    visitedAt: record.visitedAt,
                    contentId: record.contentId
                )
                
                DispatchQueue.main.async { [weak self] in
                    // 삭제 완료 후 이전 화면으로 돌아가면서 알림
                    self?.navigationController?.popViewController(animated: true)
                    NotificationCenter.default.post(
                        name: NSNotification.Name("RecordDeleted"),
                        object: self?.record
                    )
                }
                
            } catch {
                DispatchQueue.main.async { [weak self] in
                    self?.showErrorAlert("기록 삭제에 실패했습니다.")
                }
            }
        }
    }
    
    private func showErrorAlert(_ message: String) {
        let alert = UIAlertController(
            title: "오류",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}

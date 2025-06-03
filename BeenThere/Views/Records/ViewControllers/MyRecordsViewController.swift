//
//  MyRecordsViewController.swift
//  BeenThere
//
//  내 기록 뷰컨트롤러
//

import UIKit
import Combine

class MyRecordsViewController: UIViewController {
    private let viewModel = MyRecordsViewModel()
    private let myRecordsView = MyRecordsView()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - View Lifecycle
    override func loadView() {
        view = myRecordsView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupBindings()
        setupActions()
        setupCollectionView()
        setupNotificationObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 네비게이션 바 숨기기
        navigationController?.setNavigationBarHidden(true, animated: animated)
        // 기록 추가/수정 후 돌아올 때 새로고침
        viewModel.refreshCurrentDate()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // 다른 화면으로 이동할 때 네비게이션 바 다시 표시
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    // MARK: - Notification Setup (새로 추가)
    private func setupNotificationObservers() {
        // 기록 업데이트 알림 수신
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleRecordUpdated(_:)),
            name: NSNotification.Name("RecordUpdated"),
            object: nil
        )
        
        // 기록 삭제 알림 수신
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleRecordDeleted(_:)),
            name: NSNotification.Name("RecordDeleted"),
            object: nil
        )
    }

    // MARK: - Notification Handlers (새로 추가)
    @objc private func handleRecordUpdated(_ notification: Notification) {
        print("🔔 RecordUpdated 알림 받음")
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // 현재 선택된 날짜의 기록들을 다시 로드
            self.viewModel.refreshCurrentDate()
            
            print("✅ MyRecords 새로고침 완료")
        }
    }

    @objc private func handleRecordDeleted(_ notification: Notification) {
        print("🔔 RecordDeleted 알림 받음")
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // 현재 선택된 날짜의 기록들을 다시 로드
            self.viewModel.refreshCurrentDate()
            
            print("✅ MyRecords 새로고침 완료 (삭제)")
        }
    }

    // MARK: - Cleanup (새로 추가)
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Setup Methods
    private func setupView() {
        // 네비게이션 바 관련 설정 제거
        // 상태바 스타일 설정
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .dark
        }
    }
    
    private func setupBindings() {
        viewModel.$selectedDate
            .receive(on: DispatchQueue.main)
            .sink { [weak self] date in
                self?.myRecordsView.updateDateLabel(date)
                self?.myRecordsView.datePicker.date = date
            }
            .store(in: &cancellables)
        
        viewModel.$records
            .receive(on: DispatchQueue.main)
            .sink { [weak self] records in
                guard let self = self else { return }
                self.myRecordsView.updateRecordCount(records.count)
                let isEmpty = records.isEmpty && !self.viewModel.isLoading
                self.myRecordsView.showEmptyState(isEmpty)
                self.myRecordsView.timelineCollectionView.reloadData()
            }
            .store(in: &cancellables)
        
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                self?.myRecordsView.showLoading(isLoading)
                
                if let self = self {
                    let isEmpty = self.viewModel.records.isEmpty && !isLoading
                    self.myRecordsView.showEmptyState(isEmpty)
                }
            }
            .store(in: &cancellables)
        
        viewModel.$showError
            .receive(on: DispatchQueue.main)
            .sink { [weak self] showError in
                if showError {
                    self?.showErrorAlert()
                }
            }
            .store(in: &cancellables)
    }
    
    private func setupActions() {
        myRecordsView.datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        myRecordsView.todayButton.addTarget(self, action: #selector(todayTapped), for: .touchUpInside)
        myRecordsView.refreshButton.addTarget(self, action: #selector(refreshTapped), for: .touchUpInside)
    }
    
    private func setupCollectionView() {
        myRecordsView.timelineCollectionView.dataSource = self
        myRecordsView.timelineCollectionView.delegate = self
        myRecordsView.timelineCollectionView.register(RecordCardCell.self, forCellWithReuseIdentifier: RecordCardCell.identifier)
    }
    
    // MARK: - Actions
    @objc private func dateChanged(_ sender: UIDatePicker) {
        viewModel.selectDate(sender.date)
    }
    
    @objc private func todayTapped() {
        viewModel.selectToday()
    }
    
    @objc private func refreshTapped() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        viewModel.refreshCurrentDate()
    }
    
    // MARK: - Alert Methods
    private func showErrorAlert() {
        let alert = UIAlertController(
            title: "오류",
            message: viewModel.errorMessage,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
    
    private func showDeleteConfirmAlert(for record: VisitRecord) {
        let alert = UIAlertController(
            title: "기록 삭제",
            message: "'\(record.placeTitle)' 기록을 삭제하시겠습니까?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "삭제", style: .destructive) { [weak self] _ in
            Task {
                await self?.viewModel.deleteRecord(record)
            }
        })
        
        present(alert, animated: true)
    }
}

// MARK: - UICollectionViewDataSource & Delegate
extension MyRecordsViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.records.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecordCardCell.identifier, for: indexPath) as! RecordCardCell
        cell.configure(with: viewModel.records[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let record = viewModel.records[indexPath.item]
        let detailVC = RecordDetailViewController(record: record)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

// MARK: - UICollectionViewFlowLayout
extension MyRecordsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // 전체 폭으로 변경 (좌우 여백 20씩)
        let width = collectionView.frame.width - 40
        let height: CGFloat = 200 // 높이 줄임
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
}

//
//  MyRecordsViewController.swift
//  BeenThere
//
//  내 기록 뷰컨트롤러 (날짜범위 + 검색 지원)
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
        setupBindings()
        setupActions()
        setupCollectionView()
        setupNotificationObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        viewModel.refreshCurrentRange()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    // MARK: - Notification Setup
    private func setupNotificationObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleRecordUpdated(_:)),
            name: NSNotification.Name("RecordUpdated"),
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleRecordDeleted(_:)),
            name: NSNotification.Name("RecordDeleted"),
            object: nil
        )
    }

    @objc private func handleRecordUpdated(_ notification: Notification) {
        DispatchQueue.main.async { [weak self] in
            self?.viewModel.refreshCurrentRange()
        }
    }

    @objc private func handleRecordDeleted(_ notification: Notification) {
        DispatchQueue.main.async { [weak self] in
            self?.viewModel.refreshCurrentRange()
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Bindings
    private func setupBindings() {
        Publishers.CombineLatest(viewModel.$startDate, viewModel.$endDate)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] start, end in
                self?.myRecordsView.updateDateLabels(start: start, end: end)
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
    
    // MARK: - Actions
    private func setupActions() {
        myRecordsView.startDatePicker.addTarget(self, action: #selector(startDateChanged(_:)), for: .valueChanged)
        myRecordsView.endDatePicker.addTarget(self, action: #selector(endDateChanged(_:)), for: .valueChanged)
        myRecordsView.todayButton.addTarget(self, action: #selector(todayTapped), for: .touchUpInside)
        myRecordsView.refreshButton.addTarget(self, action: #selector(refreshTapped), for: .touchUpInside)
        
        // 커스텀 검색 텍스트 필드 이벤트 추가
        myRecordsView.searchTextField.addTarget(self, action: #selector(searchTextChanged(_:)), for: .editingChanged)
    }
    
    @objc private func startDateChanged(_ sender: UIDatePicker) {
        let end = viewModel.endDate
        let newStart = sender.date
        if newStart > end {
            viewModel.selectDateRange(start: end, end: end)
        } else {
            viewModel.selectDateRange(start: newStart, end: end)
        }
    }
    
    @objc private func endDateChanged(_ sender: UIDatePicker) {
        let start = viewModel.startDate
        let newEnd = sender.date
        if newEnd < start {
            viewModel.selectDateRange(start: start, end: start)
        } else {
            viewModel.selectDateRange(start: start, end: newEnd)
        }
    }
    
    @objc private func todayTapped() {
        viewModel.selectToday()
    }
    
    @objc private func refreshTapped() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        viewModel.refreshCurrentRange()
    }
    
    @objc private func searchTextChanged(_ textField: UITextField) {
        viewModel.searchQuery = textField.text ?? ""
    }
    
    // MARK: - CollectionView
    private func setupCollectionView() {
        myRecordsView.timelineCollectionView.dataSource = self
        myRecordsView.timelineCollectionView.delegate = self
        myRecordsView.timelineCollectionView.register(RecordCardCell.self, forCellWithReuseIdentifier: RecordCardCell.identifier)
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
    
    // MARK: - CollectionView DataSource & Delegate
}

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

extension MyRecordsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width - 40
        let height: CGFloat = 200
        return CGSize(width: width, height: height)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
}

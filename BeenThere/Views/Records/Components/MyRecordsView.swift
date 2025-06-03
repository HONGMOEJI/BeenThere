//
//  MyRecordsView.swift
//  BeenThere
//
//  내 기록 뷰 - 날짜별 타임라인
//

import UIKit

class MyRecordsView: UIView {
    // MARK: - UI Components
    let scrollView = UIScrollView()
    let contentView = UIView()
    
    // 헤더 섹션 (제목 + 새로고침 버튼)
    let headerContainer = UIView()
    let titleLabel = UILabel()
    let refreshButton = UIButton(type: .system)
    
    // 날짜 선택 섹션
    let dateSelectionContainer = UIView()
    let dateLabel = UILabel()
    let datePicker = UIDatePicker()
    let todayButton = UIButton(type: .system)
    
    // 타임라인 섹션
    let timelineContainer = UIView()
    let timelineHeaderView = UIView()
    let timelineLabel = UILabel()
    let recordCountLabel = UILabel()
    let emptyStateView = UIView()
    let emptyIconLabel = UILabel()
    let emptyMessageLabel = UILabel()
    let timelineCollectionView: UICollectionView
    
    // 로딩 인디케이터
    let loadingIndicator = UIActivityIndicatorView(style: .medium)
    
    // MARK: - Init
    override init(frame: CGRect) {
        // 컬렉션뷰 레이아웃 설정 - 1열로 변경
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        
        timelineCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        super.init(frame: frame)
        backgroundColor = .themeBackground
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        setupScrollView()
        setupHeader()
        setupDateSelection()
        setupTimelineSection()
        setupEmptyState()
        setupLoadingIndicator()
        setupConstraints()
    }
    
    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.backgroundColor = .themeBackground
        contentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(scrollView)
        scrollView.addSubview(contentView)
    }
    
    private func setupHeader() {
        headerContainer.translatesAutoresizingMaskIntoConstraints = false
        
        // 제목 레이블
        titleLabel.text = "내 기록"
        titleLabel.font = .systemFont(ofSize: 32, weight: .bold)
        titleLabel.textColor = .themeTextPrimary
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // 새로고침 버튼
        refreshButton.setImage(UIImage(systemName: "arrow.clockwise"), for: .normal)
        refreshButton.tintColor = .themeTextSecondary
        refreshButton.backgroundColor = UIColor.white.withAlphaComponent(0.05)
        refreshButton.layer.cornerRadius = 20
        refreshButton.translatesAutoresizingMaskIntoConstraints = false
        
        headerContainer.addSubview(titleLabel)
        headerContainer.addSubview(refreshButton)
    }
    
    private func setupDateSelection() {
        dateSelectionContainer.backgroundColor = UIColor.white.withAlphaComponent(0.03)
        dateSelectionContainer.layer.cornerRadius = 16
        dateSelectionContainer.layer.borderWidth = 1
        dateSelectionContainer.layer.borderColor = UIColor.white.withAlphaComponent(0.08).cgColor
        dateSelectionContainer.translatesAutoresizingMaskIntoConstraints = false
        
        // 날짜 레이블
        dateLabel.text = formatDate(Date())
        dateLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        dateLabel.textColor = .themeTextPrimary
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // 날짜 피커
        datePicker.timeZone = TimeZone(identifier: "Asia/Seoul")
        datePicker.locale = Locale(identifier: "ko_KR")
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.maximumDate = Date()
        datePicker.overrideUserInterfaceStyle = .dark
        datePicker.backgroundColor = .clear
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        
        // 오늘 버튼
        todayButton.setTitle("오늘", for: .normal)
        todayButton.setTitleColor(.white, for: .normal)
        todayButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        todayButton.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        todayButton.layer.cornerRadius = 8
        todayButton.translatesAutoresizingMaskIntoConstraints = false
        
        dateSelectionContainer.addSubview(dateLabel)
        dateSelectionContainer.addSubview(datePicker)
        dateSelectionContainer.addSubview(todayButton)
    }
    
    private func setupTimelineSection() {
        timelineContainer.translatesAutoresizingMaskIntoConstraints = false
        
        // 헤더
        timelineHeaderView.translatesAutoresizingMaskIntoConstraints = false
        
        timelineLabel.text = "오늘의 기록"
        timelineLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        timelineLabel.textColor = .themeTextPrimary
        timelineLabel.translatesAutoresizingMaskIntoConstraints = false
        
        recordCountLabel.text = "0곳"
        recordCountLabel.font = .systemFont(ofSize: 14, weight: .medium)
        recordCountLabel.textColor = .themeTextSecondary
        recordCountLabel.translatesAutoresizingMaskIntoConstraints = false
        
        timelineHeaderView.addSubview(timelineLabel)
        timelineHeaderView.addSubview(recordCountLabel)
        
        // 컬렉션뷰
        timelineCollectionView.backgroundColor = .clear
        timelineCollectionView.showsVerticalScrollIndicator = false
        timelineCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        timelineContainer.addSubview(timelineHeaderView)
        timelineContainer.addSubview(timelineCollectionView)
    }
    
    private func setupEmptyState() {
        emptyStateView.translatesAutoresizingMaskIntoConstraints = false
        emptyStateView.isHidden = true
        
        emptyIconLabel.text = "📝"
        emptyIconLabel.font = .systemFont(ofSize: 48)
        emptyIconLabel.textAlignment = .center
        emptyIconLabel.translatesAutoresizingMaskIntoConstraints = false
        
        emptyMessageLabel.text = "선택한 날짜에 기록이 없습니다.\n새로운 여행 기록을 만들어보세요!"
        emptyMessageLabel.font = .systemFont(ofSize: 16, weight: .medium)
        emptyMessageLabel.textColor = .themeTextSecondary
        emptyMessageLabel.textAlignment = .center
        emptyMessageLabel.numberOfLines = 0
        emptyMessageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        emptyStateView.addSubview(emptyIconLabel)
        emptyStateView.addSubview(emptyMessageLabel)
        
        timelineContainer.addSubview(emptyStateView)
    }
    
    private func setupLoadingIndicator() {
        loadingIndicator.color = .themeTextSecondary
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        timelineContainer.addSubview(loadingIndicator)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // ScrollView
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: widthAnchor),
        ])
        
        // 컨테이너들을 contentView에 추가
        [headerContainer, dateSelectionContainer, timelineContainer].forEach {
            contentView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            // 헤더 컨테이너
            headerContainer.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            headerContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            headerContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            headerContainer.heightAnchor.constraint(equalToConstant: 44),
            
            titleLabel.leadingAnchor.constraint(equalTo: headerContainer.leadingAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: headerContainer.centerYAnchor),
            
            refreshButton.trailingAnchor.constraint(equalTo: headerContainer.trailingAnchor),
            refreshButton.centerYAnchor.constraint(equalTo: headerContainer.centerYAnchor),
            refreshButton.widthAnchor.constraint(equalToConstant: 40),
            refreshButton.heightAnchor.constraint(equalToConstant: 40),
            
            // 날짜 선택 컨테이너
            dateSelectionContainer.topAnchor.constraint(equalTo: headerContainer.bottomAnchor, constant: 20),
            dateSelectionContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            dateSelectionContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            dateLabel.topAnchor.constraint(equalTo: dateSelectionContainer.topAnchor, constant: 20),
            dateLabel.leadingAnchor.constraint(equalTo: dateSelectionContainer.leadingAnchor, constant: 20),
            
            todayButton.centerYAnchor.constraint(equalTo: dateLabel.centerYAnchor),
            todayButton.trailingAnchor.constraint(equalTo: dateSelectionContainer.trailingAnchor, constant: -20),
            todayButton.widthAnchor.constraint(equalToConstant: 50),
            todayButton.heightAnchor.constraint(equalToConstant: 32),
            
            datePicker.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 16),
            datePicker.leadingAnchor.constraint(equalTo: dateLabel.leadingAnchor),
            datePicker.bottomAnchor.constraint(equalTo: dateSelectionContainer.bottomAnchor, constant: -20),
            
            // 타임라인 컨테이너
            timelineContainer.topAnchor.constraint(equalTo: dateSelectionContainer.bottomAnchor, constant: 20),
            timelineContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            timelineContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            timelineContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            // 타임라인 헤더
            timelineHeaderView.topAnchor.constraint(equalTo: timelineContainer.topAnchor),
            timelineHeaderView.leadingAnchor.constraint(equalTo: timelineContainer.leadingAnchor, constant: 20),
            timelineHeaderView.trailingAnchor.constraint(equalTo: timelineContainer.trailingAnchor, constant: -20),
            timelineHeaderView.heightAnchor.constraint(equalToConstant: 44),
            
            timelineLabel.leadingAnchor.constraint(equalTo: timelineHeaderView.leadingAnchor),
            timelineLabel.centerYAnchor.constraint(equalTo: timelineHeaderView.centerYAnchor),
            
            recordCountLabel.leadingAnchor.constraint(equalTo: timelineLabel.trailingAnchor, constant: 8),
            recordCountLabel.centerYAnchor.constraint(equalTo: timelineHeaderView.centerYAnchor),
            
            // 컬렉션뷰
            timelineCollectionView.topAnchor.constraint(equalTo: timelineHeaderView.bottomAnchor),
            timelineCollectionView.leadingAnchor.constraint(equalTo: timelineContainer.leadingAnchor),
            timelineCollectionView.trailingAnchor.constraint(equalTo: timelineContainer.trailingAnchor),
            timelineCollectionView.heightAnchor.constraint(equalToConstant: 600),
            timelineCollectionView.bottomAnchor.constraint(equalTo: timelineContainer.bottomAnchor),
            
            // 빈 상태 뷰
            emptyStateView.centerXAnchor.constraint(equalTo: timelineCollectionView.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: timelineCollectionView.centerYAnchor),
            emptyStateView.leadingAnchor.constraint(greaterThanOrEqualTo: timelineCollectionView.leadingAnchor, constant: 20),
            emptyStateView.trailingAnchor.constraint(lessThanOrEqualTo: timelineCollectionView.trailingAnchor, constant: -20),
            
            emptyIconLabel.topAnchor.constraint(equalTo: emptyStateView.topAnchor),
            emptyIconLabel.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            
            emptyMessageLabel.topAnchor.constraint(equalTo: emptyIconLabel.bottomAnchor, constant: 16),
            emptyMessageLabel.leadingAnchor.constraint(equalTo: emptyStateView.leadingAnchor),
            emptyMessageLabel.trailingAnchor.constraint(equalTo: emptyStateView.trailingAnchor),
            emptyMessageLabel.bottomAnchor.constraint(equalTo: emptyStateView.bottomAnchor),
            
            // 로딩 인디케이터
            loadingIndicator.centerXAnchor.constraint(equalTo: timelineCollectionView.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: timelineCollectionView.centerYAnchor)
        ])
    }
    
    // MARK: - Public Methods
    func updateDateLabel(_ date: Date) {
        dateLabel.text = formatDate(date)
        
        let calendar = Calendar.current
        let isToday = calendar.isDateInToday(date)
        timelineLabel.text = isToday ? "오늘의 기록" : formatDate(date) + " 기록"
    }
    
    func updateRecordCount(_ count: Int) {
        recordCountLabel.text = "\(count)곳"
    }
    
    func showEmptyState(_ show: Bool) {
        emptyStateView.isHidden = !show
        timelineCollectionView.isHidden = show
    }
    
    func showLoading(_ show: Bool) {
        if show {
            loadingIndicator.startAnimating()
        } else {
            loadingIndicator.stopAnimating()
        }
        emptyStateView.isHidden = show
        timelineCollectionView.isHidden = show
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월 d일 (E)"
        return formatter.string(from: date)
    }
}

//
//  MyRecordsView.swift
//  BeenThere
//
//  내 기록 뷰
//

import UIKit

class MyRecordsView: UIView {
    // MARK: - UI Components
    let scrollView = UIScrollView()
    let contentView = UIView()
    
    // 헤더
    let headerContainer = UIView()
    let titleLabel = UILabel()
    let refreshButton = UIButton(type: .system)
    
    // 날짜 범위 선택
    let dateRangeContainer = UIView()
    let startDateLabel = UILabel()
    let startDatePicker = UIDatePicker()
    let endDateLabel = UILabel()
    let endDatePicker = UIDatePicker()
    let todayButton = UIButton(type: .system)
    
    // 검색 (커스텀)
    let searchContainer = UIView()
    let searchIconImageView = UIImageView()
    let searchTextField = UITextField()
    
    // 타임라인
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
        setupDateRange()
        setupSearchBar()
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
        titleLabel.text = "내 기록"
        titleLabel.font = .systemFont(ofSize: 32, weight: .bold)
        titleLabel.textColor = .themeTextPrimary
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        refreshButton.setImage(UIImage(systemName: "arrow.clockwise"), for: .normal)
        refreshButton.tintColor = .themeTextSecondary
        refreshButton.backgroundColor = UIColor.white.withAlphaComponent(0.05)
        refreshButton.layer.cornerRadius = 20
        refreshButton.translatesAutoresizingMaskIntoConstraints = false
        headerContainer.addSubview(titleLabel)
        headerContainer.addSubview(refreshButton)
    }
    
    private func setupDateRange() {
        dateRangeContainer.translatesAutoresizingMaskIntoConstraints = false
        dateRangeContainer.backgroundColor = UIColor.white.withAlphaComponent(0.03)
        dateRangeContainer.layer.cornerRadius = 16
        dateRangeContainer.layer.borderWidth = 1
        dateRangeContainer.layer.borderColor = UIColor.white.withAlphaComponent(0.08).cgColor
        
        startDateLabel.text = "시작"
        startDateLabel.font = .systemFont(ofSize: 16, weight: .medium)
        startDateLabel.textColor = .themeTextPrimary
        startDateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        startDatePicker.timeZone = TimeZone(identifier: "Asia/Seoul")
        startDatePicker.locale = Locale(identifier: "ko_KR")
        startDatePicker.datePickerMode = .date
        startDatePicker.preferredDatePickerStyle = .compact
        startDatePicker.maximumDate = Date()
        startDatePicker.overrideUserInterfaceStyle = .dark
        startDatePicker.translatesAutoresizingMaskIntoConstraints = false
        
        endDateLabel.text = "종료"
        endDateLabel.font = .systemFont(ofSize: 16, weight: .medium)
        endDateLabel.textColor = .themeTextPrimary
        endDateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        endDatePicker.timeZone = TimeZone(identifier: "Asia/Seoul")
        endDatePicker.locale = Locale(identifier: "ko_KR")
        endDatePicker.datePickerMode = .date
        endDatePicker.preferredDatePickerStyle = .compact
        endDatePicker.maximumDate = Date()
        endDatePicker.overrideUserInterfaceStyle = .dark
        endDatePicker.translatesAutoresizingMaskIntoConstraints = false
        
        todayButton.setTitle("오늘", for: .normal)
        todayButton.setTitleColor(.white, for: .normal)
        todayButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        todayButton.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        todayButton.layer.cornerRadius = 8
        todayButton.translatesAutoresizingMaskIntoConstraints = false
        
        dateRangeContainer.addSubview(startDateLabel)
        dateRangeContainer.addSubview(startDatePicker)
        dateRangeContainer.addSubview(endDateLabel)
        dateRangeContainer.addSubview(endDatePicker)
        dateRangeContainer.addSubview(todayButton)
    }
    
    private func setupSearchBar() {
        searchContainer.translatesAutoresizingMaskIntoConstraints = false
        searchContainer.backgroundColor = UIColor.white.withAlphaComponent(0.03)
        searchContainer.layer.cornerRadius = 16
        searchContainer.layer.borderWidth = 1
        searchContainer.layer.borderColor = UIColor.white.withAlphaComponent(0.08).cgColor
        
        // 검색 아이콘 설정
        searchIconImageView.image = UIImage(systemName: "magnifyingglass")
        searchIconImageView.tintColor = UIColor.white.withAlphaComponent(0.6)
        searchIconImageView.contentMode = .scaleAspectFit
        searchIconImageView.translatesAutoresizingMaskIntoConstraints = false
        
        // 텍스트 필드 설정
        searchTextField.placeholder = "장소/내용/태그 검색"
        searchTextField.font = .systemFont(ofSize: 16)
        searchTextField.textColor = .themeTextPrimary
        searchTextField.backgroundColor = .clear
        searchTextField.borderStyle = .none
        searchTextField.returnKeyType = .search
        searchTextField.translatesAutoresizingMaskIntoConstraints = false
        
        // 플레이스홀더 색상 설정
        searchTextField.attributedPlaceholder = NSAttributedString(
            string: "장소/내용/태그 검색",
            attributes: [
                NSAttributedString.Key.foregroundColor: UIColor.white.withAlphaComponent(0.6)
            ]
        )
        
        searchContainer.addSubview(searchIconImageView)
        searchContainer.addSubview(searchTextField)
    }
    
    private func setupTimelineSection() {
        timelineContainer.translatesAutoresizingMaskIntoConstraints = false
        timelineHeaderView.translatesAutoresizingMaskIntoConstraints = false
        timelineLabel.text = "기록 타임라인"
        timelineLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        timelineLabel.textColor = .themeTextPrimary
        timelineLabel.translatesAutoresizingMaskIntoConstraints = false
        recordCountLabel.text = "0곳"
        recordCountLabel.font = .systemFont(ofSize: 14, weight: .medium)
        recordCountLabel.textColor = .themeTextSecondary
        recordCountLabel.translatesAutoresizingMaskIntoConstraints = false
        timelineHeaderView.addSubview(timelineLabel)
        timelineHeaderView.addSubview(recordCountLabel)
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
        emptyMessageLabel.text = "해당 기간과 조건에 맞는 기록이 없습니다.\n새로운 여행 기록을 만들어보세요!"
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
        [headerContainer, dateRangeContainer, searchContainer, timelineContainer].forEach {
            contentView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            // 헤더
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
            
            // 날짜 범위 컨테이너
            dateRangeContainer.topAnchor.constraint(equalTo: headerContainer.bottomAnchor, constant: 16),
            dateRangeContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            dateRangeContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            dateRangeContainer.heightAnchor.constraint(equalToConstant: 120),
            
            // 시작일 라벨과 피커를 컨테이너의 상단 1/2에 중앙 정렬
            startDateLabel.leadingAnchor.constraint(equalTo: dateRangeContainer.leadingAnchor, constant: 20),
            startDateLabel.centerYAnchor.constraint(equalTo: dateRangeContainer.topAnchor, constant: 30),
            startDatePicker.leadingAnchor.constraint(equalTo: startDateLabel.trailingAnchor, constant: 8),
            startDatePicker.centerYAnchor.constraint(equalTo: startDateLabel.centerYAnchor),
            
            // 종료일 라벨과 피커를 컨테이너의 하단 1/2에 중앙 정렬
            endDateLabel.leadingAnchor.constraint(equalTo: dateRangeContainer.leadingAnchor, constant: 20),
            endDateLabel.centerYAnchor.constraint(equalTo: dateRangeContainer.topAnchor, constant: 90),
            endDatePicker.leadingAnchor.constraint(equalTo: endDateLabel.trailingAnchor, constant: 8),
            endDatePicker.centerYAnchor.constraint(equalTo: endDateLabel.centerYAnchor),
            
            // 오늘 버튼을 하단 라인에 우측 정렬
            todayButton.centerYAnchor.constraint(equalTo: endDatePicker.centerYAnchor),
            todayButton.trailingAnchor.constraint(equalTo: dateRangeContainer.trailingAnchor, constant: -20),
            todayButton.widthAnchor.constraint(equalToConstant: 50),
            todayButton.heightAnchor.constraint(equalToConstant: 32),
            
            // 커스텀 검색 컨테이너
            searchContainer.topAnchor.constraint(equalTo: dateRangeContainer.bottomAnchor, constant: 16),
            searchContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            searchContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            searchContainer.heightAnchor.constraint(equalToConstant: 50),
            
            // 검색 아이콘
            searchIconImageView.leadingAnchor.constraint(equalTo: searchContainer.leadingAnchor, constant: 16),
            searchIconImageView.centerYAnchor.constraint(equalTo: searchContainer.centerYAnchor),
            searchIconImageView.widthAnchor.constraint(equalToConstant: 20),
            searchIconImageView.heightAnchor.constraint(equalToConstant: 20),
            
            // 검색 텍스트 필드
            searchTextField.leadingAnchor.constraint(equalTo: searchIconImageView.trailingAnchor, constant: 12),
            searchTextField.trailingAnchor.constraint(equalTo: searchContainer.trailingAnchor, constant: -16),
            searchTextField.centerYAnchor.constraint(equalTo: searchContainer.centerYAnchor),
            searchTextField.heightAnchor.constraint(equalToConstant: 30),
            
            // 타임라인 컨테이너
            timelineContainer.topAnchor.constraint(equalTo: searchContainer.bottomAnchor, constant: 16),
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
    func updateDateLabels(start: Date, end: Date) {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월 d일 (E)"
        startDateLabel.text = "시작일 "
        endDateLabel.text = "종료일 "
        startDatePicker.date = start
        endDatePicker.date = end
        let calendar = Calendar.current
        let isToday = calendar.isDateInToday(end)
        timelineLabel.text = isToday ? "오늘까지의 기록" : "\(formatter.string(from: start)) ~ \(formatter.string(from: end))"
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
}

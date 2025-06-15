//
//  ProfileView.swift
//  BeenThere
//
//  내정보 뷰 (헤더 스타일 수정)
//

import UIKit

class ProfileView: UIView {
    // MARK: - UI Components
    let scrollView = UIScrollView()
    let contentView = UIView()
    
    // 헤더 (내 기록 스타일과 동일하게)
    let headerContainer = UIView()
    let titleLabel = UILabel()
    let refreshButton = UIButton(type: .system)
    
    // 프로필 섹션
    let profileContainer = UIView()
    let profileImageView = UIImageView()
    let nameLabel = UILabel()
    let emailLabel = UILabel()
    let joinDateLabel = UILabel()
    
    // 통계 섹션
    let statisticsContainer = UIView()
    let statisticsHeaderLabel = UILabel()
    let statsStackView = UIStackView()
    
    // 배지 섹션
    let badgesContainer = UIView()
    let badgesHeaderLabel = UILabel()
    let badgesCollectionView: UICollectionView
    
    // 설정 섹션
    let settingsContainer = UIView()
    let logoutButton = UIButton(type: .system)
    let deleteAccountButton = UIButton(type: .system)
    
    // 로딩 인디케이터
    let loadingIndicator = UIActivityIndicatorView(style: .medium)
    
    // MARK: - Init
    override init(frame: CGRect) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 12
        layout.minimumLineSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        badgesCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
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
        setupProfileSection()
        setupStatisticsSection()
        setupBadgesSection()
        setupSettingsSection()
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
        
        titleLabel.text = "내 정보"
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
    
    private func setupProfileSection() {
        profileContainer.translatesAutoresizingMaskIntoConstraints = false
        profileContainer.backgroundColor = UIColor.white.withAlphaComponent(0.03)
        profileContainer.layer.cornerRadius = 16
        profileContainer.layer.borderWidth = 1
        profileContainer.layer.borderColor = UIColor.white.withAlphaComponent(0.08).cgColor
        
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        profileImageView.layer.cornerRadius = 35
        profileImageView.clipsToBounds = true
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.image = UIImage(systemName: "person.fill")
        profileImageView.tintColor = .themeTextSecondary
        
        nameLabel.font = .systemFont(ofSize: 24, weight: .bold)
        nameLabel.textColor = .themeTextPrimary
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        emailLabel.font = .systemFont(ofSize: 16, weight: .medium)
        emailLabel.textColor = .themeTextSecondary
        emailLabel.translatesAutoresizingMaskIntoConstraints = false
        
        joinDateLabel.font = .systemFont(ofSize: 14, weight: .regular)
        joinDateLabel.textColor = .themeTextSecondary
        joinDateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        profileContainer.addSubview(profileImageView)
        profileContainer.addSubview(nameLabel)
        profileContainer.addSubview(emailLabel)
        profileContainer.addSubview(joinDateLabel)
    }
    
    private func setupStatisticsSection() {
        statisticsContainer.translatesAutoresizingMaskIntoConstraints = false
        statisticsContainer.backgroundColor = UIColor.white.withAlphaComponent(0.03)
        statisticsContainer.layer.cornerRadius = 16
        statisticsContainer.layer.borderWidth = 1
        statisticsContainer.layer.borderColor = UIColor.white.withAlphaComponent(0.08).cgColor
        
        statisticsHeaderLabel.text = "여행 통계"
        statisticsHeaderLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        statisticsHeaderLabel.textColor = .themeTextPrimary
        statisticsHeaderLabel.translatesAutoresizingMaskIntoConstraints = false
        
        statsStackView.axis = .vertical
        statsStackView.spacing = 16
        statsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        statisticsContainer.addSubview(statisticsHeaderLabel)
        statisticsContainer.addSubview(statsStackView)
    }
    
    private func setupBadgesSection() {
        badgesContainer.translatesAutoresizingMaskIntoConstraints = false
        badgesContainer.backgroundColor = UIColor.white.withAlphaComponent(0.03)
        badgesContainer.layer.cornerRadius = 16
        badgesContainer.layer.borderWidth = 1
        badgesContainer.layer.borderColor = UIColor.white.withAlphaComponent(0.08).cgColor
        
        badgesHeaderLabel.text = "획득한 배지"
        badgesHeaderLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        badgesHeaderLabel.textColor = .themeTextPrimary
        badgesHeaderLabel.translatesAutoresizingMaskIntoConstraints = false
        
        badgesCollectionView.backgroundColor = .clear
        badgesCollectionView.showsHorizontalScrollIndicator = false
        badgesCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        badgesContainer.addSubview(badgesHeaderLabel)
        badgesContainer.addSubview(badgesCollectionView)
    }
    
    private func setupSettingsSection() {
        settingsContainer.translatesAutoresizingMaskIntoConstraints = false
        
        logoutButton.setTitle("로그아웃", for: .normal)
        logoutButton.setTitleColor(.white, for: .normal)
        logoutButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        logoutButton.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        logoutButton.layer.cornerRadius = 12
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        
        deleteAccountButton.setTitle("계정 삭제", for: .normal)
        deleteAccountButton.setTitleColor(.systemRed, for: .normal)
        deleteAccountButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        deleteAccountButton.backgroundColor = UIColor.systemRed.withAlphaComponent(0.1)
        deleteAccountButton.layer.cornerRadius = 12
        deleteAccountButton.layer.borderWidth = 1
        deleteAccountButton.layer.borderColor = UIColor.systemRed.withAlphaComponent(0.3).cgColor
        deleteAccountButton.translatesAutoresizingMaskIntoConstraints = false
        
        settingsContainer.addSubview(logoutButton)
        settingsContainer.addSubview(deleteAccountButton)
    }
    
    private func setupLoadingIndicator() {
        loadingIndicator.color = .themeTextSecondary
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(loadingIndicator)
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
        [headerContainer, profileContainer, statisticsContainer, badgesContainer, settingsContainer].forEach {
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
            
            // 프로필 컨테이너
            profileContainer.topAnchor.constraint(equalTo: headerContainer.bottomAnchor, constant: 16),
            profileContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            profileContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            profileImageView.topAnchor.constraint(equalTo: profileContainer.topAnchor, constant: 24),
            profileImageView.leadingAnchor.constraint(equalTo: profileContainer.leadingAnchor, constant: 24),
            profileImageView.widthAnchor.constraint(equalToConstant: 70),
            profileImageView.heightAnchor.constraint(equalToConstant: 70),
            
            nameLabel.topAnchor.constraint(equalTo: profileContainer.topAnchor, constant: 24),
            nameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: profileContainer.trailingAnchor, constant: -24),
            
            emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            emailLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            emailLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            
            joinDateLabel.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 4),
            joinDateLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            joinDateLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            joinDateLabel.bottomAnchor.constraint(equalTo: profileContainer.bottomAnchor, constant: -24),
            
            // 통계 컨테이너
            statisticsContainer.topAnchor.constraint(equalTo: profileContainer.bottomAnchor, constant: 20),
            statisticsContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            statisticsContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            statisticsHeaderLabel.topAnchor.constraint(equalTo: statisticsContainer.topAnchor, constant: 20),
            statisticsHeaderLabel.leadingAnchor.constraint(equalTo: statisticsContainer.leadingAnchor, constant: 20),
            statisticsHeaderLabel.trailingAnchor.constraint(equalTo: statisticsContainer.trailingAnchor, constant: -20),
            
            statsStackView.topAnchor.constraint(equalTo: statisticsHeaderLabel.bottomAnchor, constant: 16),
            statsStackView.leadingAnchor.constraint(equalTo: statisticsContainer.leadingAnchor, constant: 20),
            statsStackView.trailingAnchor.constraint(equalTo: statisticsContainer.trailingAnchor, constant: -20),
            statsStackView.bottomAnchor.constraint(equalTo: statisticsContainer.bottomAnchor, constant: -20),
            
            // 배지 컨테이너
            badgesContainer.topAnchor.constraint(equalTo: statisticsContainer.bottomAnchor, constant: 20),
            badgesContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            badgesContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            badgesHeaderLabel.topAnchor.constraint(equalTo: badgesContainer.topAnchor, constant: 20),
            badgesHeaderLabel.leadingAnchor.constraint(equalTo: badgesContainer.leadingAnchor, constant: 20),
            badgesHeaderLabel.trailingAnchor.constraint(equalTo: badgesContainer.trailingAnchor, constant: -20),
            
            badgesCollectionView.topAnchor.constraint(equalTo: badgesHeaderLabel.bottomAnchor, constant: 16),
            badgesCollectionView.leadingAnchor.constraint(equalTo: badgesContainer.leadingAnchor),
            badgesCollectionView.trailingAnchor.constraint(equalTo: badgesContainer.trailingAnchor),
            badgesCollectionView.heightAnchor.constraint(equalToConstant: 100),
            badgesCollectionView.bottomAnchor.constraint(equalTo: badgesContainer.bottomAnchor, constant: -20),
            
            // 설정 컨테이너
            settingsContainer.topAnchor.constraint(equalTo: badgesContainer.bottomAnchor, constant: 20),
            settingsContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            settingsContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            settingsContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            
            logoutButton.topAnchor.constraint(equalTo: settingsContainer.topAnchor),
            logoutButton.leadingAnchor.constraint(equalTo: settingsContainer.leadingAnchor),
            logoutButton.trailingAnchor.constraint(equalTo: settingsContainer.trailingAnchor),
            logoutButton.heightAnchor.constraint(equalToConstant: 50),
            
            deleteAccountButton.topAnchor.constraint(equalTo: logoutButton.bottomAnchor, constant: 12),
            deleteAccountButton.leadingAnchor.constraint(equalTo: settingsContainer.leadingAnchor),
            deleteAccountButton.trailingAnchor.constraint(equalTo: settingsContainer.trailingAnchor),
            deleteAccountButton.heightAnchor.constraint(equalToConstant: 50),
            deleteAccountButton.bottomAnchor.constraint(equalTo: settingsContainer.bottomAnchor),
            
            // 로딩 인디케이터
            loadingIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    // MARK: - Public Methods
    func updateProfile(name: String, email: String, joinDate: String, profileImage: UIImage?) {
        nameLabel.text = name
        emailLabel.text = email
        joinDateLabel.text = "가입일: \(joinDate)"
        
        if let image = profileImage {
            profileImageView.image = image
        }
    }
    
    func updateStatistics(totalRecords: Int, totalPlaces: Int, thisYearRecords: Int, firstRecordDate: String, favoriteLocation: String) {
        statsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let stats = [
            ("📝", "총 기록 수", "\(totalRecords)개"),
            ("📍", "방문한 장소", "\(totalPlaces)곳"),
            ("🗓️", "올해 기록", "\(thisYearRecords)개"),
            ("🎯", "첫 기록", firstRecordDate),
            ("❤️", "자주 가는 곳", favoriteLocation)
        ]
        
        stats.forEach { emoji, title, value in
            let statView = createStatView(emoji: emoji, title: title, value: value)
            statsStackView.addArrangedSubview(statView)
        }
    }
    
    private func createStatView(emoji: String, title: String, value: String) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let emojiLabel = UILabel()
        emojiLabel.text = emoji
        emojiLabel.font = .systemFont(ofSize: 24)
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = .themeTextPrimary
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = .systemFont(ofSize: 14, weight: .regular)
        valueLabel.textColor = .themeTextSecondary
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(emojiLabel)
        container.addSubview(titleLabel)
        container.addSubview(valueLabel)
        
        NSLayoutConstraint.activate([
            emojiLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            emojiLabel.widthAnchor.constraint(equalToConstant: 40),
            
            titleLabel.leadingAnchor.constraint(equalTo: emojiLabel.trailingAnchor, constant: 12),
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor),
            
            valueLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            valueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            valueLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            
            container.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        return container
    }
    
    func showLoading(_ show: Bool) {
        if show {
            loadingIndicator.startAnimating()
        } else {
            loadingIndicator.stopAnimating()
        }
    }
}

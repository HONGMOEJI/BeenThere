//
//  BadgeDetailView.swift
//  BeenThere
//
//  배지 상세 정보 뷰
//

import UIKit

class BadgeDetailView: UIView {
    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let badgeContainer = UIView()
    private let badgeIconLabel = UILabel()
    private let badgeTitleLabel = UILabel()
    private let badgeDescriptionLabel = UILabel()
    private let badgeStatusLabel = UILabel()
    
    private let progressContainer = UIView()
    private let progressHeaderLabel = UILabel()
    private let progressView = UIView()
    private let progressBar = UIView()
    private let progressLabel = UILabel()
    
    private let achievementContainer = UIView()
    private let achievementHeaderLabel = UILabel()
    private let achievementDescriptionLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .themeBackground
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        setupScrollView()
        setupBadgeSection()
        setupProgressSection()
        setupAchievementSection()
        setupConstraints()
    }
    
    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(scrollView)
        scrollView.addSubview(contentView)
    }
    
    private func setupBadgeSection() {
        badgeContainer.translatesAutoresizingMaskIntoConstraints = false
        badgeContainer.backgroundColor = UIColor.white.withAlphaComponent(0.03)
        badgeContainer.layer.cornerRadius = 16
        badgeContainer.layer.borderWidth = 1
        badgeContainer.layer.borderColor = UIColor.white.withAlphaComponent(0.08).cgColor
        
        badgeIconLabel.font = .systemFont(ofSize: 64)
        badgeIconLabel.textAlignment = .center
        badgeIconLabel.translatesAutoresizingMaskIntoConstraints = false
        
        badgeTitleLabel.font = .systemFont(ofSize: 28, weight: .bold)
        badgeTitleLabel.textColor = .themeTextPrimary
        badgeTitleLabel.textAlignment = .center
        badgeTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        badgeDescriptionLabel.font = .systemFont(ofSize: 16, weight: .medium)
        badgeDescriptionLabel.textColor = .themeTextSecondary
        badgeDescriptionLabel.textAlignment = .center
        badgeDescriptionLabel.numberOfLines = 0
        badgeDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        badgeStatusLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        badgeStatusLabel.textAlignment = .center
        badgeStatusLabel.layer.cornerRadius = 12
        badgeStatusLabel.clipsToBounds = true
        badgeStatusLabel.translatesAutoresizingMaskIntoConstraints = false
        
        badgeContainer.addSubview(badgeIconLabel)
        badgeContainer.addSubview(badgeTitleLabel)
        badgeContainer.addSubview(badgeDescriptionLabel)
        badgeContainer.addSubview(badgeStatusLabel)
    }
    
    private func setupProgressSection() {
        progressContainer.translatesAutoresizingMaskIntoConstraints = false
        progressContainer.backgroundColor = UIColor.white.withAlphaComponent(0.03)
        progressContainer.layer.cornerRadius = 16
        progressContainer.layer.borderWidth = 1
        progressContainer.layer.borderColor = UIColor.white.withAlphaComponent(0.08).cgColor
        
        progressHeaderLabel.text = "진행 상황"
        progressHeaderLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        progressHeaderLabel.textColor = .themeTextPrimary
        progressHeaderLabel.translatesAutoresizingMaskIntoConstraints = false
        
        progressView.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        progressView.layer.cornerRadius = 6
        progressView.translatesAutoresizingMaskIntoConstraints = false
        
        progressBar.backgroundColor = .systemBlue
        progressBar.layer.cornerRadius = 6
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        
        progressLabel.font = .systemFont(ofSize: 16, weight: .medium)
        progressLabel.textColor = .themeTextPrimary
        progressLabel.textAlignment = .center
        progressLabel.translatesAutoresizingMaskIntoConstraints = false
        
        progressContainer.addSubview(progressHeaderLabel)
        progressContainer.addSubview(progressView)
        progressView.addSubview(progressBar)
        progressContainer.addSubview(progressLabel)
    }
    
    private func setupAchievementSection() {
        achievementContainer.translatesAutoresizingMaskIntoConstraints = false
        achievementContainer.backgroundColor = UIColor.white.withAlphaComponent(0.03)
        achievementContainer.layer.cornerRadius = 16
        achievementContainer.layer.borderWidth = 1
        achievementContainer.layer.borderColor = UIColor.white.withAlphaComponent(0.08).cgColor
        
        achievementHeaderLabel.text = "달성 방법"
        achievementHeaderLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        achievementHeaderLabel.textColor = .themeTextPrimary
        achievementHeaderLabel.translatesAutoresizingMaskIntoConstraints = false
        
        achievementDescriptionLabel.font = .systemFont(ofSize: 16, weight: .regular)
        achievementDescriptionLabel.textColor = .themeTextSecondary
        achievementDescriptionLabel.numberOfLines = 0
        achievementDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        achievementContainer.addSubview(achievementHeaderLabel)
        achievementContainer.addSubview(achievementDescriptionLabel)
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
        [badgeContainer, progressContainer, achievementContainer].forEach {
            contentView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            // 배지 컨테이너
            badgeContainer.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            badgeContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            badgeContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            badgeIconLabel.topAnchor.constraint(equalTo: badgeContainer.topAnchor, constant: 32),
            badgeIconLabel.centerXAnchor.constraint(equalTo: badgeContainer.centerXAnchor),
            
            badgeTitleLabel.topAnchor.constraint(equalTo: badgeIconLabel.bottomAnchor, constant: 16),
            badgeTitleLabel.leadingAnchor.constraint(equalTo: badgeContainer.leadingAnchor, constant: 20),
            badgeTitleLabel.trailingAnchor.constraint(equalTo: badgeContainer.trailingAnchor, constant: -20),
            
            badgeDescriptionLabel.topAnchor.constraint(equalTo: badgeTitleLabel.bottomAnchor, constant: 8),
            badgeDescriptionLabel.leadingAnchor.constraint(equalTo: badgeContainer.leadingAnchor, constant: 20),
            badgeDescriptionLabel.trailingAnchor.constraint(equalTo: badgeContainer.trailingAnchor, constant: -20),
            
            badgeStatusLabel.topAnchor.constraint(equalTo: badgeDescriptionLabel.bottomAnchor, constant: 16),
            badgeStatusLabel.centerXAnchor.constraint(equalTo: badgeContainer.centerXAnchor),
            badgeStatusLabel.widthAnchor.constraint(equalToConstant: 120),
            badgeStatusLabel.heightAnchor.constraint(equalToConstant: 32),
            badgeStatusLabel.bottomAnchor.constraint(equalTo: badgeContainer.bottomAnchor, constant: -32),
            
            // 진행 상황 컨테이너
            progressContainer.topAnchor.constraint(equalTo: badgeContainer.bottomAnchor, constant: 20),
            progressContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            progressContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            progressHeaderLabel.topAnchor.constraint(equalTo: progressContainer.topAnchor, constant: 20),
            progressHeaderLabel.leadingAnchor.constraint(equalTo: progressContainer.leadingAnchor, constant: 20),
            progressHeaderLabel.trailingAnchor.constraint(equalTo: progressContainer.trailingAnchor, constant: -20),
            
            progressView.topAnchor.constraint(equalTo: progressHeaderLabel.bottomAnchor, constant: 16),
            progressView.leadingAnchor.constraint(equalTo: progressContainer.leadingAnchor, constant: 20),
            progressView.trailingAnchor.constraint(equalTo: progressContainer.trailingAnchor, constant: -20),
            progressView.heightAnchor.constraint(equalToConstant: 12),
            
            progressBar.topAnchor.constraint(equalTo: progressView.topAnchor),
            progressBar.leadingAnchor.constraint(equalTo: progressView.leadingAnchor),
            progressBar.bottomAnchor.constraint(equalTo: progressView.bottomAnchor),
            
            progressLabel.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 12),
            progressLabel.leadingAnchor.constraint(equalTo: progressContainer.leadingAnchor, constant: 20),
            progressLabel.trailingAnchor.constraint(equalTo: progressContainer.trailingAnchor, constant: -20),
            progressLabel.bottomAnchor.constraint(equalTo: progressContainer.bottomAnchor, constant: -20),
            
            // 달성 방법 컨테이너
            achievementContainer.topAnchor.constraint(equalTo: progressContainer.bottomAnchor, constant: 20),
            achievementContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            achievementContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            achievementContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            
            achievementHeaderLabel.topAnchor.constraint(equalTo: achievementContainer.topAnchor, constant: 20),
            achievementHeaderLabel.leadingAnchor.constraint(equalTo: achievementContainer.leadingAnchor, constant: 20),
            achievementHeaderLabel.trailingAnchor.constraint(equalTo: achievementContainer.trailingAnchor, constant: -20),
            
            achievementDescriptionLabel.topAnchor.constraint(equalTo: achievementHeaderLabel.bottomAnchor, constant: 16),
            achievementDescriptionLabel.leadingAnchor.constraint(equalTo: achievementContainer.leadingAnchor, constant: 20),
            achievementDescriptionLabel.trailingAnchor.constraint(equalTo: achievementContainer.trailingAnchor, constant: -20),
            achievementDescriptionLabel.bottomAnchor.constraint(equalTo: achievementContainer.bottomAnchor, constant: -20),
        ])
    }
    
    private var progressBarWidthConstraint: NSLayoutConstraint?
    
    func configure(with badge: ProfileViewModel.Badge) {
        badgeIconLabel.text = badge.icon
        badgeTitleLabel.text = badge.title
        badgeDescriptionLabel.text = badge.description
        
        let progress = min(Float(badge.currentCount) / Float(badge.requiredCount), 1.0)
        
        // 진행률 설정
        progressBarWidthConstraint?.isActive = false
        progressBarWidthConstraint = progressBar.widthAnchor.constraint(equalTo: progressView.widthAnchor, multiplier: CGFloat(progress))
        progressBarWidthConstraint?.isActive = true
        
        progressLabel.text = "\(badge.currentCount) / \(badge.requiredCount)"
        
        // 배지 상태에 따른 스타일 변경
        if badge.isEarned {
            badgeIconLabel.alpha = 1.0
            badgeStatusLabel.text = "획득 완료!"
            badgeStatusLabel.backgroundColor = .systemGreen
            badgeStatusLabel.textColor = .white
            progressBar.backgroundColor = .systemGreen
            achievementDescriptionLabel.text = "축하합니다! 이 배지를 성공적으로 획득했습니다."
        } else {
            badgeIconLabel.alpha = 0.5
            badgeStatusLabel.text = "미획득"
            badgeStatusLabel.backgroundColor = UIColor.white.withAlphaComponent(0.1)
            badgeStatusLabel.textColor = .themeTextSecondary
            progressBar.backgroundColor = .systemBlue
            
            // 배지별 달성 방법 안내
            let remainingCount = badge.requiredCount - badge.currentCount
            let achievementText: String
            
            switch badge.id {
            case "first_record":
                achievementText = "첫 번째 여행 기록을 작성해보세요! 어디든 가서 사진을 찍고 소감을 남겨주세요."
            case "explorer_10":
                achievementText = "아직 \(remainingCount)곳 더 방문하면 달성할 수 있어요. 새로운 장소를 탐험해보세요!"
            case "adventurer_50":
                achievementText = "아직 \(remainingCount)곳 더 방문하면 달성할 수 있어요. 계속해서 새로운 모험을 떠나보세요!"
            case "master_100":
                achievementText = "아직 \(remainingCount)곳 더 방문하면 달성할 수 있어요. 진정한 여행 마스터가 되어보세요!"
            case "record_keeper":
                achievementText = "아직 \(remainingCount)개 더 기록하면 달성할 수 있어요. 방문했던 곳의 추억을 더 많이 기록해보세요!"
            default:
                achievementText = "조건을 만족하면 배지를 획득할 수 있습니다."
            }
            
            achievementDescriptionLabel.text = achievementText
        }
    }
}

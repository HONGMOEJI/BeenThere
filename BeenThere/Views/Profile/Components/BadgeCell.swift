//
//  BadgeCell.swift
//  BeenThere
//
//  배지 컬렉션뷰 셀
//

import UIKit

class BadgeCell: UICollectionViewCell {
    static let identifier = "BadgeCell"
    
    private let containerView = UIView()
    private let emojiLabel = UILabel()
    private let titleLabel = UILabel()
    private let progressView = UIView()
    private let progressBar = UIView()
    private var progressBarWidthConstraint: NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        containerView.backgroundColor = UIColor.white.withAlphaComponent(0.03)
        containerView.layer.cornerRadius = 12
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.white.withAlphaComponent(0.08).cgColor
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        emojiLabel.font = .systemFont(ofSize: 24)
        emojiLabel.textAlignment = .center
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.font = .systemFont(ofSize: 12, weight: .medium)
        titleLabel.textColor = .themeTextPrimary
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        progressView.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        progressView.layer.cornerRadius = 2
        progressView.translatesAutoresizingMaskIntoConstraints = false
        
        progressBar.backgroundColor = .systemBlue
        progressBar.layer.cornerRadius = 2
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(containerView)
        containerView.addSubview(emojiLabel)
        containerView.addSubview(titleLabel)
        containerView.addSubview(progressView)
        progressView.addSubview(progressBar)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            emojiLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            emojiLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: emojiLabel.bottomAnchor, constant: 4),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 4),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -4),
            
            progressView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            progressView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            progressView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            progressView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8),
            progressView.heightAnchor.constraint(equalToConstant: 4),
            
            progressBar.topAnchor.constraint(equalTo: progressView.topAnchor),
            progressBar.leadingAnchor.constraint(equalTo: progressView.leadingAnchor),
            progressBar.bottomAnchor.constraint(equalTo: progressView.bottomAnchor),
        ])
    }
    
    func configure(with badge: ProfileViewModel.Badge) {
        emojiLabel.text = badge.icon
        titleLabel.text = badge.title
        
        let progress = min(Float(badge.currentCount) / Float(badge.requiredCount), 1.0)
        
        // 기존 제약 조건 제거
        progressBarWidthConstraint?.isActive = false
        
        // 새로운 제약 조건 설정
        progressBarWidthConstraint = progressBar.widthAnchor.constraint(equalTo: progressView.widthAnchor, multiplier: CGFloat(progress))
        progressBarWidthConstraint?.isActive = true
        
        // 배지 획득 여부에 따른 스타일 변경
        if badge.isEarned {
            containerView.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
            containerView.layer.borderColor = UIColor.systemBlue.withAlphaComponent(0.3).cgColor
            emojiLabel.alpha = 1.0
            progressBar.backgroundColor = .systemBlue
        } else {
            containerView.backgroundColor = UIColor.white.withAlphaComponent(0.03)
            containerView.layer.borderColor = UIColor.white.withAlphaComponent(0.08).cgColor
            emojiLabel.alpha = 0.5
            progressBar.backgroundColor = .themeTextSecondary
        }
    }
}

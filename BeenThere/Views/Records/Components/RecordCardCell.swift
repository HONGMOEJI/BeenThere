//
//  RecordCardCell.swift
//  BeenThere
//
//  방문 기록 카드 셀
//

import UIKit
import Kingfisher

class RecordCardCell: UICollectionViewCell {
    static let identifier = "RecordCardCell"
    
    // MARK: - UI Components
    private let containerView = UIView()
    private let imageView = UIImageView()
    private let gradientLayer = CAGradientLayer()
    
    private let contentContainer = UIView()
    private let titleLabel = UILabel()
    private let addressLabel = UILabel()
    private let timeLabel = UILabel()
    private let ratingStackView = UIStackView()
    private let contentPreviewLabel = UILabel()
    private let tagStackView = UIStackView()
    private let tagScrollView = UIScrollView()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = imageView.bounds
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        imageView.kf.cancelDownloadTask()
        
        // 태그 뷰들 제거
        tagStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // 별점 뷰들 제거
        ratingStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        contentView.backgroundColor = .clear
        contentView.layer.cornerRadius = 16
        contentView.clipsToBounds = true
        
        setupContainerView()
        setupImageView()
        setupContentContainer()
        setupConstraints()
    }
    
    private func setupContainerView() {
        containerView.backgroundColor = UIColor.white.withAlphaComponent(0.03)
        containerView.layer.cornerRadius = 16
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.white.withAlphaComponent(0.08).cgColor
        containerView.clipsToBounds = true
        containerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(containerView)
    }
    
    private func setupImageView() {
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = UIColor(white: 0.1, alpha: 1)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        // 그라데이션 오버레이 (더 부드럽게)
        gradientLayer.colors = [
            UIColor.clear.cgColor,
            UIColor.black.withAlphaComponent(0.1).cgColor,
            UIColor.black.withAlphaComponent(0.3).cgColor
        ]
        gradientLayer.locations = [0.0, 0.8, 1.0]
        imageView.layer.addSublayer(gradientLayer)
        
        containerView.addSubview(imageView)
    }
    
    private func setupContentContainer() {
        contentContainer.translatesAutoresizingMaskIntoConstraints = false
        
        // 제목
        titleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textColor = .themeTextPrimary
        titleLabel.numberOfLines = 2
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // 주소
        addressLabel.font = .systemFont(ofSize: 14, weight: .medium)
        addressLabel.textColor = .themeTextSecondary
        addressLabel.numberOfLines = 1
        addressLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // 시간
        timeLabel.font = .systemFont(ofSize: 12, weight: .medium)
        timeLabel.textColor = .themeTextSecondary
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // 별점
        ratingStackView.axis = .horizontal
        ratingStackView.spacing = 2
        ratingStackView.translatesAutoresizingMaskIntoConstraints = false
        
        // 내용 미리보기
        contentPreviewLabel.font = .systemFont(ofSize: 14, weight: .regular)
        contentPreviewLabel.textColor = .themeTextSecondary
        contentPreviewLabel.numberOfLines = 2
        contentPreviewLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // 태그 스크롤뷰
        tagScrollView.showsHorizontalScrollIndicator = false
        tagScrollView.translatesAutoresizingMaskIntoConstraints = false
        
        tagStackView.axis = .horizontal
        tagStackView.spacing = 6
        tagStackView.translatesAutoresizingMaskIntoConstraints = false
        tagScrollView.addSubview(tagStackView)
        
        contentContainer.addSubview(titleLabel)
        contentContainer.addSubview(addressLabel)
        contentContainer.addSubview(timeLabel)
        contentContainer.addSubview(ratingStackView)
        contentContainer.addSubview(contentPreviewLabel)
        contentContainer.addSubview(tagScrollView)
        
        containerView.addSubview(contentContainer)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // 컨테이너 뷰
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            // 이미지 뷰 (왼쪽, 정사각형)
            imageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            imageView.topAnchor.constraint(equalTo: containerView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor), // 정사각형
            
            // 콘텐츠 컨테이너 (오른쪽)
            contentContainer.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 16),
            contentContainer.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            contentContainer.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            contentContainer.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),
            
            // 제목
            titleLabel.topAnchor.constraint(equalTo: contentContainer.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor),
            
            // 주소
            addressLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            addressLabel.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            addressLabel.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor),
            
            // 시간과 별점을 같은 줄에
            timeLabel.topAnchor.constraint(equalTo: addressLabel.bottomAnchor, constant: 8),
            timeLabel.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            
            ratingStackView.centerYAnchor.constraint(equalTo: timeLabel.centerYAnchor),
            ratingStackView.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor),
            
            // 내용 미리보기
            contentPreviewLabel.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 8),
            contentPreviewLabel.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            contentPreviewLabel.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor),
            
            // 태그 스크롤뷰
            tagScrollView.topAnchor.constraint(equalTo: contentPreviewLabel.bottomAnchor, constant: 8),
            tagScrollView.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            tagScrollView.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor),
            tagScrollView.bottomAnchor.constraint(lessThanOrEqualTo: contentContainer.bottomAnchor),
            tagScrollView.heightAnchor.constraint(equalToConstant: 24),
            
            tagStackView.topAnchor.constraint(equalTo: tagScrollView.topAnchor),
            tagStackView.leadingAnchor.constraint(equalTo: tagScrollView.leadingAnchor),
            tagStackView.trailingAnchor.constraint(equalTo: tagScrollView.trailingAnchor),
            tagStackView.bottomAnchor.constraint(equalTo: tagScrollView.bottomAnchor),
            tagStackView.heightAnchor.constraint(equalTo: tagScrollView.heightAnchor)
        ])
    }
    
    // MARK: - Configure
    func configure(with record: VisitRecord) {
        titleLabel.text = record.placeTitle
        addressLabel.text = record.placeAddress
        
        // 시간 포맷
        let timeFormatter = DateFormatter()
        timeFormatter.locale = Locale(identifier: "ko_KR")
        timeFormatter.dateFormat = "HH:mm"
        timeLabel.text = timeFormatter.string(from: record.visitedAt)
        
        // 별점 표시
        setupRatingStars(record.rating)
        
        // 내용 미리보기
        let preview = record.content.prefix(60)
        contentPreviewLabel.text = preview.isEmpty ? "기록 내용이 없습니다." : String(preview) + (record.content.count > 60 ? "..." : "")
        
        // 태그 표시
        setupTags(record.tags)
        
        // 이미지 로드
        if let firstImageUrl = record.imageUrls.first,
           let url = URL(string: firstImageUrl) {
            imageView.kf.setImage(
                with: url,
                placeholder: UIImage(systemName: "photo"),
                options: [
                    .transition(.fade(0.2)),
                    .cacheOriginalImage
                ]
            )
        } else {
            imageView.image = UIImage(systemName: "photo")
            imageView.tintColor = .themeTextSecondary
        }
    }
    
    private func setupRatingStars(_ rating: Int) {
        // 기존 별점 뷰들 제거
        ratingStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for i in 1...5 {
            let starView = UIImageView()
            starView.contentMode = .scaleAspectFit
            starView.translatesAutoresizingMaskIntoConstraints = false
            
            if i <= rating {
                starView.image = UIImage(systemName: "star.fill")
                starView.tintColor = UIColor.white.withAlphaComponent(0.8)
            } else {
                starView.image = UIImage(systemName: "star")
                starView.tintColor = UIColor.white.withAlphaComponent(0.3)
            }
            
            starView.widthAnchor.constraint(equalToConstant: 12).isActive = true
            starView.heightAnchor.constraint(equalToConstant: 12).isActive = true
            
            ratingStackView.addArrangedSubview(starView)
        }
    }
    
    private func setupTags(_ tags: [String]) {
        // 기존 태그 뷰들 제거
        tagStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for tag in tags.prefix(3) { // 최대 3개만 표시
            let tagLabel = UILabel()
            tagLabel.text = "#\(tag)"
            tagLabel.font = .systemFont(ofSize: 11, weight: .medium)
            tagLabel.textColor = .themeTextSecondary
            tagLabel.backgroundColor = UIColor.white.withAlphaComponent(0.05)
            tagLabel.layer.cornerRadius = 8
            tagLabel.layer.masksToBounds = true
            tagLabel.textAlignment = .center
            tagLabel.translatesAutoresizingMaskIntoConstraints = false
            
            // 패딩 추가
            let containerView = UIView()
            containerView.addSubview(tagLabel)
            containerView.backgroundColor = tagLabel.backgroundColor
            containerView.layer.cornerRadius = 8
            
            NSLayoutConstraint.activate([
                tagLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 4),
                tagLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
                tagLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
                tagLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -4)
            ])
            
            tagStackView.addArrangedSubview(containerView)
        }
        
        // 태그가 3개보다 많으면 "..." 표시
        if tags.count > 3 {
            let moreLabel = UILabel()
            moreLabel.text = "..."
            moreLabel.font = .systemFont(ofSize: 11, weight: .medium)
            moreLabel.textColor = .themeTextSecondary
            tagStackView.addArrangedSubview(moreLabel)
        }
    }
}

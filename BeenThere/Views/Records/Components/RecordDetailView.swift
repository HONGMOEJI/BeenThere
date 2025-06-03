//
//  RecordDetailView.swift
//  BeenThere
//
//  방문 기록 상세보기 뷰
//

import UIKit
import Kingfisher

class RecordDetailView: UIView {
    // MARK: - UI Components
    let scrollView = UIScrollView()
    let contentView = UIView()
    
    // 장소 정보 헤더
    let placeHeaderView = UIView()
    let placeTitleLabel = UILabel()
    let placeAddressLabel = UILabel()
    let visitDateLabel = UILabel()
    
    // 별점 표시
    let ratingContainer = UIView()
    let ratingStackView = UIStackView()
    
    // 날씨 & 기분
    let moodWeatherContainer = UIView()
    let weatherLabel = UILabel()
    let weatherValueLabel = UILabel()
    let moodLabel = UILabel()
    let moodValueLabel = UILabel()
    
    // 사진 갤러리
    let photoContainer = UIView()
    let photoHeaderLabel = UILabel()
    let photoCollectionView: UICollectionView
    
    // 태그
    let tagContainer = UIView()
    let tagHeaderLabel = UILabel()
    let tagCollectionView: UICollectionView
    
    // 내용
    let contentContainer = UIView()
    let contentHeaderLabel = UILabel()
    let contentTextView = UITextView()
    
    // 삭제 버튼
    let deleteButtonContainer = UIView()
    let deleteButton = UIButton(type: .system)
    
    // 데이터
    private var images: [String] = []
    private var tags: [String] = []
    
    // MARK: - Init
    override init(frame: CGRect) {
        // 컬렉션뷰 초기화
        let photoLayout = UICollectionViewFlowLayout()
        photoLayout.scrollDirection = .horizontal
        photoLayout.itemSize = CGSize(width: 120, height: 120)
        photoLayout.minimumInteritemSpacing = 12
        photoLayout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        photoCollectionView = UICollectionView(frame: .zero, collectionViewLayout: photoLayout)
        
        let tagLayout = UICollectionViewFlowLayout()
        tagLayout.scrollDirection = .horizontal
        tagLayout.estimatedItemSize = CGSize(width: 100, height: 36)
        tagLayout.minimumInteritemSpacing = 8
        tagLayout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        tagCollectionView = UICollectionView(frame: .zero, collectionViewLayout: tagLayout)
        
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
        setupPlaceHeader()
        setupRating()
        setupMoodWeather()
        setupPhotoSection()
        setupTagSection()
        setupContentSection()
        setupDeleteButton()
        setupConstraints()
        setupCollectionViews()
    }
    
    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.contentInsetAdjustmentBehavior = .never
        contentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(scrollView)
        scrollView.addSubview(contentView)
    }
    
    private func setupPlaceHeader() {
        placeHeaderView.backgroundColor = UIColor.white.withAlphaComponent(0.05)
        placeHeaderView.layer.cornerRadius = 16
        placeHeaderView.layer.borderWidth = 1
        placeHeaderView.layer.borderColor = UIColor.white.withAlphaComponent(0.1).cgColor
        placeHeaderView.translatesAutoresizingMaskIntoConstraints = false
        
        placeTitleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        placeTitleLabel.textColor = .themeTextPrimary
        placeTitleLabel.numberOfLines = 2
        placeTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        placeAddressLabel.font = .systemFont(ofSize: 16, weight: .medium)
        placeAddressLabel.textColor = .themeTextSecondary
        placeAddressLabel.numberOfLines = 2
        placeAddressLabel.translatesAutoresizingMaskIntoConstraints = false
        
        visitDateLabel.font = .systemFont(ofSize: 14, weight: .medium)
        visitDateLabel.textColor = .themeTextSecondary
        visitDateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        placeHeaderView.addSubview(placeTitleLabel)
        placeHeaderView.addSubview(placeAddressLabel)
        placeHeaderView.addSubview(visitDateLabel)
    }
    
    private func setupRating() {
        ratingContainer.backgroundColor = UIColor.white.withAlphaComponent(0.05)
        ratingContainer.layer.cornerRadius = 12
        ratingContainer.layer.borderWidth = 1
        ratingContainer.layer.borderColor = UIColor.white.withAlphaComponent(0.1).cgColor
        ratingContainer.translatesAutoresizingMaskIntoConstraints = false
        
        ratingStackView.axis = .horizontal
        ratingStackView.spacing = 8
        ratingStackView.translatesAutoresizingMaskIntoConstraints = false
        
        // 별점 아이콘 5개 생성
        for _ in 0..<5 {
            let starView = UIImageView()
            starView.contentMode = .scaleAspectFit
            starView.translatesAutoresizingMaskIntoConstraints = false
            starView.widthAnchor.constraint(equalToConstant: 24).isActive = true
            starView.heightAnchor.constraint(equalToConstant: 24).isActive = true
            ratingStackView.addArrangedSubview(starView)
        }
        
        ratingContainer.addSubview(ratingStackView)
    }
    
    private func setupMoodWeather() {
        moodWeatherContainer.backgroundColor = UIColor.white.withAlphaComponent(0.05)
        moodWeatherContainer.layer.cornerRadius = 12
        moodWeatherContainer.layer.borderWidth = 1
        moodWeatherContainer.layer.borderColor = UIColor.white.withAlphaComponent(0.1).cgColor
        moodWeatherContainer.translatesAutoresizingMaskIntoConstraints = false
        
        weatherLabel.text = "날씨"
        weatherLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        weatherLabel.textColor = .themeTextPrimary
        weatherLabel.translatesAutoresizingMaskIntoConstraints = false
        
        weatherValueLabel.font = .systemFont(ofSize: 24)
        weatherValueLabel.textColor = .themeTextPrimary
        weatherValueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        moodLabel.text = "기분"
        moodLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        moodLabel.textColor = .themeTextPrimary
        moodLabel.translatesAutoresizingMaskIntoConstraints = false
        
        moodValueLabel.font = .systemFont(ofSize: 24)
        moodValueLabel.textColor = .themeTextPrimary
        moodValueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        moodWeatherContainer.addSubview(weatherLabel)
        moodWeatherContainer.addSubview(weatherValueLabel)
        moodWeatherContainer.addSubview(moodLabel)
        moodWeatherContainer.addSubview(moodValueLabel)
    }
    
    private func setupPhotoSection() {
        photoContainer.translatesAutoresizingMaskIntoConstraints = false
        
        photoHeaderLabel.text = "사진"
        photoHeaderLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        photoHeaderLabel.textColor = .themeTextPrimary
        photoHeaderLabel.translatesAutoresizingMaskIntoConstraints = false
        
        photoCollectionView.backgroundColor = .clear
        photoCollectionView.showsHorizontalScrollIndicator = false
        photoCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        photoContainer.addSubview(photoHeaderLabel)
        photoContainer.addSubview(photoCollectionView)
    }
    
    private func setupTagSection() {
        tagContainer.translatesAutoresizingMaskIntoConstraints = false
        
        tagHeaderLabel.text = "태그"
        tagHeaderLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        tagHeaderLabel.textColor = .themeTextPrimary
        tagHeaderLabel.translatesAutoresizingMaskIntoConstraints = false
        
        tagCollectionView.backgroundColor = .clear
        tagCollectionView.showsHorizontalScrollIndicator = false
        tagCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        tagContainer.addSubview(tagHeaderLabel)
        tagContainer.addSubview(tagCollectionView)
    }
    
    private func setupContentSection() {
        contentContainer.backgroundColor = UIColor.white.withAlphaComponent(0.05)
        contentContainer.layer.cornerRadius = 12
        contentContainer.layer.borderWidth = 1
        contentContainer.layer.borderColor = UIColor.white.withAlphaComponent(0.1).cgColor
        contentContainer.translatesAutoresizingMaskIntoConstraints = false
        
        contentHeaderLabel.text = "방문 소감"
        contentHeaderLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        contentHeaderLabel.textColor = .themeTextPrimary
        contentHeaderLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentTextView.font = .systemFont(ofSize: 16, weight: .regular)
        contentTextView.textColor = .themeTextPrimary
        contentTextView.backgroundColor = .clear
        contentTextView.isEditable = false
        contentTextView.isScrollEnabled = false
        contentTextView.textContainerInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        contentTextView.translatesAutoresizingMaskIntoConstraints = false
        
        contentContainer.addSubview(contentHeaderLabel)
        contentContainer.addSubview(contentTextView)
    }
    
    private func setupDeleteButton() {
        deleteButtonContainer.translatesAutoresizingMaskIntoConstraints = false
        
        deleteButton.setTitle("기록 삭제", for: .normal)
        deleteButton.setTitleColor(.white, for: .normal)
        deleteButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        deleteButton.backgroundColor = .systemRed
        deleteButton.layer.cornerRadius = 12
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        
        deleteButtonContainer.addSubview(deleteButton)
    }
    
    private func setupCollectionViews() {
        photoCollectionView.dataSource = self
        photoCollectionView.delegate = self
        photoCollectionView.register(DetailPhotoCell.self, forCellWithReuseIdentifier: "DetailPhotoCell")
        
        tagCollectionView.dataSource = self
        tagCollectionView.delegate = self
        tagCollectionView.register(DetailTagCell.self, forCellWithReuseIdentifier: "DetailTagCell")
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
        [placeHeaderView, ratingContainer, moodWeatherContainer,
         photoContainer, tagContainer, contentContainer, deleteButtonContainer].forEach {
            contentView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            // 장소 헤더
            placeHeaderView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            placeHeaderView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            placeHeaderView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            placeTitleLabel.topAnchor.constraint(equalTo: placeHeaderView.topAnchor, constant: 20),
            placeTitleLabel.leadingAnchor.constraint(equalTo: placeHeaderView.leadingAnchor, constant: 20),
            placeTitleLabel.trailingAnchor.constraint(equalTo: placeHeaderView.trailingAnchor, constant: -20),
            
            placeAddressLabel.topAnchor.constraint(equalTo: placeTitleLabel.bottomAnchor, constant: 8),
            placeAddressLabel.leadingAnchor.constraint(equalTo: placeTitleLabel.leadingAnchor),
            placeAddressLabel.trailingAnchor.constraint(equalTo: placeTitleLabel.trailingAnchor),
            
            visitDateLabel.topAnchor.constraint(equalTo: placeAddressLabel.bottomAnchor, constant: 8),
            visitDateLabel.leadingAnchor.constraint(equalTo: placeTitleLabel.leadingAnchor),
            visitDateLabel.trailingAnchor.constraint(equalTo: placeTitleLabel.trailingAnchor),
            visitDateLabel.bottomAnchor.constraint(equalTo: placeHeaderView.bottomAnchor, constant: -20),
            
            // 별점
            ratingContainer.topAnchor.constraint(equalTo: placeHeaderView.bottomAnchor, constant: 16),
            ratingContainer.leadingAnchor.constraint(equalTo: placeHeaderView.leadingAnchor),
            ratingContainer.trailingAnchor.constraint(equalTo: placeHeaderView.trailingAnchor),
            
            ratingStackView.centerXAnchor.constraint(equalTo: ratingContainer.centerXAnchor),
            ratingStackView.topAnchor.constraint(equalTo: ratingContainer.topAnchor, constant: 20),
            ratingStackView.bottomAnchor.constraint(equalTo: ratingContainer.bottomAnchor, constant: -20),
            
            // 날씨 & 기분
            moodWeatherContainer.topAnchor.constraint(equalTo: ratingContainer.bottomAnchor, constant: 16),
            moodWeatherContainer.leadingAnchor.constraint(equalTo: ratingContainer.leadingAnchor),
            moodWeatherContainer.trailingAnchor.constraint(equalTo: ratingContainer.trailingAnchor),
            
            weatherLabel.topAnchor.constraint(equalTo: moodWeatherContainer.topAnchor, constant: 20),
            weatherLabel.leadingAnchor.constraint(equalTo: moodWeatherContainer.leadingAnchor, constant: 20),
            
            weatherValueLabel.leadingAnchor.constraint(equalTo: weatherLabel.trailingAnchor, constant: 12),
            weatherValueLabel.centerYAnchor.constraint(equalTo: weatherLabel.centerYAnchor),
            
            moodLabel.topAnchor.constraint(equalTo: weatherLabel.bottomAnchor, constant: 16),
            moodLabel.leadingAnchor.constraint(equalTo: weatherLabel.leadingAnchor),
            moodLabel.bottomAnchor.constraint(equalTo: moodWeatherContainer.bottomAnchor, constant: -20),
            
            moodValueLabel.leadingAnchor.constraint(equalTo: moodLabel.trailingAnchor, constant: 12),
            moodValueLabel.centerYAnchor.constraint(equalTo: moodLabel.centerYAnchor),
            
            // 사진 섹션
            photoContainer.topAnchor.constraint(equalTo: moodWeatherContainer.bottomAnchor, constant: 32),
            photoContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            photoContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            photoHeaderLabel.topAnchor.constraint(equalTo: photoContainer.topAnchor),
            photoHeaderLabel.leadingAnchor.constraint(equalTo: photoContainer.leadingAnchor, constant: 20),
            photoHeaderLabel.trailingAnchor.constraint(equalTo: photoContainer.trailingAnchor, constant: -20),
            
            photoCollectionView.topAnchor.constraint(equalTo: photoHeaderLabel.bottomAnchor, constant: 16),
            photoCollectionView.leadingAnchor.constraint(equalTo: photoContainer.leadingAnchor),
            photoCollectionView.trailingAnchor.constraint(equalTo: photoContainer.trailingAnchor),
            photoCollectionView.heightAnchor.constraint(equalToConstant: 120),
            photoCollectionView.bottomAnchor.constraint(equalTo: photoContainer.bottomAnchor),
            
            // 태그 섹션
            tagContainer.topAnchor.constraint(equalTo: photoContainer.bottomAnchor, constant: 32),
            tagContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            tagContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            tagHeaderLabel.topAnchor.constraint(equalTo: tagContainer.topAnchor),
            tagHeaderLabel.leadingAnchor.constraint(equalTo: tagContainer.leadingAnchor, constant: 20),
            tagHeaderLabel.trailingAnchor.constraint(equalTo: tagContainer.trailingAnchor, constant: -20),
            
            tagCollectionView.topAnchor.constraint(equalTo: tagHeaderLabel.bottomAnchor, constant: 16),
            tagCollectionView.leadingAnchor.constraint(equalTo: tagContainer.leadingAnchor),
            tagCollectionView.trailingAnchor.constraint(equalTo: tagContainer.trailingAnchor),
            tagCollectionView.heightAnchor.constraint(equalToConstant: 44),
            tagCollectionView.bottomAnchor.constraint(equalTo: tagContainer.bottomAnchor),
            
            // 내용 섹션
            contentContainer.topAnchor.constraint(equalTo: tagContainer.bottomAnchor, constant: 32),
            contentContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            contentContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            contentHeaderLabel.topAnchor.constraint(equalTo: contentContainer.topAnchor, constant: 20),
            contentHeaderLabel.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor, constant: 20),
            contentHeaderLabel.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor, constant: -20),
            
            contentTextView.topAnchor.constraint(equalTo: contentHeaderLabel.bottomAnchor, constant: 12),
            contentTextView.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor, constant: 4),
            contentTextView.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor, constant: -4),
            contentTextView.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor, constant: -4),
            
            // 삭제 버튼
            deleteButtonContainer.topAnchor.constraint(equalTo: contentContainer.bottomAnchor, constant: 32),
            deleteButtonContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            deleteButtonContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            deleteButtonContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            
            deleteButton.topAnchor.constraint(equalTo: deleteButtonContainer.topAnchor),
            deleteButton.leadingAnchor.constraint(equalTo: deleteButtonContainer.leadingAnchor, constant: 20),
            deleteButton.trailingAnchor.constraint(equalTo: deleteButtonContainer.trailingAnchor, constant: -20),
            deleteButton.heightAnchor.constraint(equalToConstant: 50),
            deleteButton.bottomAnchor.constraint(equalTo: deleteButtonContainer.bottomAnchor)
        ])
    }
    
    // MARK: - Public Methods
    func configure(with record: VisitRecord) {
        print("🔄 [VIEW DEBUG] RecordDetailView.configure 시작")
        print("🔄 [VIEW DEBUG] 스레드: \(Thread.isMainThread ? "Main" : "Background")")
        print("📍 [VIEW DEBUG] 장소: \(record.placeTitle)")
        print("📝 [VIEW DEBUG] 내용: \(record.content ?? "없음")")
        print("⭐ [VIEW DEBUG] 평점: \(record.rating)")
        print("🏷️ [VIEW DEBUG] 태그 개수: \(record.tags.count)")
        print("🖼️ [VIEW DEBUG] 이미지 개수: \(record.imageUrls.count)")
        
        // 라벨 업데이트 전 상태
        print("🔍 [VIEW DEBUG] 업데이트 전:")
        print("  - placeTitleLabel.text: \(placeTitleLabel.text ?? "nil")")
        print("  - contentTextView.text: \(contentTextView.text ?? "nil")")
        
        // UI 업데이트
        placeTitleLabel.text = record.placeTitle
        placeAddressLabel.text = record.placeAddress
        
        // 방문 날짜 포맷
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "yyyy년 M월 d일 (E) HH:mm"
        visitDateLabel.text = dateFormatter.string(from: record.visitedAt)
        
        // 별점 표시
        updateRating(record.rating)
        
        // 날씨 & 기분
        weatherValueLabel.text = record.weather?.emoji ?? "-"
        moodValueLabel.text = record.mood?.emoji ?? "-"
        
        // 내용
        contentTextView.text = record.content
        
        // 이미지 & 태그
        self.images = record.imageUrls
        self.tags = record.tags
        
        // 섹션 표시/숨김
        photoContainer.isHidden = images.isEmpty
        tagContainer.isHidden = tags.isEmpty
        
        // 업데이트 후 상태
        print("🔍 [VIEW DEBUG] 업데이트 후:")
        print("  - placeTitleLabel.text: \(placeTitleLabel.text ?? "nil")")
        print("  - contentTextView.text: \(contentTextView.text ?? "nil")")
        
        // 컬렉션뷰 리로드
        print("🔄 [VIEW DEBUG] 컬렉션뷰 리로드 중...")
        DispatchQueue.main.async { [weak self] in
            self?.photoCollectionView.reloadData()
            self?.tagCollectionView.reloadData()
            print("✅ [VIEW DEBUG] 컬렉션뷰 리로드 완료")
        }
        
        // 강제 레이아웃 업데이트
        print("🔧 [VIEW DEBUG] 레이아웃 업데이트 중...")
        setNeedsLayout()
        layoutIfNeeded()
        
        print("✅ [VIEW DEBUG] RecordDetailView.configure 완료")
    }
    
    private func updateRating(_ rating: Int) {
        for (index, starView) in ratingStackView.arrangedSubviews.enumerated() {
            guard let starImageView = starView as? UIImageView else { continue }
            
            if index < rating {
                starImageView.image = UIImage(systemName: "star.fill")
                starImageView.tintColor = .systemYellow
            } else {
                starImageView.image = UIImage(systemName: "star")
                starImageView.tintColor = .themeTextSecondary
            }
        }
    }
}

// MARK: - UICollectionViewDataSource & Delegate
extension RecordDetailView: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == photoCollectionView {
            return images.count
        } else if collectionView == tagCollectionView {
            return tags.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == photoCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DetailPhotoCell", for: indexPath) as! DetailPhotoCell
            cell.configure(with: images[indexPath.item])
            return cell
        } else if collectionView == tagCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DetailTagCell", for: indexPath) as! DetailTagCell
            cell.configure(with: tags[indexPath.item])
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == photoCollectionView {
            // 사진 확대보기 기능 추가 가능
        }
    }
}

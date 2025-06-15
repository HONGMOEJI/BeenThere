//
//  RecordView.swift
//  BeenThere
//
//  방문 기록 작성 뷰
//

import UIKit

class RecordView: UIView {
    // MARK: - UI Components
    let scrollView = UIScrollView()
    let contentView = UIView()
    
    // 장소 정보 섹션 (헤더)
    let placeHeaderView = UIView()
    let placeTitleLabel = UILabel()
    let placeAddressLabel = UILabel()
    let placeIconView = UIView()
    
    // 방문 날짜
    let visitDateSection = UIView()
    let visitDateLabel = UILabel()
    let visitDatePicker = UIDatePicker()
    
    // 별점 (개선된 디자인)
    let ratingSection = UIView()
    let ratingLabel = UILabel()
    let ratingStackView = UIStackView()
    var starButtons: [UIButton] = []
    
    // 날씨 & 기분 (개선된 선택 스타일)
    let moodWeatherSection = UIView()
    let weatherLabel = UILabel()
    let weatherStackView = UIStackView()
    let moodLabel = UILabel()
    let moodStackView = UIStackView()
    
    // 사진 섹션
    let photoSection = UIView()
    let photoHeaderView = UIView()
    let photoLabel = UILabel()
    let photoCountLabel = UILabel()
    let addPhotoButton = UIButton(type: .system)
    let photoCollectionView: UICollectionView
    
    // 태그 섹션 (레이아웃 개선)
    let tagSection = UIView()
    let tagHeaderView = UIView()
    let tagLabel = UILabel()
    let tagCountLabel = UILabel()
    let tagInputContainer = UIView()
    let tagInputField = UITextField()
    let addTagButton = UIButton(type: .system)
    let tagCollectionView: UICollectionView
    
    // 내용 섹션
    let contentSection = UIView()
    let contentLabel = UILabel()
    let contentTextView = UITextView()
    let contentPlaceholder = UILabel()
    let contentCountLabel = UILabel()
    
    // 저장 버튼 (단순화)
    let saveButtonContainer = UIView()
    let saveButton = UIButton(type: .system)
    
    // MARK: - Init
    override init(frame: CGRect) {
        // 컬렉션뷰 초기화
        let photoLayout = UICollectionViewFlowLayout()
        photoLayout.scrollDirection = .horizontal
        photoLayout.itemSize = CGSize(width: 120, height: 120)
        photoLayout.minimumInteritemSpacing = 12
        photoLayout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        photoCollectionView = UICollectionView(frame: .zero, collectionViewLayout: photoLayout)
        
        // 태그 컬렉션뷰 레이아웃 개선
        let tagLayout = UICollectionViewFlowLayout()
        tagLayout.scrollDirection = .horizontal
        tagLayout.estimatedItemSize = CGSize(width: 100, height: 36) // 고정 높이 설정
        tagLayout.minimumInteritemSpacing = 8
        tagLayout.minimumLineSpacing = 8
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
        setupVisitDate()
        setupRating()
        setupMoodWeather()
        setupPhotoSection()
        setupTagSection()
        setupContentSection()
        setupSaveButton()
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
    
    private func setupPlaceHeader() {
        placeHeaderView.translatesAutoresizingMaskIntoConstraints = false
        placeHeaderView.backgroundColor = .themeBackground
        
        // 장소 아이콘 (더 미니멀하게)
        placeIconView.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        placeIconView.layer.cornerRadius = 20
        placeIconView.translatesAutoresizingMaskIntoConstraints = false
        
        let iconImageView = UIImageView(image: UIImage(systemName: "location.fill"))
        iconImageView.tintColor = .themeTextSecondary
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        placeIconView.addSubview(iconImageView)
        
        // 장소 제목 (그레이스케일 적용)
        placeTitleLabel.font = .titleLarge
        placeTitleLabel.textColor = .themeTextPrimary
        placeTitleLabel.numberOfLines = 2
        placeTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // 장소 주소
        placeAddressLabel.font = .bodyMedium
        placeAddressLabel.textColor = .themeTextSecondary
        placeAddressLabel.numberOfLines = 2
        placeAddressLabel.translatesAutoresizingMaskIntoConstraints = false
        
        placeHeaderView.addSubview(placeIconView)
        placeHeaderView.addSubview(placeTitleLabel)
        placeHeaderView.addSubview(placeAddressLabel)
        
        NSLayoutConstraint.activate([
            iconImageView.centerXAnchor.constraint(equalTo: placeIconView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: placeIconView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 20),
            iconImageView.heightAnchor.constraint(equalToConstant: 20),
            
            placeIconView.leadingAnchor.constraint(equalTo: placeHeaderView.leadingAnchor, constant: 20),
            placeIconView.topAnchor.constraint(equalTo: placeHeaderView.topAnchor, constant: 20),
            placeIconView.widthAnchor.constraint(equalToConstant: 40),
            placeIconView.heightAnchor.constraint(equalToConstant: 40),
            
            placeTitleLabel.leadingAnchor.constraint(equalTo: placeIconView.trailingAnchor, constant: 16),
            placeTitleLabel.trailingAnchor.constraint(equalTo: placeHeaderView.trailingAnchor, constant: -20),
            placeTitleLabel.topAnchor.constraint(equalTo: placeIconView.topAnchor),
            
            placeAddressLabel.leadingAnchor.constraint(equalTo: placeTitleLabel.leadingAnchor),
            placeAddressLabel.trailingAnchor.constraint(equalTo: placeTitleLabel.trailingAnchor),
            placeAddressLabel.topAnchor.constraint(equalTo: placeTitleLabel.bottomAnchor, constant: 4),
            placeAddressLabel.bottomAnchor.constraint(equalTo: placeHeaderView.bottomAnchor, constant: -20)
        ])
    }
    
    private func setupVisitDate() {
        visitDateSection.backgroundColor = UIColor.white.withAlphaComponent(0.05)
        visitDateSection.layer.cornerRadius = 12
        visitDateSection.layer.borderWidth = 1
        visitDateSection.layer.borderColor = UIColor.white.withAlphaComponent(0.1).cgColor
        visitDateSection.translatesAutoresizingMaskIntoConstraints = false
        
        visitDateLabel.text = "방문 날짜"
        visitDateLabel.font = .headlineMedium
        visitDateLabel.textColor = .themeTextPrimary
        visitDateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        visitDatePicker.datePickerMode = .date
        visitDatePicker.preferredDatePickerStyle = .compact
        visitDatePicker.maximumDate = Date()
        visitDatePicker.overrideUserInterfaceStyle = .dark
        visitDatePicker.translatesAutoresizingMaskIntoConstraints = false
        
        visitDateSection.addSubview(visitDateLabel)
        visitDateSection.addSubview(visitDatePicker)
    }
    
    private func setupRating() {
        ratingSection.backgroundColor = UIColor.white.withAlphaComponent(0.05)
        ratingSection.layer.cornerRadius = 12
        ratingSection.layer.borderWidth = 1
        ratingSection.layer.borderColor = UIColor.white.withAlphaComponent(0.1).cgColor
        ratingSection.translatesAutoresizingMaskIntoConstraints = false
        
        ratingLabel.text = "이곳은 어떠셨나요?"
        ratingLabel.font = .headlineMedium
        ratingLabel.textColor = .themeTextPrimary
        ratingLabel.translatesAutoresizingMaskIntoConstraints = false
        
        ratingStackView.axis = .horizontal
        ratingStackView.spacing = 12
        ratingStackView.distribution = .fillEqually
        ratingStackView.translatesAutoresizingMaskIntoConstraints = false
        
        // 별점 버튼 5개 생성 (배경 완전 제거)
        for i in 1...5 {
            let button = UIButton(type: .custom) // .system 대신 .custom 사용
            
            // 빈 별
            button.setImage(UIImage(systemName: "star", withConfiguration: UIImage.SymbolConfiguration(pointSize: 28, weight: .light)), for: .normal)
            
            // 채워진 별
            button.setImage(UIImage(systemName: "star.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 28, weight: .medium)), for: .selected)
            
            button.tintColor = .themeTextSecondary
            button.backgroundColor = .clear // 배경 완전 투명
            button.layer.backgroundColor = UIColor.clear.cgColor // 레이어 배경도 투명
            button.tag = i
            button.translatesAutoresizingMaskIntoConstraints = false
            button.heightAnchor.constraint(equalToConstant: 44).isActive = true
            
            // 터치 상태에서도 배경색 변경 방지
            button.adjustsImageWhenHighlighted = false
            button.showsTouchWhenHighlighted = false
            
            starButtons.append(button)
            ratingStackView.addArrangedSubview(button)
        }
        
        ratingSection.addSubview(ratingLabel)
        ratingSection.addSubview(ratingStackView)
    }
    
    private func setupMoodWeather() {
        moodWeatherSection.backgroundColor = UIColor.white.withAlphaComponent(0.05)
        moodWeatherSection.layer.cornerRadius = 12
        moodWeatherSection.layer.borderWidth = 1
        moodWeatherSection.layer.borderColor = UIColor.white.withAlphaComponent(0.1).cgColor
        moodWeatherSection.translatesAutoresizingMaskIntoConstraints = false
        
        weatherLabel.text = "날씨"
        weatherLabel.font = .headlineMedium
        weatherLabel.textColor = .themeTextPrimary
        weatherLabel.translatesAutoresizingMaskIntoConstraints = false
        
        weatherStackView.axis = .horizontal
        weatherStackView.spacing = 8
        weatherStackView.distribution = .fillEqually
        weatherStackView.translatesAutoresizingMaskIntoConstraints = false
        
        moodLabel.text = "기분"
        moodLabel.font = .headlineMedium
        moodLabel.textColor = .themeTextPrimary
        moodLabel.translatesAutoresizingMaskIntoConstraints = false
        
        moodStackView.axis = .horizontal
        moodStackView.spacing = 8
        moodStackView.distribution = .fillEqually
        moodStackView.translatesAutoresizingMaskIntoConstraints = false
        
        moodWeatherSection.addSubview(weatherLabel)
        moodWeatherSection.addSubview(weatherStackView)
        moodWeatherSection.addSubview(moodLabel)
        moodWeatherSection.addSubview(moodStackView)
    }
    
    private func setupPhotoSection() {
        photoSection.translatesAutoresizingMaskIntoConstraints = false
        
        // 헤더
        photoHeaderView.translatesAutoresizingMaskIntoConstraints = false
        
        photoLabel.text = "사진"
        photoLabel.font = .headlineLarge
        photoLabel.textColor = .themeTextPrimary
        photoLabel.translatesAutoresizingMaskIntoConstraints = false
        
        photoCountLabel.text = "0/10"
        photoCountLabel.font = .labelMedium
        photoCountLabel.textColor = .themeTextSecondary
        photoCountLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // 더 심플한 추가 버튼
        addPhotoButton.setImage(UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)), for: .normal)
        addPhotoButton.tintColor = .themeTextSecondary
        addPhotoButton.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        addPhotoButton.layer.cornerRadius = 16
        addPhotoButton.translatesAutoresizingMaskIntoConstraints = false
        
        photoHeaderView.addSubview(photoLabel)
        photoHeaderView.addSubview(photoCountLabel)
        photoHeaderView.addSubview(addPhotoButton)
        
        // 컬렉션뷰
        photoCollectionView.backgroundColor = .clear
        photoCollectionView.showsHorizontalScrollIndicator = false
        photoCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        photoSection.addSubview(photoHeaderView)
        photoSection.addSubview(photoCollectionView)
    }
    
    private func setupTagSection() {
        tagSection.translatesAutoresizingMaskIntoConstraints = false
        
        // 헤더
        tagHeaderView.translatesAutoresizingMaskIntoConstraints = false
        
        tagLabel.text = "태그"
        tagLabel.font = .headlineLarge
        tagLabel.textColor = .themeTextPrimary
        tagLabel.translatesAutoresizingMaskIntoConstraints = false
        
        tagCountLabel.text = "0/10"
        tagCountLabel.font = .labelMedium
        tagCountLabel.textColor = .themeTextSecondary
        tagCountLabel.translatesAutoresizingMaskIntoConstraints = false
        
        tagHeaderView.addSubview(tagLabel)
        tagHeaderView.addSubview(tagCountLabel)
        
        // 태그 입력 컨테이너 (미니멀 디자인)
        tagInputContainer.backgroundColor = UIColor.white.withAlphaComponent(0.05)
        tagInputContainer.layer.cornerRadius = 12
        tagInputContainer.layer.borderWidth = 1
        tagInputContainer.layer.borderColor = UIColor.white.withAlphaComponent(0.1).cgColor
        tagInputContainer.translatesAutoresizingMaskIntoConstraints = false
        
        tagInputField.placeholder = "태그를 입력하세요..."
        tagInputField.font = .bodyMedium
        tagInputField.textColor = .themeTextPrimary
        tagInputField.backgroundColor = .clear
        tagInputField.returnKeyType = .done
        tagInputField.translatesAutoresizingMaskIntoConstraints = false
        
        // 플레이스홀더 색상
        tagInputField.attributedPlaceholder = NSAttributedString(
            string: "태그를 입력하세요...",
            attributes: [.foregroundColor: UIColor.themeTextPlaceholder]
        )
        
        addTagButton.setImage(UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)), for: .normal)
        addTagButton.tintColor = .themeTextSecondary
        addTagButton.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        addTagButton.layer.cornerRadius = 12
        addTagButton.translatesAutoresizingMaskIntoConstraints = false
        
        tagInputContainer.addSubview(tagInputField)
        tagInputContainer.addSubview(addTagButton)
        
        // 태그 컬렉션뷰
        tagCollectionView.backgroundColor = .clear
        tagCollectionView.showsHorizontalScrollIndicator = false
        tagCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        tagSection.addSubview(tagHeaderView)
        tagSection.addSubview(tagInputContainer)
        tagSection.addSubview(tagCollectionView)
    }
    
    private func setupContentSection() {
        contentSection.backgroundColor = UIColor.white.withAlphaComponent(0.05)
        contentSection.layer.cornerRadius = 12
        contentSection.layer.borderWidth = 1
        contentSection.layer.borderColor = UIColor.white.withAlphaComponent(0.1).cgColor
        contentSection.translatesAutoresizingMaskIntoConstraints = false
        
        contentLabel.text = "방문 소감"
        contentLabel.font = .headlineMedium
        contentLabel.textColor = .themeTextPrimary
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // 초기값을 "0자"로 설정
        contentCountLabel.text = "0자"
        contentCountLabel.font = .labelSmall
        contentCountLabel.textColor = .themeTextSecondary
        contentCountLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentTextView.font = .bodyMedium
        contentTextView.textColor = .themeTextPrimary
        contentTextView.backgroundColor = .clear
        contentTextView.layer.cornerRadius = 8
        contentTextView.textContainerInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        contentTextView.translatesAutoresizingMaskIntoConstraints = false
        
        contentPlaceholder.text = "이곳에서의 경험과 느낌을 자유롭게 적어보세요..."
        contentPlaceholder.font = .bodyMedium
        contentPlaceholder.textColor = .themeTextPlaceholder
        contentPlaceholder.numberOfLines = 0
        contentPlaceholder.translatesAutoresizingMaskIntoConstraints = false
        
        contentSection.addSubview(contentLabel)
        contentSection.addSubview(contentCountLabel)
        contentSection.addSubview(contentTextView)
        contentSection.addSubview(contentPlaceholder)
    }
    
    private func setupSaveButton() {
        saveButtonContainer.translatesAutoresizingMaskIntoConstraints = false
        
        saveButton.setTitle("기록 저장하기", for: .normal)
        saveButton.setTitleColor(.buttonPrimaryText, for: .normal)
        saveButton.titleLabel?.font = .buttonLarge
        saveButton.backgroundColor = .buttonPrimaryBackground
        saveButton.layer.cornerRadius = 12
        
        // 그림자 제거하고 심플하게
        saveButton.layer.shadowColor = UIColor.clear.cgColor
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        
        saveButtonContainer.addSubview(saveButton)
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
        [placeHeaderView, visitDateSection, ratingSection, moodWeatherSection,
         photoSection, tagSection, contentSection, saveButtonContainer].forEach {
            contentView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            // 장소 헤더
            placeHeaderView.topAnchor.constraint(equalTo: contentView.topAnchor),
            placeHeaderView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            placeHeaderView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            // 방문 날짜
            visitDateSection.topAnchor.constraint(equalTo: placeHeaderView.bottomAnchor, constant: 20),
            visitDateSection.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            visitDateSection.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            visitDateLabel.leadingAnchor.constraint(equalTo: visitDateSection.leadingAnchor, constant: 20),
            visitDateLabel.centerYAnchor.constraint(equalTo: visitDateSection.centerYAnchor),
            
            visitDatePicker.trailingAnchor.constraint(equalTo: visitDateSection.trailingAnchor, constant: -20),
            visitDatePicker.centerYAnchor.constraint(equalTo: visitDateSection.centerYAnchor),
            visitDatePicker.topAnchor.constraint(equalTo: visitDateSection.topAnchor, constant: 16),
            visitDatePicker.bottomAnchor.constraint(equalTo: visitDateSection.bottomAnchor, constant: -16),
            
            // 별점
            ratingSection.topAnchor.constraint(equalTo: visitDateSection.bottomAnchor, constant: 16),
            ratingSection.leadingAnchor.constraint(equalTo: visitDateSection.leadingAnchor),
            ratingSection.trailingAnchor.constraint(equalTo: visitDateSection.trailingAnchor),
            
            ratingLabel.topAnchor.constraint(equalTo: ratingSection.topAnchor, constant: 20),
            ratingLabel.leadingAnchor.constraint(equalTo: ratingSection.leadingAnchor, constant: 20),
            ratingLabel.trailingAnchor.constraint(equalTo: ratingSection.trailingAnchor, constant: -20),
            
            ratingStackView.topAnchor.constraint(equalTo: ratingLabel.bottomAnchor, constant: 16),
            ratingStackView.leadingAnchor.constraint(equalTo: ratingLabel.leadingAnchor),
            ratingStackView.trailingAnchor.constraint(equalTo: ratingLabel.trailingAnchor),
            ratingStackView.bottomAnchor.constraint(equalTo: ratingSection.bottomAnchor, constant: -20),
            
            // 날씨 & 기분
            moodWeatherSection.topAnchor.constraint(equalTo: ratingSection.bottomAnchor, constant: 16),
            moodWeatherSection.leadingAnchor.constraint(equalTo: ratingSection.leadingAnchor),
            moodWeatherSection.trailingAnchor.constraint(equalTo: ratingSection.trailingAnchor),
            
            weatherLabel.topAnchor.constraint(equalTo: moodWeatherSection.topAnchor, constant: 20),
            weatherLabel.leadingAnchor.constraint(equalTo: moodWeatherSection.leadingAnchor, constant: 20),
            weatherLabel.trailingAnchor.constraint(equalTo: moodWeatherSection.trailingAnchor, constant: -20),
            
            weatherStackView.topAnchor.constraint(equalTo: weatherLabel.bottomAnchor, constant: 12),
            weatherStackView.leadingAnchor.constraint(equalTo: weatherLabel.leadingAnchor),
            weatherStackView.trailingAnchor.constraint(equalTo: weatherLabel.trailingAnchor),
            weatherStackView.heightAnchor.constraint(equalToConstant: 40),
            
            moodLabel.topAnchor.constraint(equalTo: weatherStackView.bottomAnchor, constant: 20),
            moodLabel.leadingAnchor.constraint(equalTo: weatherLabel.leadingAnchor),
            moodLabel.trailingAnchor.constraint(equalTo: weatherLabel.trailingAnchor),
            
            moodStackView.topAnchor.constraint(equalTo: moodLabel.bottomAnchor, constant: 12),
            moodStackView.leadingAnchor.constraint(equalTo: moodLabel.leadingAnchor),
            moodStackView.trailingAnchor.constraint(equalTo: moodLabel.trailingAnchor),
            moodStackView.heightAnchor.constraint(equalToConstant: 40),
            moodStackView.bottomAnchor.constraint(equalTo: moodWeatherSection.bottomAnchor, constant: -20),
            
            // 사진 섹션
            photoSection.topAnchor.constraint(equalTo: moodWeatherSection.bottomAnchor, constant: 32),
            photoSection.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            photoSection.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            // 사진 헤더
            photoHeaderView.topAnchor.constraint(equalTo: photoSection.topAnchor),
            photoHeaderView.leadingAnchor.constraint(equalTo: photoSection.leadingAnchor, constant: 20),
            photoHeaderView.trailingAnchor.constraint(equalTo: photoSection.trailingAnchor, constant: -20),
            photoHeaderView.heightAnchor.constraint(equalToConstant: 44),
            
            photoLabel.leadingAnchor.constraint(equalTo: photoHeaderView.leadingAnchor),
            photoLabel.centerYAnchor.constraint(equalTo: photoHeaderView.centerYAnchor),
            
            photoCountLabel.leadingAnchor.constraint(equalTo: photoLabel.trailingAnchor, constant: 8),
            photoCountLabel.centerYAnchor.constraint(equalTo: photoHeaderView.centerYAnchor),
            
            addPhotoButton.trailingAnchor.constraint(equalTo: photoHeaderView.trailingAnchor),
            addPhotoButton.centerYAnchor.constraint(equalTo: photoHeaderView.centerYAnchor),
            addPhotoButton.widthAnchor.constraint(equalToConstant: 32),
            addPhotoButton.heightAnchor.constraint(equalToConstant: 32),
            
            // 사진 컬렉션뷰
            photoCollectionView.topAnchor.constraint(equalTo: photoHeaderView.bottomAnchor, constant: 16),
            photoCollectionView.leadingAnchor.constraint(equalTo: photoSection.leadingAnchor),
            photoCollectionView.trailingAnchor.constraint(equalTo: photoSection.trailingAnchor),
            photoCollectionView.heightAnchor.constraint(equalToConstant: 120),
            photoCollectionView.bottomAnchor.constraint(equalTo: photoSection.bottomAnchor),
            
            // 태그 섹션
            tagSection.topAnchor.constraint(equalTo: photoSection.bottomAnchor, constant: 32),
            tagSection.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            tagSection.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            // 태그 헤더
            tagHeaderView.topAnchor.constraint(equalTo: tagSection.topAnchor),
            tagHeaderView.leadingAnchor.constraint(equalTo: tagSection.leadingAnchor, constant: 20),
            tagHeaderView.trailingAnchor.constraint(equalTo: tagSection.trailingAnchor, constant: -20),
            tagHeaderView.heightAnchor.constraint(equalToConstant: 44),
            
            tagLabel.leadingAnchor.constraint(equalTo: tagHeaderView.leadingAnchor),
            tagLabel.centerYAnchor.constraint(equalTo: tagHeaderView.centerYAnchor),
            
            tagCountLabel.leadingAnchor.constraint(equalTo: tagLabel.trailingAnchor, constant: 8),
            tagCountLabel.centerYAnchor.constraint(equalTo: tagHeaderView.centerYAnchor),
            
            // 태그 입력 컨테이너
            tagInputContainer.topAnchor.constraint(equalTo: tagHeaderView.bottomAnchor, constant: 16),
            tagInputContainer.leadingAnchor.constraint(equalTo: tagHeaderView.leadingAnchor),
            tagInputContainer.trailingAnchor.constraint(equalTo: tagHeaderView.trailingAnchor),
            tagInputContainer.heightAnchor.constraint(equalToConstant: 48),
            
            tagInputField.leadingAnchor.constraint(equalTo: tagInputContainer.leadingAnchor, constant: 16),
            tagInputField.centerYAnchor.constraint(equalTo: tagInputContainer.centerYAnchor),
            
            addTagButton.leadingAnchor.constraint(equalTo: tagInputField.trailingAnchor, constant: 8),
            addTagButton.trailingAnchor.constraint(equalTo: tagInputContainer.trailingAnchor, constant: -16),
            addTagButton.centerYAnchor.constraint(equalTo: tagInputContainer.centerYAnchor),
            addTagButton.widthAnchor.constraint(equalToConstant: 24),
            addTagButton.heightAnchor.constraint(equalToConstant: 24),
            
            // 태그 컬렉션뷰 (높이 고정)
            tagCollectionView.topAnchor.constraint(equalTo: tagInputContainer.bottomAnchor, constant: 16),
            tagCollectionView.leadingAnchor.constraint(equalTo: tagSection.leadingAnchor),
            tagCollectionView.trailingAnchor.constraint(equalTo: tagSection.trailingAnchor),
            tagCollectionView.heightAnchor.constraint(equalToConstant: 44), // 고정 높이로 잘림 방지
            tagCollectionView.bottomAnchor.constraint(equalTo: tagSection.bottomAnchor),
            
            // 내용 섹션
            contentSection.topAnchor.constraint(equalTo: tagSection.bottomAnchor, constant: 32),
            contentSection.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            contentSection.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            contentLabel.topAnchor.constraint(equalTo: contentSection.topAnchor, constant: 20),
            contentLabel.leadingAnchor.constraint(equalTo: contentSection.leadingAnchor, constant: 20),
            
            contentCountLabel.trailingAnchor.constraint(equalTo: contentSection.trailingAnchor, constant: -20),
            contentCountLabel.centerYAnchor.constraint(equalTo: contentLabel.centerYAnchor),
            
            contentTextView.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: 12),
            contentTextView.leadingAnchor.constraint(equalTo: contentSection.leadingAnchor, constant: 4),
            contentTextView.trailingAnchor.constraint(equalTo: contentSection.trailingAnchor, constant: -4),
            contentTextView.heightAnchor.constraint(equalToConstant: 120),
            contentTextView.bottomAnchor.constraint(equalTo: contentSection.bottomAnchor, constant: -4),
            
            contentPlaceholder.topAnchor.constraint(equalTo: contentTextView.topAnchor, constant: 16),
            contentPlaceholder.leadingAnchor.constraint(equalTo: contentTextView.leadingAnchor, constant: 20),
            contentPlaceholder.trailingAnchor.constraint(equalTo: contentTextView.trailingAnchor, constant: -20),
            
            // 저장 버튼 컨테이너
            saveButtonContainer.topAnchor.constraint(equalTo: contentSection.bottomAnchor, constant: 32),
            saveButtonContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            saveButtonContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            saveButtonContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            
            // 저장 버튼
            saveButton.topAnchor.constraint(equalTo: saveButtonContainer.topAnchor),
            saveButton.leadingAnchor.constraint(equalTo: saveButtonContainer.leadingAnchor, constant: 20),
            saveButton.trailingAnchor.constraint(equalTo: saveButtonContainer.trailingAnchor, constant: -20),
            saveButton.heightAnchor.constraint(equalToConstant: 50),
            saveButton.bottomAnchor.constraint(equalTo: saveButtonContainer.bottomAnchor)
        ])
    }
    
    // MARK: - Public Methods
    func updateStarRating(_ rating: Int) {
        for (index, button) in starButtons.enumerated() {
            button.isSelected = index < rating
            // 선택된 별은 노란색, 선택되지 않은 별은 회색 (배경색 없음)
            button.tintColor = index < rating ? .systemYellow : .themeTextSecondary
            // 배경색 완전 제거 확인
            button.backgroundColor = .clear
            button.layer.backgroundColor = UIColor.clear.cgColor
        }
    }
    
    func updatePlaceholderVisibility(hasText: Bool) {
        contentPlaceholder.isHidden = hasText
    }
    
    func updateSaveButtonState(isEnabled: Bool) {
        saveButton.isEnabled = isEnabled
        saveButton.alpha = isEnabled ? 1.0 : 0.6
        saveButton.backgroundColor = isEnabled ? .buttonPrimaryBackground : .buttonPrimaryBackground.withAlphaComponent(0.6)
    }
    
    func updatePhotoCount(_ count: Int) {
        photoCountLabel.text = "\(count)/10"
    }

    func reloadPhotoCollection() {
        photoCollectionView.reloadData()
    }
    
    func updateTagCount(_ count: Int) {
        tagCountLabel.text = "\(count)/10"
    }
    
    func updateContentCount(_ count: Int) {
        contentCountLabel.text = "\(count)자"
    }
}

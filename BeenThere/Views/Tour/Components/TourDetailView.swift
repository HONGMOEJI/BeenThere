//
//  TourDetailView.swift
//  BeenThere
//
//  관광지 상세 정보 뷰
//

import UIKit
import MapKit
import Kingfisher

class TourDetailView: UIView {
    // MARK: - UI Components
    let scrollView = UIScrollView()
    let contentView = UIView()
    
    // 향상된 이미지 갤러리 (간단한 페이지뷰)
    let imageGalleryContainer = UIView()
    let imagePageView: UIScrollView
    let imagePageControl = UIPageControl()
    
    let nameLabel = UILabel()
    let addressLabel = UILabel()
    let typeLabel = UILabel()
    let descLabel = UILabel()
    let mapView = MKMapView()
    let phoneStack = UIStackView()
    let phoneIcon = UIImageView(image: UIImage(systemName: "phone"))
    let phoneLabel = UILabel()
    let homepageButton = UIButton(type: .system)
    
    // 방문 횟수 표시 뷰 추가
    let visitCountView = VisitCountView()
    
    let recordButton = UIButton(type: .system)
    let distLabel = UILabel()
    let separator = UIView()
    
    // 상세 정보 섹션들
    let detailInfoContainer = UIView()
    let detailInfo2Container = UIView()

    // MARK: - Gallery Data
    private var galleryImages: [TourSiteImage] = []
    private var imageViews: [UIImageView] = []

    // MARK: - Init
    override init(frame: CGRect) {
        // 페이지뷰 스타일 스크롤뷰
        imagePageView = UIScrollView()
        imagePageView.isPagingEnabled = true
        imagePageView.showsHorizontalScrollIndicator = false
        
        super.init(frame: frame)
        backgroundColor = .themeBackground
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(scrollView)
        scrollView.addSubview(contentView)

        // 이미지 갤러리 컨테이너
        setupImageGallery()

        // 이름
        nameLabel.font = .titleLarge
        nameLabel.textColor = .themeTextPrimary
        nameLabel.numberOfLines = 2
        nameLabel.translatesAutoresizingMaskIntoConstraints = false

        // 타입
        typeLabel.font = .labelLarge
        typeLabel.textColor = .themeTextSecondary
        typeLabel.translatesAutoresizingMaskIntoConstraints = false

        // 주소
        addressLabel.font = .bodyMedium
        addressLabel.textColor = .themeTextSecondary
        addressLabel.numberOfLines = 2
        addressLabel.translatesAutoresizingMaskIntoConstraints = false

        // 거리
        distLabel.font = .captionLarge
        distLabel.textColor = .themeTextPlaceholder
        distLabel.translatesAutoresizingMaskIntoConstraints = false

        // 설명
        descLabel.font = .bodyMedium
        descLabel.textColor = .themeTextPrimary
        descLabel.numberOfLines = 0
        descLabel.translatesAutoresizingMaskIntoConstraints = false

        // 지도
        mapView.layer.cornerRadius = 12
        mapView.isUserInteractionEnabled = false
        mapView.translatesAutoresizingMaskIntoConstraints = false

        // 구분선
        separator.backgroundColor = .themeSeparator
        separator.translatesAutoresizingMaskIntoConstraints = false

        // 전화번호
        setupPhoneStack()

        // 홈페이지 버튼
        setupHomepageButton()
        
        // 방문 횟수 뷰 설정
        setupVisitCountView()
        
        // 기록 버튼
        setupRecordButton()
        
        // 상세 정보 컨테이너들
        setupDetailInfoContainers()

        // 계층 구조
        [imageGalleryContainer, nameLabel, typeLabel, addressLabel, distLabel, separator, mapView, descLabel, detailInfoContainer, detailInfo2Container, phoneStack, homepageButton, visitCountView, recordButton].forEach { contentView.addSubview($0) }

        setupConstraints()
    }
    
    private func setupImageGallery() {
        imageGalleryContainer.translatesAutoresizingMaskIntoConstraints = false
        imageGalleryContainer.layer.cornerRadius = 14
        imageGalleryContainer.clipsToBounds = true
        imageGalleryContainer.backgroundColor = UIColor(white: 0.18, alpha: 1)
        
        // 페이지뷰 (전체 영역 사용)
        imagePageView.translatesAutoresizingMaskIntoConstraints = false
        imagePageView.delegate = self
        
        // 페이지 컨트롤 (오버레이 스타일)
        imagePageControl.translatesAutoresizingMaskIntoConstraints = false
        imagePageControl.currentPageIndicatorTintColor = .white
        imagePageControl.pageIndicatorTintColor = UIColor.white.withAlphaComponent(0.4)
        imagePageControl.hidesForSinglePage = true
        imagePageControl.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        imagePageControl.layer.cornerRadius = 12
        
        imageGalleryContainer.addSubview(imagePageView)
        imageGalleryContainer.addSubview(imagePageControl)
        
        NSLayoutConstraint.activate([
            // 페이지뷰가 전체 컨테이너를 채움
            imagePageView.topAnchor.constraint(equalTo: imageGalleryContainer.topAnchor),
            imagePageView.leadingAnchor.constraint(equalTo: imageGalleryContainer.leadingAnchor),
            imagePageView.trailingAnchor.constraint(equalTo: imageGalleryContainer.trailingAnchor),
            imagePageView.bottomAnchor.constraint(equalTo: imageGalleryContainer.bottomAnchor),
            
            // 페이지 컨트롤이 우하단에 오버레이
            imagePageControl.trailingAnchor.constraint(equalTo: imageGalleryContainer.trailingAnchor, constant: -16),
            imagePageControl.bottomAnchor.constraint(equalTo: imageGalleryContainer.bottomAnchor, constant: -16),
            imagePageControl.heightAnchor.constraint(equalToConstant: 24),
            imagePageControl.widthAnchor.constraint(greaterThanOrEqualToConstant: 60)
        ])
    }
    
    private func setupPhoneStack() {
        phoneStack.axis = .horizontal
        phoneStack.spacing = 7
        phoneStack.alignment = .center
        phoneStack.translatesAutoresizingMaskIntoConstraints = false

        phoneIcon.tintColor = .themeTextPlaceholder
        phoneIcon.contentMode = .scaleAspectFit
        phoneIcon.setContentHuggingPriority(.required, for: .horizontal)
        phoneIcon.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 13, weight: .medium)

        phoneLabel.font = .bodySmall
        phoneLabel.textColor = .themeTextSecondary

        phoneStack.addArrangedSubview(phoneIcon)
        phoneStack.addArrangedSubview(phoneLabel)
    }
    
    private func setupHomepageButton() {
        homepageButton.setTitle("홈페이지 바로가기", for: .normal)
        homepageButton.setTitleColor(.primaryBlue, for: .normal)
        homepageButton.titleLabel?.font = .buttonSmall
        homepageButton.isHidden = true
        homepageButton.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupVisitCountView() {
        visitCountView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupRecordButton() {
        recordButton.setTitle("📝 기록하기", for: .normal)
        recordButton.setTitleColor(.white, for: .normal)
        recordButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        recordButton.backgroundColor = .primaryBlue
        recordButton.layer.cornerRadius = 12
        recordButton.layer.shadowColor = UIColor.primaryBlue.cgColor
        recordButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        recordButton.layer.shadowOpacity = 0.3
        recordButton.layer.shadowRadius = 8
        recordButton.isEnabled = false
        recordButton.alpha = 0.5
        recordButton.translatesAutoresizingMaskIntoConstraints = false
        
        // 버튼 애니메이션 효과
        recordButton.addTarget(self, action: #selector(recordButtonPressed), for: .touchDown)
        recordButton.addTarget(self, action: #selector(recordButtonReleased), for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }
    
    @objc private func recordButtonPressed() {
        UIView.animate(withDuration: 0.1) {
            self.recordButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }
    }
    
    @objc private func recordButtonReleased() {
        UIView.animate(withDuration: 0.1) {
            self.recordButton.transform = .identity
        }
    }
    
    private func setupDetailInfoContainers() {
        detailInfoContainer.translatesAutoresizingMaskIntoConstraints = false
        detailInfo2Container.translatesAutoresizingMaskIntoConstraints = false
        
        // 컨테이너 스타일
        [detailInfoContainer, detailInfo2Container].forEach { container in
            container.backgroundColor = UIColor(white: 0.05, alpha: 0.8)
            container.layer.cornerRadius = 12
            container.layer.borderWidth = 1
            container.layer.borderColor = UIColor.white.withAlphaComponent(0.08).cgColor
        }
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // ScrollView를 Safe Area에 맞춤
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),

            // ContentView는 ScrollView에 맞춤
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: widthAnchor),

            // 이미지 갤러리는 여백 추가하여 네비게이션 바와 겹치지 않도록
            imageGalleryContainer.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            imageGalleryContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            imageGalleryContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            imageGalleryContainer.heightAnchor.constraint(equalToConstant: 250),

            nameLabel.topAnchor.constraint(equalTo: imageGalleryContainer.bottomAnchor, constant: 22),
            nameLabel.leadingAnchor.constraint(equalTo: imageGalleryContainer.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: imageGalleryContainer.trailingAnchor),

            typeLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 6),
            typeLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),

            distLabel.centerYAnchor.constraint(equalTo: typeLabel.centerYAnchor),
            distLabel.trailingAnchor.constraint(equalTo: imageGalleryContainer.trailingAnchor),
            distLabel.leadingAnchor.constraint(greaterThanOrEqualTo: typeLabel.trailingAnchor, constant: 10),

            addressLabel.topAnchor.constraint(equalTo: typeLabel.bottomAnchor, constant: 10),
            addressLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            addressLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),

            separator.topAnchor.constraint(equalTo: addressLabel.bottomAnchor, constant: 16),
            separator.leadingAnchor.constraint(equalTo: addressLabel.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: addressLabel.trailingAnchor),
            separator.heightAnchor.constraint(equalToConstant: 1),

            mapView.topAnchor.constraint(equalTo: separator.bottomAnchor, constant: 18),
            mapView.leadingAnchor.constraint(equalTo: imageGalleryContainer.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: imageGalleryContainer.trailingAnchor),
            mapView.heightAnchor.constraint(equalToConstant: 150),

            descLabel.topAnchor.constraint(equalTo: mapView.bottomAnchor, constant: 22),
            descLabel.leadingAnchor.constraint(equalTo: mapView.leadingAnchor),
            descLabel.trailingAnchor.constraint(equalTo: mapView.trailingAnchor),

            detailInfoContainer.topAnchor.constraint(equalTo: descLabel.bottomAnchor, constant: 20),
            detailInfoContainer.leadingAnchor.constraint(equalTo: descLabel.leadingAnchor),
            detailInfoContainer.trailingAnchor.constraint(equalTo: descLabel.trailingAnchor),

            detailInfo2Container.topAnchor.constraint(equalTo: detailInfoContainer.bottomAnchor, constant: 15),
            detailInfo2Container.leadingAnchor.constraint(equalTo: descLabel.leadingAnchor),
            detailInfo2Container.trailingAnchor.constraint(equalTo: descLabel.trailingAnchor),

            phoneStack.topAnchor.constraint(equalTo: detailInfo2Container.bottomAnchor, constant: 20),
            phoneStack.leadingAnchor.constraint(equalTo: descLabel.leadingAnchor),

            homepageButton.topAnchor.constraint(equalTo: phoneStack.bottomAnchor, constant: 12),
            homepageButton.leadingAnchor.constraint(equalTo: phoneStack.leadingAnchor),
            homepageButton.trailingAnchor.constraint(equalTo: phoneStack.trailingAnchor),

            // 방문 횟수 뷰
            visitCountView.topAnchor.constraint(equalTo: homepageButton.bottomAnchor, constant: 20),
            visitCountView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            visitCountView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            // 기록 버튼
            recordButton.topAnchor.constraint(equalTo: visitCountView.bottomAnchor, constant: 12),
            recordButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            recordButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            recordButton.heightAnchor.constraint(equalToConstant: 50),

            // 하단 여백 추가하여 Safe Area 고려
            recordButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -38)
        ])
    }
    
    // MARK: - 이미지 갤러리 설정 (간단한 버전)
    private func setupImageGallery(with images: [TourSiteImage]) {
        // 기존 이미지뷰들 제거
        imageViews.forEach { $0.removeFromSuperview() }
        imageViews.removeAll()
        
        guard !images.isEmpty else {
            imageGalleryContainer.isHidden = true
            return
        }
        
        imageGalleryContainer.isHidden = false
        imagePageControl.numberOfPages = images.count
        imagePageControl.currentPage = 0
        
        // 페이지뷰 콘텐츠 크기 설정
        imagePageView.contentSize = CGSize(width: imagePageView.frame.width * CGFloat(images.count), height: imagePageView.frame.height)
        
        // 각 이미지뷰 생성
        for (index, image) in images.enumerated() {
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.backgroundColor = UIColor(white: 0.18, alpha: 1)
            
            if let url = URL(string: image.originimgurl ?? "") {
                imageView.kf.setImage(with: url, placeholder: UIImage(systemName: "photo"))
            } else {
                imageView.image = UIImage(systemName: "photo")
            }
            
            imagePageView.addSubview(imageView)
            imageViews.append(imageView)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateImageViewFrames()
    }
    
    private func updateImageViewFrames() {
        let pageWidth = imagePageView.frame.width
        let pageHeight = imagePageView.frame.height
        
        for (index, imageView) in imageViews.enumerated() {
            imageView.frame = CGRect(
                x: CGFloat(index) * pageWidth,
                y: 0,
                width: pageWidth,
                height: pageHeight
            )
        }
        
        imagePageView.contentSize = CGSize(width: pageWidth * CGFloat(imageViews.count), height: pageHeight)
    }

    // MARK: - 데이터 적용 (개선된 버전 - 각 섹션 독립적 처리)
    func configure(with detail: TourSiteDetail, images: [TourSiteImage] = [], infos: [DetailInfo] = []) {
        // 기본 정보는 반드시 있어야 함
        configureBasicInfo(with: detail)
        
        // 이미지 갤러리 - 실패해도 다른 섹션에 영향 없음
        do {
            setupImageGallery(with: images)
            galleryImages = images
        } catch {
            print("이미지 갤러리 설정 실패: \(error)")
            imageGalleryContainer.isHidden = true
        }
        
        // 지도 - 좌표가 없으면 숨김
        configureMap(with: detail)
        
        // 연락처 정보 - 없으면 숨김
        configureContactInfo(with: detail)
        
        // 상세 정보 섹션들 - 데이터가 없으면 숨김
        if !infos.isEmpty {
            let halfCount = infos.count / 2
            let detailInfo = Array(infos.prefix(halfCount))
            let detailInfo2 = Array(infos.suffix(infos.count - halfCount))
            
            setupDetailInfoSection(container: detailInfoContainer, title: "상세 정보", infos: detailInfo)
            setupDetailInfoSection(container: detailInfo2Container, title: "이용 안내", infos: detailInfo2)
        } else {
            detailInfoContainer.isHidden = true
            detailInfo2Container.isHidden = true
        }
    }
    
    // MARK: - 방문 횟수 표시 업데이트
    func updateVisitCount(count: Int, message: String) {
        visitCountView.configure(count: count, message: message)
        
        // 기록 버튼 텍스트 업데이트
        if count > 0 {
            recordButton.setTitle("📝 새로운 기록 작성", for: .normal)
        } else {
            recordButton.setTitle("📝 기록하기", for: .normal)
        }
    }
    
    private func setupDetailInfoSection(container: UIView, title: String, infos: [DetailInfo]) {
        // 기존 서브뷰 제거
        container.subviews.forEach { $0.removeFromSuperview() }
        
        guard !infos.isEmpty else {
            container.isHidden = true
            return
        }
        
        container.isHidden = false
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(stackView)
        
        // 섹션 타이틀
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .headlineLarge
        titleLabel.textColor = .themeTextPrimary
        stackView.addArrangedSubview(titleLabel)
        
        // 구분선
        let divider = UIView()
        divider.backgroundColor = .themeSeparator
        divider.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(divider)
        
        // 정보 아이템들
        for info in infos {
            let itemView = createInfoItemView(info: info)
            stackView.addArrangedSubview(itemView)
        }
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16),
            
            divider.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
    
    private func createInfoItemView(info: DetailInfo) -> UIView {
        let containerView = UIView()
        
        let nameLabel = UILabel()
        nameLabel.font = .labelLarge
        nameLabel.textColor = .themeTextSecondary
        nameLabel.text = info.infoname?.removeHTMLTags()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        let valueLabel = UILabel()
        valueLabel.font = .bodyMedium
        valueLabel.textColor = .themeTextPrimary
        valueLabel.text = info.infotext?.removeHTMLTags()
        valueLabel.numberOfLines = 0
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(nameLabel)
        containerView.addSubview(valueLabel)
        
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: containerView.topAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            nameLabel.widthAnchor.constraint(lessThanOrEqualTo: containerView.widthAnchor, multiplier: 0.3),
            
            valueLabel.topAnchor.constraint(equalTo: containerView.topAnchor),
            valueLabel.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor, constant: 12),
            valueLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            valueLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        return containerView
    }

    func showEmptyState(_ message: String) {
        nameLabel.text = message
        nameLabel.textAlignment = .center
        nameLabel.font = .headlineLarge
        nameLabel.textColor = .themeTextSecondary
        
        // 모든 다른 요소들 숨기기
        [typeLabel, addressLabel, descLabel, mapView, phoneStack, homepageButton, recordButton, imageGalleryContainer, separator, detailInfoContainer, detailInfo2Container, visitCountView].forEach { $0.isHidden = true }
    }
    
    // MARK: - 각 섹션 개별 처리를 위한 헬퍼 메서드들
    private func configureBasicInfo(with detail: TourSiteDetail) {
        nameLabel.text = detail.title
        nameLabel.textAlignment = .left
        nameLabel.font = .titleLarge
        nameLabel.textColor = .themeTextPrimary
        
        typeLabel.text = APIConstants.ContentTypes.name(for: Int(detail.contenttypeid ?? "") ?? 0)
        typeLabel.isHidden = false
        
        addressLabel.text = detail.fullAddress
        addressLabel.isHidden = false
        
        descLabel.text = detail.overview?.removeHTMLTags() ?? "설명이 제공되지 않습니다."
        descLabel.isHidden = false
        
        separator.isHidden = false
        distLabel.isHidden = true
    }
    
    private func configureMap(with detail: TourSiteDetail) {
        mapView.removeAnnotations(mapView.annotations)
        
        if let lat = detail.latitude, let lng = detail.longitude {
            let coord = CLLocationCoordinate2D(latitude: lat, longitude: lng)
            let ann = MKPointAnnotation()
            ann.coordinate = coord
            ann.title = detail.title
            mapView.addAnnotation(ann)
            let region = MKCoordinateRegion(center: coord, latitudinalMeters: 700, longitudinalMeters: 700)
            mapView.setRegion(region, animated: false)
            mapView.isHidden = false
        } else {
            mapView.isHidden = true
        }
    }
    
    private func configureContactInfo(with detail: TourSiteDetail) {
        // 전화번호
        if let phone = detail.tel, !phone.isEmpty {
            phoneStack.isHidden = false
            phoneLabel.text = phone
        } else {
            phoneStack.isHidden = true
        }

        // 홈페이지
        if let homepage = detail.homepage?.htmlLinkToUrlAndTitle()?.url {
            homepageButton.setTitle("홈페이지 바로가기", for: .normal)
            homepageButton.isHidden = false
            homepageButton.removeTarget(nil, action: nil, for: .allEvents)
            homepageButton.addAction(UIAction { _ in
                if let url = URL(string: homepage) {
                    UIApplication.shared.open(url)
                }
            }, for: .touchUpInside)
        } else {
            homepageButton.isHidden = true
        }
    }
}

// MARK: - ScrollView Delegate (페이지 전환)
extension TourDetailView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView == imagePageView else { return }
        
        let pageIndex = round(scrollView.contentOffset.x / scrollView.frame.width)
        imagePageControl.currentPage = Int(pageIndex)
    }
}

// MARK: - 방문 횟수 표시 커스텀 뷰
class VisitCountView: UIView {
    private let iconLabel = UILabel()
    private let messageLabel = UILabel()
    private let containerView = UIView()
    private var heightConstraint: NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        translatesAutoresizingMaskIntoConstraints = false
        
        containerView.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
        containerView.layer.cornerRadius = 12
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.systemBlue.withAlphaComponent(0.2).cgColor
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        iconLabel.font = .systemFont(ofSize: 24)
        iconLabel.textAlignment = .center
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        
        messageLabel.font = .bodyMedium
        messageLabel.textColor = .themeTextSecondary
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(containerView)
        containerView.addSubview(iconLabel)
        containerView.addSubview(messageLabel)
        
        // 초기 높이 제약 조건 설정
        heightConstraint = heightAnchor.constraint(equalToConstant: 0)
        heightConstraint?.isActive = true
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            iconLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            iconLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            iconLabel.heightAnchor.constraint(equalToConstant: 30),
            
            messageLabel.topAnchor.constraint(equalTo: iconLabel.bottomAnchor, constant: 8),
            messageLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            messageLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            messageLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16)
        ])
    }
    
    func configure(count: Int, message: String) {
        print("🎨 VisitCountView configure - count: \(count), message: \(message)")
        
        let icons = ["🎉", "✨", "🏆", "👑"]
        let iconIndex = min(count - 1, icons.count - 1)
        iconLabel.text = count > 0 ? icons[max(0, iconIndex)] : ""
        messageLabel.text = message
        
        // AutoLayout 업데이트
        heightConstraint?.isActive = false
        
        if message.isEmpty {
            isHidden = true
            heightConstraint = heightAnchor.constraint(equalToConstant: 0)
        } else {
            isHidden = false
            heightConstraint = heightAnchor.constraint(greaterThanOrEqualToConstant: 80)
        }
        
        heightConstraint?.isActive = true
        
        // 애니메이션과 함께 레이아웃 업데이트
        UIView.animate(withDuration: 0.3) {
            self.superview?.layoutIfNeeded()
        }
        
        print("🎨 VisitCountView 설정 완료 - isHidden: \(isHidden)")
    }
}

// MARK: - String Extension (HTML 태그 제거)
extension String {
    func removeHTMLTags() -> String {
        return self.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
            .replacingOccurrences(of: "&nbsp;", with: " ")
            .replacingOccurrences(of: "&amp;", with: "&")
            .replacingOccurrences(of: "&lt;", with: "<")
            .replacingOccurrences(of: "&gt;", with: ">")
            .replacingOccurrences(of: "&quot;", with: "\"")
            .replacingOccurrences(of: "&apos;", with: "'")
            .replacingOccurrences(of: "&#39;", with: "'")
            .replacingOccurrences(of: "&#x27;", with: "'")
            .replacingOccurrences(of: "&hellip;", with: "…")
            .replacingOccurrences(of: "&mdash;", with: "—")
            .replacingOccurrences(of: "&ndash;", with: "–")
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

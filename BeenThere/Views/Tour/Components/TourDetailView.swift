//
//  TourDetailView.swift
//  BeenThere
//
//  관광지 상세 정보 뷰
//

import UIKit
import MapKit
import Kingfisher
import ObjectiveC

class TourDetailView: UIView {
    // MARK: - UI Components
    let scrollView = UIScrollView()
    let contentView = UIView()
    
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
    
    let visitCountView = VisitCountView()
    let recordButton = UIButton(type: .system)
    let distLabel = UILabel()
    let separator = UIView()
    let detailInfoContainer = UIView()

    private var galleryImages: [TourSiteImage] = []
    private var imageViews: [UIImageView] = []
    
    // MARK: - Dynamic Constraints
    private var dynamicConstraints: [NSLayoutConstraint] = []

    override init(frame: CGRect) {
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

        setupImageGallery()

        nameLabel.font = .titleLarge
        nameLabel.textColor = .themeTextPrimary
        nameLabel.numberOfLines = 2
        nameLabel.translatesAutoresizingMaskIntoConstraints = false

        typeLabel.font = .labelLarge
        typeLabel.textColor = .themeTextSecondary
        typeLabel.translatesAutoresizingMaskIntoConstraints = false

        addressLabel.font = .bodyMedium
        addressLabel.textColor = .themeTextSecondary
        addressLabel.numberOfLines = 2
        addressLabel.translatesAutoresizingMaskIntoConstraints = false

        distLabel.font = .captionLarge
        distLabel.textColor = .themeTextPlaceholder
        distLabel.translatesAutoresizingMaskIntoConstraints = false

        descLabel.font = .bodyMedium
        descLabel.textColor = .themeTextPrimary
        descLabel.numberOfLines = 0
        descLabel.translatesAutoresizingMaskIntoConstraints = false

        mapView.layer.cornerRadius = 12
        mapView.isUserInteractionEnabled = true
        mapView.translatesAutoresizingMaskIntoConstraints = false

        separator.backgroundColor = .themeSeparator
        separator.translatesAutoresizingMaskIntoConstraints = false

        setupPhoneStack()
        setupHomepageButton()
        setupVisitCountView()
        setupRecordButton()
        setupDetailInfoContainer()

        [imageGalleryContainer, nameLabel, typeLabel, addressLabel, distLabel, separator, mapView, descLabel, detailInfoContainer, phoneStack, homepageButton, visitCountView, recordButton].forEach { contentView.addSubview($0) }

        setupStaticConstraints()
    }
    
    private func setupImageGallery() {
        imageGalleryContainer.translatesAutoresizingMaskIntoConstraints = false
        imageGalleryContainer.layer.cornerRadius = 14
        imageGalleryContainer.clipsToBounds = true
        imageGalleryContainer.backgroundColor = UIColor(white: 0.18, alpha: 1)
        
        imagePageView.translatesAutoresizingMaskIntoConstraints = false
        imagePageView.delegate = self
        
        imagePageControl.translatesAutoresizingMaskIntoConstraints = false
        imagePageControl.currentPageIndicatorTintColor = .white
        imagePageControl.pageIndicatorTintColor = UIColor.white.withAlphaComponent(0.4)
        imagePageControl.hidesForSinglePage = true
        imagePageControl.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        imagePageControl.layer.cornerRadius = 12
        
        imageGalleryContainer.addSubview(imagePageView)
        imageGalleryContainer.addSubview(imagePageControl)
        
        NSLayoutConstraint.activate([
            imagePageView.topAnchor.constraint(equalTo: imageGalleryContainer.topAnchor),
            imagePageView.leadingAnchor.constraint(equalTo: imageGalleryContainer.leadingAnchor),
            imagePageView.trailingAnchor.constraint(equalTo: imageGalleryContainer.trailingAnchor),
            imagePageView.bottomAnchor.constraint(equalTo: imageGalleryContainer.bottomAnchor),
            
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
    
    private func setupDetailInfoContainer() {
        detailInfoContainer.translatesAutoresizingMaskIntoConstraints = false
        detailInfoContainer.backgroundColor = UIColor(white: 0.05, alpha: 0.8)
        detailInfoContainer.layer.cornerRadius = 12
        detailInfoContainer.layer.borderWidth = 1
        detailInfoContainer.layer.borderColor = UIColor.white.withAlphaComponent(0.08).cgColor
    }

    private func setupStaticConstraints() {
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),

            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: widthAnchor),

            imageGalleryContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            imageGalleryContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            imageGalleryContainer.heightAnchor.constraint(equalToConstant: 250),

            nameLabel.leadingAnchor.constraint(equalTo: imageGalleryContainer.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: imageGalleryContainer.trailingAnchor),

            typeLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            typeLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 6),

            distLabel.centerYAnchor.constraint(equalTo: typeLabel.centerYAnchor),
            distLabel.trailingAnchor.constraint(equalTo: imageGalleryContainer.trailingAnchor),
            distLabel.leadingAnchor.constraint(greaterThanOrEqualTo: typeLabel.trailingAnchor, constant: 10),

            addressLabel.topAnchor.constraint(equalTo: typeLabel.bottomAnchor, constant: 10),
            addressLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            addressLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),

            separator.leadingAnchor.constraint(equalTo: addressLabel.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: addressLabel.trailingAnchor),
            separator.heightAnchor.constraint(equalToConstant: 1),

            mapView.leadingAnchor.constraint(equalTo: imageGalleryContainer.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: imageGalleryContainer.trailingAnchor),
            mapView.heightAnchor.constraint(equalToConstant: 150),

            descLabel.leadingAnchor.constraint(equalTo: mapView.leadingAnchor),
            descLabel.trailingAnchor.constraint(equalTo: mapView.trailingAnchor),

            detailInfoContainer.leadingAnchor.constraint(equalTo: descLabel.leadingAnchor),
            detailInfoContainer.trailingAnchor.constraint(equalTo: descLabel.trailingAnchor),

            phoneStack.leadingAnchor.constraint(equalTo: descLabel.leadingAnchor),

            homepageButton.leadingAnchor.constraint(equalTo: phoneStack.leadingAnchor),
            homepageButton.trailingAnchor.constraint(equalTo: phoneStack.trailingAnchor),

            visitCountView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            visitCountView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            recordButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            recordButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            recordButton.heightAnchor.constraint(equalToConstant: 50),
        ])
    }
    
    private func updateDynamicConstraints(hasImages: Bool, hasMap: Bool, hasDetailInfo: Bool, hasPhone: Bool, hasHomepage: Bool, hasVisitCount: Bool) {
        NSLayoutConstraint.deactivate(dynamicConstraints)
        dynamicConstraints.removeAll()
        
        var topAnchor: NSLayoutYAxisAnchor = contentView.topAnchor
        var topConstant: CGFloat = 20
        
        if hasImages {
            imageGalleryContainer.isHidden = false
            dynamicConstraints.append(imageGalleryContainer.topAnchor.constraint(equalTo: topAnchor, constant: topConstant))
            topAnchor = imageGalleryContainer.bottomAnchor
            topConstant = 22
        } else {
            imageGalleryContainer.isHidden = true
        }
        
        dynamicConstraints.append(nameLabel.topAnchor.constraint(equalTo: topAnchor, constant: topConstant))
        topAnchor = addressLabel.bottomAnchor
        topConstant = 16
        
        separator.isHidden = false
        dynamicConstraints.append(separator.topAnchor.constraint(equalTo: topAnchor, constant: topConstant))
        topAnchor = separator.bottomAnchor
        topConstant = 18
        
        if hasMap {
            mapView.isHidden = false
            dynamicConstraints.append(mapView.topAnchor.constraint(equalTo: topAnchor, constant: topConstant))
            topAnchor = mapView.bottomAnchor
            topConstant = 22
        } else {
            mapView.isHidden = true
        }
        
        dynamicConstraints.append(descLabel.topAnchor.constraint(equalTo: topAnchor, constant: topConstant))
        topAnchor = descLabel.bottomAnchor
        topConstant = 20
        
        if hasDetailInfo {
            detailInfoContainer.isHidden = false
            dynamicConstraints.append(detailInfoContainer.topAnchor.constraint(equalTo: topAnchor, constant: topConstant))
            topAnchor = detailInfoContainer.bottomAnchor
        } else {
            detailInfoContainer.isHidden = true
        }
        
        if hasPhone {
            phoneStack.isHidden = false
            dynamicConstraints.append(phoneStack.topAnchor.constraint(equalTo: topAnchor, constant: 20))
            topAnchor = phoneStack.bottomAnchor
            topConstant = 12
        } else {
            phoneStack.isHidden = true
            topConstant = 20
        }
        
        if hasHomepage {
            homepageButton.isHidden = false
            dynamicConstraints.append(homepageButton.topAnchor.constraint(equalTo: topAnchor, constant: topConstant))
            topAnchor = homepageButton.bottomAnchor
            topConstant = 20
        } else {
            homepageButton.isHidden = true
        }
        
        if hasVisitCount {
            visitCountView.isHidden = false
            dynamicConstraints.append(visitCountView.topAnchor.constraint(equalTo: topAnchor, constant: topConstant))
            topAnchor = visitCountView.bottomAnchor
            topConstant = 12
        } else {
            visitCountView.isHidden = true
        }
        
        dynamicConstraints.append(recordButton.topAnchor.constraint(equalTo: topAnchor, constant: topConstant))
        dynamicConstraints.append(recordButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -38))
        
        NSLayoutConstraint.activate(dynamicConstraints)
    }
    
    private func setupImageGallery(with images: [TourSiteImage]) {
        imageViews.forEach { $0.removeFromSuperview() }
        imageViews.removeAll()
        
        guard !images.isEmpty else { return }
        
        imagePageControl.numberOfPages = images.count
        imagePageControl.currentPage = 0
        
        imagePageView.contentSize = CGSize(width: imagePageView.frame.width * CGFloat(images.count), height: imagePageView.frame.height)
        
        for (_, image) in images.enumerated() {
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

    // MARK: - 지도 탭 기능 관련 메서드
    
    // objc_setAssociatedObject 키 충돌 방지용 struct
    private struct AssociatedKeys {
        static var coordinate = "coordinate"
        static var placeName = "placeName"
    }
    
    // 지도에 탭 제스처 추가
    private func setupMapTapGesture(coordinate: CLLocationCoordinate2D, placeName: String) {
        // 기존 제스처 제거
        mapView.gestureRecognizers?.forEach { mapView.removeGestureRecognizer($0) }

        // 탭 제스처 추가
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(mapTapped))
        mapView.addGestureRecognizer(tapGesture)

        // 지도 위에 탭 안내 오버레이 추가
        addMapTapOverlay()

        // 좌표와 장소명 저장 (NSValue로 감싸서 저장)
        let coordValue = NSValue(mkCoordinate: coordinate)
        objc_setAssociatedObject(mapView, &AssociatedKeys.coordinate, coordValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        objc_setAssociatedObject(mapView, &AssociatedKeys.placeName, placeName, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    // 지도에 탭 안내 오버레이 추가
    private func addMapTapOverlay() {
        // 기존 오버레이 제거
        mapView.subviews.filter { $0.tag == 9999 }.forEach { $0.removeFromSuperview() }

        // 탭 안내 라벨 생성
        let tapHintLabel = UILabel()
        tapHintLabel.text = "탭하여 Apple 지도에서 보기"
        tapHintLabel.font = .systemFont(ofSize: 12, weight: .medium)
        tapHintLabel.textColor = .white
        tapHintLabel.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        tapHintLabel.textAlignment = .center
        tapHintLabel.layer.cornerRadius = 12
        tapHintLabel.clipsToBounds = true
        tapHintLabel.translatesAutoresizingMaskIntoConstraints = false
        tapHintLabel.tag = 9999

        mapView.addSubview(tapHintLabel)

        NSLayoutConstraint.activate([
            tapHintLabel.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -12),
            tapHintLabel.centerXAnchor.constraint(equalTo: mapView.centerXAnchor),
            tapHintLabel.heightAnchor.constraint(equalToConstant: 28),
            tapHintLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 160)
        ])

        tapHintLabel.alpha = 0
        UIView.animate(withDuration: 0.3, delay: 0.5) {
            tapHintLabel.alpha = 1
        }
    }
    
    // 지도 탭 이벤트 처리
    @objc private func mapTapped() {
        guard
            let coordValue = objc_getAssociatedObject(mapView, &AssociatedKeys.coordinate) as? NSValue,
            let placeName = objc_getAssociatedObject(mapView, &AssociatedKeys.placeName) as? String
        else {
            return
        }
        let coordinate = coordValue.mkCoordinateValue

        // 탭 애니메이션 (시각적 효과)
        let overlayView = UIView(frame: mapView.bounds)
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        mapView.addSubview(overlayView)
        UIView.animate(withDuration: 0.1, animations: {
            overlayView.alpha = 1
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                overlayView.alpha = 0
            } completion: { _ in
                overlayView.removeFromSuperview()
            }
        }

        openInAppleMaps(coordinate: coordinate, placeName: placeName)
    }
    
    // Apple 지도 앱에서 위치 열기
    private func openInAppleMaps(coordinate: CLLocationCoordinate2D, placeName: String) {
        let query = placeName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "http://maps.apple.com/?q=\(query)&ll=\(coordinate.latitude),\(coordinate.longitude)&z=16"
        if let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            UIApplication.shared.open(url, options: [:])
        } else {
            showMapOpenFailAlert()
        }
    }
    
    // 지도 앱을 열 수 없을 때 알림 표시
    private func showMapOpenFailAlert() {
        guard let viewController = findViewController() else { return }
        let alert = UIAlertController(
            title: "지도 앱을 열 수 없습니다",
            message: "Apple 지도 앱을 사용할 수 없습니다. 기기 설정을 확인해주세요.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        viewController.present(alert, animated: true)
    }
    
    // 현재 뷰의 뷰컨트롤러 찾기
    private func findViewController() -> UIViewController? {
        var responder: UIResponder? = self
        while let r = responder {
            if let vc = r as? UIViewController { return vc }
            responder = r.next
        }
        return nil
    }

    func configure(with detail: TourSiteDetail, images: [TourSiteImage] = [], infos: [DetailInfo] = []) {
        configureBasicInfo(with: detail)
        
        setupImageGallery(with: images)
        galleryImages = images
        
        let hasMap = configureMap(with: detail)
        let (hasPhone, hasHomepage) = configureContactInfo(with: detail)
        
        let validInfos = filterValidDetailInfos(infos)
        let hasDetailInfo = !validInfos.isEmpty
        if hasDetailInfo {
            setupDetailInfoSection(container: detailInfoContainer, title: "상세 정보", infos: validInfos)
        }
        
        updateDynamicConstraints(
            hasImages: !images.isEmpty,
            hasMap: hasMap,
            hasDetailInfo: hasDetailInfo,
            hasPhone: hasPhone,
            hasHomepage: hasHomepage,
            hasVisitCount: false
        )
    }
    
    private func filterValidDetailInfos(_ infos: [DetailInfo]) -> [DetailInfo] {
        return infos.filter { info in
            let hasValidName = !(info.infoname?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
            let hasValidText = !(info.infotext?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
            return hasValidName && hasValidText
        }
    }
    
    func updateVisitCount(count: Int, message: String) {
        let hasVisitCount = !message.isEmpty
        visitCountView.configure(count: count, message: message)
        
        if count > 0 {
            recordButton.setTitle("📝 새로운 기록 작성", for: .normal)
        } else {
            recordButton.setTitle("📝 기록하기", for: .normal)
        }
        
        updateDynamicConstraints(
            hasImages: !galleryImages.isEmpty,
            hasMap: !mapView.isHidden,
            hasDetailInfo: !detailInfoContainer.isHidden,
            hasPhone: !phoneStack.isHidden,
            hasHomepage: !homepageButton.isHidden,
            hasVisitCount: hasVisitCount
        )
    }
    
    private func setupDetailInfoSection(container: UIView, title: String, infos: [DetailInfo]) {
        container.subviews.forEach { $0.removeFromSuperview() }
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(stackView)
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textColor = .themeTextPrimary
        stackView.addArrangedSubview(titleLabel)
        
        let divider = UIView()
        divider.backgroundColor = .themeSeparator
        divider.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(divider)
        
        let gridStackView = UIStackView()
        gridStackView.axis = .vertical
        gridStackView.spacing = 12
        gridStackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(gridStackView)
        
        for i in stride(from: 0, to: infos.count, by: 2) {
            let rowStackView = UIStackView()
            rowStackView.axis = .horizontal
            rowStackView.distribution = .fillEqually
            rowStackView.spacing = 16
            rowStackView.translatesAutoresizingMaskIntoConstraints = false
            
            let firstItem = createCompactInfoItemView(info: infos[i])
            rowStackView.addArrangedSubview(firstItem)
            
            if i + 1 < infos.count {
                let secondItem = createCompactInfoItemView(info: infos[i + 1])
                rowStackView.addArrangedSubview(secondItem)
            } else {
                let emptyView = UIView()
                rowStackView.addArrangedSubview(emptyView)
            }
            
            gridStackView.addArrangedSubview(rowStackView)
        }
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: container.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -20),
            
            divider.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
    
    private func createCompactInfoItemView(info: DetailInfo) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = UIColor.white.withAlphaComponent(0.03)
        containerView.layer.cornerRadius = 8
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.white.withAlphaComponent(0.1).cgColor
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        let nameLabel = UILabel()
        nameLabel.font = .systemFont(ofSize: 12, weight: .medium)
        nameLabel.textColor = .themeTextSecondary
        nameLabel.text = info.infoname?.removeHTMLTags()
        nameLabel.textAlignment = .center
        nameLabel.numberOfLines = 1
        
        let valueLabel = UILabel()
        valueLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        valueLabel.textColor = .themeTextPrimary
        valueLabel.text = info.infotext?.removeHTMLTags()
        valueLabel.textAlignment = .center
        valueLabel.numberOfLines = 2
        
        stackView.addArrangedSubview(nameLabel)
        stackView.addArrangedSubview(valueLabel)
        
        containerView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
            
            containerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 60)
        ])
        
        return containerView
    }

    func showEmptyState(_ message: String) {
        nameLabel.text = message
        nameLabel.textAlignment = .center
        nameLabel.font = .headlineLarge
        nameLabel.textColor = .themeTextSecondary
        
        [typeLabel, addressLabel, descLabel, mapView, phoneStack, homepageButton, recordButton, imageGalleryContainer, separator, detailInfoContainer, visitCountView].forEach { $0.isHidden = true }
    }
    
    private func configureBasicInfo(with detail: TourSiteDetail) {
        nameLabel.text = detail.title
        nameLabel.textAlignment = .left
        nameLabel.font = .titleLarge
        nameLabel.textColor = .themeTextPrimary
        
        typeLabel.text = APIConstants.ContentTypes.name(for: Int(detail.contenttypeid ?? "") ?? 0)
        addressLabel.text = detail.fullAddress
        descLabel.text = detail.overview?.removeHTMLTags() ?? "설명이 제공되지 않습니다."
        
        distLabel.isHidden = true
    }
    
    private func configureMap(with detail: TourSiteDetail) -> Bool {
        mapView.removeAnnotations(mapView.annotations)
        
        guard let lat = detail.latitude, let lng = detail.longitude else {
            return false
        }
        
        let coord = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        let ann = MKPointAnnotation()
        ann.coordinate = coord
        ann.title = detail.title
        mapView.addAnnotation(ann)
        let region = MKCoordinateRegion(center: coord, latitudinalMeters: 700, longitudinalMeters: 700)
        mapView.setRegion(region, animated: false)
        
        // 지도 탭 제스처 추가
        setupMapTapGesture(coordinate: coord, placeName: detail.title ?? "")
        
        return true
    }
    
    private func configureContactInfo(with detail: TourSiteDetail) -> (hasPhone: Bool, hasHomepage: Bool) {
        let hasPhone = detail.tel != nil && !detail.tel!.isEmpty
        let hasHomepage = detail.homepage?.htmlLinkToUrlAndTitle()?.url != nil
        
        if hasPhone {
            phoneLabel.text = detail.tel
        }

        if hasHomepage, let homepage = detail.homepage?.htmlLinkToUrlAndTitle()?.url {
            homepageButton.setTitle("홈페이지 바로가기", for: .normal)
            homepageButton.removeTarget(nil, action: nil, for: .allEvents)
            homepageButton.addAction(UIAction { _ in
                if let url = URL(string: homepage) {
                    UIApplication.shared.open(url)
                }
            }, for: .touchUpInside)
        }
        
        return (hasPhone, hasHomepage)
    }
}

extension TourDetailView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView == imagePageView else { return }
        
        let pageIndex = round(scrollView.contentOffset.x / scrollView.frame.width)
        imagePageControl.currentPage = Int(pageIndex)
    }
}

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
        let icons = ["🎉", "✨", "🏆", "👑"]
        let iconIndex = min(count - 1, icons.count - 1)
        iconLabel.text = count > 0 ? icons[max(0, iconIndex)] : ""
        messageLabel.text = message
        
        heightConstraint?.isActive = false
        
        if message.isEmpty {
            heightConstraint = heightAnchor.constraint(equalToConstant: 0)
        } else {
            heightConstraint = heightAnchor.constraint(greaterThanOrEqualToConstant: 80)
        }
        
        heightConstraint?.isActive = true
        
        UIView.animate(withDuration: 0.3) {
            self.superview?.layoutIfNeeded()
        }
    }
}

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

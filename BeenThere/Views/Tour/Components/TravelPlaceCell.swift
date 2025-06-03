//
//  TravelPlaceCell.swift
//  BeenThere
//
//  그레이스케일 테마 여행지 카드 셀
//  - 거리/전화번호 박스 디자인 개선, 타이틀과 거리 정렬
//

import UIKit
import Kingfisher
import CoreLocation

class TravelPlaceCell: UICollectionViewCell {
    static let reuseIdentifier = "TravelPlaceCell"
    
    // MARK: - Design Constants
    struct Design {
        static let backgroundColor = UIColor(white: 0.18, alpha: 1.0)
        static let surfaceColor = UIColor(white: 0.15, alpha: 1.0)
        static let borderColor = UIColor(white: 0.25, alpha: 1.0)
        
        static let textPrimary = UIColor.themeTextPrimary
        static let textSecondary = UIColor.themeTextSecondary
        static let textTertiary = UIColor.themeTextPlaceholder
        
        static let accentColor = UIColor(white: 0.85, alpha: 1.0)
        static let visitedColor = UIColor(white: 0.90, alpha: 1.0)
        
        static let cornerRadius: CGFloat = 20
        static let imageHeight: CGFloat = 200
        static let contentPadding: CGFloat = 16
        static let smallPadding: CGFloat = 8
        
        static let shadowColor = UIColor.black.cgColor
        static let shadowOpacity: Float = 0.4
        static let shadowRadius: CGFloat = 15
        static let shadowOffset = CGSize(width: 0, height: 8)
    }
    
    // MARK: - UI Components
    
    private let cardContainer: UIView = {
        let view = UIView()
        view.backgroundColor = Design.backgroundColor
        view.layer.cornerRadius = Design.cornerRadius
        view.layer.shadowColor = Design.shadowColor
        view.layer.shadowOpacity = Design.shadowOpacity
        view.layer.shadowOffset = Design.shadowOffset
        view.layer.shadowRadius = Design.shadowRadius
        view.layer.borderWidth = 1
        view.layer.borderColor = Design.borderColor.cgColor
        view.clipsToBounds = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let contentContainer: UIView = {
        let view = UIView()
        view.backgroundColor = Design.backgroundColor
        view.layer.cornerRadius = Design.cornerRadius
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let placeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = Design.surfaceColor
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let imageOverlay: UIView = {
        let view = UIView()
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor.black.withAlphaComponent(0.6).cgColor,
            UIColor.black.withAlphaComponent(0.3).cgColor,
            UIColor.clear.cgColor
        ]
        gradientLayer.locations = [0, 0.4, 1.0]
        view.layer.addSublayer(gradientLayer)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let categoryTag: UIView = {
        let view = UIView()
        view.backgroundColor = Design.surfaceColor.withAlphaComponent(0.9)
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 1
        view.layer.borderColor = Design.borderColor.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private let categoryIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = Design.accentColor
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    private let categoryLabel: UILabel = {
        let label = UILabel()
        label.font = .labelSmall
        label.textColor = Design.textPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let visitButton: UIButton = {
        let button = UIButton(type: .system)
        var config = UIButton.Configuration.filled()
        config.cornerStyle = .capsule
        config.baseBackgroundColor = Design.surfaceColor.withAlphaComponent(0.9)
        config.baseForegroundColor = Design.textSecondary
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        config.image = UIImage(systemName: "plus.circle.fill", withConfiguration: symbolConfig)
        button.configuration = config
        button.layer.borderWidth = 1
        button.layer.borderColor = Design.borderColor.cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let textContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .titleSmall
        label.textColor = Design.textPrimary
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let addressLabel: UILabel = {
        let label = UILabel()
        label.font = .bodySmall
        label.textColor = Design.textSecondary
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    // 전화번호 표시 레이블
    private let phoneLabel: UILabel = {
        let label = UILabel()
        label.font = .bodySmall
        label.textColor = Design.textTertiary
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // 거리(박스)
    private let distanceContainer: UIView = {
        let view = UIView()
        view.backgroundColor = Design.surfaceColor
        view.layer.cornerRadius = 16
        view.layer.borderWidth = 1
        view.layer.borderColor = Design.borderColor.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private let distanceShortLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .semibold) // 더 크게!
        label.textColor = Design.textPrimary
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // 방문 완료
    private let visitedMarker: UIView = {
        let view = UIView()
        view.backgroundColor = Design.visitedColor
        view.layer.cornerRadius = 10
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private let visitedIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "checkmark")
        imageView.tintColor = Design.backgroundColor
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    private let visitedLabel: UILabel = {
        let label = UILabel()
        label.text = "방문완료"
        label.font = .labelSmall
        label.textColor = Design.backgroundColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // title + 거리 박스를 정렬하는 StackView
    private lazy var titleRowStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel, distanceContainer])
        stack.axis = .horizontal
        stack.alignment = .center // 수직 중앙 정렬!
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // MARK: - Properties
    private var toggleCallback: (() -> Void)?
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
        setupConstraints()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let gradientLayer = imageOverlay.layer.sublayers?.first as? CAGradientLayer {
            gradientLayer.frame = imageOverlay.bounds
        }
        cardContainer.layer.shadowPath = UIBezierPath(
            roundedRect: cardContainer.bounds,
            cornerRadius: Design.cornerRadius
        ).cgPath
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // 🔥 동적으로 생성된 제약 조건들 정리
        phoneLabel.constraints.forEach { constraint in
            if constraint.firstAttribute == .bottom {
                constraint.isActive = false
            }
        }
        addressLabel.constraints.forEach { constraint in
            if constraint.firstAttribute == .bottom {
                constraint.isActive = false
            }
        }
        
        placeImageView.kf.cancelDownloadTask()
        placeImageView.image = nil
        titleLabel.text = nil
        addressLabel.text = nil
        phoneLabel.text = nil
        distanceShortLabel.text = nil
        categoryLabel.text = nil
        categoryIcon.image = nil
        visitedMarker.isHidden = true
        distanceContainer.isHidden = false
        categoryTag.isHidden = false
        var config = visitButton.configuration
        config?.image = UIImage(systemName: "plus.circle.fill")
        config?.baseForegroundColor = Design.textSecondary
        visitButton.configuration = config
        toggleCallback = nil
    }
    
    // MARK: - Setup
    
    private func setupViews() {
        contentView.addSubview(cardContainer)
        cardContainer.addSubview(contentContainer)
        contentContainer.addSubview(placeImageView)
        contentContainer.addSubview(imageOverlay)
        contentContainer.addSubview(categoryTag)
        categoryTag.addSubview(categoryIcon)
        categoryTag.addSubview(categoryLabel)
        contentContainer.addSubview(visitButton)
        contentContainer.addSubview(textContainer)
        // 타이틀 행을 textContainer에 먼저 추가
        textContainer.addSubview(titleRowStack)
        distanceContainer.addSubview(distanceShortLabel)
        textContainer.addSubview(addressLabel)
        textContainer.addSubview(phoneLabel)
        contentContainer.addSubview(visitedMarker)
        visitedMarker.addSubview(visitedIcon)
        visitedMarker.addSubview(visitedLabel)
        visitButton.addTarget(self, action: #selector(visitButtonTapped), for: .touchUpInside)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            cardContainer.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            cardContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            
            contentContainer.topAnchor.constraint(equalTo: cardContainer.topAnchor),
            contentContainer.leadingAnchor.constraint(equalTo: cardContainer.leadingAnchor),
            contentContainer.trailingAnchor.constraint(equalTo: cardContainer.trailingAnchor),
            contentContainer.bottomAnchor.constraint(equalTo: cardContainer.bottomAnchor),
            
            placeImageView.topAnchor.constraint(equalTo: contentContainer.topAnchor),
            placeImageView.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            placeImageView.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor),
            placeImageView.heightAnchor.constraint(equalToConstant: Design.imageHeight),
            
            imageOverlay.topAnchor.constraint(equalTo: placeImageView.topAnchor),
            imageOverlay.leadingAnchor.constraint(equalTo: placeImageView.leadingAnchor),
            imageOverlay.trailingAnchor.constraint(equalTo: placeImageView.trailingAnchor),
            imageOverlay.heightAnchor.constraint(equalToConstant: 100),
            
            // 카테고리 태그
            categoryTag.topAnchor.constraint(equalTo: contentContainer.topAnchor, constant: 12),
            categoryTag.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor, constant: 12),
            categoryTag.heightAnchor.constraint(equalToConstant: 24),
            categoryIcon.leadingAnchor.constraint(equalTo: categoryTag.leadingAnchor, constant: 6),
            categoryIcon.centerYAnchor.constraint(equalTo: categoryTag.centerYAnchor),
            categoryIcon.widthAnchor.constraint(equalToConstant: 12),
            categoryIcon.heightAnchor.constraint(equalToConstant: 12),
            categoryLabel.leadingAnchor.constraint(equalTo: categoryIcon.trailingAnchor, constant: 4),
            categoryLabel.centerYAnchor.constraint(equalTo: categoryTag.centerYAnchor),
            categoryLabel.trailingAnchor.constraint(equalTo: categoryTag.trailingAnchor, constant: -6),
            
            // 방문 버튼
            visitButton.topAnchor.constraint(equalTo: contentContainer.topAnchor, constant: 12),
            visitButton.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor, constant: -12),
            visitButton.widthAnchor.constraint(equalToConstant: 40),
            visitButton.heightAnchor.constraint(equalToConstant: 40),
            
            // 🔥 텍스트 컨테이너 - 하단을 contentContainer와 정확히 연결
            textContainer.topAnchor.constraint(equalTo: placeImageView.bottomAnchor, constant: Design.contentPadding),
            textContainer.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor, constant: Design.contentPadding),
            textContainer.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor, constant: -Design.contentPadding),
            textContainer.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor, constant: -Design.contentPadding), // lessThanOrEqualTo 제거!
            
            // 타이틀+거리 스택
            titleRowStack.topAnchor.constraint(equalTo: textContainer.topAnchor),
            titleRowStack.leadingAnchor.constraint(equalTo: textContainer.leadingAnchor),
            titleRowStack.trailingAnchor.constraint(equalTo: textContainer.trailingAnchor),
            
            distanceContainer.heightAnchor.constraint(equalToConstant: 32),
            distanceContainer.widthAnchor.constraint(greaterThanOrEqualToConstant: 60),
            distanceShortLabel.centerXAnchor.constraint(equalTo: distanceContainer.centerXAnchor),
            distanceShortLabel.centerYAnchor.constraint(equalTo: distanceContainer.centerYAnchor),
            distanceShortLabel.leadingAnchor.constraint(equalTo: distanceContainer.leadingAnchor, constant: 10),
            distanceShortLabel.trailingAnchor.constraint(equalTo: distanceContainer.trailingAnchor, constant: -10),
            
            // 주소
            addressLabel.topAnchor.constraint(equalTo: titleRowStack.bottomAnchor, constant: 4),
            addressLabel.leadingAnchor.constraint(equalTo: textContainer.leadingAnchor),
            addressLabel.trailingAnchor.constraint(equalTo: textContainer.trailingAnchor),
            
            // 🔥 전화번호 - 하단 제약 조건을 조건부로 설정
            phoneLabel.topAnchor.constraint(equalTo: addressLabel.bottomAnchor, constant: 2),
            phoneLabel.leadingAnchor.constraint(equalTo: textContainer.leadingAnchor),
            phoneLabel.trailingAnchor.constraint(equalTo: textContainer.trailingAnchor),
            // phoneLabel.bottomAnchor 제약은 configure에서 동적으로 설정
            
            // 방문 완료 마커
            visitedMarker.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor, constant: -16),
            visitedMarker.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor, constant: -16),
            visitedMarker.heightAnchor.constraint(equalToConstant: 20),
            visitedIcon.leadingAnchor.constraint(equalTo: visitedMarker.leadingAnchor, constant: 6),
            visitedIcon.centerYAnchor.constraint(equalTo: visitedMarker.centerYAnchor),
            visitedIcon.widthAnchor.constraint(equalToConstant: 10),
            visitedIcon.heightAnchor.constraint(equalToConstant: 10),
            visitedLabel.leadingAnchor.constraint(equalTo: visitedIcon.trailingAnchor, constant: 4),
            visitedLabel.centerYAnchor.constraint(equalTo: visitedMarker.centerYAnchor),
            visitedLabel.trailingAnchor.constraint(equalTo: visitedMarker.trailingAnchor, constant: -6),
                ])
    }
    
    // MARK: - Configuration
    
    func configure(with site: TourSiteItem, currentLocation: CLLocation?, isVisited: Bool, onToggle: @escaping () -> Void) {
        toggleCallback = onToggle
        titleLabel.text = site.title
        addressLabel.text = site.fullAddress ?? "주소 정보 없음"
        
        // 🔥 기존 하단 제약 조건 제거
        phoneLabel.constraints.forEach { constraint in
            if constraint.firstAttribute == .bottom && constraint.secondItem === textContainer {
                constraint.isActive = false
            }
        }
        
        // 전화번호 표시 및 하단 제약 조건 동적 설정
        if let phone = site.phoneNumber, !phone.isEmpty {
            phoneLabel.text = "전화: \(phone)"
            phoneLabel.isHidden = false
            // 전화번호가 있으면 phoneLabel을 하단에 고정
            phoneLabel.bottomAnchor.constraint(equalTo: textContainer.bottomAnchor).isActive = true
        } else {
            phoneLabel.text = nil
            phoneLabel.isHidden = true
            // 전화번호가 없으면 addressLabel을 하단에 고정
            addressLabel.bottomAnchor.constraint(equalTo: textContainer.bottomAnchor).isActive = true
        }
        
        // 거리만 박스 안에
        if let current = currentLocation, let lat = site.latitude, let lng = site.longitude {
            let placeLoc = CLLocation(latitude: lat, longitude: lng)
            let dist = current.distance(from: placeLoc)
            let km = dist / 1000.0
            distanceShortLabel.text = String(format: "%.1fkm", km)
            distanceContainer.isHidden = false
        } else if let distFromAPI = site.dist {
            let km = distFromAPI / 1000.0
            distanceShortLabel.text = String(format: "%.1fkm", km)
            distanceContainer.isHidden = false
        } else {
            distanceShortLabel.text = nil
            distanceContainer.isHidden = true
        }
        
        configureImage(with: site)
        configureCategory(with: site)
        configureVisitedState(isVisited)
        animateAppearance()
    }
    
    private func configureImage(with site: TourSiteItem) {
        if let imageURL = site.thumbnailURL {
            let processor = DownsamplingImageProcessor(size: CGSize(width: 400, height: 300))
            placeImageView.kf.indicatorType = .activity
            placeImageView.kf.setImage(
                with: imageURL,
                placeholder: createPlaceholderImage(),
                options: [
                    .processor(processor),
                    .transition(.fade(0.3)),
                    .cacheOriginalImage,
                    .scaleFactor(UIScreen.main.scale),
                    .backgroundDecode,
                    .retryStrategy(DelayRetryStrategy(maxRetryCount: 2, retryInterval: .seconds(1)))
                ]
            ) { [weak self] result in
                switch result {
                case .success(_): break
                case .failure(_): self?.placeImageView.image = self?.createPlaceholderImage()
                }
            }
        } else {
            placeImageView.image = createPlaceholderImage()
        }
    }
    private func createPlaceholderImage() -> UIImage? {
        let size = CGSize(width: 400, height: 300)
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        let context = UIGraphicsGetCurrentContext()
        let colors = [
            Design.surfaceColor.cgColor,
            Design.backgroundColor.cgColor
        ]
        let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                  colors: colors as CFArray,
                                  locations: nil)
        context?.drawLinearGradient(gradient!,
                                   start: CGPoint(x: 0, y: 0),
                                   end: CGPoint(x: size.width, y: size.height),
                                   options: [])
        let icon = UIImage(systemName: "photo.fill")?.withTintColor(Design.textTertiary, renderingMode: .alwaysOriginal)
        let iconSize = CGSize(width: 50, height: 50)
        let iconRect = CGRect(x: (size.width - iconSize.width) / 2,
                             y: (size.height - iconSize.height) / 2,
                             width: iconSize.width,
                             height: iconSize.height)
        icon?.draw(in: iconRect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    private func configureCategory(with site: TourSiteItem) {
        if let typeName = site.contentTypeName {
            categoryLabel.text = typeName
            categoryIcon.image = UIImage(systemName: site.sfSymbol)
            categoryTag.isHidden = false
        } else {
            categoryTag.isHidden = true
        }
    }
    private func configureVisitedState(_ isVisited: Bool) {
        visitedMarker.isHidden = !isVisited
        var config = visitButton.configuration
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        if isVisited {
            config?.image = UIImage(systemName: "checkmark.circle.fill", withConfiguration: symbolConfig)
            config?.baseForegroundColor = Design.visitedColor
        } else {
            config?.image = UIImage(systemName: "plus.circle.fill", withConfiguration: symbolConfig)
            config?.baseForegroundColor = Design.textSecondary
        }
        visitButton.configuration = config
    }
    private func animateAppearance() {
        alpha = 0
        transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        UIView.animate(
            withDuration: 0.6,
            delay: 0.1,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.3
        ) {
            self.alpha = 1
            self.transform = CGAffineTransform.identity
        }
    }
    
    // MARK: - Actions
    
    @objc private func visitButtonTapped() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
        UIView.animate(withDuration: 0.1, animations: {
            self.visitButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.visitButton.transform = .identity
            }
        }
        toggleCallback?()
    }
    
    // MARK: - Touch Events
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        UIView.animate(withDuration: 0.1) {
            self.cardContainer.transform = CGAffineTransform(scaleX: 0.98, y: 0.98)
        }
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.3) {
            self.cardContainer.transform = .identity
        }
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.3) {
            self.cardContainer.transform = .identity
        }
    }
}

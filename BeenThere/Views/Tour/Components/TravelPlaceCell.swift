//
//  TravelPlaceCell.swift
//  BeenThere
//
//  여행지 카드 셀
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
        static let visitCountColor = UIColor.systemGreen
        
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
    
    // 방문 횟수 뱃지
    private let visitCountBadge: UIView = {
        let view = UIView()
        view.backgroundColor = Design.visitCountColor.withAlphaComponent(0.9)
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 1
        view.layer.borderColor = Design.visitCountColor.cgColor
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let visitCountIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "checkmark.circle.fill")
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let visitCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 11, weight: .semibold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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
        label.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        label.textColor = Design.textPrimary
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // title + 거리 박스를 정렬하는 StackView
    private lazy var titleRowStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel, distanceContainer])
        stack.axis = .horizontal
        stack.alignment = .center
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
        
        // 동적으로 생성된 제약 조건들 정리
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
        visitCountBadge.isHidden = true
        visitCountLabel.text = nil
        distanceContainer.isHidden = false
        categoryTag.isHidden = false
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
        
        // 방문 횟수 뱃지 추가
        contentContainer.addSubview(visitCountBadge)
        visitCountBadge.addSubview(visitCountIcon)
        visitCountBadge.addSubview(visitCountLabel)
        
        contentContainer.addSubview(textContainer)
        textContainer.addSubview(titleRowStack)
        distanceContainer.addSubview(distanceShortLabel)
        textContainer.addSubview(addressLabel)
        textContainer.addSubview(phoneLabel)
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
            
            // 방문 횟수 뱃지 (우측 상단)
            visitCountBadge.topAnchor.constraint(equalTo: contentContainer.topAnchor, constant: 12),
            visitCountBadge.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor, constant: -12),
            visitCountBadge.heightAnchor.constraint(equalToConstant: 24),
            
            visitCountIcon.leadingAnchor.constraint(equalTo: visitCountBadge.leadingAnchor, constant: 6),
            visitCountIcon.centerYAnchor.constraint(equalTo: visitCountBadge.centerYAnchor),
            visitCountIcon.widthAnchor.constraint(equalToConstant: 12),
            visitCountIcon.heightAnchor.constraint(equalToConstant: 12),
            
            visitCountLabel.leadingAnchor.constraint(equalTo: visitCountIcon.trailingAnchor, constant: 4),
            visitCountLabel.centerYAnchor.constraint(equalTo: visitCountBadge.centerYAnchor),
            visitCountLabel.trailingAnchor.constraint(equalTo: visitCountBadge.trailingAnchor, constant: -6),
            
            // 텍스트 컨테이너
            textContainer.topAnchor.constraint(equalTo: placeImageView.bottomAnchor, constant: Design.contentPadding),
            textContainer.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor, constant: Design.contentPadding),
            textContainer.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor, constant: -Design.contentPadding),
            textContainer.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor, constant: -Design.contentPadding),
            
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
            
            // 전화번호
            phoneLabel.topAnchor.constraint(equalTo: addressLabel.bottomAnchor, constant: 2),
            phoneLabel.leadingAnchor.constraint(equalTo: textContainer.leadingAnchor),
            phoneLabel.trailingAnchor.constraint(equalTo: textContainer.trailingAnchor),
        ])
    }
    
    // MARK: - Configuration
    
    func configure(with site: TourSiteItem, currentLocation: CLLocation?, visitCount: Int = 0, onToggle: @escaping () -> Void) {
        toggleCallback = onToggle
        titleLabel.text = site.title
        addressLabel.text = site.fullAddress ?? "주소 정보 없음"
        
        // 기존 하단 제약 조건 제거
        phoneLabel.constraints.forEach { constraint in
            if constraint.firstAttribute == .bottom && constraint.secondItem === textContainer {
                constraint.isActive = false
            }
        }
        
        // 전화번호 표시 및 하단 제약 조건 동적 설정
        if let phone = site.phoneNumber, !phone.isEmpty {
            phoneLabel.text = "전화: \(phone)"
            phoneLabel.isHidden = false
            phoneLabel.bottomAnchor.constraint(equalTo: textContainer.bottomAnchor).isActive = true
        } else {
            phoneLabel.text = nil
            phoneLabel.isHidden = true
            addressLabel.bottomAnchor.constraint(equalTo: textContainer.bottomAnchor).isActive = true
        }
        
        // 거리 표시
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
        
        // 방문 횟수 뱃지 설정
        configureVisitCountBadge(visitCount)
        
        configureImage(with: site)
        configureCategory(with: site)
        animateAppearance()
    }
    
    // 방문 횟수 뱃지 설정 메서드
    private func configureVisitCountBadge(_ visitCount: Int) {
        if visitCount > 0 {
            visitCountBadge.isHidden = false
            visitCountLabel.text = "\(visitCount)번 방문"
            
            // 방문 횟수에 따라 애니메이션 효과
            UIView.animate(withDuration: 0.3, delay: 0.2, options: [.curveEaseOut]) {
                self.visitCountBadge.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
            } completion: { _ in
                UIView.animate(withDuration: 0.2) {
                    self.visitCountBadge.transform = .identity
                }
            }
        } else {
            visitCountBadge.isHidden = true
            visitCountLabel.text = nil
        }
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

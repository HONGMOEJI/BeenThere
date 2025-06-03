import UIKit
import Kingfisher

class TravelPlaceCell: UICollectionViewCell {
    static let reuseIdentifier = "TravelPlaceCell"
    
    // MARK: - Design Constants
    private struct Design {
        static let cornerRadius: CGFloat = 20
        static let imageHeight: CGFloat = 220
        static let contentInset: CGFloat = 16
        static let smallSpacing: CGFloat = 8
        static let mediumSpacing: CGFloat = 12
        static let shadowOpacity: Float = 0.1
        static let gradientColors = [
            UIColor.black.withAlphaComponent(0.5).cgColor,
            UIColor.black.withAlphaComponent(0.3).cgColor,
            UIColor.clear.cgColor
        ]
        
        static let primaryColor = UIColor.systemBlue
        static let visitedColor = UIColor.systemGreen
        static let distanceBackgroundColor = UIColor.systemBlue.withAlphaComponent(0.15)
        static let tagBackgroundColor = UIColor.secondarySystemBackground
    }
    
    // MARK: - UI Components
    
    /// 메인 컨테이너
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = Design.cornerRadius
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = Design.shadowOpacity
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 15
        view.clipsToBounds = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    /// 콘텐츠 컨테이너 (그림자 없이 모서리만 둥글게)
    private let contentContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = Design.cornerRadius
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    /// 이미지 뷰
    private let placeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = UIColor.systemGray6
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    /// 이미지 그라데이션 레이어
    private let gradientView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let gradientLayer: CAGradientLayer = {
        let gradient = CAGradientLayer()
        gradient.colors = Design.gradientColors
        gradient.locations = [0, 0.5, 1.0]
        return gradient
    }()
    
    /// 콘텐츠 타입 태그
    private let typeTagView: UIView = {
        let view = UIView()
        view.backgroundColor = Design.tagBackgroundColor
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let typeIconImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .label
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let typeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    /// 방문 체크 버튼
    private let visitButton: UIButton = {
        let button = UIButton(type: .system)
        
        // 현대적인 버튼 스타일 적용
        var config = UIButton.Configuration.filled()
        config.cornerStyle = .capsule
        config.baseBackgroundColor = .white
        config.baseForegroundColor = .systemGray
        
        // 이미지 설정
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        config.image = UIImage(systemName: "plus.circle", withConfiguration: symbolConfig)
        
        button.configuration = config
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.2
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    /// 여행지 제목 레이블
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .label
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    /// 주소 레이블
    private let addressLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    /// 하단 세부정보 스택
    private let detailsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .equalSpacing
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    /// 거리 표시 컨테이너
    private let distanceContainer: UIView = {
        let view = UIView()
        view.backgroundColor = Design.distanceBackgroundColor
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let distanceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = Design.primaryColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    /// 날짜 컨테이너
    private let dateContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemGray6
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    /// 방문 완료 마커
    private let visitedMarkerView: UIView = {
        let view = UIView()
        view.backgroundColor = Design.visitedColor
        view.layer.cornerRadius = 10
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let visitedMarkerImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "checkmark")
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .white
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let visitedLabel: UILabel = {
        let label = UILabel()
        label.text = "방문 완료"
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Properties
    private var toggleCallback: (() -> Void)?
    private var currentSite: TourSiteItem?
    
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
        
        // 그라데이션 레이어 프레임 설정
        gradientLayer.frame = gradientView.bounds
        
        // 그림자 경로 최적화
        containerView.layer.shadowPath = UIBezierPath(
            roundedRect: containerView.bounds,
            cornerRadius: Design.cornerRadius
        ).cgPath
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        placeImageView.kf.cancelDownloadTask()
        placeImageView.image = nil
        titleLabel.text = nil
        addressLabel.text = nil
        distanceLabel.text = nil
        dateLabel.text = nil
        typeLabel.text = nil
        typeIconImageView.image = nil
        
        // 버튼 초기화
        var config = visitButton.configuration
        config?.image = UIImage(systemName: "plus.circle")
        config?.baseForegroundColor = .systemGray
        visitButton.configuration = config
        
        // 방문 마커 숨기기
        visitedMarkerView.isHidden = true
        
        // 비활성화
        distanceContainer.isHidden = false
        dateContainer.isHidden = false
        typeTagView.isHidden = false
        
        // 콜백 제거
        toggleCallback = nil
        currentSite = nil
    }
    
    // MARK: - Setup
    private func setupViews() {
        contentView.addSubview(containerView)
        containerView.addSubview(contentContainer)
        
        contentContainer.addSubview(placeImageView)
        contentContainer.addSubview(gradientView)
        gradientView.layer.addSublayer(gradientLayer)
        
        contentContainer.addSubview(typeTagView)
        typeTagView.addSubview(typeIconImageView)
        typeTagView.addSubview(typeLabel)
        
        contentContainer.addSubview(visitButton)
        contentContainer.addSubview(titleLabel)
        contentContainer.addSubview(addressLabel)
        
        contentContainer.addSubview(detailsStack)
        
        contentContainer.addSubview(distanceContainer)
        distanceContainer.addSubview(distanceLabel)
        
        contentContainer.addSubview(dateContainer)
        dateContainer.addSubview(dateLabel)
        
        contentContainer.addSubview(visitedMarkerView)
        visitedMarkerView.addSubview(visitedMarkerImageView)
        visitedMarkerView.addSubview(visitedLabel)
        
        visitButton.addTarget(self, action: #selector(visitButtonTapped), for: .touchUpInside)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // 컨테이너
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            
            // 컨텐츠 컨테이너
            contentContainer.topAnchor.constraint(equalTo: containerView.topAnchor),
            contentContainer.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            contentContainer.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            contentContainer.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            // 이미지 뷰
            placeImageView.topAnchor.constraint(equalTo: contentContainer.topAnchor),
            placeImageView.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            placeImageView.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor),
            placeImageView.heightAnchor.constraint(equalToConstant: Design.imageHeight),
            
            // 그라데이션 뷰
            gradientView.topAnchor.constraint(equalTo: placeImageView.topAnchor),
            gradientView.leadingAnchor.constraint(equalTo: placeImageView.leadingAnchor),
            gradientView.trailingAnchor.constraint(equalTo: placeImageView.trailingAnchor),
            gradientView.heightAnchor.constraint(equalToConstant: 100),
            
            // 타입 태그
            typeTagView.topAnchor.constraint(equalTo: contentContainer.topAnchor, constant: 16),
            typeTagView.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor, constant: 16),
            typeTagView.heightAnchor.constraint(equalToConstant: 24),
            
            // 타입 아이콘
            typeIconImageView.leadingAnchor.constraint(equalTo: typeTagView.leadingAnchor, constant: 8),
            typeIconImageView.centerYAnchor.constraint(equalTo: typeTagView.centerYAnchor),
            typeIconImageView.widthAnchor.constraint(equalToConstant: 14),
            typeIconImageView.heightAnchor.constraint(equalToConstant: 14),
            
            // 타입 레이블
            typeLabel.leadingAnchor.constraint(equalTo: typeIconImageView.trailingAnchor, constant: 4),
            typeLabel.centerYAnchor.constraint(equalTo: typeTagView.centerYAnchor),
            typeLabel.trailingAnchor.constraint(equalTo: typeTagView.trailingAnchor, constant: -8),
            
            // 방문 버튼
            visitButton.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor, constant: -16),
            visitButton.topAnchor.constraint(equalTo: contentContainer.topAnchor, constant: 16),
            visitButton.widthAnchor.constraint(equalToConstant: 42),
            visitButton.heightAnchor.constraint(equalToConstant: 42),
            
            // 제목 레이블
            titleLabel.topAnchor.constraint(equalTo: placeImageView.bottomAnchor, constant: Design.contentInset),
            titleLabel.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor, constant: Design.contentInset),
            titleLabel.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor, constant: -Design.contentInset),
            
            // 주소 레이블
            addressLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            addressLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            addressLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            // 거리 컨테이너
            distanceContainer.topAnchor.constraint(equalTo: addressLabel.bottomAnchor, constant: Design.contentInset),
            distanceContainer.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            distanceContainer.heightAnchor.constraint(equalToConstant: 24),
            distanceContainer.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor, constant: -Design.contentInset),
            
            // 거리 레이블
            distanceLabel.leadingAnchor.constraint(equalTo: distanceContainer.leadingAnchor, constant: 8),
            distanceLabel.trailingAnchor.constraint(equalTo: distanceContainer.trailingAnchor, constant: -8),
            distanceLabel.centerYAnchor.constraint(equalTo: distanceContainer.centerYAnchor),
            
            // 날짜 컨테이너
            dateContainer.leadingAnchor.constraint(equalTo: distanceContainer.trailingAnchor, constant: 8),
            dateContainer.centerYAnchor.constraint(equalTo: distanceContainer.centerYAnchor),
            dateContainer.heightAnchor.constraint(equalToConstant: 24),
            
            // 날짜 레이블
            dateLabel.leadingAnchor.constraint(equalTo: dateContainer.leadingAnchor, constant: 8),
            dateLabel.trailingAnchor.constraint(equalTo: dateContainer.trailingAnchor, constant: -8),
            dateLabel.centerYAnchor.constraint(equalTo: dateContainer.centerYAnchor),
            
            // 방문 완료 마커
            visitedMarkerView.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor, constant: -Design.contentInset),
            visitedMarkerView.centerYAnchor.constraint(equalTo: distanceContainer.centerYAnchor),
            visitedMarkerView.heightAnchor.constraint(equalToConstant: 24),
            
            // 방문 마커 아이콘
            visitedMarkerImageView.leadingAnchor.constraint(equalTo: visitedMarkerView.leadingAnchor, constant: 8),
            visitedMarkerImageView.centerYAnchor.constraint(equalTo: visitedMarkerView.centerYAnchor),
            visitedMarkerImageView.widthAnchor.constraint(equalToConstant: 10),
            visitedMarkerImageView.heightAnchor.constraint(equalToConstant: 10),
            
            // 방문 마커 레이블
            visitedLabel.leadingAnchor.constraint(equalTo: visitedMarkerImageView.trailingAnchor, constant: 4),
            visitedLabel.trailingAnchor.constraint(equalTo: visitedMarkerView.trailingAnchor, constant: -8),
            visitedLabel.centerYAnchor.constraint(equalTo: visitedMarkerView.centerYAnchor)
        ])
    }
    
    // MARK: - Configuration
    func configure(with site: TourSiteItem, isVisited: Bool, onToggle: @escaping () -> Void) {
        currentSite = site
        toggleCallback = onToggle
        
        // 이미지 설정
        if let imageURL = site.thumbnailURL {
            let processor = DownsamplingImageProcessor(size: CGSize(width: 600, height: 400))
            placeImageView.kf.indicatorType = .activity
            placeImageView.kf.setImage(
                with: imageURL,
                placeholder: UIImage(systemName: "photo.fill"),
                options: [
                    .processor(processor),
                    .transition(.fade(0.3)),
                    .cacheOriginalImage,
                    .scaleFactor(UIScreen.main.scale)
                ]
            )
        } else {
            // 플레이스홀더 이미지
            placeImageView.image = UIImage(systemName: "photo.fill")
            placeImageView.backgroundColor = UIColor.systemGray5
            placeImageView.tintColor = UIColor.systemGray3
        }
        
        // 제목과 주소 설정
        titleLabel.text = site.title
        addressLabel.text = site.fullAddress ?? site.addr1
        
        // 콘텐츠 타입 설정
        if let typeId = Int(site.contenttypeid ?? "0"), let typeName = site.contentTypeName {
            typeLabel.text = typeName
            typeIconImageView.image = UIImage(systemName: site.sfSymbol)
        } else {
            typeTagView.isHidden = true
        }
        
        // 거리 설정
        if let distanceText = site.distanceText {
            distanceLabel.text = "📍 \(distanceText)"
            distanceContainer.isHidden = false
        } else {
            distanceContainer.isHidden = true
        }
        
        // 날짜 설정 (수정일 또는 생성일)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        
        if let modDate = site.modificationDate {
            dateLabel.text = "🕐 \(dateFormatter.string(from: modDate))"
            dateContainer.isHidden = false
        } else if let createDate = site.creationDate {
            dateLabel.text = "🕐 \(dateFormatter.string(from: createDate))"
            dateContainer.isHidden = false
        } else {
            dateContainer.isHidden = true
        }
        
        // 방문 상태 설정
        updateVisitedState(isVisited)
        
        // 애니메이션 효과
        animateAppearance()
    }
    
    private func updateVisitedState(_ isVisited: Bool) {
        // 방문 버튼 업데이트
        var config = visitButton.configuration
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        
        if isVisited {
            config?.image = UIImage(systemName: "checkmark.circle.fill", withConfiguration: symbolConfig)
            config?.baseForegroundColor = Design.visitedColor
            visitedMarkerView.isHidden = false
        } else {
            config?.image = UIImage(systemName: "plus.circle", withConfiguration: symbolConfig)
            config?.baseForegroundColor = .systemGray
            visitedMarkerView.isHidden = true
        }
        
        visitButton.configuration = config
    }
    
    private func animateAppearance() {
        // 나타날 때 애니메이션
        alpha = 0
        transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        
        UIView.animate(withDuration: 0.4, delay: 0.05, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5) {
            self.alpha = 1
            self.transform = CGAffineTransform.identity
        }
    }
    
    // MARK: - Actions
    @objc private func visitButtonTapped() {
        // 햅틱 피드백
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
        
        // 버튼 애니메이션
        UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseInOut], animations: {
            self.visitButton.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
        }) { _ in
            UIView.animate(withDuration: 0.2) {
                self.visitButton.transform = .identity
            }
        }
        
        toggleCallback?()
    }
    
    // 셀 선택 효과
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        UIView.animate(withDuration: 0.1) {
            self.containerView.transform = CGAffineTransform(scaleX: 0.98, y: 0.98)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.2) {
            self.containerView.transform = .identity
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.2) {
            self.containerView.transform = .identity
        }
    }
}

// MARK: - 공유하기 기능 확장
extension TravelPlaceCell {
    func shareContent() {
        guard let site = currentSite else { return }
        
        var items: [Any] = []
        
        // 공유 텍스트 생성
        let shareText = "BeenThere - \(site.title)\n"
        + (site.fullAddress != nil ? "주소: \(site.fullAddress!)\n" : "")
        + (site.distanceText != nil ? "위치: \(site.distanceText!) 거리\n" : "")
        + "여행 추천 앱 BeenThere에서 확인하세요!"
        
        items.append(shareText)
        
        // 이미지가 있으면 추가
        if let imageURL = site.thumbnailURL, let imageData = try? Data(contentsOf: imageURL) {
            if let image = UIImage(data: imageData) {
                items.append(image)
            }
        }
        
        // 공유 URL 추가 (앱 딥링크나 웹사이트)
        if let url = URL(string: "https://beenthere.app/place/\(site.contentid)") {
            items.append(url)
        }
        
        // 공유 컨트롤러 표시 (뷰 컨트롤러에서 구현)
        NotificationCenter.default.post(name: NSNotification.Name("ShareTravelPlace"), object: nil, userInfo: ["items": items])
    }
}

// MARK: - Preview Support
#if DEBUG
import SwiftUI

struct TravelPlaceCellPreview: UIViewRepresentable {
    func makeUIView(context: Context) -> TravelPlaceCell {
        let cell = TravelPlaceCell(frame: CGRect(x: 0, y: 0, width: 350, height: 400))
        
        // 더미 데이터
        let dummySite = TourSiteItem.sample
        
        cell.configure(with: dummySite, isVisited: false) {
            print("방문 체크 토글됨")
        }
        
        return cell
    }
    
    func updateUIView(_ uiView: TravelPlaceCell, context: Context) {}
}

struct TravelPlaceCell_Previews: PreviewProvider {
    static var previews: some View {
        TravelPlaceCellPreview()
            .frame(width: 350, height: 400)
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
#endif

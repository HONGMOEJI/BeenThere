//
//  MainView.swift
//  BeenThere
//
//  앱 메인 화면
//

import UIKit
import Lottie

class MainView: UIView {
    
    struct Design {
        static let backgroundColor = UIColor.themeBackground
        static let surfaceColor = UIColor(white: 0.15, alpha: 1.0)
        static let cardColor = UIColor(white: 0.18, alpha: 1.0)
        static let borderColor = UIColor(white: 0.25, alpha: 1.0)
        
        static let textPrimary = UIColor.themeTextPrimary
        static let textSecondary = UIColor.themeTextSecondary
        static let textTertiary = UIColor.themeTextPlaceholder
        
        static let accentColor = UIColor(white: 0.85, alpha: 1.0)
        static let accentColorPressed = UIColor(white: 0.75, alpha: 1.0)
        
        static let cornerRadius: CGFloat = 16
        static let cardCornerRadius: CGFloat = 20
        static let spacing: CGFloat = 20
        static let smallSpacing: CGFloat = 12
        static let cardSpacing: CGFloat = 16
        
        static let shadowColor = UIColor.black.cgColor
        static let shadowOpacity: Float = 0.3
        static let shadowRadius: CGFloat = 20
        static let shadowOffset = CGSize(width: 0, height: 8)
    }
    
    // MARK: - UI Components
    
    private let mainTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "어디를 가볼까요?"
        label.font = .displayMedium
        label.textColor = Design.textPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let mainSubtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "새로운 여행지를 찾아보세요"
        label.font = .bodyMedium
        label.textColor = Design.textSecondary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let locationButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = Design.surfaceColor
        button.layer.cornerRadius = 14
        button.layer.borderWidth = 1
        button.layer.borderColor = Design.borderColor.cgColor
        button.clipsToBounds = true
        button.setTitleColor(Design.textPrimary, for: .normal)
        button.titleLabel?.font = .buttonMedium
        
        button.setTitle("내 위치", for: .normal)
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)
        let icon = UIImage(systemName: "location.fill", withConfiguration: symbolConfig)
        button.setImage(icon, for: .normal)
        button.tintColor = Design.textPrimary
        if #available(iOS 15.0, *) {
            // UIButtonConfiguration ignores edgeInsets on iOS 15+, no action needed
        } else {
            button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -2, bottom: 0, right: 2)
            button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: -4)
        }
        
        return button
    }()
    
    private lazy var titleSubtitleStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [mainTitleLabel, mainSubtitleLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var titleStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleSubtitleStack, locationButton])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // 🔥 스크롤뷰를 public으로 변경 (델리게이트 접근을 위해)
    let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.backgroundColor = Design.backgroundColor
        sv.showsVerticalScrollIndicator = false
        sv.showsHorizontalScrollIndicator = false
        sv.contentInsetAdjustmentBehavior = .automatic
        sv.bounces = true
        sv.alwaysBounceVertical = true
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private let contentContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let refreshControl: UIRefreshControl = {
        let rc = UIRefreshControl()
        rc.tintColor = Design.accentColor
        rc.attributedTitle = NSAttributedString(
            string: "당겨서 새로고침",
            attributes: [
                .foregroundColor: Design.textSecondary,
                .font: UIFont.captionLarge
            ]
        )
        return rc
    }()
    
    // 카테고리
    private let categoryTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "카테고리"
        label.font = .titleSmall
        label.textColor = Design.textPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let categoryScrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsHorizontalScrollIndicator = false
        sv.showsVerticalScrollIndicator = false
        sv.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        sv.bounces = true
        sv.alwaysBounceHorizontal = true
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    let categoryStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 12
        sv.distribution = .fillProportionally
        sv.alignment = .center
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    // 콘텐츠 섹션 헤더
    private let contentSectionHeader: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let sectionTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "추천 여행지"
        label.font = .titleMedium
        label.textColor = Design.textPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var subtitleLabel: UILabel { sectionSubtitleLabel }
    private let sectionSubtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "인기 여행지를 둘러보세요"
        label.font = .bodySmall
        label.textColor = Design.textSecondary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // 🔥 컬렉션뷰 - 스크롤 비활성화 (스크롤뷰가 담당)
    lazy var collectionView: UICollectionView = {
        let layout = createCollectionViewLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.showsVerticalScrollIndicator = false
        cv.showsHorizontalScrollIndicator = false
        
        // 🔥 스크롤 비활성화 - 스크롤뷰가 담당
        cv.isScrollEnabled = false
        cv.alwaysBounceVertical = false
        cv.bounces = false
        
        cv.register(TravelPlaceCell.self, forCellWithReuseIdentifier: TravelPlaceCell.reuseIdentifier)
        cv.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "DefaultCell")
        cv.translatesAutoresizingMaskIntoConstraints = false
        
        print("🔧 CollectionView 설정 완료 (스크롤 비활성화)")
        print("   - isScrollEnabled: \(cv.isScrollEnabled)")
        
        return cv
    }()
    
    // State Views
    lazy var loadingAnimationView: LottieAnimationView = {
        let animationView = LottieAnimationView(name: "loading")
        animationView.loopMode = .loop
        animationView.contentMode = .scaleAspectFit
        animationView.backgroundColor = Design.backgroundColor.withAlphaComponent(0.8)
        animationView.isHidden = true
        animationView.translatesAutoresizingMaskIntoConstraints = false
        return animationView
    }()
    
    let emptyStateView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let emptyStateImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "map.fill")
        iv.tintColor = Design.textTertiary
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "검색 결과가 없습니다"
        label.font = .headlineMedium
        label.textColor = Design.textSecondary
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let emptyStateButton: UIButton = {
        let button = UIButton(type: .system)
        var config = UIButton.Configuration.filled()
        config.title = "다시 시도하기"
        config.baseBackgroundColor = Design.accentColor
        config.baseForegroundColor = Design.backgroundColor
        config.cornerStyle = .medium
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = .buttonMedium
            return outgoing
        }
        button.configuration = config
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
        setupRefreshControl()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
        setupConstraints()
        setupRefreshControl()
    }
    
    private func setupViews() {
        backgroundColor = Design.backgroundColor
        
        addSubview(scrollView)
        scrollView.addSubview(contentContainer)
        
        contentContainer.addSubview(titleStack)
        contentContainer.addSubview(categoryTitleLabel)
        contentContainer.addSubview(categoryScrollView)
        categoryScrollView.addSubview(categoryStackView)
        contentContainer.addSubview(contentSectionHeader)
        contentSectionHeader.addSubview(sectionTitleLabel)
        contentSectionHeader.addSubview(sectionSubtitleLabel)
        contentContainer.addSubview(collectionView)
        
        addSubview(loadingAnimationView)
        contentContainer.addSubview(emptyStateView)
        emptyStateView.addSubview(emptyStateImageView)
        emptyStateView.addSubview(emptyStateLabel)
        emptyStateView.addSubview(emptyStateButton)
    }
    
    private func setupRefreshControl() {
        scrollView.refreshControl = refreshControl
    }
    
    private func createCollectionViewLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(340)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(340)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = Design.cardSpacing
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: Design.spacing,
            bottom: 0,  // 🔥 하단 패딩을 0으로 변경 (기존 40에서)
            trailing: Design.spacing
        )
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    private func setupConstraints() {
        let safeArea = safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            contentContainer.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentContainer.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentContainer.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentContainer.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentContainer.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            titleStack.topAnchor.constraint(equalTo: contentContainer.topAnchor, constant: Design.spacing),
            titleStack.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor, constant: Design.spacing),
            titleStack.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor, constant: -Design.spacing),
            locationButton.widthAnchor.constraint(lessThanOrEqualToConstant: 120),
            locationButton.heightAnchor.constraint(equalToConstant: 40),
            
            categoryTitleLabel.topAnchor.constraint(equalTo: titleStack.bottomAnchor, constant: Design.spacing + 8),
            categoryTitleLabel.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor, constant: Design.spacing),
            
            categoryScrollView.topAnchor.constraint(equalTo: categoryTitleLabel.bottomAnchor, constant: Design.smallSpacing),
            categoryScrollView.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            categoryScrollView.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor),
            categoryScrollView.heightAnchor.constraint(equalToConstant: 44),
            
            categoryStackView.topAnchor.constraint(equalTo: categoryScrollView.topAnchor),
            categoryStackView.leadingAnchor.constraint(equalTo: categoryScrollView.leadingAnchor),
            categoryStackView.trailingAnchor.constraint(equalTo: categoryScrollView.trailingAnchor),
            categoryStackView.bottomAnchor.constraint(equalTo: categoryScrollView.bottomAnchor),
            categoryStackView.heightAnchor.constraint(equalTo: categoryScrollView.heightAnchor),
            
            contentSectionHeader.topAnchor.constraint(equalTo: categoryScrollView.bottomAnchor, constant: Design.spacing + 8),
            contentSectionHeader.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            contentSectionHeader.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor),
            contentSectionHeader.heightAnchor.constraint(equalToConstant: 60),
            
            sectionTitleLabel.topAnchor.constraint(equalTo: contentSectionHeader.topAnchor),
            sectionTitleLabel.leadingAnchor.constraint(equalTo: contentSectionHeader.leadingAnchor, constant: Design.spacing),
            
            sectionSubtitleLabel.topAnchor.constraint(equalTo: sectionTitleLabel.bottomAnchor, constant: 4),
            sectionSubtitleLabel.leadingAnchor.constraint(equalTo: sectionTitleLabel.leadingAnchor),
            
            collectionView.topAnchor.constraint(equalTo: contentSectionHeader.bottomAnchor, constant: Design.smallSpacing),
            collectionView.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor),
            
            loadingAnimationView.topAnchor.constraint(equalTo: topAnchor),
            loadingAnimationView.leadingAnchor.constraint(equalTo: leadingAnchor),
            loadingAnimationView.trailingAnchor.constraint(equalTo: trailingAnchor),
            loadingAnimationView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            emptyStateView.centerXAnchor.constraint(equalTo: contentContainer.centerXAnchor),
            emptyStateView.topAnchor.constraint(equalTo: contentSectionHeader.bottomAnchor, constant: 80),
            emptyStateView.widthAnchor.constraint(equalToConstant: 240),
            
            emptyStateImageView.topAnchor.constraint(equalTo: emptyStateView.topAnchor),
            emptyStateImageView.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            emptyStateImageView.widthAnchor.constraint(equalToConstant: 60),
            emptyStateImageView.heightAnchor.constraint(equalToConstant: 60),
            
            emptyStateLabel.topAnchor.constraint(equalTo: emptyStateImageView.bottomAnchor, constant: 16),
            emptyStateLabel.leadingAnchor.constraint(equalTo: emptyStateView.leadingAnchor),
            emptyStateLabel.trailingAnchor.constraint(equalTo: emptyStateView.trailingAnchor),
            
            emptyStateButton.topAnchor.constraint(equalTo: emptyStateLabel.bottomAnchor, constant: 20),
            emptyStateButton.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            emptyStateButton.widthAnchor.constraint(equalToConstant: 140),
            emptyStateButton.heightAnchor.constraint(equalToConstant: 44),
            emptyStateButton.bottomAnchor.constraint(equalTo: emptyStateView.bottomAnchor)
        ])
    }
    
    // MARK: - Public Methods
    
    func createCategoryButton(title: String, icon: String, tag: Int) -> UIButton {
        let button = UIButton(type: .system)
        button.tag = tag
        
        var config = UIButton.Configuration.filled()
        config.title = title
        config.image = UIImage(systemName: icon)
        config.imagePlacement = .leading
        config.imagePadding = 6
        config.cornerStyle = .capsule
        config.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 14, bottom: 10, trailing: 14)
        config.baseBackgroundColor = Design.surfaceColor
        config.baseForegroundColor = Design.textSecondary
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = .buttonSmall
            return outgoing
        }
        
        button.configuration = config
        button.layer.borderWidth = 1
        button.layer.borderColor = Design.borderColor.cgColor
        button.layer.cornerRadius = 22
        button.configurationUpdateHandler = { button in
            var config = button.configuration
            if button.isSelected {
                config?.baseBackgroundColor = Design.accentColor
                config?.baseForegroundColor = Design.backgroundColor
                button.layer.borderColor = Design.accentColor.cgColor
            } else {
                config?.baseBackgroundColor = Design.surfaceColor
                config?.baseForegroundColor = Design.textSecondary
                button.layer.borderColor = Design.borderColor.cgColor
            }
            button.configuration = config
        }
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
    
    func showLoadingState() {
        loadingAnimationView.isHidden = false
        loadingAnimationView.play()
        emptyStateView.isHidden = true
        collectionView.isHidden = true
    }
    
    func hideLoadingState() {
        loadingAnimationView.isHidden = true
        loadingAnimationView.stop()
        collectionView.isHidden = false
    }
    
    func showEmptyState(message: String = "검색 결과가 없습니다", icon: String = "map.fill") {
        emptyStateView.isHidden = false
        collectionView.isHidden = true
        emptyStateLabel.text = message
        emptyStateImageView.image = UIImage(systemName: icon)
    }
    
    func hideEmptyState() {
        emptyStateView.isHidden = true
        collectionView.isHidden = false
    }
    
    func updateCollectionViewHeight(_ height: CGFloat) {
        // 사용하지 않음 - adjustCollectionViewHeight 사용
        print("📐 updateCollectionViewHeight 호출됨 - adjustCollectionViewHeight 사용")
    }
}

extension MainView {
    func adjustCollectionViewHeight(for itemCount: Int) {
        print("📐 adjustCollectionViewHeight 호출됨: \(itemCount)개 아이템")
        
        guard itemCount > 0 else {
            // 아이템이 없으면 높이를 0으로 설정
            collectionView.constraints.forEach { constraint in
                if constraint.firstAttribute == .height {
                    constraint.isActive = false
                }
            }
            collectionView.heightAnchor.constraint(equalToConstant: 0).isActive = true
            layoutIfNeeded()
            return
        }
        
        // 🔥 TravelPlaceCell의 최적화된 높이 계산
        let imageHeight: CGFloat = 200           // 이미지 높이
        let contentPadding: CGFloat = 32         // 상하 패딩 (16 + 16)
        let titleHeight: CGFloat = 40            // 타이틀 영역 (더 정확한 높이)
        let addressHeight: CGFloat = 18          // 주소 줄
        let phoneHeight: CGFloat = 18            // 전화번호 줄
        let textSpacing: CGFloat = 6             // 텍스트 간 여백 최소화
        let cardMargin: CGFloat = 8              // 카드 상하 여백 (4 + 4)
        
        // 셀 하나의 최적화된 높이
        let singleItemHeight = imageHeight + contentPadding + titleHeight + addressHeight + phoneHeight + textSpacing + cardMargin
        
        // 아이템 간 간격 (마지막 아이템 제외)
        let totalSpacing = CGFloat(max(0, itemCount - 1)) * Design.cardSpacing
        
        // 🔥 하단 여백을 더욱 최소화 (16 -> 8로 줄임)
        let bottomPadding: CGFloat = 8
        
        let calculatedHeight = CGFloat(itemCount) * singleItemHeight + totalSpacing + bottomPadding
        
        // 기존 높이 제약 조건 제거
        collectionView.constraints.forEach { constraint in
            if constraint.firstAttribute == .height {
                constraint.isActive = false
            }
        }
        
        // 새로운 높이 제약 조건 추가
        let heightConstraint = collectionView.heightAnchor.constraint(equalToConstant: calculatedHeight)
        heightConstraint.isActive = true
        
        print("   - 단일 아이템 높이: \(singleItemHeight)")
        print("   - 계산된 총 높이: \(calculatedHeight)")
        print("   - 간격 총합: \(totalSpacing)")
        print("   - 하단 패딩: \(bottomPadding)")
        
        // 레이아웃 업데이트
        layoutIfNeeded()
        
        // 스크롤뷰의 콘텐츠 사이즈도 업데이트
        DispatchQueue.main.async { [weak self] in
            self?.setNeedsLayout()
            self?.layoutIfNeeded()
        }
    }
}

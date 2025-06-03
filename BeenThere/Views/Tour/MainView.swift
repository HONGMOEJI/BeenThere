//
//  MainView.swift
//  BeenThere
//
//  메인 화면의 UI 요소만을 담당하는 View 클래스
//  - 위치 버튼, 검색창, 카테고리 필터링 등 UI 컴포넌트 정의
//  - 레이아웃 설정만 담당
//  - 비즈니스 로직은 ViewController에서 처리
//
//  BeenThere/Views/Tour/MainView.swift
//

import UIKit
import Lottie

class MainView: UIView {
    // MARK: - Constants
    struct Design {
        static let cornerRadius: CGFloat = 20
        static let smallCornerRadius: CGFloat = 16
        static let shadowOpacity: Float = 0.12
        static let headerHeight: CGFloat = 140
        static let cardSpacing: CGFloat = 16
        
        static let primaryColor = UIColor.systemBlue
        static let secondaryColor = UIColor.systemIndigo
        static let backgroundColor = UIColor.systemBackground
        static let surfaceColor = UIColor.secondarySystemBackground
        
        static let categoryHeight: CGFloat = 44
        static let buttonHeight: CGFloat = 50
    }
    
    // MARK: - UI Components
    
    /// 배경용 스크롤뷰 (당겨서 새로고침 지원)
    let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.backgroundColor = Design.backgroundColor
        sv.contentInsetAdjustmentBehavior = .never
        sv.showsVerticalScrollIndicator = false
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    /// 당겨서 새로고침 컨트롤
    let refreshControl: UIRefreshControl = {
        let rc = UIRefreshControl()
        rc.tintColor = Design.primaryColor
        rc.attributedTitle = NSAttributedString(string: "당겨서 새로고침")
        return rc
    }()
    
    /// 헤더 컨테이너 뷰 (상단 고정)
    let headerView: UIView = {
        let view = UIView()
        view.backgroundColor = Design.backgroundColor
        view.layer.masksToBounds = false
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = Design.shadowOpacity
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    /// 검색 및 위치 컨테이너
    let searchContainer: UIView = {
        let view = UIView()
        view.backgroundColor = Design.surfaceColor
        view.layer.cornerRadius = Design.cornerRadius
        view.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    /// 앱 로고 이미지
    let logoImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "app-logo")
        iv.contentMode = .scaleAspectFit
        iv.tintColor = Design.primaryColor
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    /// 앱 타이틀 레이블
    let appTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "BeenThere"
        label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        label.textColor = Design.primaryColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    /// 좌측 위치 버튼 (내 위치 표시 및 변경)
    let locationButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.tertiarySystemBackground
        button.layer.cornerRadius = Design.smallCornerRadius
        
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = Design.surfaceColor
        config.baseForegroundColor = Design.primaryColor
        config.imagePlacement = .leading
        config.imagePadding = 8
        config.cornerStyle = .medium
        
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)
        config.image = UIImage(systemName: "location.fill", withConfiguration: imageConfig)
        config.title = "내 위치"
        
        button.configuration = config
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    /// 우측 검색 바
    let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "여행지, 명소, 지역 검색"
        searchBar.searchBarStyle = .minimal
        searchBar.backgroundColor = .clear
        searchBar.tintColor = Design.primaryColor
        
        searchBar.searchTextField.backgroundColor = UIColor.tertiarySystemBackground
        searchBar.searchTextField.layer.cornerRadius = 12
        searchBar.searchTextField.clipsToBounds = true
        searchBar.searchTextField.font = .systemFont(ofSize: 16)
                    
        if let glassIconView = searchBar.searchTextField.leftView as? UIImageView {
            glassIconView.tintColor = Design.primaryColor.withAlphaComponent(0.8)
        }
                    
        searchBar.searchTextField.tintColor = Design.primaryColor
        
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()
    
    /// 카테고리 필터 스크롤 뷰
    let categoryScrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsHorizontalScrollIndicator = false
        sv.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    /// 카테고리 버튼을 담을 스택 뷰
    let categoryStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 12
        sv.distribution = .fillProportionally
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    /// 섹션 제목 레이블
    let sectionTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "추천 여행지"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    /// 서브타이틀 레이블
    let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "새로운 여행지를 발견해보세요"
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    /// 위치 모드 컨테이너 (스위치 + 레이블)
    let locationModeContainer: UIView = {
        let view = UIView()
        view.backgroundColor = Design.surfaceColor
        view.layer.cornerRadius = Design.smallCornerRadius
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    /// 위치 기반 모드 토글 스위치
    let locationModeSwitch: UISwitch = {
        let sw = UISwitch()
        sw.isOn = false
        sw.onTintColor = Design.primaryColor
        sw.translatesAutoresizingMaskIntoConstraints = false
        return sw
    }()
    
    let locationModeLabel: UILabel = {
        let label = UILabel()
        label.text = "내 주변 보기"
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    /// 컬렉션 뷰 (카드 스타일)
    lazy var collectionView: UICollectionView = {
        let layout = createLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.showsVerticalScrollIndicator = false
        cv.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 24, right: 0)
        cv.register(TravelPlaceCell.self, forCellWithReuseIdentifier: TravelPlaceCell.reuseIdentifier)
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()
    
    /// 로딩 애니메이션 뷰
    lazy var loadingAnimationView: LottieAnimationView = {
        let animationView = LottieAnimationView(name: "location-loading")
        animationView.loopMode = .loop
        animationView.contentMode = .scaleAspectFit
        animationView.isHidden = true
        animationView.translatesAutoresizingMaskIntoConstraints = false
        return animationView
    }()
    
    /// 빈 데이터 표시 뷰
    let emptyStateView: UIView = {
        let view = UIView()
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let emptyStateImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "mappin.and.ellipse")
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .secondaryLabel
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "검색 결과가 없습니다"
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let emptyStateButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("다시 시도하기", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = Design.primaryColor
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - 초기화 메서드
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
    
    // MARK: - UI 설정
    private func setupViews() {
        backgroundColor = Design.backgroundColor
        
        // 서브뷰 추가
        addSubview(scrollView)
        addSubview(headerView)
        
        headerView.addSubview(searchContainer)
        searchContainer.addSubview(logoImageView)
        searchContainer.addSubview(appTitleLabel)
        searchContainer.addSubview(locationButton)
        searchContainer.addSubview(searchBar)
        
        scrollView.addSubview(categoryScrollView)
        categoryScrollView.addSubview(categoryStackView)
        
        scrollView.addSubview(sectionTitleLabel)
        scrollView.addSubview(subtitleLabel)
        scrollView.addSubview(locationModeContainer)
        
        locationModeContainer.addSubview(locationModeLabel)
        locationModeContainer.addSubview(locationModeSwitch)
        
        scrollView.addSubview(collectionView)
        
        addSubview(loadingAnimationView)
        
        scrollView.addSubview(emptyStateView)
        emptyStateView.addSubview(emptyStateImageView)
        emptyStateView.addSubview(emptyStateLabel)
        emptyStateView.addSubview(emptyStateButton)
        
        scrollView.refreshControl = refreshControl
    }
    
    // MARK: - 컬렉션 뷰 레이아웃
    private func createLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(300)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(300)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = Design.cardSpacing
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: Design.cardSpacing,
            bottom: 0,
            trailing: Design.cardSpacing
        )
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    // MARK: - 제약 조건 설정
    private func setupConstraints() {
        // 여기에 기존의 setupConstraints 코드를 옮겨옵니다.
        // 기존 View Controller의 constraint 코드에서 safeArea 참조를 self.safeAreaLayoutGuide로 변경합니다.
        let safeArea = self.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            // 스크롤 뷰
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // 헤더 뷰 (상단 고정)
            headerView.topAnchor.constraint(equalTo: topAnchor),
            headerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: Design.headerHeight),
            
            // 기타 제약 조건들...
            
            // 컬렉션 뷰
            collectionView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 3000), // 충분히 큰 값
            collectionView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            
            // 로딩 애니메이션
            loadingAnimationView.centerXAnchor.constraint(equalTo: centerXAnchor),
            loadingAnimationView.centerYAnchor.constraint(equalTo: centerYAnchor),
            loadingAnimationView.widthAnchor.constraint(equalToConstant: 150),
            loadingAnimationView.heightAnchor.constraint(equalToConstant: 150),
            
            // 빈 데이터 상태 뷰
            emptyStateView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            emptyStateView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 80),
            emptyStateView.widthAnchor.constraint(equalToConstant: 240)
            
            // 나머지 제약 조건도 추가...
        ])
        
        // 스크롤 뷰 콘텐츠 영역 설정
        scrollView.contentLayoutGuide.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
    }
}
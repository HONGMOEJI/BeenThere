//
//  OnboardingViewController.swift
//  BeenThere
//
//  온보딩 화면
//

import UIKit

// MARK: - 온보딩 데이터 구조체
struct OnboardingPage {
    let title: String
    let subtitle: String
    let animationType: AnimationType

    enum AnimationType {
        case floatingDots    // 떠다니는 점들
        case drawingLines    // 선 그리기
        case buildingMap     // 지도 구성 (격자 + 무작위 핀)
    }
}

// MARK: - 온보딩 페이지 뷰
class OnboardingPageView: UIView {
    private let data: OnboardingPage
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let animationContainerView = UIView()
    private var animationElements: [UIView] = []

    init(data: OnboardingPage) {
        self.data = data
        super.init(frame: .zero)
        setupLabels()
        setupAnimationContainer()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: – 레이블 초기화
    private func setupLabels() {
        // 타이틀 레이블
        titleLabel.text = data.title
        titleLabel.font = UIFont(name: "Pretendard-Bold", size: 28) ??
            .systemFont(ofSize: 28, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        // 서브타이틀 레이블
        subtitleLabel.text = data.subtitle
        subtitleLabel.font = UIFont(name: "Pretendard-Regular", size: 16) ??
            .systemFont(ofSize: 16, weight: .regular)
        subtitleLabel.textColor = UIColor(white: 0.85, alpha: 1)
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0
        subtitleLabel.lineBreakMode = .byWordWrapping
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false

        // 애니메이션 컨테이너
        animationContainerView.backgroundColor = .clear
        animationContainerView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(animationContainerView)
        addSubview(titleLabel)
        addSubview(subtitleLabel)
    }

    // MARK: – 애니메이션 요소 생성
    private func setupAnimationContainer() {
        switch data.animationType {
        case .floatingDots:
            createFloatingDots()
        case .drawingLines:
            createDrawingLines()
        case .buildingMap:
            createBuildingMap()
        }
    }

    private func createFloatingDots() {
        let containerSize = UIScreen.main.bounds.width * 0.8
        for _ in 0..<12 {
            let dot = UIView()
            let size = CGFloat.random(in: 12...24)
            let x = CGFloat.random(in: 0...(containerSize - size))
            let y = CGFloat.random(in: 0...(containerSize - size))
            dot.frame = CGRect(x: x, y: y, width: size, height: size)
            dot.backgroundColor = UIColor.systemBlue.withAlphaComponent(CGFloat.random(in: 0.4...0.8))
            dot.layer.cornerRadius = size / 2
            dot.alpha = 0
            animationContainerView.addSubview(dot)
            animationElements.append(dot)
        }
    }

    private func createDrawingLines() {
        let containerWidth = UIScreen.main.bounds.width * 0.8
        let penBody = UIView()
        penBody.frame = CGRect(x: 20, y: 20, width: 20, height: 60)
        penBody.backgroundColor = UIColor.systemOrange
        penBody.layer.cornerRadius = 4
        penBody.alpha = 0
        animationContainerView.addSubview(penBody)
        animationElements.append(penBody)

        for i in 0..<4 {
            let yPosition = 100 + CGFloat(i) * 30
            let line = UIView()
            line.frame = CGRect(x: 60, y: yPosition, width: containerWidth - 100, height: 4)
            line.backgroundColor = UIColor.white.withAlphaComponent(0.8)
            line.layer.cornerRadius = 2
            line.transform = CGAffineTransform(scaleX: 0, y: 1)
            animationContainerView.addSubview(line)
            animationElements.append(line)
        }
    }

    private func createBuildingMap() {
        // 1. mapBase: 반투명 배경
        let mapBase = UIView()
        mapBase.backgroundColor = UIColor(white: 0.08, alpha: 0.8)
        mapBase.layer.cornerRadius = 12
        mapBase.layer.borderWidth = 1
        mapBase.layer.borderColor = UIColor.white.withAlphaComponent(0.15).cgColor
        mapBase.alpha = 0
        mapBase.translatesAutoresizingMaskIntoConstraints = false
        animationContainerView.addSubview(mapBase)
        animationElements.append(mapBase) // index 0: mapBase

        // 2. 제약: mapBase를 컨테이너의 80% 폭 정사각형 배치
        NSLayoutConstraint.activate([
            mapBase.centerXAnchor.constraint(equalTo: animationContainerView.centerXAnchor),
            mapBase.centerYAnchor.constraint(equalTo: animationContainerView.centerYAnchor),
            mapBase.widthAnchor.constraint(equalTo: animationContainerView.widthAnchor, multiplier: 0.8),
            mapBase.heightAnchor.constraint(equalTo: mapBase.widthAnchor)
        ])

        // 3. 격자 패턴 추가 (layoutIfNeeded 후)
        DispatchQueue.main.async { [weak self] in
            guard let mapView = self?.animationElements.first else { return }
            self?.addGridPattern(to: mapView)
            self?.placeRandomPins(on: mapView)
        }
    }

    // MARK: – 무작위 핀 배치
    private func placeRandomPins(on view: UIView) {
        let rows = 4
        let cols = 4
        let pinCount = 5

        // 셀 크기
        let cellWidth = view.bounds.width / CGFloat(cols)
        let cellHeight = view.bounds.height / CGFloat(rows)

        for i in 0..<pinCount {
            // 랜덤 셀 인덱스 (0..<rows), (0..<cols)
            let randomRow = Int.random(in: 0..<rows)
            let randomCol = Int.random(in: 0..<cols)

            // 셀 안에서 약간의 여유 공간을 주기 위해 패딩 사용
            let padding: CGFloat = 8
            let xOffset = CGFloat.random(in: padding...(cellWidth - padding))
            let yOffset = CGFloat.random(in: padding...(cellHeight - padding))

            let x = cellWidth * CGFloat(randomCol) + xOffset
            let y = cellHeight * CGFloat(randomRow) + yOffset

            let pinContainer = createMapPin(index: i)
            pinContainer.alpha = 0
            pinContainer.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            view.addSubview(pinContainer)
            animationElements.append(pinContainer) // indices 1...5: pins

            pinContainer.frame = CGRect(x: x - 8, y: y - 8, width: 16, height: 16)
        }
    }

    // 핀 뷰 생성 함수 (색상, 테두리, 그림자)
    private func createMapPin(index: Int) -> UIView {
        let container = UIView()

        let colors: [UIColor] = [
            .systemRed,
            .systemBlue,
            .systemGreen,
            .systemOrange,
            .systemPurple
        ]

        let pin = UIView()
        pin.backgroundColor = colors[index % colors.count]
        pin.layer.cornerRadius = 8
        pin.layer.borderWidth = 2
        pin.layer.borderColor = UIColor.white.cgColor

        // 그림자 추가
        pin.layer.shadowColor = UIColor.black.cgColor
        pin.layer.shadowOffset = CGSize(width: 0, height: 2)
        pin.layer.shadowOpacity = 0.4
        pin.layer.shadowRadius = 3

        pin.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(pin)

        NSLayoutConstraint.activate([
            pin.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            pin.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            pin.widthAnchor.constraint(equalToConstant: 16),
            pin.heightAnchor.constraint(equalToConstant: 16)
        ])

        return container
    }

    // 격자 패턴 추가: 가로/세로 5선 (4칸)
    private func addGridPattern(to view: UIView) {
        view.layoutIfNeeded()
        let gridLayer = CAShapeLayer()
        let path = UIBezierPath()

        let w = view.bounds.width
        let h = view.bounds.height

        let rows = 4
        let cols = 4

        // 세로선
        for i in 0...cols {
            let x = CGFloat(i) * (w / CGFloat(cols))
            path.move(to: CGPoint(x: x, y: 0))
            path.addLine(to: CGPoint(x: x, y: h))
        }

        // 가로선
        for i in 0...rows {
            let y = CGFloat(i) * (h / CGFloat(rows))
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: w, y: y))
        }

        gridLayer.path = path.cgPath
        gridLayer.strokeColor = UIColor.white.withAlphaComponent(0.12).cgColor
        gridLayer.lineWidth = 0.8
        gridLayer.fillColor = UIColor.clear.cgColor

        view.layer.addSublayer(gridLayer)
    }

    // MARK: – 제약 설정
    private func setupConstraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        animationContainerView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            // 애니메이션 컨테이너: 화면 중앙, 너비 = 화면 너비의 80%
            animationContainerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            animationContainerView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -40),
            animationContainerView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.8),
            animationContainerView.heightAnchor.constraint(equalTo: animationContainerView.widthAnchor),

            // 타이틀 레이블: 컨테이너 아래 32pt, 좌/우 24pt 여백
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: animationContainerView.bottomAnchor, constant: 32),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),

            // 서브타이틀 레이블: 타이틀 아래 16pt, 좌/우 24pt 여백
            subtitleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            subtitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            subtitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24)
        ])
    }

    // MARK: – 애니메이션 실행
    func startAnimation() {
        switch data.animationType {
        case .floatingDots:
            animateFloatingDots()
        case .drawingLines:
            animateDrawingLines()
        case .buildingMap:
            animateBuildingMap()
        }
    }

    private func animateFloatingDots() {
        for (index, dot) in animationElements.enumerated() {
            let delay = Double(index) * 0.1

            UIView.animate(
                withDuration: 0.8,
                delay: delay,
                usingSpringWithDamping: 0.7,
                initialSpringVelocity: 0.5
            ) {
                dot.alpha = 1
            } completion: { _ in
                self.addFloatingAnimation(to: dot)
            }
        }
    }

    private func addFloatingAnimation(to view: UIView) {
        let animation = CABasicAnimation(keyPath: "transform.translation.y")
        animation.fromValue = 0
        animation.toValue = CGFloat.random(in: -20...20)
        animation.duration = Double.random(in: 2...4)
        animation.autoreverses = true
        animation.repeatCount = .infinity
        view.layer.add(animation, forKey: "floating")
    }

    private func animateDrawingLines() {
        guard animationElements.count >= 5 else { return }
        let penView = animationElements[0]
        UIView.animate(withDuration: 0.5) {
            penView.alpha = 1
        }

        for i in 1..<animationElements.count {
            let line = animationElements[i]
            let delay = Double(i - 1) * 0.3 + 0.5
            UIView.animate(withDuration: 0.6, delay: delay) {
                line.transform = .identity
            }
        }
    }

    private func animateBuildingMap() {
        guard animationElements.count >= 1 else { return }
        let mapBase = animationElements[0]
        UIView.animate(withDuration: 0.6) {
            mapBase.alpha = 1
        }

        // 핀들(인덱스 1~) 순차 등장
        for i in 1..<animationElements.count {
            let pin = animationElements[i]
            let delay = Double(i - 1) * 0.3 + 0.6
            UIView.animate(
                withDuration: 0.5,
                delay: delay,
                usingSpringWithDamping: 0.6,
                initialSpringVelocity: 0.8
            ) {
                pin.alpha = 1
                pin.transform = .identity
            }
        }
    }
}

// MARK: - OnboardingViewController
class OnboardingViewController: UIViewController, UIScrollViewDelegate {
    private let scrollView = UIScrollView()
    private let pageControl = UIPageControl()
    private let nextButton = ViewFactory.primaryButton(title: "다음")
    private let skipButton = ViewFactory.secondaryButton(title: "건너뛰기")

    // 온보딩 데이터
    private let onboardingData = [
        OnboardingPage(
            title: "내 주변에 있는 놀거리",
            subtitle: "발견하지 못했던 숨은 명소들을\n가까운 곳부터 찾아보세요",
            animationType: .floatingDots
        ),
        OnboardingPage(
            title: "나의 한 줄",
            subtitle: "여행의 순간을 간단한 기록으로\n특별한 추억을 남겨보세요",
            animationType: .drawingLines
        ),
        OnboardingPage(
            title: "나만의 지도",
            subtitle: "다녀온 곳들이 모여\n나만의 여행 지도를 완성해가요",
            animationType: .buildingMap
        )
    ]

    private var pageViews: [OnboardingPageView] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()
        setupScrollView()
        setupPageControl()
        setupButtons()
        setupPages()
        setupConstraints()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        pageViews.first?.startAnimation()
    }

    // MARK: – 배경 설정 (풀스크린 그라데이션)
    private func setupBackground() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [
            UIColor(red: 0.05, green: 0.05, blue: 0.1, alpha: 1).cgColor,
            UIColor.black.cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        view.layer.insertSublayer(gradientLayer, at: 0)
    }

    // MARK: – UIScrollView 세팅 (풀스크린, 가로 전용 스크롤)
    private func setupScrollView() {
        scrollView.isPagingEnabled = true
        scrollView.delegate = self
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.alwaysBounceVertical = false
        scrollView.bounces = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
    }

    // MARK: – UIPageControl 세팅
    private func setupPageControl() {
        pageControl.numberOfPages = onboardingData.count
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = UIColor.white.withAlphaComponent(0.3)
        pageControl.currentPageIndicatorTintColor = .systemBlue
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pageControl)
    }

    // MARK: – 버튼 세팅 (Next / Skip)
    private func setupButtons() {
        nextButton.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
        nextButton.layer.cornerRadius = 22
        nextButton.layer.shadowColor = UIColor.systemBlue.cgColor
        nextButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        nextButton.layer.shadowOpacity = 0.3
        nextButton.layer.shadowRadius = 6
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nextButton)

        skipButton.addTarget(self, action: #selector(done), for: .touchUpInside)
        skipButton.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        skipButton.layer.cornerRadius = 16
        skipButton.titleLabel?.font = .pretendardRegular(size: 14)
        skipButton.setTitleColor(UIColor(white: 0.9, alpha: 1), for: .normal)
        skipButton.contentEdgeInsets = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)
        skipButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(skipButton)
    }

    // MARK: – 각 페이지 뷰 생성
    private func setupPages() {
        for (index, data) in onboardingData.enumerated() {
            let pageView = OnboardingPageView(data: data)
            pageView.frame = CGRect(
                x: CGFloat(index) * view.bounds.width,
                y: 0,
                width: view.bounds.width,
                height: view.bounds.height
            )
            scrollView.addSubview(pageView)
            pageViews.append(pageView)
        }

        scrollView.contentSize = CGSize(
            width: view.bounds.width * CGFloat(onboardingData.count),
            height: view.bounds.height
        )
    }

    // MARK: – 오토레이아웃 제약
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // 1) scrollView: 전체 뷰를 꽉 채움
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // 2) PageControl: Next 버튼 위 24pt
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: nextButton.topAnchor, constant: -24),

            // 3) NextButton: SafeArea 바텀에서 40pt 위, 좌우 32pt 여백, 높이 AppConstants.Layout.buttonHeight
            nextButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            nextButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            nextButton.heightAnchor.constraint(equalToConstant: AppConstants.Layout.buttonHeight),

            // 4) SkipButton: SafeArea 상단 우측 24pt
            skipButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            skipButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24)
        ])
    }

    // MARK: – Next/Done 액션
    @objc private func nextTapped() {
        let next = pageControl.currentPage + 1
        if next < onboardingData.count {
            scrollView.setContentOffset(CGPoint(x: CGFloat(next) * view.bounds.width, y: 0), animated: true)
        } else {
            done()
        }
    }

    @objc private func done() {
        UserDefaults.standard.set(true, forKey: AppConstants.UserDefaults.isFirstLaunch)
        let authVC = AuthViewController()
        authVC.modalPresentationStyle = .fullScreen
        present(authVC, animated: true)
    }

    // MARK: – UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = Int(round(scrollView.contentOffset.x / view.bounds.width))
        pageControl.currentPage = page
        nextButton.setTitle(page == onboardingData.count - 1 ? "시작하기" : "다음", for: .normal)
        skipButton.isHidden = (page == onboardingData.count - 1)

        if page < pageViews.count {
            pageViews[page].startAnimation()
        }
    }
}

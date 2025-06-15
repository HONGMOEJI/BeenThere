//
//  SplashViewController.swift
//  BeenThere
//
//  스플래시 화면
//

import UIKit

class SplashViewController: UIViewController {

    // 1) 보도블럭을 담을 UIView 배열
    private var blockViews: [UIView] = []
    
    // 2) 블럭 생성 시 사운드 효과를 위한 임팩트 피드백
    private let impactFeedback = UIImpactFeedbackGenerator(style: .light)

    // 3) 하단 텍스트 레이블
    private let leftLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "다녀오다"
        lbl.font = UIFont(name: "Pretendard-Bold", size: 28) ??
            .systemFont(ofSize: 28, weight: .bold)
        lbl.textColor = .white
        lbl.alpha = 0
        // 텍스트에 미묘한 그림자 추가
        lbl.layer.shadowColor = UIColor.black.cgColor
        lbl.layer.shadowOffset = CGSize(width: 0, height: 2)
        lbl.layer.shadowOpacity = 0.3
        lbl.layer.shadowRadius = 4
        return lbl
    }()
    
    private let rightLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "여행 톺아보기"
        lbl.font = UIFont(name: "Pretendard-Medium", size: 16) ??
            .systemFont(ofSize: 16, weight: .medium)
        lbl.textColor = UIColor(white: 0.85, alpha: 1)
        lbl.alpha = 0
        // 텍스트에 미묘한 그림자 추가
        lbl.layer.shadowColor = UIColor.black.cgColor
        lbl.layer.shadowOffset = CGSize(width: 0, height: 1)
        lbl.layer.shadowOpacity = 0.2
        lbl.layer.shadowRadius = 2
        return lbl
    }()

    // 애니메이션 중복 실행 방지 플래그
    private var didAnimateCompletion = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setupGradientBackground()
        setupBlockViews()
        setupLabels()
        
        // 햅틱 피드백 준비
        impactFeedback.prepare()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateBlocksFromBottom()
    }
    
    // MARK: - 그라데이션 배경 설정
    private func setupGradientBackground() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [
            UIColor(red: 0.05, green: 0.05, blue: 0.1, alpha: 1).cgColor,  // 매우 어두운 남색
            UIColor(red: 0.02, green: 0.02, blue: 0.05, alpha: 1).cgColor,  // 거의 검은색
            UIColor.black.cgColor                                            // 완전 검은색
        ]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        gradientLayer.locations = [0.0, 0.7, 1.0]
        view.layer.insertSublayer(gradientLayer, at: 0)
    }

    // MARK: - 향상된 보도블럭 뷰들 생성 (질감, 그림자, 다양한 색상)
    private func setupBlockViews() {
        let w = view.bounds.width
        let h = view.bounds.height

        let topY: CGFloat = h * 0.12
        let midY: CGFloat = h * 0.58
        let blockAreaHeight = midY - topY

        let horizontalInset: CGFloat = 24
        let availableWidth = w - horizontalInset * 2

        let columns = 6
        let rows = 3
        let blockWidth = availableWidth / CGFloat(columns)
        let blockHeight = blockAreaHeight / CGFloat(rows)
        
        // 블럭 사이에 약간의 간격 추가
        let spacing: CGFloat = 2

        for row in 0..<rows {
            for col in 0..<columns {
                let x = horizontalInset + CGFloat(col) * blockWidth + spacing/2
                let y = midY - CGFloat(row + 1) * blockHeight + spacing/2
                
                let actualWidth = blockWidth - spacing
                let actualHeight = blockHeight - spacing

                let frame = CGRect(x: x, y: y, width: actualWidth, height: actualHeight)
                let block = createEnhancedBlock(frame: frame, row: row, col: col)

                view.addSubview(block)
                blockViews.append(block)
            }
        }
    }
    
    // MARK: - 향상된 블럭 생성 (질감, 그림자, 다양한 스타일)
    private func createEnhancedBlock(frame: CGRect, row: Int, col: Int) -> UIView {
        let block = UIView(frame: frame)
        
        // 다양한 회색 톤 생성
        let grayVariations: [UIColor] = [
            UIColor(white: 0.25, alpha: 1),   // 밝은 회색
            UIColor(white: 0.2, alpha: 1),    // 중간 회색
            UIColor(white: 0.15, alpha: 1),   // 어두운 회색
            UIColor(white: 0.12, alpha: 1),   // 매우 어두운 회색
        ]
        
        // 패턴에 따라 색상 선택 (완전 랜덤하지 않고 패턴이 있도록)
        let colorIndex = (row * 2 + col) % grayVariations.count
        block.backgroundColor = grayVariations[colorIndex]
        
        // 모서리를 살짝 둥글게
        block.layer.cornerRadius = 3
        
        // 그림자 추가 (입체감)
        block.layer.shadowColor = UIColor.black.cgColor
        block.layer.shadowOffset = CGSize(width: 0, height: 3)
        block.layer.shadowOpacity = 0.4
        block.layer.shadowRadius = 4
        
        // 테두리 추가 (블럭 느낌 강화)
        block.layer.borderWidth = 0.5
        block.layer.borderColor = UIColor(white: 0.1, alpha: 0.8).cgColor
        
        // 질감을 위한 노이즈 패턴 레이어 추가
        addTexturePattern(to: block)
        
        // 미묘한 하이라이트 추가 (상단에 밝은 선)
        addHighlight(to: block)
        
        block.alpha = 0
        // 초기 상태: 아래쪽에서 시작하고 약간 작게
        block.transform = CGAffineTransform(translationX: 0, y: 30).scaledBy(x: 0.8, y: 0.8)
        
        return block
    }
    
    // MARK: - 질감 패턴 추가
    private func addTexturePattern(to block: UIView) {
        let textureLayer = CALayer()
        textureLayer.frame = block.bounds
        
        // 점들을 랜덤하게 배치해서 질감 만들기
        for _ in 0..<8 {
            let dotLayer = CALayer()
            dotLayer.frame = CGRect(
                x: CGFloat.random(in: 2...(block.bounds.width-4)),
                y: CGFloat.random(in: 2...(block.bounds.height-4)),
                width: CGFloat.random(in: 0.5...1.5),
                height: CGFloat.random(in: 0.5...1.5)
            )
            dotLayer.backgroundColor = UIColor(white: CGFloat.random(in: 0.05...0.4), alpha: 0.6).cgColor
            dotLayer.cornerRadius = dotLayer.frame.width / 2
            textureLayer.addSublayer(dotLayer)
        }
        
        block.layer.addSublayer(textureLayer)
    }
    
    // MARK: - 하이라이트 추가
    private func addHighlight(to block: UIView) {
        let highlightLayer = CAGradientLayer()
        highlightLayer.frame = CGRect(x: 0, y: 0, width: block.bounds.width, height: 2)
        highlightLayer.colors = [
            UIColor(white: 1, alpha: 0.15).cgColor,
            UIColor(white: 1, alpha: 0.05).cgColor
        ]
        highlightLayer.startPoint = CGPoint(x: 0, y: 0)
        highlightLayer.endPoint = CGPoint(x: 0, y: 1)
        block.layer.addSublayer(highlightLayer)
    }

    // MARK: - 하단 레이블 배치 (Auto Layout)
    private func setupLabels() {
        view.addSubview(leftLabel)
        view.addSubview(rightLabel)

        leftLabel.translatesAutoresizingMaskIntoConstraints = false
        rightLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            leftLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            leftLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),

            rightLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            rightLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24)
        ])
    }

    // MARK: - 향상된 블록 애니메이션 (바운스, 회전, 햅틱)
    private func animateBlocksFromBottom() {
        guard !didAnimateCompletion else { return }

        let totalBlocks = blockViews.count

        for (index, block) in blockViews.enumerated() {
            // 아래에서부터 순차적으로, 약간의 랜덤 딜레이 추가
            let baseDelay = Double(index) * 0.04
            let randomDelay = Double.random(in: 0...0.02)
            let delay = baseDelay + randomDelay

            UIView.animate(
                withDuration: 0.6,
                delay: delay,
                usingSpringWithDamping: 0.7,
                initialSpringVelocity: 0.8,
                options: [.curveEaseOut],
                animations: {
                    block.alpha = 1
                    block.transform = .identity
                },
                completion: { _ in
                    // 블럭이 나타날 때마다 미묘한 바운스 효과
                    UIView.animate(
                        withDuration: 0.2,
                        delay: 0,
                        usingSpringWithDamping: 0.6,
                        initialSpringVelocity: 0.8
                    ) {
                        block.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
                    } completion: { _ in
                        UIView.animate(withDuration: 0.15) {
                            block.transform = .identity
                        }
                    }
                    
                    // 햅틱 피드백 (매 3번째 블럭마다)
                    if index % 3 == 0 {
                        self.impactFeedback.impactOccurred()
                    }
                    
                    // 마지막 블록일 때 레이블 애니메이션
                    if index == totalBlocks - 1 {
                        self.showLabelsAndHold()
                    }
                }
            )
        }
    }

    // MARK: - 향상된 레이블 애니메이션
    private func showLabelsAndHold() {
        guard !didAnimateCompletion else { return }
        didAnimateCompletion = true

        // 등장 전 상태 설정
        leftLabel.transform = CGAffineTransform(translationX: -60, y: 20).scaledBy(x: 0.8, y: 0.8)
        rightLabel.transform = CGAffineTransform(translationX: 60, y: 20).scaledBy(x: 0.8, y: 0.8)

        // 왼쪽 레이블 애니메이션
        UIView.animate(
            withDuration: 0.8,
            delay: 0.2,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0.8
        ) {
            self.leftLabel.alpha = 1
            self.leftLabel.transform = .identity
        }

        // 오른쪽 레이블 애니메이션 (약간 늦게)
        UIView.animate(
            withDuration: 0.8,
            delay: 0.4,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0.8
        ) {
            self.rightLabel.alpha = 1
            self.rightLabel.transform = .identity
        } completion: { _ in
            // 레이블 애니메이션 완료 후 미묘한 펄스 효과
            self.addPulseEffect()
            
            // 1.8초 후 화면 전환
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                self.route()
            }
        }
    }
    
    // MARK: - 텍스트 펄스 효과
    private func addPulseEffect() {
        UIView.animate(
            withDuration: 1.5,
            delay: 0,
            options: [.repeat, .autoreverse, .curveEaseInOut]
        ) {
            self.leftLabel.alpha = 0.7
        }
    }

    // MARK: - 기존 스플래시 분기 로직 유지
    private func route() {
        guard presentedViewController == nil else { return }

        let isFirstLaunch = !UserDefaults.standard.bool(forKey: AppConstants.UserDefaults.isFirstLaunch)
        let nextVC: UIViewController = isFirstLaunch ? OnboardingViewController() : AuthViewController()
        nextVC.modalPresentationStyle = .fullScreen
        present(nextVC, animated: true)
    }
}

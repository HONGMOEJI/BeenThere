//
//  VisitCell.swift
//  BeenThere
//
//  UICollectionViewCell을 코드로 구성하여
//  - TourSiteItem 썸네일, 제목, 거리, 날짜 표시
//  - 방문 체크(Visit) 버튼을 눌렀을 때 콜백 호출
//  BeenThere/Views/Tour/VisitCell.swift
//

import UIKit
import Kingfisher

class VisitCell: UICollectionViewCell {
    // 재사용 식별자
    static let reuseIdentifier = "VisitCell"

    // MARK: - UI 컴포넌트 정의

    private let thumbnailImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 12
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let titleLabel: UILabel = {
        let lb = UILabel()
        lb.font = .systemFont(ofSize: 16, weight: .semibold)
        lb.textColor = .label
        lb.numberOfLines = 2
        lb.translatesAutoresizingMaskIntoConstraints = false
        return lb
    }()

    private let distanceLabel: UILabel = {
        let lb = UILabel()
        lb.font = .systemFont(ofSize: 12)
        lb.textColor = .systemBlue
        lb.translatesAutoresizingMaskIntoConstraints = false
        return lb
    }()

    private let dateLabel: UILabel = {
        let lb = UILabel()
        lb.font = .systemFont(ofSize: 12)
        lb.textColor = .darkGray
        lb.translatesAutoresizingMaskIntoConstraints = false
        return lb
    }()

    private let visitButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "circle"), for: .normal)
        btn.tintColor = .gray
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    // 방문 토글 콜백
    private var toggleCallback: (() -> Void)?

    // MARK: - 초기화

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        thumbnailImageView.image = nil
        titleLabel.text = nil
        distanceLabel.text = nil
        dateLabel.text = nil
        visitButton.setImage(UIImage(systemName: "circle"), for: .normal)
        visitButton.tintColor = .gray
        toggleCallback = nil
    }

    // MARK: - 뷰 구성

    private func setupViews() {
        contentView.backgroundColor = .systemBackground
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true

        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.05
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowRadius = 4
        layer.masksToBounds = false

        // 서브뷰 추가
        contentView.addSubview(thumbnailImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(distanceLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(visitButton)

        // AutoLayout 제약
        NSLayoutConstraint.activate([
            // 1) thumbnailImageView: 상단 좌우 8pt, 높이 = (cellWidth × 2/3)
            thumbnailImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            thumbnailImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            thumbnailImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            thumbnailImageView.heightAnchor.constraint(equalTo: thumbnailImageView.widthAnchor, multiplier: 2/3),

            // 2) titleLabel: thumbnail 바로 아래, 좌우 8pt
            titleLabel.topAnchor.constraint(equalTo: thumbnailImageView.bottomAnchor, constant: 4),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),

            // 3) distanceLabel: title 아래, leading 8pt, bottom 8pt
            distanceLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            distanceLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            distanceLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

            // 4) dateLabel: title 아래, trailing 8pt, bottom 8pt
            dateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            dateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

            // 5) visitButton: cell 오른쪽 상단, 8pt 띄우기, 크기 24×24
            visitButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            visitButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            visitButton.widthAnchor.constraint(equalToConstant: 24),
            visitButton.heightAnchor.constraint(equalToConstant: 24)
        ])

        // 방문 버튼 액션 연결
        visitButton.addTarget(self, action: #selector(onVisitTapped), for: .touchUpInside)
    }

    /// 셀 데이터 바인딩 메서드
    /// - Parameters:
    ///   - site: TourSiteItem
    ///   - isVisited: Bool (이미 방문 여부)
    ///   - onToggle: (() -> Void) 방문 버튼 탭 시 호출될 클로저
    func configure(with site: TourSiteItem, isVisited: Bool, onToggle: @escaping () -> Void) {
        // 1) 이미지 로드
        if let urlString = site.firstimage2, let url = URL(string: urlString) {
            thumbnailImageView.kf.setImage(with: url, placeholder: UIImage(systemName: "photo"))
        } else {
            thumbnailImageView.image = UIImage(systemName: "photo")
        }

        // 2) 제목
        titleLabel.text = site.title

        // 3) 거리
        if let dist = site.dist {
            distanceLabel.text = String(format: "%.0fm", dist)
            distanceLabel.textColor = .systemBlue
        } else {
            distanceLabel.text = ""
        }

        // 4) 수정일 (YYYYMMDD → YYYY.MM.DD)
        if let mod = site.modifiedtime, mod.count >= 8 {
            let year = String(mod.prefix(4))
            let month = String(mod.dropFirst(4).prefix(2))
            let day = String(mod.dropFirst(6).prefix(2))
            dateLabel.text = "\(year).\(month).\(day)"
            dateLabel.textColor = .darkGray
        } else {
            dateLabel.text = ""
        }

        // 5) 방문 버튼 상태
        let imageName = isVisited ? "checkmark.circle.fill" : "circle"
        visitButton.setImage(UIImage(systemName: imageName), for: .normal)
        visitButton.tintColor = isVisited ? .systemGreen : .gray

        // 6) 콜백 저장
        toggleCallback = onToggle
    }

    @objc private func onVisitTapped() {
        toggleCallback?()
    }
}

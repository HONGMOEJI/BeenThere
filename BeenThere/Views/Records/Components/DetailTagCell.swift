//
//  DetailTagCell.swift
//  BeenThere
//
//  기록 상세보기용 태그 셀
//

import UIKit

class DetailTagCell: UICollectionViewCell {
    static let identifier = "DetailTagCell"
    
    // MARK: - UI Components
    private let containerView = UIView()
    private let tagLabel = UILabel()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        tagLabel.text = nil
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        contentView.backgroundColor = .clear
        
        // 컨테이너 뷰
        containerView.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        containerView.layer.cornerRadius = 18
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
        containerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(containerView)
        
        // 태그 레이블
        tagLabel.font = .systemFont(ofSize: 14, weight: .medium)
        tagLabel.textColor = .themeTextPrimary
        tagLabel.textAlignment = .center
        tagLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(tagLabel)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 36),
            
            tagLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            tagLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            tagLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            tagLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8)
        ])
    }
    
    // MARK: - Configure
    func configure(with tag: String) {
        tagLabel.text = "#\(tag)"
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let attributes = super.preferredLayoutAttributesFitting(layoutAttributes)
        
        // 태그 텍스트 크기에 맞게 셀 크기 조정
        let targetSize = CGSize(width: CGFloat.greatestFiniteMagnitude, height: 36)
        let size = contentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: .fittingSizeLevel, verticalFittingPriority: .required)
        
        attributes.frame.size = CGSize(width: max(size.width, 60), height: 36)
        return attributes
    }
}

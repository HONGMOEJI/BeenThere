//
//  TagCell.swift
//  BeenThere
//
//  태그 컬렉션뷰 셀
//

import UIKit

class TagCell: UICollectionViewCell {
    private let tagLabel = UILabel()
    private let deleteButton = UIButton(type: .system)
    private let containerView = UIView()
    
    var onDelete: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        // 컨테이너 뷰 설정
        containerView.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        containerView.layer.cornerRadius = 18
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        // 태그 레이블 설정
        tagLabel.font = .bodySmall
        tagLabel.textColor = .themeTextSecondary
        tagLabel.textAlignment = .center
        tagLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // 삭제 버튼 설정
        deleteButton.setImage(UIImage(systemName: "xmark", withConfiguration: UIImage.SymbolConfiguration(pointSize: 10, weight: .medium)), for: .normal)
        deleteButton.tintColor = .themeTextSecondary
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        
        contentView.addSubview(containerView)
        containerView.addSubview(tagLabel)
        containerView.addSubview(deleteButton)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 36),
            
            tagLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            tagLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            deleteButton.leadingAnchor.constraint(equalTo: tagLabel.trailingAnchor, constant: 8),
            deleteButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            deleteButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            deleteButton.widthAnchor.constraint(equalToConstant: 16),
            deleteButton.heightAnchor.constraint(equalToConstant: 16)
        ])
    }
    
    func configure(with tag: String) {
        tagLabel.text = "#\(tag)"
        
        // 내용에 따라 셀 크기 조정
        let labelWidth = tagLabel.intrinsicContentSize.width
        let totalWidth = labelWidth + 48 // padding + delete button
        
        NSLayoutConstraint.activate([
            containerView.widthAnchor.constraint(equalToConstant: max(totalWidth, 80))
        ])
    }
    
    @objc private func deleteButtonTapped() {
        onDelete?()
    }
}

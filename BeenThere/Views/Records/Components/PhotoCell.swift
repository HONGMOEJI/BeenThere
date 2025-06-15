//
//  PhotoCell.swift
//  BeenThere
//
//  기록 작성용 사진 셀
//

import UIKit
import Kingfisher

class PhotoCell: UICollectionViewCell {
    static let identifier = "PhotoCell"
    
    // MARK: - UI Components
    private let imageView = UIImageView()
    private let deleteButton = UIButton(type: .system)
    private let loadingIndicator = UIActivityIndicatorView(style: .medium)
    
    // MARK: - Properties
    var onDelete: (() -> Void)?
    
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
        imageView.image = nil
        imageView.kf.cancelDownloadTask()
        loadingIndicator.stopAnimating()
        onDelete = nil
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        contentView.backgroundColor = UIColor.white.withAlphaComponent(0.05)
        contentView.layer.cornerRadius = 12
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.white.withAlphaComponent(0.1).cgColor
        contentView.clipsToBounds = true
        
        // 이미지뷰
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageView)
        
        // 로딩 인디케이터
        loadingIndicator.color = .themeTextSecondary
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(loadingIndicator)
        
        // 삭제 버튼
        deleteButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        deleteButton.tintColor = .systemRed
        deleteButton.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        deleteButton.layer.cornerRadius = 12
        deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(deleteButton)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            deleteButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            deleteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            deleteButton.widthAnchor.constraint(equalToConstant: 24),
            deleteButton.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    // MARK: - Configure
    func configure(with imageType: ImageType) {
        switch imageType {
        case .existing(let url):
            configureWithURL(url)
        case .new(let image):
            configureWithImage(image)
        }
    }
    
    private func configureWithURL(_ urlString: String) {
        guard let url = URL(string: urlString) else {
            imageView.image = createPlaceholderImage()
            return
        }
        
        loadingIndicator.startAnimating()
        
        imageView.kf.setImage(
            with: url,
            placeholder: createPlaceholderImage(),
            options: [
                .processor(DownsamplingImageProcessor(size: CGSize(width: 240, height: 240))),
                .transition(.fade(0.3)),
                .cacheOriginalImage,
                .scaleFactor(UIScreen.main.scale)
            ]
        ) { [weak self] result in
            DispatchQueue.main.async {
                self?.loadingIndicator.stopAnimating()
                
                switch result {
                case .success(_):
                    break
                case .failure(_):
                    self?.imageView.image = self?.createPlaceholderImage()
                }
            }
        }
    }
    
    private func configureWithImage(_ image: UIImage) {
        imageView.image = image
    }
    
    private func createPlaceholderImage() -> UIImage? {
        let size = CGSize(width: 120, height: 120)
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        let context = UIGraphicsGetCurrentContext()
        
        // 그라데이션 배경
        let colors = [
            UIColor.white.withAlphaComponent(0.05).cgColor,
            UIColor.white.withAlphaComponent(0.02).cgColor
        ]
        let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                  colors: colors as CFArray,
                                  locations: nil)
        context?.drawLinearGradient(gradient!,
                                   start: CGPoint(x: 0, y: 0),
                                   end: CGPoint(x: size.width, y: size.height),
                                   options: [])
        
        // 아이콘 추가
        let icon = UIImage(systemName: "photo.fill")?.withTintColor(.themeTextPlaceholder, renderingMode: .alwaysOriginal)
        let iconSize = CGSize(width: 24, height: 24)
        let iconRect = CGRect(x: (size.width - iconSize.width) / 2,
                             y: (size.height - iconSize.height) / 2,
                             width: iconSize.width,
                             height: iconSize.height)
        icon?.draw(in: iconRect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    // MARK: - Actions
    @objc private func deleteTapped() {
        onDelete?()
    }
}

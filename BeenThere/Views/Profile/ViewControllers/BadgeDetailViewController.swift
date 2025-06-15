//
//  BadgeDetailViewController.swift
//  BeenThere
//
//  배지 상세 정보 화면
//

import UIKit

class BadgeDetailViewController: UIViewController {
    private let badge: ProfileViewModel.Badge
    private let badgeDetailView = BadgeDetailView()
    
    init(badge: ProfileViewModel.Badge) {
        self.badge = badge
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = badgeDetailView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureBadgeInfo()
        
        // 네비게이션 타이틀과 버튼을 흰색으로
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.white
        ]
        navigationController?.navigationBar.tintColor = .white
    }
    
    private func setupUI() {
        title = "배지 정보"
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(closeTapped)
        )
    }
    
    private func configureBadgeInfo() {
        badgeDetailView.configure(with: badge)
    }
    
    @objc private func closeTapped() {
        dismiss(animated: true)
    }
}

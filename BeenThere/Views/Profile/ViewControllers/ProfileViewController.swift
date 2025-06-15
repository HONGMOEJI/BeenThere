//
//  ProfileViewController.swift
//  BeenThere
//
//  내정보 뷰컨트롤러
//

import UIKit
import Combine

class ProfileViewController: UIViewController {
    private let viewModel = ProfileViewModel()
    private let profileView = ProfileView()
    private var cancellables = Set<AnyCancellable>()
    
    override func loadView() {
        view = profileView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBindings()
        setupActions()
        setupCollectionView()
        setupNotificationObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        viewModel.loadTravelStatistics()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    // MARK: - Notification Setup
    private func setupNotificationObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleUserSignOut),
            name: NSNotification.Name("UserDidSignOut"),
            object: nil
        )
    }
    
    @objc private func handleUserSignOut() {
        // 로그인 화면으로 전환
        DispatchQueue.main.async {
            self.navigateToLoginScreen()
        }
    }
    
    private func navigateToLoginScreen() {
        // SceneDelegate에서 window의 rootViewController를 변경하는 방식
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else { return }
        
        // 로그인 뷰컨트롤러로 전환 (실제 로그인 VC 클래스명으로 변경)
        let loginVC = AuthViewController() // 실제 로그인 VC로 변경하세요
        let navigationController = UINavigationController(rootViewController: loginVC)
        
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        
        // 부드러운 전환 애니메이션
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupBindings() {
        // 프로필 정보 바인딩
        Publishers.CombineLatest4(
            viewModel.$displayName,
            viewModel.$userEmail,
            viewModel.$joinDate,
            viewModel.$profileImage
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] name, email, joinDate, profileImage in
            self?.profileView.updateProfile(
                name: name,
                email: email,
                joinDate: joinDate,
                profileImage: profileImage
            )
        }
        .store(in: &cancellables)
        
        // 통계 정보 바인딩
        Publishers.CombineLatest4(
            viewModel.$totalRecords,
            viewModel.$totalPlaces,
            viewModel.$thisYearRecords,
            viewModel.$firstRecordDate
        )
        .combineLatest(viewModel.$favoriteLocation)
        .receive(on: DispatchQueue.main)
        .sink { [weak self] statsData, favoriteLocation in
            let (totalRecords, totalPlaces, thisYear, firstDate) = statsData
            self?.profileView.updateStatistics(
                totalRecords: totalRecords,
                totalPlaces: totalPlaces,
                thisYearRecords: thisYear,
                firstRecordDate: firstDate,
                favoriteLocation: favoriteLocation
            )
        }
        .store(in: &cancellables)
        
        // 배지 정보 바인딩
        viewModel.$earnedBadges
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.profileView.badgesCollectionView.reloadData()
            }
            .store(in: &cancellables)
        
        // 로딩 상태 바인딩
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                self?.profileView.showLoading(isLoading)
            }
            .store(in: &cancellables)
        
        // 에러 처리
        viewModel.$showError
            .receive(on: DispatchQueue.main)
            .sink { [weak self] showError in
                if showError {
                    self?.showErrorAlert()
                }
            }
            .store(in: &cancellables)
    }
    
    private func setupActions() {
        profileView.refreshButton.addTarget(self, action: #selector(refreshTapped), for: .touchUpInside)
        profileView.logoutButton.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)
        profileView.deleteAccountButton.addTarget(self, action: #selector(deleteAccountTapped), for: .touchUpInside)
    }
    
    private func setupCollectionView() {
        profileView.badgesCollectionView.dataSource = self
        profileView.badgesCollectionView.delegate = self
        profileView.badgesCollectionView.register(BadgeCell.self, forCellWithReuseIdentifier: BadgeCell.identifier)
    }
    
    @objc private func refreshTapped() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        viewModel.loadTravelStatistics()
    }
    
    @objc private func logoutTapped() {
        let alert = UIAlertController(
            title: "로그아웃",
            message: "정말 로그아웃하시겠습니까?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "로그아웃", style: .destructive) { [weak self] _ in
            self?.viewModel.signOut()
        })
        
        present(alert, animated: true)
    }
    
    @objc private func deleteAccountTapped() {
        let alert = UIAlertController(
            title: "계정 삭제",
            message: "계정을 삭제하면 모든 데이터가 영구적으로 삭제됩니다.\n정말 계정을 삭제하시겠습니까?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "삭제", style: .destructive) { [weak self] _ in
            self?.viewModel.deleteAccount()
        })
        
        present(alert, animated: true)
    }
    
    private func showErrorAlert() {
        let alert = UIAlertController(
            title: "오류",
            message: viewModel.errorMessage,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - Collection View DataSource & Delegate
extension ProfileViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.earnedBadges.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BadgeCell.identifier, for: indexPath) as! BadgeCell
        cell.configure(with: viewModel.earnedBadges[indexPath.item])
        return cell
    }
    
    // 배지 터치 시 상세보기 표시
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let badge = viewModel.earnedBadges[indexPath.item]
        let badgeDetailVC = BadgeDetailViewController(badge: badge)
        let navigationController = UINavigationController(rootViewController: badgeDetailVC)
        present(navigationController, animated: true)
    }
}

extension ProfileViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 80, height: 100)
    }
}

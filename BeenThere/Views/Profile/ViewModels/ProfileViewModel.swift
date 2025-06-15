//
//  ProfileViewModel.swift
//  BeenThere
//
//  내정보 뷰모델
//

import Foundation
import UIKit
import Combine
import FirebaseAuth
import FirebaseFirestore

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var userEmail: String = ""
    @Published var displayName: String = ""
    @Published var joinDate: String = ""
    @Published var profileImage: UIImage?
    
    // 여행 통계
    @Published var totalRecords: Int = 0
    @Published var totalPlaces: Int = 0
    @Published var firstRecordDate: String = ""
    @Published var favoriteLocation: String = ""
    @Published var thisYearRecords: Int = 0
    
    // 배지 관련
    @Published var earnedBadges: [Badge] = []
    
    // 상태
    @Published var isLoading: Bool = false
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""
    @Published var isUploadingProfileImage: Bool = false
    
    private let firestoreService = FirestoreService.shared
    private var cancellables = Set<AnyCancellable>()
    
    struct Badge {
        let id: String
        let title: String
        let description: String
        let icon: String
        let isEarned: Bool
        let requiredCount: Int
        let currentCount: Int
    }
    
    init() {
        loadUserProfile()
        loadTravelStatistics()
    }
    
    func loadUserProfile() {
        guard let user = Auth.auth().currentUser else { return }
        
        userEmail = user.email ?? ""
        displayName = user.displayName ?? "여행자"
        
        // 가입일 계산
        if let creationDate = user.metadata.creationDate {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "ko_KR")
            formatter.dateFormat = "yyyy년 M월 d일"
            joinDate = formatter.string(from: creationDate)
        }
        
        // 프로필 이미지가 있다면 로드
        if let photoURL = user.photoURL {
            loadProfileImage(from: photoURL)
        }
    }
    
    private func loadProfileImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self?.profileImage = image
                }
            }
        }.resume()
    }
    
    // MARK: - 프로필 이미지 업로드
    func updateProfileImage(_ image: UIImage) {
        guard let user = Auth.auth().currentUser else {
            showErrorMessage("로그인이 필요합니다.")
            return
        }
        
        isUploadingProfileImage = true
        
        Task {
            do {
                // 1. FirestoreService를 통해 이미지 업로드
                let imageUrl = try await firestoreService.uploadProfileImage(userId: user.uid, image: image)
                
                // 2. Firebase Auth 프로필 업데이트
                let changeRequest = user.createProfileChangeRequest()
                changeRequest.photoURL = URL(string: imageUrl)
                try await changeRequest.commitChanges()
                
                // 3. UI 업데이트
                await MainActor.run {
                    self.profileImage = image
                    self.isUploadingProfileImage = false
                }
                
            } catch {
                await MainActor.run {
                    self.showErrorMessage("프로필 사진 업로드에 실패했습니다.")
                    self.isUploadingProfileImage = false
                }
            }
        }
    }
    
    // MARK: - 프로필 이미지 삭제
    func deleteProfileImage() {
        guard let user = Auth.auth().currentUser else {
            showErrorMessage("로그인이 필요합니다.")
            return
        }
        
        isUploadingProfileImage = true
        
        Task {
            do {
                // 1. FirestoreService를 통해 이미지 삭제
                try await firestoreService.deleteProfileImage(userId: user.uid)
                
                // 2. Firebase Auth 프로필 업데이트
                let changeRequest = user.createProfileChangeRequest()
                changeRequest.photoURL = nil
                try await changeRequest.commitChanges()
                
                // 3. UI 업데이트
                await MainActor.run {
                    self.profileImage = nil
                    self.isUploadingProfileImage = false
                }
                
            } catch {
                await MainActor.run {
                    self.showErrorMessage("프로필 사진 삭제에 실패했습니다.")
                    self.isUploadingProfileImage = false
                }
            }
        }
    }
    
    func loadTravelStatistics() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        isLoading = true
        
        Task {
            do {
                // 전체 기록 수
                let allRecords = try await firestoreService.fetchAllRecords(userId: userId)
                
                // 올해 기록 수
                let calendar = Calendar.current
                let currentYear = calendar.component(.year, from: Date())
                let thisYearCount = allRecords.filter { record in
                    calendar.component(.year, from: record.visitedAt) == currentYear
                }.count
                
                // 첫 번째 기록 날짜
                let firstRecord = allRecords.min { $0.visitedAt < $1.visitedAt }
                let firstDateString: String
                if let firstRecord = firstRecord {
                    let formatter = DateFormatter()
                    formatter.locale = Locale(identifier: "ko_KR")
                    formatter.dateFormat = "yyyy년 M월 d일"
                    firstDateString = formatter.string(from: firstRecord.visitedAt)
                } else {
                    firstDateString = "기록 없음"
                }
                
                // 가장 많이 방문한 지역 (간단하게 주소에서 시/도 추출)
                let locationCounts = Dictionary(grouping: allRecords) { record in
                    extractCity(from: record.placeAddress)
                }.mapValues { $0.count }
                
                let favoriteCity = locationCounts.max { $0.value < $1.value }?.key ?? "기록 없음"
                
                // 고유한 장소 수 (contentId 기준으로 중복 제거)
                let uniquePlaces = Set(allRecords.map { $0.contentId })
                
                await MainActor.run {
                    self.totalRecords = allRecords.count
                    self.totalPlaces = uniquePlaces.count
                    self.thisYearRecords = thisYearCount
                    self.firstRecordDate = firstDateString
                    self.favoriteLocation = favoriteCity
                    self.earnedBadges = calculateBadges(recordCount: allRecords.count, placeCount: uniquePlaces.count)
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.showErrorMessage("통계를 불러오는데 실패했습니다.")
                    self.isLoading = false
                }
            }
        }
    }
    
    private func extractCity(from address: String) -> String {
        let components = address.split(separator: " ")
        for component in components {
            let str = String(component)
            if str.hasSuffix("시") || str.hasSuffix("도") || str.hasSuffix("구") {
                return str
            }
        }
        return "기타"
    }
    
    private func calculateBadges(recordCount: Int, placeCount: Int) -> [Badge] {
        let badgeConfigs = [
            ("first_record", "첫 기록", "첫 여행 기록을 작성했어요", "📝", 1),
            ("explorer_10", "탐험가", "10곳을 방문했어요", "🗺️", 10),
            ("adventurer_50", "모험가", "50곳을 방문했어요", "🎒", 50),
            ("master_100", "여행 마스터", "100곳을 방문했어요", "🏆", 100),
            ("record_keeper", "기록왕", "50개의 기록을 작성했어요", "📚", 50)
        ]
        
        return badgeConfigs.map { (id, title, description, icon, required) in
            let currentCount = id.contains("record") ? recordCount : placeCount
            return Badge(
                id: id,
                title: title,
                description: description,
                icon: icon,
                isEarned: currentCount >= required,
                requiredCount: required,
                currentCount: currentCount
            )
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            // 로그아웃 성공 시 로그인 화면으로 이동하는 노티피케이션 발송
            NotificationCenter.default.post(name: NSNotification.Name("UserDidSignOut"), object: nil)
        } catch {
            showErrorMessage("로그아웃에 실패했습니다.")
        }
    }
    
    func deleteAccount() {
        guard let user = Auth.auth().currentUser else { return }
        
        Task {
            do {
                // Firestore의 사용자 데이터 삭제 (프로필 이미지 포함)
                try await firestoreService.deleteAllUserData(userId: user.uid)
                
                // Firebase Auth 계정 삭제
                try await user.delete()
                
                await MainActor.run {
                    NotificationCenter.default.post(name: NSNotification.Name("UserDidSignOut"), object: nil)
                }
            } catch {
                await MainActor.run {
                    self.showErrorMessage("계정 삭제에 실패했습니다. 다시 로그인 후 시도해주세요.")
                }
            }
        }
    }
}

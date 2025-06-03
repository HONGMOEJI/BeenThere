//
//  RecordViewModel.swift
//  BeenThere
//
//  방문 기록 뷰모델 (편집 모드에서 기존 이미지 유지)
//

import Foundation
import UIKit
import Combine
import FirebaseAuth

enum RecordMode {
    case create
    case edit
}

// 이미지 타입 구분
enum ImageType {
    case existing(url: String)  // 기존 이미지 (URL)
    case new(image: UIImage)    // 새로 추가된 이미지
}

@MainActor
class RecordViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var placeTitle: String = ""
    @Published var placeAddress: String = ""
    @Published var visitDate: Date = Date()
    @Published var rating: Int = 5
    @Published var content: String = ""
    @Published var imageItems: [ImageType] = []  // 기존 + 새 이미지 통합 관리
    @Published var selectedWeather: WeatherType? = nil
    @Published var selectedMood: MoodType? = nil
    @Published var tags: [String] = []
    @Published var newTag: String = ""
    
    // UI State
    @Published var isLoading: Bool = false
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""
    @Published var isSaveEnabled: Bool = false
    @Published var showSuccessAlert: Bool = false
    
    // MARK: - Private Properties
    let contentId: String
    private let firestoreService = FirestoreService.shared
    private var cancellables = Set<AnyCancellable>()
    private let mode: RecordMode
    private let originalRecord: VisitRecord?
    private var savedRecord: VisitRecord?
    
    // MARK: - Computed Properties
    var canSave: Bool {
        !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && rating > 0
    }
    
    // UI에서 사용할 이미지들 (표시용)
    var displayImages: [UIImage] {
        var images: [UIImage] = []
        for item in imageItems {
            switch item {
            case .existing(_):
                // 기존 이미지의 경우 placeholder 또는 캐시된 이미지 사용
                if let placeholderImage = createPlaceholderImage() {
                    images.append(placeholderImage)
                }
            case .new(let image):
                images.append(image)
            }
        }
        return images
    }
    
    // 새로 추가된 이미지들만
    var newImages: [UIImage] {
        return imageItems.compactMap { item in
            if case .new(let image) = item {
                return image
            }
            return nil
        }
    }
    
    // 기존 이미지 URL들
    var existingImageUrls: [String] {
        return imageItems.compactMap { item in
            if case .existing(let url) = item {
                return url
            }
            return nil
        }
    }
    
    // MARK: - Init
    convenience init(tourSite: TourSiteDetail) {
        self.init(
            contentId: tourSite.contentid ?? "",
            placeTitle: tourSite.title ?? "알 수 없는 장소",
            placeAddress: tourSite.fullAddress ?? "",
            mode: .create,
            originalRecord: nil
        )
    }
    
    convenience init(record: VisitRecord) {
        self.init(
            contentId: record.contentId,
            placeTitle: record.placeTitle,
            placeAddress: record.placeAddress,
            mode: .edit,
            originalRecord: record
        )
        
        // 기존 데이터로 초기화
        self.visitDate = record.visitedAt
        self.rating = record.rating
        self.content = record.content
        self.selectedWeather = record.weather
        self.selectedMood = record.mood
        self.tags = record.tags
        
        // 기존 이미지들을 imageItems에 추가
        self.imageItems = record.imageUrls.map { ImageType.existing(url: $0) }
    }
    
    private init(contentId: String, placeTitle: String, placeAddress: String, mode: RecordMode, originalRecord: VisitRecord?) {
        self.contentId = contentId
        self.placeTitle = placeTitle
        self.placeAddress = placeAddress
        self.mode = mode
        self.originalRecord = originalRecord
        
        setupBindings()
    }
    
    // MARK: - Private Methods
    private func setupBindings() {
        Publishers.CombineLatest($content, $rating)
            .map { content, rating in
                !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && rating > 0
            }
            .assign(to: &$isSaveEnabled)
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
    
    // MARK: - Image Management
    func addImage(_ image: UIImage) {
        guard imageItems.count < 10 else {
            showErrorMessage("최대 10장까지 선택할 수 있습니다.")
            return
        }
        imageItems.append(.new(image: image))
    }
    
    func removeImage(at index: Int) {
        guard index < imageItems.count else { return }
        imageItems.remove(at: index)
    }
    
    func moveImage(from source: IndexSet, to destination: Int) {
        imageItems.move(fromOffsets: source, toOffset: destination)
    }
    
    // MARK: - Tag Management
    func addTag() {
        let trimmedTag = newTag.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTag.isEmpty, !tags.contains(trimmedTag), tags.count < 10 else {
            if tags.count >= 10 {
                showErrorMessage("최대 10개까지 태그를 추가할 수 있습니다.")
            }
            return
        }
        tags.append(trimmedTag)
        newTag = ""
    }
    
    func removeTag(_ tag: String) {
        tags.removeAll { $0 == tag }
    }
    
    // MARK: - Save Record
    func getUpdatedRecord() -> VisitRecord? {
        print("📊 [VM] getUpdatedRecord 호출됨")
        if let saved = savedRecord {
            print("📊 [VM] 저장된 기록 반환: \(saved.placeTitle)")
            return saved
        } else {
            print("❌ [VM] 저장된 기록이 없음, 현재 데이터로 생성")
            
            // VisitRecord의 실제 생성자에 맞춰서 수정
            return VisitRecord(
                contentId: contentId,
                placeTitle: placeTitle,
                placeAddress: placeAddress,
                visitedAt: visitDate,
                rating: rating,
                content: content,
                imageUrls: existingImageUrls,
                weather: selectedWeather,
                mood: selectedMood,
                tags: tags
            )
        }
    }

    // saveRecord에서도 동일하게 수정
    func saveRecord() async {
        print("💾 [VM] saveRecord 시작")
        
        guard canSave else {
            showErrorMessage("필수 정보를 입력해주세요.")
            return
        }
        
        guard let userId = Auth.auth().currentUser?.uid else {
            showErrorMessage("로그인이 필요합니다.")
            return
        }
        
        isLoading = true
        
        do {
            let record = VisitRecord(
                contentId: contentId,
                placeTitle: placeTitle,
                placeAddress: placeAddress,
                visitedAt: visitDate,
                rating: rating,
                content: content,
                imageUrls: existingImageUrls,
                weather: selectedWeather,
                mood: selectedMood,
                tags: tags
            )
            
            print("💾 [VM] 저장할 기록: \(record.placeTitle)")
            
            switch mode {
            case .create:
                try await firestoreService.addVisitRecord(
                    userId: userId,
                    record: record,
                    images: newImages
                )
                
            case .edit:
                guard let originalRecord = originalRecord else {
                    throw NSError(domain: "RecordViewModel", code: -1, userInfo: [NSLocalizedDescriptionKey: "원본 기록을 찾을 수 없습니다."])
                }
                
                try await firestoreService.updateVisitRecord(
                    userId: userId,
                    originalRecord: originalRecord,
                    updatedRecord: record,
                    newImages: newImages
                )
            }
            
            // 저장 성공 후 현재 데이터로 기록 생성 (업데이트된 시간 반영을 위해)
            var savedRecordCopy = record
            savedRecordCopy.updatedAt = Date()
            
            // 편집 모드의 경우 기존 id 유지
            if let originalId = originalRecord?.id {
                savedRecordCopy.id = originalId
            }
            
            self.savedRecord = savedRecordCopy
            
            print("💾 [VM] 저장 완료, savedRecord 설정됨")
            showSuccessAlert = true
            
        } catch {
            print("❌ [VM] 저장 실패: \(error)")
            showErrorMessage("기록 저장에 실패했습니다: \(error.localizedDescription)")
        }
        
        isLoading = false
    }

    // 모든 이미지 URL 반환 (기존 + 새로 저장된)
    private func getAllImageUrls() -> [String] {
        // 실제로는 FirestoreService에서 반환된 최종 기록의 imageUrls를 사용해야 함
        // 임시로 기존 URL만 반환
        return existingImageUrls
    }
    
    // MARK: - Error Handling
    private func showErrorMessage(_ message: String) {
        errorMessage = message
        showError = true
    }
}

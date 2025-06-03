import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import UIKit

/// FirestoreService: users/{uid}/visitRecords/{contentId}_{YYYYMMDD_HHmmss} 경로로 방문 기록 CRUD 및 이미지 업로드 제공
final class FirestoreService {
    static let shared = FirestoreService()
    private init() {}

    private let db = Firestore.firestore()
    private let storage = Storage.storage()

    // MARK: - 날짜 포매터
    private func createDateFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd_HHmmss"
        formatter.timeZone = TimeZone.current
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }

    // MARK: - Visit Record CRUD

    /// 방문 기록 추가 (새로운 단순 구조)
    func addVisitRecord(userId: String, record: VisitRecord, images: [UIImage] = []) async throws {
        print("💾 기록 저장 시작 - contentId: \(record.contentId), title: \(record.placeTitle)")
        
        // 1. 이미지 업로드
        var imageUrls: [String] = []
        if !images.isEmpty {
            imageUrls = try await uploadImages(userId: userId, contentId: record.contentId, images: images)
        }
        
        // 2. 기록 데이터 구성
        var updatedRecord = record
        updatedRecord.imageUrls = imageUrls
        updatedRecord.updatedAt = Date()

        // 3. 고유한 visitId 생성: {contentId}_{날짜시간}
        let dateFormatter = createDateFormatter()
        let visitDateTimeKey = dateFormatter.string(from: record.visitedAt)
        let visitId = "\(record.contentId)_\(visitDateTimeKey)"
        
        print("📅 저장 경로: users/\(userId)/visitRecords/\(visitId)")

        // 4. 단순 구조로 Firestore 저장: users/{uid}/visitRecords/{visitId}
        let recordRef = db
            .collection("users")
            .document(userId)
            .collection("visitRecords")
            .document(visitId)

        try await recordRef.setData(from: updatedRecord, merge: true)
        print("✅ 기록 저장 완료")
    }

    /// 방문 기록 수정
    func updateVisitRecord(userId: String, originalRecord: VisitRecord, updatedRecord: VisitRecord, newImages: [UIImage] = []) async throws {
        print("🔄 기록 수정 시작 - contentId: \(originalRecord.contentId), title: \(originalRecord.placeTitle)")
        
        // 1. 원본 기록의 document ID 생성
        let dateFormatter = createDateFormatter()
        let visitDateTimeKey = dateFormatter.string(from: originalRecord.visitedAt)
        let originalVisitId = "\(originalRecord.contentId)_\(visitDateTimeKey)"
        
        // 2. 새로운 이미지 업로드
        var imageUrls: [String] = updatedRecord.imageUrls // 기존 이미지 URL 유지
        if !newImages.isEmpty {
            let newImageUrls = try await uploadImages(userId: userId, contentId: updatedRecord.contentId, images: newImages)
            imageUrls.append(contentsOf: newImageUrls)
        }
        
        // 3. 수정된 기록 데이터 구성
        var finalRecord = updatedRecord
        finalRecord.imageUrls = imageUrls
        finalRecord.updatedAt = Date()
        
        // 4. 방문 날짜가 변경된 경우 새로운 document ID 생성
        let newVisitDateTimeKey = dateFormatter.string(from: updatedRecord.visitedAt)
        let newVisitId = "\(updatedRecord.contentId)_\(newVisitDateTimeKey)"
        
        let recordsRef = db
            .collection("users")
            .document(userId)
            .collection("visitRecords")
        
        if originalVisitId != newVisitId {
            // 방문 날짜가 변경된 경우: 기존 문서 삭제 후 새 문서 생성
            print("📅 방문 날짜 변경됨 - 기존: \(originalVisitId) → 새로운: \(newVisitId)")
            
            // 새 문서 생성
            try await recordsRef.document(newVisitId).setData(from: finalRecord)
            
            // 기존 문서 삭제
            try await recordsRef.document(originalVisitId).delete()
            
            print("✅ 기록 이동 완료: \(originalVisitId) → \(newVisitId)")
        } else {
            // 방문 날짜가 동일한 경우: 기존 문서 업데이트
            print("📅 기존 문서 업데이트: \(originalVisitId)")
            try await recordsRef.document(originalVisitId).setData(from: finalRecord, merge: true)
            print("✅ 기록 수정 완료")
        }
    }

    /// 방문 기록 삭제
    func deleteVisitRecord(userId: String, visitedAt: Date, contentId: String) async throws {
        let dateFormatter = createDateFormatter()
        let visitDateTimeKey = dateFormatter.string(from: visitedAt)
        let visitId = "\(contentId)_\(visitDateTimeKey)"

        let recordRef = db
            .collection("users")
            .document(userId)
            .collection("visitRecords")
            .document(visitId)

        let document = try await recordRef.getDocument()
        if let record = try? document.data(as: VisitRecord.self), !record.imageUrls.isEmpty {
            try await deleteImages(record.imageUrls)
        }
        try await recordRef.delete()
        print("✅ 기록 삭제 완료: \(visitId)")
    }

    /// 특정 장소의 방문 기록 조회 (여러 방문 기록 지원!)
    func fetchVisitHistory(userId: String, contentId: String) async throws -> (records: [VisitRecord], count: Int) {
        print("🔍 fetchVisitHistory 시작 - userId: \(userId), contentId: \(contentId)")
        
        let visitRecordsRef = db
            .collection("users")
            .document(userId)
            .collection("visitRecords")
        
        // contentId로 필터링해서 해당 장소의 모든 방문 기록 조회
        let snapshot = try await visitRecordsRef
            .whereField("contentId", isEqualTo: contentId)
            .order(by: "visitedAt", descending: true) // 최신순 정렬
            .getDocuments()
        
        print("📊 방문 기록 개수: \(snapshot.documents.count)")
        
        var records: [VisitRecord] = []
        
        for doc in snapshot.documents {
            do {
                var record = try doc.data(as: VisitRecord.self)
                record.id = doc.documentID
                records.append(record)
                print("✅ 기록 추가: \(record.placeTitle) - \(record.visitedAt)")
            } catch {
                print("❌ 기록 파싱 실패: \(error)")
            }
        }
        
        print("📊 최종 결과 - 총 \(records.count)개 기록")
        return (records: records, count: records.count)
    }

    /// 방문 횟수만 조회 (매우 빠름!)
    func fetchVisitCount(userId: String, contentId: String) async throws -> Int {
        let visitRecordsRef = db
            .collection("users")
            .document(userId)
            .collection("visitRecords")
        
        let snapshot = try await visitRecordsRef
            .whereField("contentId", isEqualTo: contentId)
            .getDocuments()
        
        print("📊 장소 \(contentId) 방문 횟수: \(snapshot.documents.count)")
        return snapshot.documents.count
    }

    /// 타임라인(모든 장소의 최근 방문 기록) 조회
    func fetchTimelineRecords(userId: String, limit: Int = 30) async throws -> [VisitRecord] {
        print("🔍 타임라인 조회 시작")
        
        let visitRecordsRef = db
            .collection("users")
            .document(userId)
            .collection("visitRecords")
        
        let snapshot = try await visitRecordsRef
            .order(by: "visitedAt", descending: true) // 최신순
            .limit(to: limit) // 제한
            .getDocuments()
        
        var records: [VisitRecord] = []
        
        for doc in snapshot.documents {
            do {
                var record = try doc.data(as: VisitRecord.self)
                record.id = doc.documentID
                records.append(record)
            } catch {
                print("❌ 기록 파싱 실패: \(error)")
            }
        }
        
        print("📊 타임라인 결과: \(records.count)개 기록")
        return records
    }

    /// 특정 날짜에 방문한 모든 장소 조회 (매우 효율적!)
    func fetchRecordsForDate(userId: String, date: Date) async throws -> [VisitRecord] {
        // 한국 시간대 설정
        let koreaTimeZone = TimeZone(identifier: "Asia/Seoul")!
        var calendar = Calendar.current
        calendar.timeZone = koreaTimeZone
        
        // 선택된 날짜의 한국 시간 기준 00:00:00 ~ 23:59:59
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        // 디버깅용 포맷터 (한국 시간)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = koreaTimeZone
        
        print("🔍 날짜별 기록 조회 시작 (새로운 단순 구조)")
        print("  - 사용자 ID: \(userId)")
        print("  - 대상 날짜: \(formatter.string(from: date))")
        print("  - 범위 시작: \(formatter.string(from: startOfDay))")
        print("  - 범위 종료: \(formatter.string(from: endOfDay))")
        
        let visitRecordsRef = db
            .collection("users")
            .document(userId)
            .collection("visitRecords")
        
        // Firestore 쿼리로 날짜 범위 필터링 (매우 효율적!)
        let snapshot = try await visitRecordsRef
            .whereField("visitedAt", isGreaterThanOrEqualTo: startOfDay)
            .whereField("visitedAt", isLessThan: endOfDay)
            .order(by: "visitedAt", descending: true) // 최신순 정렬
            .getDocuments()
        
        print("📊 쿼리 결과: \(snapshot.documents.count)개 기록")
        
        var records: [VisitRecord] = []
        
        for doc in snapshot.documents {
            do {
                var record = try doc.data(as: VisitRecord.self)
                record.id = doc.documentID
                records.append(record)
                
                print("✅ 기록 추가: \(record.placeTitle) - \(formatter.string(from: record.visitedAt))")
            } catch {
                print("❌ 기록 파싱 실패: \(error)")
            }
        }
        
        print("📊 최종 결과: \(records.count)개 기록")
        return records
    }

    /// 🆕 모든 방문 장소 목록 (중복 제거, 방문 횟수 포함)
    func fetchUniqueVisitedPlaces(userId: String) async throws -> [PlaceSummary] {
        print("🏠 모든 방문 장소 목록 조회 시작")
        
        let visitRecordsRef = db
            .collection("users")
            .document(userId)
            .collection("visitRecords")
        
        let snapshot = try await visitRecordsRef
            .order(by: "visitedAt", descending: true)
            .getDocuments()
        
        // contentId별로 그룹화
        var placeGroups: [String: [VisitRecord]] = [:]
        
        for doc in snapshot.documents {
            if let record = try? doc.data(as: VisitRecord.self) {
                var updatedRecord = record
                updatedRecord.id = doc.documentID
                
                if placeGroups[record.contentId] == nil {
                    placeGroups[record.contentId] = []
                }
                placeGroups[record.contentId]?.append(updatedRecord)
            }
        }
        
        // 각 장소별 요약 정보 생성
        var placeSummaries: [PlaceSummary] = []
        
        for (contentId, visits) in placeGroups {
            guard let firstVisit = visits.first else { continue }
            
            let summary = PlaceSummary(
                contentId: contentId,
                placeTitle: firstVisit.placeTitle,
                placeAddress: firstVisit.placeAddress,
                totalVisits: visits.count,
                firstVisitedAt: visits.min(by: { $0.visitedAt < $1.visitedAt })?.visitedAt,
                lastVisitedAt: visits.max(by: { $0.visitedAt < $1.visitedAt })?.visitedAt
            )
            
            placeSummaries.append(summary)
        }
        
        // 최근 방문순으로 정렬
        placeSummaries.sort { $0.lastVisitedAt ?? Date.distantPast > $1.lastVisitedAt ?? Date.distantPast }
        
        print("🏠 총 \(placeSummaries.count)개 고유 장소 발견")
        return placeSummaries
    }

    // MARK: - Image Upload/Delete Methods (기존과 동일)
    private func uploadImages(userId: String, contentId: String, images: [UIImage]) async throws -> [String] {
        var imageUrls: [String] = []
        for (index, image) in images.enumerated() {
            let imageUrl = try await uploadSingleImage(
                userId: userId,
                contentId: contentId,
                image: image,
                index: index
            )
            imageUrls.append(imageUrl)
        }
        return imageUrls
    }

    private func uploadSingleImage(userId: String, contentId: String, image: UIImage, index: Int) async throws -> String {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw FirestoreError.imageCompressionFailed
        }
        let timestamp = Int(Date().timeIntervalSince1970)
        let fileName = "\(timestamp)_\(index).jpg"
        let storageRef = storage.reference()
            .child("users")
            .child(userId)
            .child("visitRecords")
            .child(contentId)
            .child(fileName)
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        _ = try await storageRef.putDataAsync(imageData, metadata: metadata)
        let downloadURL = try await storageRef.downloadURL()
        return downloadURL.absoluteString
    }

    private func deleteImages(_ imageUrls: [String]) async throws {
        for imageUrl in imageUrls {
            try await deleteSingleImage(imageUrl)
        }
    }

    private func deleteSingleImage(_ imageUrl: String) async throws {
        let storageRef = storage.reference(forURL: imageUrl)
        try await storageRef.delete()
    }
}

// MARK: - Extensions
extension StorageReference {
    func putDataAsync(_ uploadData: Data, metadata: StorageMetadata? = nil) async throws -> StorageMetadata {
        return try await withCheckedThrowingContinuation { continuation in
            putData(uploadData, metadata: metadata) { metadata, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let metadata = metadata {
                    continuation.resume(returning: metadata)
                } else {
                    continuation.resume(throwing: FirestoreError.uploadFailed)
                }
            }
        }
    }
}

// MARK: - 새로운 데이터 모델들
struct PlaceSummary {
    let contentId: String
    let placeTitle: String
    let placeAddress: String
    let totalVisits: Int
    let firstVisitedAt: Date?
    let lastVisitedAt: Date?
}

enum FirestoreError: LocalizedError {
    case imageCompressionFailed
    case uploadFailed
    case userNotAuthenticated

    var errorDescription: String? {
        switch self {
        case .imageCompressionFailed:
            return "이미지 압축에 실패했습니다."
        case .uploadFailed:
            return "업로드에 실패했습니다."
        case .userNotAuthenticated:
            return "로그인이 필요합니다."
        }
    }
}

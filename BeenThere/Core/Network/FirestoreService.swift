//
//  FirestoreService.swift
//  BeenThere
//
//  방문 기록 파이어스토어 서비스
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import UIKit

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
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter
    }

    // MARK: - Visit Record CRUD

    func addVisitRecord(userId: String, record: VisitRecord, images: [UIImage] = []) async throws {
        var imageUrls: [String] = []
        if !images.isEmpty {
            imageUrls = try await uploadImages(userId: userId, contentId: record.contentId, images: images)
        }
        var updatedRecord = record
        updatedRecord.imageUrls = imageUrls
        updatedRecord.updatedAt = Date()

        let dateFormatter = createDateFormatter()
        let visitDateTimeKey = dateFormatter.string(from: record.visitedAt)
        let visitId = "\(record.contentId)_\(visitDateTimeKey)"

        let recordRef = db
            .collection("users")
            .document(userId)
            .collection("visitRecords")
            .document(visitId)

        try recordRef.setData(from: updatedRecord, merge: true)
    }

    func updateVisitRecord(userId: String, originalRecord: VisitRecord, updatedRecord: VisitRecord, newImages: [UIImage] = []) async throws {
        let dateFormatter = createDateFormatter()
        let visitDateTimeKey = dateFormatter.string(from: originalRecord.visitedAt)
        let originalVisitId = "\(originalRecord.contentId)_\(visitDateTimeKey)"
        var imageUrls: [String] = updatedRecord.imageUrls
        if !newImages.isEmpty {
            let newImageUrls = try await uploadImages(userId: userId, contentId: updatedRecord.contentId, images: newImages)
            imageUrls.append(contentsOf: newImageUrls)
        }
        var finalRecord = updatedRecord
        finalRecord.imageUrls = imageUrls
        finalRecord.updatedAt = Date()
        let newVisitDateTimeKey = dateFormatter.string(from: updatedRecord.visitedAt)
        let newVisitId = "\(updatedRecord.contentId)_\(newVisitDateTimeKey)"
        let recordsRef = db
            .collection("users")
            .document(userId)
            .collection("visitRecords")
        if originalVisitId != newVisitId {
            try recordsRef.document(newVisitId).setData(from: finalRecord)
            try await recordsRef.document(originalVisitId).delete()
        } else {
            try recordsRef.document(originalVisitId).setData(from: finalRecord, merge: true)
        }
    }

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
    }

    func fetchVisitHistory(userId: String, contentId: String) async throws -> (records: [VisitRecord], count: Int) {
        let visitRecordsRef = db
            .collection("users")
            .document(userId)
            .collection("visitRecords")
        let snapshot = try await visitRecordsRef
            .whereField("contentId", isEqualTo: contentId)
            .order(by: "visitedAt", descending: true)
            .getDocuments()
        var records: [VisitRecord] = []
        for doc in snapshot.documents {
            do {
                var record = try doc.data(as: VisitRecord.self)
                record.id = doc.documentID
                records.append(record)
            } catch {
                // pass
            }
        }
        return (records: records, count: records.count)
    }

    func fetchVisitCount(userId: String, contentId: String) async throws -> Int {
        let visitRecordsRef = db
            .collection("users")
            .document(userId)
            .collection("visitRecords")
        let snapshot = try await visitRecordsRef
            .whereField("contentId", isEqualTo: contentId)
            .getDocuments()
        return snapshot.documents.count
    }

    func fetchTimelineRecords(userId: String, limit: Int = 30) async throws -> [VisitRecord] {
        let visitRecordsRef = db
            .collection("users")
            .document(userId)
            .collection("visitRecords")
        let snapshot = try await visitRecordsRef
            .order(by: "visitedAt", descending: true)
            .limit(to: limit)
            .getDocuments()
        var records: [VisitRecord] = []
        for doc in snapshot.documents {
            do {
                var record = try doc.data(as: VisitRecord.self)
                record.id = doc.documentID
                records.append(record)
            } catch {
                // pass
            }
        }
        return records
    }

    // MARK: - 날짜 범위 내 기록 조회
    /// 특정 기간에 방문한 모든 기록 조회 (start <= visitedAt < end+1d)
    func fetchRecordsForRange(userId: String, start: Date, end: Date) async throws -> [VisitRecord] {
        let calendar = Calendar.current
        let endOfRange = calendar.date(byAdding: .day, value: 1, to: end)!
        let visitRecordsRef = db
            .collection("users")
            .document(userId)
            .collection("visitRecords")
        let snapshot = try await visitRecordsRef
            .whereField("visitedAt", isGreaterThanOrEqualTo: start)
            .whereField("visitedAt", isLessThan: endOfRange)
            .order(by: "visitedAt", descending: true)
            .getDocuments()
        var records: [VisitRecord] = []
        for doc in snapshot.documents {
            do {
                var record = try doc.data(as: VisitRecord.self)
                record.id = doc.documentID
                records.append(record)
            } catch {
                // pass
            }
        }
        return records
    }

    // MARK: - 프로필 관련 메서드
    
    /// 사용자의 모든 기록 조회 (프로필 통계용)
    func fetchAllRecords(userId: String) async throws -> [VisitRecord] {
        let visitRecordsRef = db
            .collection("users")
            .document(userId)
            .collection("visitRecords")
        let snapshot = try await visitRecordsRef
            .order(by: "visitedAt", descending: true)
            .getDocuments()
        var records: [VisitRecord] = []
        for doc in snapshot.documents {
            do {
                var record = try doc.data(as: VisitRecord.self)
                record.id = doc.documentID
                records.append(record)
            } catch {
                // pass
            }
        }
        return records
    }
    
    // MARK: - 프로필 이미지 관련 메서드 (🆕 추가)
    
    /// 프로필 이미지 업로드 및 Firebase Auth 프로필 업데이트
    func uploadProfileImage(userId: String, image: UIImage) async throws -> String {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw FirestoreError.imageCompressionFailed
        }
        
        let fileName = "profile_\(Int(Date().timeIntervalSince1970)).jpg"
        let storageRef = storage.reference()
            .child("users")
            .child(userId)
            .child("profile")
            .child(fileName)
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        // 기존 프로필 이미지가 있다면 삭제
        try await deleteExistingProfileImage(userId: userId)
        
        // 새 이미지 업로드
        _ = try await storageRef.putDataAsync(imageData, metadata: metadata)
        let downloadURL = try await storageRef.downloadURL()
        
        return downloadURL.absoluteString
    }
    
    /// 기존 프로필 이미지 삭제
    func deleteExistingProfileImage(userId: String) async throws {
        guard let user = Auth.auth().currentUser,
              let photoURL = user.photoURL else { return }
        
        // Firebase Storage URL인지 확인
        if photoURL.absoluteString.contains("firebasestorage.googleapis.com") {
            let storageRef = storage.reference(forURL: photoURL.absoluteString)
            try await storageRef.delete()
        }
    }
    
    /// 프로필 이미지 완전 삭제 (Storage + Auth)
    func deleteProfileImage(userId: String) async throws {
        // 1. Storage에서 이미지 삭제
        try await deleteExistingProfileImage(userId: userId)
        
        // 2. Firebase Auth 프로필 업데이트는 ViewModel에서 처리
        // (FirestoreService는 데이터 레이어이므로 Auth 업데이트는 ViewModel이 담당)
    }
    
    /// 프로필 폴더 전체 삭제 (계정 삭제 시 사용)
    private func deleteProfileFolder(userId: String) async throws {
        let profileFolderRef = storage.reference()
            .child("users")
            .child(userId)
            .child("profile")
        
        do {
            let result = try await profileFolderRef.listAll()
            
            // 프로필 폴더의 모든 파일 삭제
            for item in result.items {
                try await item.delete()
            }
        } catch {
            // 프로필 폴더가 없는 경우는 무시
            print("프로필 폴더 삭제 실패 (존재하지 않을 수 있음): \(error.localizedDescription)")
        }
    }
    
    /// 사용자의 모든 데이터 삭제 (계정 삭제용) - 프로필 이미지 삭제 포함
    func deleteAllUserData(userId: String) async throws {
        let batch = db.batch()
        
        // 사용자의 모든 기록 조회
        let recordsSnapshot = try await db
            .collection("users")
            .document(userId)
            .collection("visitRecords")
            .getDocuments()
        
        // 기록과 관련된 이미지들 먼저 삭제
        for document in recordsSnapshot.documents {
            if let record = try? document.data(as: VisitRecord.self),
               !record.imageUrls.isEmpty {
                try await deleteImages(record.imageUrls)
            }
            // 기록 문서 삭제를 배치에 추가
            batch.deleteDocument(document.reference)
        }
        
        // 사용자 문서 삭제 (만약 별도로 사용자 정보를 저장한다면)
        let userDocRef = db.collection("users").document(userId)
        batch.deleteDocument(userDocRef)
        
        // 배치 실행
        try await batch.commit()
        
        // Storage에서 사용자 폴더 전체 삭제 시도 (프로필 이미지 포함)
        try await deleteUserStorageFolder(userId: userId)
    }

    func fetchUniqueVisitedPlaces(userId: String) async throws -> [PlaceSummary] {
        let visitRecordsRef = db
            .collection("users")
            .document(userId)
            .collection("visitRecords")
        let snapshot = try await visitRecordsRef
            .order(by: "visitedAt", descending: true)
            .getDocuments()
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
        placeSummaries.sort { $0.lastVisitedAt ?? Date.distantPast > $1.lastVisitedAt ?? Date.distantPast }
        return placeSummaries
    }

    // MARK: - Image Upload/Delete Methods (일반 이미지)
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
    
    /// 사용자의 Storage 폴더 전체 삭제 (프로필 이미지 포함)
    private func deleteUserStorageFolder(userId: String) async throws {
        let userFolderRef = storage.reference()
            .child("users")
            .child(userId)
        
        do {
            // listAll을 사용해서 모든 파일과 하위 폴더를 가져온 후 삭제
            let result = try await userFolderRef.listAll()
            
            // 모든 파일 삭제
            for item in result.items {
                try await item.delete()
            }
            
            // 하위 폴더들도 재귀적으로 삭제
            for prefix in result.prefixes {
                try await deleteStoragePrefix(prefix)
            }
        } catch {
            // Storage 삭제 실패는 로그만 남기고 에러를 던지지 않음
            print("Storage 폴더 삭제 실패: \(error.localizedDescription)")
        }
    }
    
    /// Storage 폴더 재귀 삭제 헬퍼 메서드
    private func deleteStoragePrefix(_ prefix: StorageReference) async throws {
        let result = try await prefix.listAll()
        
        for item in result.items {
            try await item.delete()
        }
        
        for subPrefix in result.prefixes {
            try await deleteStoragePrefix(subPrefix)
        }
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

// MARK: - Storage Reference 확장
extension StorageReference {
    func listAll() async throws -> StorageListResult {
        return try await withCheckedThrowingContinuation { continuation in
            listAll { result, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let result = result {
                    continuation.resume(returning: result)
                } else {
                    continuation.resume(throwing: FirestoreError.uploadFailed)
                }
            }
        }
    }
}

// MARK: - 데이터 모델/에러
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

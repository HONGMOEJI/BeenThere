//
//  FirestoreService.swift
//  BeenThere
//
//  방문 기록 파이어스토어 서비스 (날짜 범위 쿼리 포함)
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
        formatter.locale = Locale(identifier: "en_US_POSIX")
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

        try await recordRef.setData(from: updatedRecord, merge: true)
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
            try await recordsRef.document(newVisitId).setData(from: finalRecord)
            try await recordsRef.document(originalVisitId).delete()
        } else {
            try await recordsRef.document(originalVisitId).setData(from: finalRecord, merge: true)
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

    // MARK: - 날짜 범위 내 기록 조회 (🆕)
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

    // MARK: - Image Upload/Delete Methods
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

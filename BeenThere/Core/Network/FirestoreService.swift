//
//  FirestoreService.swift
//  BeenThere
//
//  Firestore에 방문 기록(VisitRecord) CRUD 기능을 제공하는 서비스 레이어
//  BeenThere/Core/Network/FirestoreService.swift
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

/// FirestoreService: Firestore의 users/{uid}/visitRecords 경로로 CRUD 수행
final class FirestoreService {
    static let shared = FirestoreService()
    private init() {}

    private let db = Firestore.firestore()

    // MARK: - Visit Record CRUD

    /// 방문 기록 추가 (contentId를 도큐먼트 ID로 사용)
    func addVisitRecord(userId: String, record: VisitRecord) async throws {
        let recordRef = db
            .collection(APIConstants.Firebase.users)
            .document(userId)
            .collection(APIConstants.Firebase.visitRecords)
            .document(record.contentId)

        try await recordRef.setData(from: record, merge: true)
    }

    /// 방문 기록 삭제
    func deleteVisitRecord(userId: String, contentId: String) async throws {
        let recordRef = db
            .collection(APIConstants.Firebase.users)
            .document(userId)
            .collection(APIConstants.Firebase.visitRecords)
            .document(contentId)
        try await recordRef.delete()
    }

    /// 모든 방문 기록 불러오기
    func fetchAllVisitRecords(userId: String) async throws -> [VisitRecord] {
        let querySnapshot = try await db
            .collection(APIConstants.Firebase.users)
            .document(userId)
            .collection(APIConstants.Firebase.visitRecords)
            .order(by: "visitedAt", descending: true)
            .getDocuments()

        let records: [VisitRecord] = try querySnapshot.documents.compactMap { doc in
            return try doc.data(as: VisitRecord.self)
        }
        return records
    }
}

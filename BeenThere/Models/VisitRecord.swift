//
//  VisitRecord.swift
//  BeenThere
//
//  Firestore에 저장할 방문 기록(VisitRecord) 모델
//  - users/{uid}/visitRecords/{contentId} 경로에 저장
//  BeenThere/Models/VisitRecord.swift
//

import Foundation
import FirebaseFirestore

/// Firestore에 저장할 Visit Record 모델
struct VisitRecord: Codable, Identifiable {
    /// Firestore 도큐먼트 ID (contentId로 설정)
    @DocumentID var id: String?
    /// TourAPI에서 받아온 콘텐츠 ID
    let contentId: String
    /// 관광지 제목
    let title: String
    /// 사용자가 방문한 시각 (서버 타임스탬프 사용 권장)
    let visitedAt: Date
    /// 관광지 위도 (Double)
    let lat: Double
    /// 관광지 경도 (Double)
    let lng: Double
    /// 썸네일 이미지 URL (옵셔널)
    let thumbnail: String?

    /// 생성자: contentId를 id로 설정하여 중복 저장 방지
    init(
        contentId: String,
        title: String,
        visitedAt: Date = Date(),
        lat: Double,
        lng: Double,
        thumbnail: String? = nil
    ) {
        self.id = contentId
        self.contentId = contentId
        self.title = title
        self.visitedAt = visitedAt
        self.lat = lat
        self.lng = lng
        self.thumbnail = thumbnail
    }
}

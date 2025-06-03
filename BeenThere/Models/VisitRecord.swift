//
//  VisitRecord.swift
//  BeenThere
//
//  방문 기록 데이터 모델
//

import Foundation
import FirebaseFirestore

struct VisitRecord: Codable, Identifiable {
    @DocumentID var id: String?
    let contentId: String
    let placeTitle: String
    let placeAddress: String
    let visitedAt: Date
    let rating: Int // 1-5 별점
    let content: String // 방문 소감
    var imageUrls: [String] = [] // Firebase Storage URLs
    let weather: WeatherType?
    let mood: MoodType?
    let tags: [String]
    let createdAt: Date
    var updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case contentId
        case placeTitle
        case placeAddress
        case visitedAt
        case rating
        case content
        case imageUrls
        case weather
        case mood
        case tags
        case createdAt
        case updatedAt
    }
    
    init(contentId: String, placeTitle: String, placeAddress: String, visitedAt: Date, rating: Int, content: String, imageUrls: [String] = [], weather: WeatherType? = nil, mood: MoodType? = nil, tags: [String] = []) {
        self.contentId = contentId
        self.placeTitle = placeTitle
        self.placeAddress = placeAddress
        self.visitedAt = visitedAt
        self.rating = rating
        self.content = content
        self.imageUrls = imageUrls
        self.weather = weather
        self.mood = mood
        self.tags = tags
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

enum WeatherType: String, Codable, CaseIterable {
    case sunny = "sunny"
    case cloudy = "cloudy"
    case rainy = "rainy"
    case snowy = "snowy"
    
    var emoji: String {
        switch self {
        case .sunny: return "☀️"
        case .cloudy: return "☁️"
        case .rainy: return "🌧️"
        case .snowy: return "❄️"
        }
    }
    
    var displayName: String {
        switch self {
        case .sunny: return "맑음"
        case .cloudy: return "흐림"
        case .rainy: return "비"
        case .snowy: return "눈"
        }
    }
}

enum MoodType: String, Codable, CaseIterable {
    case happy = "happy"
    case excited = "excited"
    case relaxed = "relaxed"
    case thoughtful = "thoughtful"
    case romantic = "romantic"
    
    var emoji: String {
        switch self {
        case .happy: return "😊"
        case .excited: return "🤩"
        case .relaxed: return "😌"
        case .thoughtful: return "🤔"
        case .romantic: return "🥰"
        }
    }
    
    var displayName: String {
        switch self {
        case .happy: return "행복해요"
        case .excited: return "신나요"
        case .relaxed: return "편안해요"
        case .thoughtful: return "생각이 많아요"
        case .romantic: return "설레요"
        }
    }
}

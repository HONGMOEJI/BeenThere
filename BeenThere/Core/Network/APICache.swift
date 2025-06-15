//
//  APICache.swift
//  BeenThere
//
//  API 응답 캐싱 기능을 제공하는 유틸리티 클래스
//

import Foundation

/// API 응답을 캐시하는 서비스 클래스
final class APICache {
    // 싱글톤 인스턴스
    static let shared = APICache()
    
    // 메모리 캐시
    private let cache = NSCache<NSString, CacheItem>()
    
    // 파일 매니저 (디스크 캐싱용)
    private let fileManager = FileManager.default
    
    // 캐시 디렉토리
    private let cacheDirectory: URL
    
    // 캐시 설정값
    private let cacheExpirationTime: TimeInterval = 60 * 60 * 24 // 1일
    
    // 초기화
    private init() {
        // 캐시 크기 설정
        cache.totalCostLimit = 50 * 1024 * 1024 // 50MB
        
        // 캐시 디렉토리 설정
        let cachesDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        cacheDirectory = cachesDirectory.appendingPathComponent("APICache")
        
        // 디렉토리가 없으면 생성
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        
        // 앱 시작 시 오래된 캐시 정리
        cleanExpiredCache()
    }
    
    // 데이터 캐싱
    func cache(_ data: Data, for key: String, cost: Int = 0) {
        // 메모리 캐시
        let item = CacheItem(data: data)
        let cacheKey = NSString(string: key)
        cache.setObject(item, forKey: cacheKey, cost: cost)
        
        // 디스크 캐시
        let fileURL = cacheFileURL(for: key)
        try? data.write(to: fileURL)
    }
    
    // 캐시된 데이터 조회
    func retrieveData(for key: String) -> Data? {
        // 1. 메모리 캐시 확인
        let cacheKey = NSString(string: key)
        if let item = cache.object(forKey: cacheKey), !item.isExpired {
            return item.data
        }
        
        // 2. 디스크 캐시 확인
        let fileURL = cacheFileURL(for: key)
        if fileManager.fileExists(atPath: fileURL.path) {
            do {
                // 파일 정보 확인하여 만료 여부 체크
                let attributes = try fileManager.attributesOfItem(atPath: fileURL.path)
                if let modificationDate = attributes[.modificationDate] as? Date {
                    // 만료 시간 체크
                    if Date().timeIntervalSince(modificationDate) > cacheExpirationTime {
                        // 만료된 파일 삭제
                        try? fileManager.removeItem(at: fileURL)
                        return nil
                    }
                }
                
                // 파일에서 데이터 읽기
                let data = try Data(contentsOf: fileURL)
                
                // 메모리 캐시에도 저장
                let item = CacheItem(data: data)
                cache.setObject(item, forKey: cacheKey, cost: data.count)
                
                return data
            } catch {
                print("캐시 파일 읽기 실패: \(error)")
            }
        }
        
        return nil
    }
    
    // 특정 키의 캐시 삭제
    func removeCache(for key: String) {
        let cacheKey = NSString(string: key)
        cache.removeObject(forKey: cacheKey)
        
        let fileURL = cacheFileURL(for: key)
        try? fileManager.removeItem(at: fileURL)
    }
    
    // 모든 캐시 삭제
    func clearAllCache() {
        cache.removeAllObjects()
        
        try? fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil).forEach { url in
            try? fileManager.removeItem(at: url)
        }
    }
    
    // 만료된 캐시 파일 정리
    private func cleanExpiredCache() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }
            
            do {
                let files = try self.fileManager.contentsOfDirectory(
                    at: self.cacheDirectory,
                    includingPropertiesForKeys: [.contentModificationDateKey]
                )
                
                let now = Date()
                
                for fileURL in files {
                    guard let attributes = try? self.fileManager.attributesOfItem(atPath: fileURL.path),
                          let modificationDate = attributes[.modificationDate] as? Date else {
                        continue
                    }
                    
                    if now.timeIntervalSince(modificationDate) > self.cacheExpirationTime {
                        try? self.fileManager.removeItem(at: fileURL)
                    }
                }
            } catch {
                print("캐시 정리 중 오류 발생: \(error)")
            }
        }
    }
    
    // 캐시 파일 URL 생성
    private func cacheFileURL(for key: String) -> URL {
        // 키를 해시하여 파일명으로 사용
        let hashedKey = key.hashValue
        return cacheDirectory.appendingPathComponent("\(hashedKey)")
    }
    
    // 캐시 아이템 클래스
    final class CacheItem {
        let data: Data
        let timestamp: Date
        
        init(data: Data) {
            self.data = data
            self.timestamp = Date()
        }
        
        var isExpired: Bool {
            return Date().timeIntervalSince(timestamp) > APICache.shared.cacheExpirationTime
        }
    }
}

//
//  NetworkLogger.swift
//  BeenThere
//
//  네트워크 요청/응답을 로깅하는 유틸리티
//  BeenThere/Core/Network/NetworkLogger.swift
//

import Foundation

class NetworkLogger {
    static let shared = NetworkLogger()
    private init() {}
    
    var isEnabled = true
    
    func logRequest(_ request: URLRequest) {
        guard isEnabled else { return }
        
        print("\n---------- 📡 API 요청 시작 ----------")
        print("📍 URL: \(request.url?.absoluteString ?? "없음")")
        print("📤 메서드: \(request.httpMethod ?? "GET")")
        
        if let headers = request.allHTTPHeaderFields, !headers.isEmpty {
            print("🔖 헤더:")
            headers.forEach { print("   \($0.key): \($0.value)") }
        }
        
        if let body = request.httpBody {
            print("📦 요청 본문:")
            if let bodyString = String(data: body, encoding: .utf8) {
                print("   \(bodyString)")
            } else {
                print("   <바이너리 데이터: \(body.count) 바이트>")
            }
        }
        
        print("-----------------------------------\n")
    }
    
    func logResponse(data: Data?, response: URLResponse?, error: Error?, startTime: Date) {
        guard isEnabled else { return }
        
        let elapsedTime = Date().timeIntervalSince(startTime)
        print("\n---------- ✅ API 응답 수신 ----------")
        print("⏱️ 소요 시간: \(String(format: "%.3f", elapsedTime))초")
        
        if let error = error {
            print("❌ 오류: \(error.localizedDescription)")
        }
        
        if let httpResponse = response as? HTTPURLResponse {
            let statusEmoji = 200...299 ~= httpResponse.statusCode ? "✅" : "❌"
            print("\(statusEmoji) 상태 코드: \(httpResponse.statusCode)")
            
            if !httpResponse.allHeaderFields.isEmpty {
                print("🔖 응답 헤더:")
                httpResponse.allHeaderFields.forEach { print("   \($0.key): \($0.value)") }
            }
        }
        
        guard let data = data else {
            print("📦 응답 본문: 없음")
            print("-----------------------------------\n")
            return
        }
        
        print("📦 응답 데이터 크기: \(data.count) 바이트")
        
        // 응답 데이터 미리보기
        if let json = try? JSONSerialization.jsonObject(with: data) {
            if let prettyData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted),
               let prettyString = String(data: prettyData, encoding: .utf8) {
                
                let previewLength = min(1000, prettyString.count)
                if prettyString.count > previewLength {
                    print("📄 응답 내용 미리보기: \n\(prettyString.prefix(previewLength))...\n[총 \(prettyString.count)자]")
                } else {
                    print("📄 응답 내용: \n\(prettyString)")
                }
            }
        } else if let strData = String(data: data, encoding: .utf8) {
            let previewLength = min(500, strData.count)
            if strData.count > previewLength {
                print("📄 응답 내용 미리보기 (JSON 아님): \n\(strData.prefix(previewLength))...\n[총 \(strData.count)자]")
            } else {
                print("📄 응답 내용 (JSON 아님): \n\(strData)")
            }
            
            // HTML/XML 응답 탐지
            if strData.trimmingCharacters(in: .whitespacesAndNewlines).starts(with: "<") {
                print("⚠️ 경고: HTML/XML 응답이 감지되었습니다. API 요청이 올바르지 않을 수 있습니다.")
            }
        } else {
            print("📄 응답 내용: <디코딩 불가능한 바이너리 데이터>")
        }
        
        print("-----------------------------------\n")
    }
}

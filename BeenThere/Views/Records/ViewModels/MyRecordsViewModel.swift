//
//  MyRecordsViewModel.swift
//  BeenThere
//
//  내 기록 뷰모델
//

import Foundation
import UIKit
import Combine
import FirebaseAuth

@MainActor
class MyRecordsViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var selectedDate: Date = Date()
    @Published var records: [VisitRecord] = []
    @Published var isLoading: Bool = false
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""
    
    // MARK: - Private Properties
    private let firestoreService = FirestoreService.shared
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Computed Properties
    var recordCount: Int {
        records.count
    }
    
    var isEmpty: Bool {
        records.isEmpty && !isLoading
    }
    
    // MARK: - Init
    init() {
        setupBindings()
        loadRecordsForDate(selectedDate)
    }
    
    // MARK: - Private Methods
    private func setupBindings() {
        $selectedDate
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] date in
                self?.loadRecordsForDate(date)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Public Methods
    func selectDate(_ date: Date) {
        // 한국 시간대 기준으로 날짜 처리
        let koreaTimeZone = TimeZone(identifier: "Asia/Seoul")!
        var calendar = Calendar.current
        calendar.timeZone = koreaTimeZone
        
        // 선택된 날짜의 한국 시간 기준으로 설정
        selectedDate = date
        
        // 디버깅 출력
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = koreaTimeZone
        
        print("📅 날짜 선택됨:")
        print("  - 선택 날짜 (한국 시간): \(formatter.string(from: date))")
        print("  - UTC 시간: \(date)")
        
        loadRecordsForDate(date)
    }

    func selectToday() {
        // 현재 한국 시간 기준으로 오늘 날짜 설정
        let koreaTimeZone = TimeZone(identifier: "Asia/Seoul")!
        var calendar = Calendar.current
        calendar.timeZone = koreaTimeZone
        
        let today = Date()
        let todayInKorea = calendar.startOfDay(for: today)
        
        print("📅 오늘 버튼 클릭:")
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = koreaTimeZone
        print("  - 오늘 (한국 시간): \(formatter.string(from: todayInKorea))")
        
        selectedDate = todayInKorea
        loadRecordsForDate(todayInKorea)
    }
    
    func loadRecordsForDate(_ date: Date) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("❌ 사용자 인증 실패")
            showErrorMessage("로그인이 필요합니다.")
            return
        }
        
        print("🔍 날짜별 기록 조회 시작")
        print("  - 현재 로그인 사용자: HONGMOEJI")
        print("  - 사용자 UID: \(userId)")
        print("  - 조회 날짜: \(date)")
        print("  - 현재 시간: \(Date())")
        
        isLoading = true
        
        Task {
            do {
                print("📞 FirestoreService.fetchRecordsForDate 호출")
                let fetchedRecords = try await firestoreService.fetchRecordsForDate(userId: userId, date: date)
                
                print("📞 FirestoreService 응답 받음: \(fetchedRecords.count)개")
                
                // 방문 시간순으로 정렬 (최신순)
                let sortedRecords = fetchedRecords.sorted { $0.visitedAt > $1.visitedAt }
                
                print("📊 날짜별 기록 조회 결과 - count: \(sortedRecords.count)")
                
                for (index, record) in sortedRecords.enumerated() {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
                    print("  \(index+1). \(record.placeTitle) - \(formatter.string(from: record.visitedAt))")
                }
                
                await MainActor.run {
                    self.records = sortedRecords
                    self.isLoading = false
                    print("📱 UI 업데이트 완료: \(self.records.count)개 기록")
                }
                
            } catch {
                print("❌ 날짜별 기록 조회 실패: \(error)")
                print("❌ 에러 타입: \(type(of: error))")
                print("❌ 에러 설명: \(error.localizedDescription)")
                
                await MainActor.run {
                    self.showErrorMessage("기록을 불러오는데 실패했습니다.")
                    self.records = []
                    self.isLoading = false
                    print("📱 에러 상태로 UI 업데이트 완료")
                }
            }
        }
    }
    
    func deleteRecord(_ record: VisitRecord) async {
        guard let userId = Auth.auth().currentUser?.uid else {
            showErrorMessage("로그인이 필요합니다.")
            return
        }
        
        do {
            try await firestoreService.deleteVisitRecord(
                userId: userId,
                visitedAt: record.visitedAt,
                contentId: record.contentId
            )
            
            // 로컬에서도 제거
            records.removeAll { $0.id == record.id }
            
        } catch {
            print("❌ 기록 삭제 실패: \(error)")
            showErrorMessage("기록 삭제에 실패했습니다.")
        }
    }
    
    func refreshCurrentDate() {
        loadRecordsForDate(selectedDate)
    }
    
    // MARK: - Error Handling
    private func showErrorMessage(_ message: String) {
        errorMessage = message
        showError = true
    }
}

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
    @Published var startDate: Date
    @Published var endDate: Date
    @Published var searchQuery: String = ""
    @Published var records: [VisitRecord] = []
    @Published var isLoading: Bool = false
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""
    
    private let firestoreService = FirestoreService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // 기본: 오늘 하루
        let today = Date()
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: today)
        self.startDate = start
        self.endDate = today
        setupBindings()
        loadRecordsForRangeAndQuery(start: start, end: today, query: "")
    }
    
    private func setupBindings() {
        Publishers.CombineLatest3($startDate, $endDate, $searchQuery)
            .debounce(for: .milliseconds(200), scheduler: DispatchQueue.main)
            .sink { [weak self] (start, end, query) in
                self?.loadRecordsForRangeAndQuery(start: start, end: end, query: query)
            }
            .store(in: &cancellables)
    }

    func selectDateRange(start: Date, end: Date) {
        self.startDate = start
        self.endDate = end
    }
    func selectToday() {
        let today = Date()
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: today)
        self.startDate = start
        self.endDate = today
    }
    
    func loadRecordsForRangeAndQuery(start: Date, end: Date, query: String) {
        guard let userId = Auth.auth().currentUser?.uid else {
            showErrorMessage("로그인이 필요합니다.")
            return
        }
        isLoading = true
        
        Task {
            do {
                let fetchedRecords = try await firestoreService.fetchRecordsForRange(userId: userId, start: start, end: end)
                let filtered = filterRecords(records: fetchedRecords, query: query)
                await MainActor.run {
                    self.records = filtered.sorted { $0.visitedAt > $1.visitedAt }
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.showErrorMessage("기록을 불러오는데 실패했습니다.")
                    self.records = []
                    self.isLoading = false
                }
            }
        }
    }
    
    private func filterRecords(records: [VisitRecord], query: String) -> [VisitRecord] {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else { return records }
        let lower = query.lowercased()
        return records.filter { rec in
            rec.placeTitle.lowercased().contains(lower) ||
            rec.placeAddress.lowercased().contains(lower) ||
            rec.content.lowercased().contains(lower) ||
            rec.tags.contains(where: { $0.lowercased().contains(lower) })
        }
    }
    
    func refreshCurrentRange() {
        loadRecordsForRangeAndQuery(start: startDate, end: endDate, query: searchQuery)
    }
    
    private func showErrorMessage(_ message: String) {
        errorMessage = message
        showError = true
    }
}

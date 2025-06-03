//
//  LocationManager.swift
//  BeenThere
//
//  CoreLocation을 사용해 현재 위치를 가져오는 객체
//  BeenThere/Core/Location/LocationManager.swift
//

import Foundation
import CoreLocation
import Combine
import SwiftUI

/// LocationManager: 현재 GPS 좌표와 권한 상태를 Observable로 제공
final class LocationManager: NSObject, ObservableObject {
    // MARK: - Published 속성
    /// 현재 위치 정보
    @Published var currentLocation: CLLocation?
    
    /// 위치 서비스 권한 상태
    @Published var authorizationStatus: CLAuthorizationStatus
    
    /// 위치 정보 가져오기 실패 시 에러
    @Published var locationError: Error?
    
    /// 위치 검색 중인지 여부
    @Published var isUpdating = false
    
    // MARK: - 내부 속성
    /// Core Location 매니저
    private let locationManager = CLLocationManager()
    
    /// 마지막 위치 저장 UserDefaults 키
    private let lastLocationLatKey = "lastLocationLat"
    private let lastLocationLngKey = "lastLocationLng"
    private let lastLocationTimeKey = "lastLocationTimestamp"
    
    /// 위치 업데이트 모드
    enum UpdateMode {
        case continuous    // 지속적 업데이트
        case oneTime       // 일회성 업데이트
    }
    
    /// 현재 업데이트 모드
    private var currentUpdateMode: UpdateMode = .oneTime
    
    // MARK: - 초기화
    override init() {
        self.authorizationStatus = locationManager.authorizationStatus
        super.init()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.distanceFilter = 100 // 100m 이상 움직였을 때만 업데이트
    }
    
    // MARK: - 위치 권한 관련 메서드
    
    /// 위치 권한 요청
    func requestPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    /// 위치 권한이 있는지 확인
    var hasLocationPermission: Bool {
        return authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways
    }
    
    /// 위치 서비스 설정 화면으로 이동 요청
    func openAppSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }
    }
    
    // MARK: - 위치 업데이트 메서드
    
    /// 위치 업데이트 시작 (모드 선택 가능)
    /// - Parameter mode: 업데이트 모드 (지속적 또는 일회성)
    func startUpdating(mode: UpdateMode = .oneTime) {
        guard hasLocationPermission else {
            locationError = NSError(
                domain: "LocationManager",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: APIConstants.ErrorMessages.permissionDenied]
            )
            return
        }
        
        currentUpdateMode = mode
        isUpdating = true
        locationError = nil
        
        if mode == .continuous {
            locationManager.distanceFilter = 100 // 지속 모드에서는 100m마다 업데이트
        } else {
            locationManager.distanceFilter = kCLDistanceFilterNone // 일회성은 필터 없음
        }
        
        locationManager.startUpdatingLocation()
    }
    
    /// 높은 정확도의 일회성 위치 요청
    func requestPreciseLocation() {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        startUpdating(mode: .oneTime)
    }
    
    /// 위치 업데이트 중지
    func stopUpdating() {
        locationManager.stopUpdatingLocation()
        isUpdating = false
    }
    
    // MARK: - 위치 캐싱 메서드
    
    /// 현재 위치 정보 UserDefaults에 저장
    func saveCurrentLocation() {
        guard let location = currentLocation else { return }
        
        UserDefaults.standard.set(location.coordinate.latitude, forKey: lastLocationLatKey)
        UserDefaults.standard.set(location.coordinate.longitude, forKey: lastLocationLngKey)
        UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: lastLocationTimeKey)
    }
    
    /// 저장된 위치 정보 불러오기
    /// - Returns: 저장된 마지막 위치 (없으면 nil)
    func loadLastLocation() -> CLLocation? {
        let lat = UserDefaults.standard.double(forKey: lastLocationLatKey)
        let lng = UserDefaults.standard.double(forKey: lastLocationLngKey)
        let timestamp = UserDefaults.standard.double(forKey: lastLocationTimeKey)
        
        // 저장된 위치가 있고 유효한 좌표인지 확인
        if lat != 0 && lng != 0 && timestamp != 0 {
            return CLLocation(
                coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lng),
                altitude: 0,
                horizontalAccuracy: 0,
                verticalAccuracy: 0,
                timestamp: Date(timeIntervalSince1970: timestamp)
            )
        }
        return nil
    }
    
    /// 위치 정확도 설정
    /// - Parameter accuracy: 원하는 위치 정확도
    func setAccuracy(_ accuracy: CLLocationAccuracy) {
        locationManager.desiredAccuracy = accuracy
    }
}

// MARK: - CLLocationManagerDelegate 구현
extension LocationManager: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        DispatchQueue.main.async {
            self.authorizationStatus = manager.authorizationStatus
            
            switch self.authorizationStatus {
            case .authorizedWhenInUse, .authorizedAlways:
                // 권한 허용 시 위치 업데이트 시작
                self.startUpdating(mode: self.currentUpdateMode)
            case .denied, .restricted:
                // 권한 거부 시 에러 발생
                self.locationError = NSError(
                    domain: "LocationManager",
                    code: 2,
                    userInfo: [NSLocalizedDescriptionKey: APIConstants.ErrorMessages.permissionDenied]
                )
                self.currentLocation = nil
            case .notDetermined:
                // 권한 요청 대기 중
                break
            @unknown default:
                break
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        DispatchQueue.main.async {
            self.currentLocation = location
            self.locationError = nil
            self.saveCurrentLocation()
            
            // 일회성 업데이트 모드인 경우 업데이트 중지
            if self.currentUpdateMode == .oneTime {
                self.stopUpdating()
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.locationError = error
            if self.currentUpdateMode == .oneTime {
                self.stopUpdating()
            }
            
            print("LocationManager Error: \(error.localizedDescription)")
            
            // 저장된 마지막 위치 불러오기 시도
            if self.currentLocation == nil, let lastLocation = self.loadLastLocation() {
                self.currentLocation = lastLocation
            }
        }
    }
}

// MARK: - 편의 확장
extension LocationManager {
    /// 기본 위치 사용 (앱 테스트용)
    func useDefaultLocation() {
        // 서울 시청 좌표
        let defaultLocation = CLLocation(
            coordinate: CLLocationCoordinate2D(latitude: 37.5662952, longitude: 126.9779451),
            altitude: 0,
            horizontalAccuracy: 0,
            verticalAccuracy: 0,
            timestamp: Date()
        )
        self.currentLocation = defaultLocation
    }
    
    /// 두 지점 간 거리 계산
    /// - Parameters:
    ///   - coordinate: 목표 좌표
    /// - Returns: 현재 위치부터 목표 좌표까지의 거리 (미터)
    func distanceToCoordinate(_ coordinate: CLLocationCoordinate2D) -> CLLocationDistance? {
        guard let currentLocation = currentLocation else { return nil }
        
        let targetLocation = CLLocation(
            latitude: coordinate.latitude,
            longitude: coordinate.longitude
        )
        
        return currentLocation.distance(from: targetLocation)
    }
    
    /// 거리 포맷팅 (1.2km, 800m 형태로)
    /// - Parameter distance: 미터 단위 거리
    /// - Returns: 포맷된 거리 문자열
    static func formatDistance(_ distance: Double) -> String {
        if distance < 1000 {
            return "\(Int(distance))m"
        } else {
            return String(format: "%.1fkm", distance / 1000)
        }
    }
}

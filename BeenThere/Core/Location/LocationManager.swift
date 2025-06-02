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

/// LocationManager: 현재 GPS 좌표와 권한 상태를 Observable로 제공
final class LocationManager: NSObject, ObservableObject {
    @Published var currentLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus

    private let locationManager = CLLocationManager()

    override init() {
        self.authorizationStatus = locationManager.authorizationStatus
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    /// 위치 권한 요청
    func requestPermission() {
        locationManager.requestWhenInUseAuthorization()
    }

    /// 위치 업데이트 시작
    func startUpdating() {
        locationManager.startUpdatingLocation()
    }

    /// 위치 업데이트 중지
    func stopUpdating() {
        locationManager.stopUpdatingLocation()
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        switch authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
        case .denied, .restricted:
            // 권한이 거부된 경우에는 currentLocation을 nil로 두고, 필요시 사용자에게 알림
            break
        default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        currentLocation = location
        manager.stopUpdatingLocation() // 최초 한 번만 받아오고 중지
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("LocationManager Error: \(error.localizedDescription)")
    }
}

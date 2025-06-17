//
//  LocationSelectionViewController.swift
//  BeenThere
//
//  위치 선택 화면 - 지도와 주소 검색을 통한 위치 선택
//  - 지도에서 핀으로 위치 선택
//  - 주소 검색 기능
//  - 주요 도시 바로가기
//

import UIKit
import MapKit
import CoreLocation

protocol LocationSelectionDelegate: AnyObject {
    func didSelectLocation(_ location: CLLocation, name: String)
}

class LocationSelectionViewController: UIViewController {
    
    // MARK: - Properties
    weak var delegate: LocationSelectionDelegate?
    private var selectedLocation: CLLocation?
    private var selectedLocationName: String = ""
    private let geocoder = CLGeocoder()
    
    // MARK: - UI Components
    
    private let headerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.themeBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "위치 선택"
        label.font = .titleMedium
        label.textColor = UIColor.themeTextPrimary
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "주소나 지역명을 검색하세요"
        searchBar.searchBarStyle = .minimal
        searchBar.backgroundColor = UIColor.themeBackground
        searchBar.barTintColor = UIColor.themeBackground
        searchBar.searchTextField.backgroundColor = UIColor(white: 0.15, alpha: 1.0)
        searchBar.searchTextField.textColor = UIColor.themeTextPrimary
        searchBar.searchTextField.layer.cornerRadius = 12
        searchBar.tintColor = UIColor(white: 0.85, alpha: 1.0)
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()
    
    private let mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.mapType = .standard
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .none
        mapView.layer.cornerRadius = 16
        mapView.clipsToBounds = true
        mapView.translatesAutoresizingMaskIntoConstraints = false
        return mapView
    }()
    
    private let bottomContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.15, alpha: 1.0)
        view.layer.cornerRadius = 16
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor(white: 0.25, alpha: 1.0).cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let selectedLocationLabel: UILabel = {
        let label = UILabel()
        label.text = "지도에서 위치를 선택하세요"
        label.font = .headlineMedium
        label.textColor = UIColor.themeTextPrimary
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let selectButton: UIButton = {
        let button = UIButton(type: .system)
        
        var config = UIButton.Configuration.filled()
        config.title = "이 위치로 설정"
        config.baseBackgroundColor = UIColor(white: 0.85, alpha: 1.0)
        config.baseForegroundColor = UIColor.themeBackground
        config.cornerStyle = .medium
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = .buttonLarge
            return outgoing
        }
        
        button.configuration = config
        button.isEnabled = false
        button.alpha = 0.5
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        
        var config = UIButton.Configuration.plain()
        config.title = "취소"
        config.baseForegroundColor = UIColor.themeTextSecondary
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = .buttonMedium
            return outgoing
        }
        
        button.configuration = config
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupMapView()
        setupActions()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = UIColor.themeBackground
        
        view.addSubview(headerView)
        headerView.addSubview(titleLabel)
        view.addSubview(searchBar)
        view.addSubview(mapView)
        view.addSubview(bottomContainer)
        
        bottomContainer.addSubview(selectedLocationLabel)
        bottomContainer.addSubview(selectButton)
        bottomContainer.addSubview(cancelButton)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            // 헤더
            headerView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 60),
            
            // 타이틀
            titleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            
            // 검색바
            searchBar.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 8),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            // 지도뷰
            mapView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 16),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            mapView.bottomAnchor.constraint(equalTo: bottomContainer.topAnchor, constant: -16),
            
            // 하단 컨테이너
            bottomContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            bottomContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            bottomContainer.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -16),
            bottomContainer.heightAnchor.constraint(equalToConstant: 140),
            
            // 선택된 위치 레이블
            selectedLocationLabel.topAnchor.constraint(equalTo: bottomContainer.topAnchor, constant: 16),
            selectedLocationLabel.leadingAnchor.constraint(equalTo: bottomContainer.leadingAnchor, constant: 16),
            selectedLocationLabel.trailingAnchor.constraint(equalTo: bottomContainer.trailingAnchor, constant: -16),
            
            // 선택 버튼
            selectButton.topAnchor.constraint(equalTo: selectedLocationLabel.bottomAnchor, constant: 12),
            selectButton.leadingAnchor.constraint(equalTo: bottomContainer.leadingAnchor, constant: 16),
            selectButton.trailingAnchor.constraint(equalTo: bottomContainer.trailingAnchor, constant: -16),
            selectButton.heightAnchor.constraint(equalToConstant: 50),
            
            // 취소 버튼
            cancelButton.topAnchor.constraint(equalTo: selectButton.bottomAnchor, constant: 4),
            cancelButton.centerXAnchor.constraint(equalTo: bottomContainer.centerXAnchor),
            cancelButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    private func setupMapView() {
        mapView.delegate = self
        
        // 한국 중심으로 초기 설정
        let koreaCenter = CLLocationCoordinate2D(latitude: 36.5, longitude: 127.5)
        let region = MKCoordinateRegion(center: koreaCenter, latitudinalMeters: 500000, longitudinalMeters: 500000)
        mapView.setRegion(region, animated: false)
        
        // 탭 제스처 추가
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(mapTapped(_:)))
        mapView.addGestureRecognizer(tapGesture)
    }
    
    private func setupActions() {
        searchBar.delegate = self
        selectButton.addTarget(self, action: #selector(selectButtonTapped), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Actions
    
    @objc private func mapTapped(_ gesture: UITapGestureRecognizer) {
        let point = gesture.location(in: mapView)
        let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        selectLocation(location)
    }
    
    @objc private func selectButtonTapped() {
        guard let location = selectedLocation else { return }
        
        // 햅틱 피드백
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
        
        delegate?.didSelectLocation(location, name: selectedLocationName)
        dismiss(animated: true)
    }
    
    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
    }
    
    // MARK: - Private Methods
    
    private func selectLocation(_ location: CLLocation) {
        selectedLocation = location
        
        // 기존 핀 제거
        mapView.removeAnnotations(mapView.annotations.filter { !($0 is MKUserLocation) })
        
        // 새 핀 추가
        let annotation = MKPointAnnotation()
        annotation.coordinate = location.coordinate
        mapView.addAnnotation(annotation)
        
        // 지역명 검색
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            DispatchQueue.main.async {
                if let placemark = placemarks?.first {
                    let name = self?.formatLocationName(from: placemark) ?? "선택된 위치"
                    self?.selectedLocationName = name
                    self?.selectedLocationLabel.text = name
                    annotation.title = name
                } else {
                    self?.selectedLocationName = "선택된 위치"
                    self?.selectedLocationLabel.text = "선택된 위치"
                }
                
                // 선택 버튼 활성화
                self?.selectButton.isEnabled = true
                self?.selectButton.alpha = 1.0
                
                // 버튼 활성화 애니메이션
                UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.3) {
                    self?.selectButton.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
                } completion: { _ in
                    UIView.animate(withDuration: 0.2) {
                        self?.selectButton.transform = .identity
                    }
                }
            }
        }
    }
    
    private func formatLocationName(from placemark: CLPlacemark) -> String {
        var components: [String] = []
        
        if let administrativeArea = placemark.administrativeArea {
            components.append(administrativeArea)
        }
        
        if let locality = placemark.locality {
            components.append(locality)
        }
        
        if let subLocality = placemark.subLocality {
            components.append(subLocality)
        }
        
        return components.isEmpty ? "선택된 위치" : components.joined(separator: " ")
    }
    
    private func searchLocation(with query: String) {
        geocoder.geocodeAddressString(query) { [weak self] placemarks, error in
            guard let self = self, let placemark = placemarks?.first else {
                // 검색 실패 알림
                DispatchQueue.main.async {
                    self?.showSearchFailureAlert()
                }
                return
            }
            
            DispatchQueue.main.async {
                if let location = placemark.location {
                    // 지도 이동
                    let region = MKCoordinateRegion(center: location.coordinate,
                                                   latitudinalMeters: 10000,
                                                   longitudinalMeters: 10000)
                    self.mapView.setRegion(region, animated: true)
                    
                    // 위치 선택
                    self.selectLocation(location)
                }
            }
        }
    }
    
    private func showSearchFailureAlert() {
        let alert = UIAlertController(
            title: "검색 실패",
            message: "해당 주소를 찾을 수 없습니다.\n다른 검색어를 시도해보세요.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - MKMapViewDelegate
extension LocationSelectionViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else { return nil }

        let identifier = "LocationPin"
        let annotationView: MKAnnotationView
        if #available(iOS 16.0, *) {
            var markerView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
            if markerView == nil {
                markerView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                markerView?.canShowCallout = true
                markerView?.markerTintColor = UIColor(white: 0.85, alpha: 1.0)
            } else {
                markerView?.annotation = annotation
            }
            annotationView = markerView!
        } else {
            var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView
            if pinView == nil {
                pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                pinView?.canShowCallout = true
                pinView?.pinTintColor = UIColor(white: 0.85, alpha: 1.0)
            } else {
                pinView?.annotation = annotation
            }
            annotationView = pinView!
        }
        return annotationView
    }
}

// MARK: - UISearchBarDelegate
extension LocationSelectionViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        
        guard let searchText = searchBar.text, !searchText.isEmpty else { return }
        searchLocation(with: searchText)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }
}

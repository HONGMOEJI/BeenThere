//
//  RecordViewController.swift
//  BeenThere
//
//  방문 기록 작성/편집 화면
//

import UIKit
import PhotosUI
import Combine
import FirebaseAuth

class RecordViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UITextViewDelegate, PHPickerViewControllerDelegate {
    private let viewModel: RecordViewModel
    private let recordView = RecordView()
    private var cancellables = Set<AnyCancellable>()
    private let mode: RecordMode
    
    // 완료 콜백
    var onSaveCompletion: ((VisitRecord) -> Void)?
    
    // MARK: - Init
    convenience init(tourSite: TourSiteDetail) {
        let viewModel = RecordViewModel(tourSite: tourSite)
        self.init(viewModel: viewModel, mode: .create)
    }
    
    init(viewModel: RecordViewModel, mode: RecordMode) {
        self.viewModel = viewModel
        self.mode = mode
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Lifecycle
    override func loadView() {
        view = recordView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupBindings()
        setupActions()
        setupCollectionViews()
        setupTextView()
        updateUIFromViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // MARK: - Setup Methods
    private func setupNavigationBar() {
        title = mode == .create ? "기록 작성" : "기록 수정"
        if let navigationBar = navigationController?.navigationBar {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .themeBackground
            appearance.shadowColor = .clear
            appearance.titleTextAttributes = [
                .foregroundColor: UIColor.themeTextPrimary,
                .font: UIFont.systemFont(ofSize: 17, weight: .semibold)
            ]
            navigationBar.standardAppearance = appearance
            navigationBar.scrollEdgeAppearance = appearance
            navigationBar.compactAppearance = appearance
            navigationBar.tintColor = .themeTextPrimary
        }
        let cancelButton = UIBarButtonItem(
            title: "취소",
            style: .plain,
            target: self,
            action: #selector(cancelTapped)
        )
        cancelButton.tintColor = .themeTextPrimary
        navigationItem.leftBarButtonItem = cancelButton
    }
    
    private func setupBindings() {
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                self?.recordView.saveButton.isEnabled = !isLoading
                self?.recordView.saveButton.setTitle(
                    isLoading ? "저장 중..." : (self?.mode == .create ? "기록 저장하기" : "기록 수정하기"),
                    for: .normal
                )
                self?.recordView.saveButton.alpha = isLoading ? 0.6 : 1.0
            }
            .store(in: &cancellables)
        
        viewModel.$isSaveEnabled
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isEnabled in
                self?.recordView.updateSaveButtonState(isEnabled: isEnabled)
            }
            .store(in: &cancellables)
        
        viewModel.$showError
            .receive(on: DispatchQueue.main)
            .sink { [weak self] showError in
                if showError { self?.showErrorAlert() }
            }
            .store(in: &cancellables)
        
        viewModel.$showSuccessAlert
            .receive(on: DispatchQueue.main)
            .sink { [weak self] showSuccess in
                if showSuccess { self?.showSuccessAlert() }
            }
            .store(in: &cancellables)
        
        viewModel.$content
            .receive(on: DispatchQueue.main)
            .sink { [weak self] content in
                self?.recordView.updatePlaceholderVisibility(hasText: !content.isEmpty)
                self?.recordView.updateContentCount(content.count)
            }
            .store(in: &cancellables)
        
        viewModel.$rating
            .receive(on: DispatchQueue.main)
            .sink { [weak self] rating in
                self?.recordView.updateStarRating(rating)
            }
            .store(in: &cancellables)
        
        viewModel.$imageItems
            .receive(on: DispatchQueue.main)
            .sink { [weak self] items in
                self?.recordView.photoCollectionView.reloadData()
                self?.recordView.updatePhotoCount(items.count)
            }
            .store(in: &cancellables)
        
        viewModel.$tags
            .receive(on: DispatchQueue.main)
            .sink { [weak self] tags in
                self?.recordView.tagCollectionView.reloadData()
                self?.recordView.updateTagCount(tags.count)
            }
            .store(in: &cancellables)
        
        viewModel.$newTag
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newTag in
                if self?.recordView.tagInputField.text != newTag {
                    self?.recordView.tagInputField.text = newTag
                }
            }
            .store(in: &cancellables)
    }
    
    private func setupActions() {
        for (index, button) in recordView.starButtons.enumerated() {
            button.tag = index + 1
            button.addTarget(self, action: #selector(starButtonTapped(_:)), for: .touchUpInside)
        }
        setupWeatherButtons()
        setupMoodButtons()
        recordView.addPhotoButton.addTarget(self, action: #selector(addPhotoTapped), for: .touchUpInside)
        recordView.addTagButton.addTarget(self, action: #selector(addTagTapped), for: .touchUpInside)
        recordView.saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        recordView.visitDatePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        recordView.tagInputField.addTarget(self, action: #selector(tagTextChanged(_:)), for: .editingChanged)
        recordView.tagInputField.addTarget(self, action: #selector(tagEditingDidEndOnExit), for: .editingDidEndOnExit)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    private func setupWeatherButtons() {
        recordView.weatherStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for (index, weather) in WeatherType.allCases.enumerated() {
            let button = createSelectionButton(title: "\(weather.emoji)")
            button.tag = index
            button.addAction(UIAction { [weak self] _ in
                self?.weatherButtonTapped(weather)
            }, for: .touchUpInside)
            recordView.weatherStackView.addArrangedSubview(button)
        }
    }
    
    private func setupMoodButtons() {
        recordView.moodStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for (index, mood) in MoodType.allCases.enumerated() {
            let button = createSelectionButton(title: "\(mood.emoji)")
            button.tag = index
            button.addAction(UIAction { [weak self] _ in
                self?.moodButtonTapped(mood)
            }, for: .touchUpInside)
            recordView.moodStackView.addArrangedSubview(button)
        }
    }
    
    private func createSelectionButton(title: String) -> UIButton {
        let button = UIButton(type: .custom)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 24)
        button.setTitleColor(.themeTextSecondary, for: .normal)
        button.backgroundColor = UIColor.white.withAlphaComponent(0.05)
        button.setTitleColor(.themeTextPrimary, for: .selected)
        button.layer.cornerRadius = 8
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.white.withAlphaComponent(0.1).cgColor
        if #available(iOS 15.0, *) {
            // On iOS 15+, custom buttons ignore highlight by default; no action needed
        } else {
            button.adjustsImageWhenHighlighted = false
            button.showsTouchWhenHighlighted = false
        }
        button.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchDown)
        button.addTarget(self, action: #selector(buttonReleased(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        return button
    }
    
    private func setupCollectionViews() {
        recordView.photoCollectionView.dataSource = self
        recordView.photoCollectionView.delegate = self
        recordView.photoCollectionView.register(PhotoCell.self, forCellWithReuseIdentifier: "PhotoCell")
        
        recordView.tagCollectionView.dataSource = self
        recordView.tagCollectionView.delegate = self
        recordView.tagCollectionView.register(TagCell.self, forCellWithReuseIdentifier: "TagCell")
    }

    private func setupTextView() {
        recordView.contentTextView.delegate = self
    }
    
    private func updateUIFromViewModel() {
        recordView.placeTitleLabel.text = viewModel.placeTitle
        recordView.placeAddressLabel.text = viewModel.placeAddress
        recordView.visitDatePicker.date = viewModel.visitDate
        recordView.contentTextView.text = viewModel.content
        recordView.updateStarRating(viewModel.rating)
        recordView.updatePlaceholderVisibility(hasText: !viewModel.content.isEmpty)
        recordView.updateContentCount(viewModel.content.count)
        updateWeatherButtonStates()
        updateMoodButtonStates()
        recordView.saveButton.setTitle(
            mode == .create ? "기록 저장하기" : "기록 수정하기",
            for: .normal
        )
    }
    
    // MARK: - Actions
    @objc private func cancelTapped() {
        if hasUnsavedChanges() {
            showCancelConfirmAlert()
        } else {
            dismiss(animated: true)
        }
    }
    
    @objc private func starButtonTapped(_ sender: UIButton) {
        let rating = sender.tag
        viewModel.rating = rating
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    private func weatherButtonTapped(_ weather: WeatherType) {
        if viewModel.selectedWeather == weather {
            viewModel.selectedWeather = nil
        } else {
            viewModel.selectedWeather = weather
        }
        updateWeatherButtonStates()
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    private func moodButtonTapped(_ mood: MoodType) {
        if viewModel.selectedMood == mood {
            viewModel.selectedMood = nil
        } else {
            viewModel.selectedMood = mood
        }
        updateMoodButtonStates()
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    @objc private func buttonPressed(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            sender.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }
    }
    
    @objc private func buttonReleased(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            sender.transform = .identity
        }
    }
    
    private func updateWeatherButtonStates() {
        for (index, button) in recordView.weatherStackView.arrangedSubviews.enumerated() {
            guard let button = button as? UIButton, index < WeatherType.allCases.count else { continue }
            let weather = WeatherType.allCases[index]
            let isSelected = viewModel.selectedWeather == weather
            button.isSelected = isSelected
            if isSelected {
                button.backgroundColor = UIColor.white.withAlphaComponent(0.2)
                button.layer.borderColor = UIColor.white.withAlphaComponent(0.4).cgColor
                button.layer.borderWidth = 2
            } else {
                button.backgroundColor = UIColor.white.withAlphaComponent(0.05)
                button.layer.borderColor = UIColor.white.withAlphaComponent(0.1).cgColor
                button.layer.borderWidth = 1
            }
        }
    }
    
    private func updateMoodButtonStates() {
        for (index, button) in recordView.moodStackView.arrangedSubviews.enumerated() {
            guard let button = button as? UIButton, index < MoodType.allCases.count else { continue }
            let mood = MoodType.allCases[index]
            let isSelected = viewModel.selectedMood == mood
            button.isSelected = isSelected
            if isSelected {
                button.backgroundColor = UIColor.white.withAlphaComponent(0.2)
                button.layer.borderColor = UIColor.white.withAlphaComponent(0.4).cgColor
                button.layer.borderWidth = 2
            } else {
                button.backgroundColor = UIColor.white.withAlphaComponent(0.05)
                button.layer.borderColor = UIColor.white.withAlphaComponent(0.1).cgColor
                button.layer.borderWidth = 1
            }
        }
    }
    
    @objc private func addPhotoTapped() {
        let remainingSlots = 10 - viewModel.imageItems.count
        guard remainingSlots > 0 else {
            showErrorAlert("최대 10장까지 선택할 수 있습니다.")
            return
        }
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = remainingSlots
        configuration.filter = .images
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    @objc private func addTagTapped() {
        viewModel.addTag()
        recordView.tagInputField.text = ""
        recordView.tagInputField.resignFirstResponder()
    }
    
    @objc private func saveTapped() {
        view.endEditing(true)
        Task {
            await viewModel.saveRecord()
        }
    }
    
    @objc private func dateChanged(_ sender: UIDatePicker) {
        viewModel.visitDate = sender.date
    }
    
    @objc private func tagTextChanged(_ sender: UITextField) {
        viewModel.newTag = sender.text ?? ""
    }
    
    @objc private func tagEditingDidEndOnExit() {
        if !viewModel.newTag.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            viewModel.addTag()
            recordView.tagInputField.text = ""
        }
        recordView.tagInputField.resignFirstResponder()
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Keyboard Handling
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardHeight = keyboardFrame.cgRectValue.height
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
        recordView.scrollView.contentInset = contentInsets
        recordView.scrollView.scrollIndicatorInsets = contentInsets
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        recordView.scrollView.contentInset = .zero
        recordView.scrollView.scrollIndicatorInsets = .zero
    }
    
    // MARK: - Helper Methods
    private func hasUnsavedChanges() -> Bool {
        switch mode {
        case .create:
            return !viewModel.content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                   !viewModel.imageItems.isEmpty ||
                   !viewModel.tags.isEmpty ||
                   viewModel.selectedWeather != nil ||
                   viewModel.selectedMood != nil
        case .edit:
            return true
        }
    }
    
    private func showCancelConfirmAlert() {
        let alert = UIAlertController(
            title: "작성 중인 내용이 있습니다",
            message: "저장하지 않고 나가시겠습니까?\n작성된 내용은 사라집니다.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "계속 작성", style: .cancel))
        alert.addAction(UIAlertAction(title: "나가기", style: .destructive) { [weak self] _ in
            self?.dismiss(animated: true)
        })
        present(alert, animated: true)
    }
    
    private func showErrorAlert() {
        let alert = UIAlertController(
            title: "오류",
            message: viewModel.errorMessage,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
    
    private func showErrorAlert(_ message: String) {
        let alert = UIAlertController(
            title: "오류",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
    
    private func showSuccessAlert() {
        print("🎉 [SUCCESS] showSuccessAlert 호출됨")
        
        let message = mode == .create ? "기록이 저장되었습니다." : "기록이 수정되었습니다."
        let alert = UIAlertController(
            title: "완료",
            message: message,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "확인", style: .default) { [weak self] _ in
            print("🎉 [SUCCESS] 확인 버튼 클릭됨")
            
            guard let self = self else {
                print("❌ [SUCCESS] self가 nil")
                return
            }
            
            // ViewModel에서 업데이트된 기록 가져오기
            if let updatedRecord = self.viewModel.getUpdatedRecord() {
                print("🎉 [SUCCESS] 업데이트된 기록: \(updatedRecord.placeTitle)")
                
                // 1. 먼저 dismiss
                self.dismiss(animated: true) {
                    print("🎉 [SUCCESS] dismiss 완료, 콜백 호출")
                    
                    // 2. dismiss 완료 후 콜백 호출
                    if let completion = self.onSaveCompletion {
                        print("🎉 [SUCCESS] onSaveCompletion 콜백 호출 중...")
                        completion(updatedRecord)
                        print("✅ [SUCCESS] onSaveCompletion 콜백 호출 완료")
                    } else {
                        print("❌ [SUCCESS] onSaveCompletion이 nil")
                    }
                }
            } else {
                print("❌ [SUCCESS] updatedRecord를 가져올 수 없음")
                self.dismiss(animated: true)
            }
        })
        
        present(alert, animated: true)
    }

    // MARK: - UICollectionViewDataSource & Delegate
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == recordView.photoCollectionView {
            return viewModel.imageItems.count
        } else if collectionView == recordView.tagCollectionView {
            return viewModel.tags.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == recordView.photoCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
            cell.configure(with: viewModel.imageItems[indexPath.item])
            cell.onDelete = { [weak self] in
                self?.viewModel.removeImage(at: indexPath.item)
            }
            return cell
        } else if collectionView == recordView.tagCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TagCell", for: indexPath) as! TagCell
            cell.configure(with: viewModel.tags[indexPath.item])
            cell.onDelete = { [weak self] in
                let tag = self?.viewModel.tags[indexPath.item] ?? ""
                self?.viewModel.removeTag(tag)
            }
            return cell
        }
        return UICollectionViewCell()
    }
    
    // MARK: - UITextViewDelegate
    func textViewDidChange(_ textView: UITextView) {
        viewModel.content = textView.text
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let rect = textView.convert(textView.bounds, to: self.recordView.scrollView)
            self.recordView.scrollView.scrollRectToVisible(rect, animated: true)
        }
    }
    
    // MARK: - PHPickerViewControllerDelegate
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        for result in results {
            result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
                if let image = object as? UIImage {
                    DispatchQueue.main.async {
                        self?.viewModel.addImage(image)
                    }
                } else if let error = error {
                    print("이미지 로드 실패: \(error)")
                }
            }
        }
    }
}

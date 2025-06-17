# 🗺️ 다녀오다.

<div align="center">

[![Demo Video](https://img.shields.io/badge/YouTube-Project%20Demo-FF0000?style=for-the-badge&logo=youtube&logoColor=white)](https://youtu.be/dKOGrfb-Lrg)
[![Swift](https://img.shields.io/badge/Swift-FA7343?style=for-the-badge&logo=swift&logoColor=white)](https://swift.org/)
[![iOS](https://img.shields.io/badge/iOS-000000?style=for-the-badge&logo=ios&logoColor=white)](https://developer.apple.com/ios/)
[![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com/)

**여행의 순간을 기록하고, 추억을 지도 위에 새겨보세요** ✨

*나만의 여행지, 추억, 방문 기록을 관리하는 iOS 앱*

</div>

---

## 🌟 프로젝트 소개

**다녀오다**는 여러분의 소중한 여행 경험을 디지털로 기록하고 관리할 수 있는 iOS 앱입니다. 
방문했던 장소들을 표시하고, 그 순간의 감정과 추억을 사진과 메모로 남겨보세요.

---

## ✨ 주요 기능

<table>
<tr>
<td width="50%">

### 🚪 **온보딩 & 로그인**
- Firebase Auth 기반 간편 인증
- 직관적인 사용자 온보딩 경험

### 🏠 **메인 대시보드**
- 내 주변 카테고리별 여행지 탐색
- 한국관광공사 관광정보 API 실시간 연동
- 개인화된 추천 시스템

### 📋 **여행지 상세 정보**
- 고화질 대표 사진 갤러리
- 상세한 설명 및 시설 정보
- 실시간 운영 상태 확인

</td>
<td width="50%">

### 🗺️ **지도 & 내비게이션**
- 인터랙티브 지도 기반 탐색
- 실시간 길찾기 및 네비게이션
- 커스텀 마커 및 클러스터링

### 💭 **추억 기록**
- 다중 사진 업로드
- 리치 텍스트 메모 작성
- Firebase Storage/Firestore 실시간 동기화

### 📊 **통계 & 분석**
- 방문 장소 통계 시각화
- 사진/메모 활동 분석
- 개인 여행 패턴 인사이트

</td>
</tr>
</table>

---

## 🛠️ 기술 스택

<div align="center">

### **Frontend**
![Swift](https://img.shields.io/badge/Swift-FA7343?style=for-the-badge&logo=swift&logoColor=white)
![UIKit](https://img.shields.io/badge/UIKit-2396F3?style=for-the-badge&logo=apple&logoColor=white)
![MapKit](https://img.shields.io/badge/MapKit-4A90E2?style=for-the-badge&logo=apple&logoColor=white)

### **Backend & Services**
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
![Firestore](https://img.shields.io/badge/Firestore-FF6F00?style=for-the-badge&logo=firebase&logoColor=white)
![Firebase Storage](https://img.shields.io/badge/Firebase_Storage-FF8C00?style=for-the-badge&logo=firebase&logoColor=white)

### **APIs & Integration**
![Korea Tourism API](https://img.shields.io/badge/한국관광공사_API-00A86B?style=for-the-badge&logo=southkorea&logoColor=white)

</div>

---

## 🚀 설치 및 실행 방법

### **필수 요구사항**
- Xcode 14.0 이상
- iOS 14.0 이상
- Swift 5.0 이상

### **설치 단계**

```bash
# 1. 저장소 클론
git clone https://github.com/HONGMOEJI/BeenThere.git
cd BeenThere

# 2. Workspace 파일 열기
open BeenThere.xcworkspace
```

### **Firebase 설정**

1. [Firebase Console](https://console.firebase.google.com/)에서 새 프로젝트 생성
2. `GoogleService-Info.plist` 파일 다운로드
3. Xcode /Resources에 파일 추가
4. Authentication, Firestore, Storage 서비스 활성화

### **API 키 설정**

```swift
// APIConstants.swift에 API 키 추가
struct TourAPI {
    static let serviceKey = "YOUR_SERVICE_KEY"
}
```

---

## 👨‍💻 개발자

<div align="center">

<a href="https://github.com/HONGMOEJI">
  <img src="https://github.com/HONGMOEJI.png" width="100px" alt="HONGMOEJI"/>
  <br/>
  <strong>HONGMOEJI</strong>
</a>

*iOS Developer & Project Creator*

[![GitHub](https://img.shields.io/badge/GitHub-100000?style=for-the-badge&logo=github&logoColor=white)](https://github.com/HONGMOEJI)

</div>

---

## 🙏 감사의 말

- [한국관광공사](https://www.visitkorea.or.kr/) - 관광 정보 API 제공
- [Firebase](https://firebase.google.com/) - 백엔드 서비스 제공
- [Apple](https://developer.apple.com/) - 개발 플랫폼 제공

---

<div align="center">

**⭐ 이 프로젝트가 도움이 되었다면 별표를 눌러주세요! ⭐**
</div>

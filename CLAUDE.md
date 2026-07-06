# mybio.kr - Flutter Project

Flutter 크로스플랫폼 앱 (웹 + Android + iOS)

## 빌드 & 배포
- `flutter build web --release` → `build/web` 생성
- `firebase deploy --only hosting` → mybio.kr 배포
- Firebase 프로젝트: `my-profile-5209e`

## 구조
- `lib/` — Dart 소스코드
- `lib/screens/` — 화면 (login, dashboard, public_profile)
- `lib/widgets/` — 위젯 (profile_card, category_section, modals)
- `lib/constants.dart` — 색상, 카테고리 정의
- `lib/firebase_options.dart` — Firebase 설정

## 앱 출시 참고
- Android: `flutter build apk` 또는 `flutter build appbundle`
- iOS: `flutter build ios` (macOS 필요)

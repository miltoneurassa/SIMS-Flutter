# SIMS Flutter App — Setup Guide

## Prerequisites
- Flutter SDK 3.x+ installed → https://flutter.dev/docs/get-started/install
- Dart SDK 3.x+ (bundled with Flutter)
- For Android: Android Studio + Android SDK
- For iOS: Xcode 15+ (Mac only)

## Quick Start

```bash
# 1. Navigate to this folder
cd flutter_app

# 2. Install dependencies
flutter pub get

# 3. Run on Android
flutter run -d android

# 4. Run on iOS (Mac only)
flutter run -d ios

# 5. Build release APK for Android
flutter build apk --release

# 6. Build release IPA for iOS
flutter build ipa --release
```

## Project Structure

```
flutter_app/
├── lib/
│   ├── main.dart                    # App entry point
│   ├── common/
│   │   ├── config.dart              # API endpoints & constants
│   │   ├── theme.dart               # Colors, fonts, widget styles
│   │   ├── models/
│   │   │   └── user_model.dart      # User data model
│   │   └── services/
│   │       ├── api_service.dart     # HTTP API calls
│   │       └── storage_service.dart # Local storage (SharedPreferences)
│   ├── screens/
│   │   ├── splash_screen.dart       # Animated launch screen
│   │   ├── login_screen.dart        # Login + QR code scanner
│   │   ├── home_screen.dart         # Dashboard with 10 module grid
│   │   └── report_screen.dart       # Query result display
│   └── widgets/
│       └── dashboard_card.dart      # Animated module card widget
├── android/
│   └── app/src/main/
│       └── AndroidManifest.xml      # Android permissions
├── ios/
│   └── Runner/
│       └── Info.plist               # iOS permissions
└── pubspec.yaml                     # Dependencies
```

## Features
- Beautiful Material Design 3 UI with gradient headers
- Animated splash screen
- Secure login with username/password
- QR Code login (scan SIMS QR code from web)
- Dashboard with 10 colorful module cards
- QR Code scanner for each module
- Student data report viewer
- Offline detection with friendly messages
- Runs identically on Android & iOS
```

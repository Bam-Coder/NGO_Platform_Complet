# NGO Agent Mobile App - Deployment Checklist

## Pre-Release Checklist ✅

### Code Quality
- [x] `flutter analyze` passes with no errors
- [x] `flutter test` all tests pass
- [x] Code formatted with `dart format`
- [x] No unused imports or variables
- [x] Comments added to complex logic

### Features Tested
- [x] Login flow works
- [x] Session persistence works
- [x] Project list loads
- [x] Expense form submits
- [x] Report form submits
- [x] Logout clears data
- [x] Navigation between screens works

### Performance
- [ ] App loads < 3s
- [ ] UI smooth 60fps
- [ ] No memory leaks
- [ ] ProGuard enabled (Android)

### Compatibility
- [ ] Tested on Android 7.0+
- [ ] Tested on iOS 11.0+
- [ ] Responsive on phones (4.5"-6.5")
- [ ] Responsive on tablets

### Security
- [ ] JWT tokens never logged
- [ ] Passwords never stored plaintext
- [ ] API calls use HTTPS (in production)
- [ ] No sensitive data in logs

### Documentation
- [x] README.md complete
- [x] Setup instructions clear
- [x] Code comments sufficient
- [x] API integration documented

---

## Build Instructions

### Android APK (Testing)
```bash
flutter build apk --debug
# → build/app/outputs/flutter-apk/app-debug.apk
```

### Android Release APK
```bash
flutter build apk --release
# → build/app/outputs/flutter-apk/app-release.apk
```

### Android App Bundle (PlayStore)
```bash
flutter build appbundle --release
# → build/app/outputs/bundle/release/app-release.aab
```

### iOS Simulator
```bash
flutter build ios --simulator
```

### iOS Device (IPA)
```bash
flutter build ipa --release
# → build/ios/ipa/ngo_app.ipa
```

---

## Local Testing

### Desktop Emulator
```bash
# Start emulator
emulator -avd Pixel_4_API_30

# Run app
flutter run
```

### Physical Device
```bash
# Enable USB debugging
# Connect device via USB

flutter devices  # Verify device detected
flutter run      # Run app
```

### Remote Testing
```bash
# Build APK
flutter build apk --release

# Share APK with testers
# or use Firebase App Distribution
```

---

## Backend API Checks

Before deploying, ensure backend has:

- [x] POST `/auth/login` endpoint
- [x] GET `/projects` endpoint
- [x] GET `/projects/{id}` endpoint
- [x] GET `/expenses` endpoint
- [x] POST `/expenses` endpoint
- [x] GET `/impact-reports` endpoint
- [x] POST `/impact-reports` endpoint

---

## Environment Configuration

### Development
```dart
const String baseUrl = 'http://10.0.2.2:3000';
const bool debugLogging = true;
```

### Staging
```dart
const String baseUrl = 'https://staging-api.ngo.com';
const bool debugLogging = true;
```

### Production
```dart
const String baseUrl = 'https://api.ngo.com';
const bool debugLogging = false;
```

---

## Distribution Channels

### Android
- **Play Store**: Via Google Play Console
- **Direct APK**: Via website download
- **Beta Testing**: Via Firebase App Distribution

### iOS
- **App Store**: Via Apple App Store
- **TestFlight**: For beta testing
- **Ad-hoc**: For internal distribution

---

## Version Management

Current: `1.0.0-alpha`

Versioning:
- `1.0.0` = First release
- `1.1.0` = New features
- `1.0.1` = Bug fixes
- `2.0.0` = Major rewrite

---

## Monitoring Post-Launch

- [ ] Crash reporting (Firebase)
- [ ] Usage analytics
- [ ] Performance monitoring
- [ ] User feedback collection

---

## Future Releases

### 1.1.0 (Phase 2)
- Offline support
- Photo uploads
- GPS integration
- Sync background

### 1.2.0 (Phase 3)
- Push notifications
- Biometric auth
- Dark mode
- Multi-language

### 2.0.0 (Phase 4)
- Complete redesign
- Performance improvements
- New features based on feedback

# VidiVideo Flutter Client

This Flutter app is structured as one client with two flows:

- Desktop/admin flow: dashboard, users, reports, staff, PDF report entry points.
- Mobile/user flow: recommended feed, following feed, search, create video, profile, subscriptions.

## Structure

```text
lib/
  main.dart
  src/
    app/                 App root and routes
    core/
      config/            API URL and environment config
      network/           API client base
      storage/           Session/token storage placeholder
      theme/             Material theme
    shared/widgets/      Reusable UI widgets
    features/
      auth/
      admin/
      mobile/
      videos/
```

## Running

Windows desktop:

```powershell
flutter run -d windows --dart-define=API_BASE_URL=http://localhost:5000
```

Android emulator:

```powershell
flutter run -d emulator --dart-define=API_BASE_URL=http://10.0.2.2:5000
```

Android SDK is only required for emulator/APK builds. You can still work on Dart/Flutter code before the Android setup is complete.

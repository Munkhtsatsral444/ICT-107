# Meeting Silent Scheduler
Meeting Silent Scheduler is a responsive Flutter application for managing meeting schedules. It can automatically change an Android device to silent mode during scheduled meeting hours.

## Main Features

- Create meeting schedules
- Select meeting date, time, and duration
- Automatically use Silent mode
- Enable, disable, and delete meetings
- Receive pre-meeting notifications
- Display time for major international cities
- Switch between English and German
- Switch between light and dark themes
- Open Zoom, Google Meet, and Microsoft Teams
- Responsive layout for mobile, tablet, and web
- Store meetings and settings locally

## Technologies

- Flutter
- Dart
- Kotlin for Android functionality
- SharedPreferences for local storage
- JSON for meeting data
- Flutter Local Notifications
- Timezone package
- Sound Mode package

## Project Structure

```text
lib/
├── models/
│   └── meeting.dart
├── pages/
│   ├── home_page.dart
│   ├── schedule_page.dart
│   ├── settings_page.dart
│   └── world_clock_page.dart
├── services/
│   ├── alarm_service.dart
│   ├── notification_service.dart
│   ├── sound_service.dart
│   └── storage_service.dart
├── widgets/
│   └── clock_card.dart
└── main.dart
```

## Run the App

```bash
flutter pub get
flutter run
```

## Build APK

```bash
flutter build apk --release
```

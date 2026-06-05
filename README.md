# aspiro_trade

Aspiro Trade mobile client (Flutter).

## Configuration

The API base URL is injected at build time via `--dart-define` (no `.env`
bundled into the APK/IPA).

```dart
const apiUrl = String.fromEnvironment(
  'API_URL',
  defaultValue: 'http://localhost:3001',
);
```

## Build

Debug / local run:

```bash
flutter pub get
flutter run --dart-define=API_URL=http://localhost:3001
```

Release Android:

```bash
flutter build apk --release \
  --dart-define=API_URL=https://tradeaspiro.ru

flutter build appbundle --release \
  --dart-define=API_URL=https://tradeaspiro.ru
```

Release iOS:

```bash
flutter build ipa --release \
  --dart-define=API_URL=https://tradeaspiro.ru
```

Versioning is controlled from `pubspec.yaml` (`version: X.Y.Z+build`).
iOS `MARKETING_VERSION` / `CURRENT_PROJECT_VERSION` in
`ios/Runner.xcodeproj/project.pbxproj` must be kept in sync with it.

## Signing

Android keystore (`aspiro_trade_key.jks`) and `key.properties` are
git-ignored. Keep them in secure storage — losing the keystore means
the app cannot be updated on Google Play without a key reset.

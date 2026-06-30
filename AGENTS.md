# 心迹 (xinji-app) — Agent Guide

Flutter 随笔 app running on `sdk: ^3.2.0`, stable channel. Flutter 3.27.x pinned in CI.

## Commands

```bash
flutter pub get                              # install deps (generates .flutter-plugins)
dart run build_runner build --delete-conflicting-outputs  # generate .g.dart files
flutter analyze --no-fatal-warnings --no-fatal-infos  # lint (CI uses both flags)
flutter test                                  # run all tests
flutter test --coverage && genhtml coverage/lcov.info -o coverage/html  # test + html report
flutter build apk --debug                     # build debug APK
flutter build apk --split-per-abi             # smaller per-arch APKs
```

**Order matters**: `pub get → codegen → analyze → test → build`. Generated `.g.dart` files are gitignored — must regen after each `pub get`.

## Architecture

- **State**: Riverpod 2.x (`@riverpod` code-gen). `StateNotifier` for the write form only (`lib/presentation/screens/write/write_provider.dart`).
- **DB**: Drift (SQLite). WAL mode. schemaVersion 4. 4 tables: `diary_entries`, `mood_records`, `tags`, `todos`.
  - Always `import '../database/app_database.dart' as db` and use `db.` prefix for generated types (`db.DiaryEntriesCompanion`, `db.AppDatabase`).
- **Router**: GoRouter with `ShellRoute` for bottom nav (3 tabs: timeline/insights/profile), push routes for write/detail/story/search.
- **Layers**: `domain/` (models + repo interfaces) → `data/` (Drift impls) → `engine/` → `presentation/` (providers + screens).
- **Engines**: `MoodAnalysisEngine`, `MoodTrendEngine`, `StoryEngine`, `SearchEngine`, `ExportEngine`, `ReminderEngine`, `ScrollSyncEngine` (ChangeNotifier).
- **Entry**: `lib/main.dart` → `initializeDateFormatting('zh_CN')` then `ProviderScope` → `XinjiApp`.

## Key Packages

- `fl_chart` for mood trend charts, `image_picker` for photos, `flutter_local_notifications` for reminders.
- `equatable` on domain models, `json_annotation` + `json_serializable` available but not yet used.
- `mocktail` declared in `pubspec.yaml` but tests use **hand-rolled mocks** (`test/presentation/providers/diary_providers_test.dart`).
- **Only 2 test files** — `test/domain/model/diary_entry_test.dart` and `test/presentation/providers/diary_providers_test.dart`. No widget/integration tests.

## Style

- 6 moods enum: `MoodType.{happy,calm,longing,sad,anxious,hopeful}` with Chinese labels + emoji. `MoodType` holds its `Color` directly — no switch-based mapping needed.
- Theme: Organic anchor — sand `#E8DCC7` bg, oat `#D4B895` cards, Fraunces (display), Epilogue (body) via `google_fonts`.
- Linter: `prefer_const_constructors`, `prefer_const_declarations` — use `const` everywhere possible.
- `withValues(alpha:)` used for color opacity (not `.withOpacity()`) in widgets.
- No assets directory; icons from Material Design.
- Design docs at `docs/compose/specs/` and `docs/compose/plans/`.

## Build & Runtime Gotchas

- `flutter_local_notifications` requires `coreLibraryDesugaring` in `android/app/build.gradle.kts` or the build fails.
- `Colors.transparent` renders as black on some Android devices — use concrete colors for `Scaffold(backgroundColor:)` instead.

## Build & CI Quirks (Termux-hosted)

- `android/gradlew` shebang must be `#!/usr/bin/bash` — Termux sets `#!/data/data/com.termux/files/usr/bin/bash` which breaks CI.
- `android/settings.gradle.kts:2` has hardcoded `flutterSdkPath = "/data/data/com.termux/files/home/flutter"` — CI patches this with sed.
- NDK `28.2.13676358` in `android/app/build.gradle.kts:9` — auto-downloaded on first build.
- `google_fonts` downloads fonts at app **runtime** (network required on first launch).
- CI workflow (`.github/workflows/ci.yml`) runs `test` then `build` jobs; both include codegen + analyze steps.
- CI uploads coverage artifact and debug APK.

## Server Build (Tencent Cloud LightApp)

All builds and tests run on the remote server (`43.139.123.172`, ubuntu, TISY).

```bash
# SSH key
ssh -i ~/.ssh/Whiper.pem ubuntu@43.139.123.172

# Sync project to server (tar + scp, no rsync on phone)
cd ~/xinji-app
tar czf /tmp/xinji-build.tar.gz \
  --exclude='.dart_tool' --exclude='build' --exclude='.git' --exclude='node_modules' \
  --exclude='*.g.dart' --exclude='.flutter-plugins*' --exclude='*.lock' \
  .
scp /tmp/xinji-build.tar.gz ubuntu@43.139.123.172:~/xinji-build.tar.gz

# On server: extract, fix paths, build
ssh -i ~/.ssh/Whiper.pem ubuntu@43.139.123.172 '
  tar xzf xinji-build.tar.gz -C xinji-app/
  sed -i "1s|.*|#!/usr/bin/bash|" xinji-app/android/gradlew
  sed -i "s|/data/data/com.termux/files/home/flutter|/home/ubuntu/flutter|" xinji-app/android/settings.gradle.kts
  cd xinji-app
  export ANDROID_HOME=$HOME/android-sdk
  ~/flutter/bin/flutter pub get
  ~/flutter/bin/dart run build_runner build --delete-conflicting-outputs
  ~/flutter/bin/flutter build apk --release
'

# Download APK
scp ubuntu@43.139.123.172:~/xinji-app/build/app/outputs/flutter-apk/app-release.apk .
```

**Server env**: Flutter 3.29.2 stable, Android SDK (`~/android-sdk`), Gradle 8.13, Java 21, NDK available.
**Full build time**: ~3 min (pub get + build_runner 30s + assembleRelease 126s).

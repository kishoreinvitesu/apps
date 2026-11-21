# Muggu Studio Development Log

This file tracks implementation progress, verified environment setup,
issues, fixes and next steps. Product requirements remain in
[Muggu_Studio_README.md](Muggu_Studio_README.md).

## 2026-11-13 — Environment setup

### Verified

- Flutter 3.50.0 stable and Dart 3.14.0 are installed at `D:\Software\flutter`.
- VS Code's `dart.flutterSdkPath` and the user PATH point to that SDK.
- Android SDK Command-line Tools are installed under
  `C:\Users\kisho\AppData\Local\Android\Sdk\cmdline-tools\latest`.
- Android SDK licenses are accepted.
- Android Studio and the Android 37 emulator are installed.

### Issues and fixes

- **Flutter SDK Git metadata was incomplete:** restored the matching official
  stable revision so Flutter and Dart commands work.
- **Duplicate Flutter copy in Downloads:** removed the duplicate after verifying
  the D: SDK; approximately 1 GiB was freed. Updated the VS Code Flutter SDK
  setting to use the D: SDK.
- **Android command-line tools were not configured:** copied them into the
  Android SDK's `cmdline-tools\latest` directory and verified `sdkmanager`.
- **Android licenses were not accepted:** accepted them after authorization.
- **Emulator appeared running but ADB initially reported it offline:** after
  cold-boot troubleshooting, a later check showed `emulator-5554` online and
  visible to Flutter.
- **Emulator DLL warning:** the named DLLs were present in the SDK emulator
  directory and `emulator.exe -version` ran successfully. The cause of the
  reported Windows DLL dialog has not been confirmed; recheck if it recurs.
- **Windows desktop tooling warning:** Visual Studio is not installed. This is
  not required for the Android target.

## 2026-11-13 — Sprint 1 foundation

### Implemented

- Created the Android Flutter project scaffold.
- Added the Material 3 Muggu Studio color theme.
- Added English, Telugu and Tamil ARB localization.
- Added a language selector that saves the selection locally.
- Added Home, Explore, Create and Saved routes with a shared bottom navigation
  bar.
- Added localized placeholder states for features planned in later sprints.
- Added project run and validation instructions to `README.md`.

### Issues and fixes

- **Flutter 3.50 Material API migration:** replaced deprecated
  `package:flutter/material.dart` imports with the SDK's `material_ui` package.
- **Tamil widget test lacked Material localizations:** configured the current
  Material localization delegates rather than relying on the older generated
  delegate list.
- **First Android build stopped on a duplicate `material_ui` dependency key:**
  normalized the generated localization dependencies in `pubspec.yaml`. The
  Android build also installed the required NDK and Android SDK platforms
  before reaching that manifest error.
- **Android build initially ran out of C: drive space:** moved the generated
  project `build` directory to `D:\Software\muggu_studio_build\build` and
  created a junction at the project's normal `build` path. The successful
  Gradle retry used D: for its cache and temporary files. C: now has additional
  free space after cleanup.

### Validation

- `dart format lib test` — passed.
- `flutter analyze` — passed with no issues.
- `flutter test` — passed; verifies navigation, Tamil language selection and
  language preference persistence.
- Android APK — built successfully at
  `D:\Software\muggu_studio_build\build\app\outputs\flutter-apk\app-debug.apk`
  and installed on `emulator-5554`.
- The `flutter run --no-resident` command then reported a DevFS service
  disconnect and exited with code 3. A follow-up check confirmed ADB still
  sees the emulator, Flutter lists it as a connected device, and the app
  process is running.

## 2026-11-13 — Emulator verification

### Issues and fixes

- After reboot, the AVD repeatedly appeared offline and briefly showed a
  "System UI isn't responding" prompt. Stopped only the identified AVD
  processes and relaunched it with `-no-snapshot-load` (without wiping data).
  ADB and Flutter then detected `emulator-5554`.
- `flutter build apk --debug --target-platform android-x64` succeeded.
  `flutter install` then looked for a release APK, so installed the generated
  debug APK directly with `adb install -r`.

### Verified on emulator

- Muggu Studio launches and displays the Home screen.
- Explore navigation opens its localized placeholder screen.
- Selecting Tamil updates the app UI, including the navigation labels.
- After force-stopping and relaunching the app, Tamil remains selected.
- The app process remained alive, and no Flutter fatal exception was found
  in the checked log window.

## 2026-11-13 — GitHub publication

- Published the app under `kishoreinvitesu/apps/app-muggu-studio` on `main`.
- Initial commit: `26e31159f369086ab891ca2ade8c294eab1b4ee9`.
- The existing standalone `mobile_apps_dev/muggu_studio` folder was left
  untouched as requested. The repo checkout is the copy to use for GitHub
  changes; removal or consolidation of the standalone copy is deferred.

## 2026-11-13 — Sprint 1 audit

### Findings and adjustments

- The four-tab shell, localized placeholder states, saved language preference
  and documented Material 3 palette match the Sprint 1 scope. Explore, Create
  and Saved remain placeholders for later work.
- The Android scaffold still used its default `muggu_studio` launcher label and
  Flutter logo. Replaced these with the Muggu Studio label, a custom adaptive
  kolam-inspired icon, a legacy vector fallback and a warm-cream launch screen.
- Expanded widget coverage to exercise all four destinations and switch
  between Tamil and Telugu while checking that the locale choice is saved.

### Validation

- `dart format lib test` — passed; no formatting changes were needed.
- `flutter analyze` — passed with no issues.
- `flutter test` — passed; both widget tests succeeded.
- `flutter build apk --debug --target-platform android-x64` — passed.
- Installed the APK on `emulator-5554`; the app process remained alive and the
  checked log window contained no Flutter fatal exception.
- APK metadata reports the `Muggu Studio` application label and the custom
  adaptive launcher icon.
- The application ID remains `com.example.muggu_studio`; choose the permanent
  publisher ID before release, as noted in `README.md`.

Sprint 1 is ready for review. Sprint 2 has not been started.

## 2026-11-13 — Product requirements baseline updated

- Replaced `Muggu_Studio_README.md` with the updated requirements document
  supplied in Downloads.
- Preserved the previous requirements as
  `Muggu_Studio_README_Version_1.md`.
- The updated document is now the product source of truth; Sprint 2 remains
  unstarted.

### Key product direction recorded from the updated brief

- Position Muggu Studio for discovery across Muggu, Kolam, Rangoli and Indian
  Floor Art, while treating regional traditions as distinct and validating
  names, origins and techniques with knowledgeable reviewers.
- The first content milestone is 10 verified designs and 5 complete tutorials;
  the broader MVP targets 60 designs and 20 tutorials. Use only original or
  properly licensed artwork and retain rights/review records.
- Sprint 2 is limited to the offline catalogue and Explore: begin with 10
  reviewed designs, localized metadata, synonym search, combinable/clearable
  filters, relevant sorting, useful empty/error states and locally persisted
  favourites. Do not build the drawing engine in this sprint.
- Keep the product local-first with no account or backend. Defer tutorials,
  tracing and creator work to later sprints; defer ads and one-time Premium
  until the core experience is validated. AI, community and cloud features
  remain out of scope absent explicit approval.
- Preserve English, Telugu and Tamil support, review regional-language content
  with fluent speakers, and validate offline use, accessibility and Android
  rendering as features are added.

## 2026-11-13 — In-app brand heading update

- Kept the product title as `Muggu Studio` in English, Telugu and Tamil, in
  line with the updated brief's instruction to preserve the working brand.
- Replaced the generic Home brand line with the specified positioning:
  `Rangoli • Kolam • Muggu • Indian Floor Art`. The canonical English terms
  remain visible in each UI language; surrounding Home content stays localized.
- Updated widget assertions to check the title and descriptor across locales.

### Validation

- `flutter gen-l10n` — passed.
- `dart format lib test` — passed; no formatting changes were needed.
- `flutter analyze` — passed with no issues.
- `flutter test` — passed; both widget tests succeeded.

## 2026-11-14 — Updated title APK verification

- Built the universal debug APK with `flutter build apk --debug`.
- Installed it on `emulator-5554` with `adb install -r` and visually verified
  the Home screen shows `Muggu Studio` and
  `Rangoli • Kolam • Muggu • Indian Floor Art`.
- The connected Android target was the emulator; no physical phone was
  connected over ADB. A phone with an older install must install this new APK
  to receive the title update; pushing source code does not update an installed
  app.
- APK: `build\app\outputs\flutter-apk\app-debug.apk` (debug build).

## 2026-11-14 — Dependency hygiene

- Retained `material_ui`: the installed Flutter SDK deprecates the old
  `package:flutter/material.dart` entrypoint and directs apps to the official
  Flutter package.
- Removed unused direct dependencies `cupertino_ui` and `cupertino_icons`.
  `cupertino_ui` remains transitively required by `material_ui`.
- `flutter analyze` — passed with no issues.
- `flutter test` — passed; both widget tests succeeded.

## 2026-11-14 — Sprint 2 catalogue and Explore

### Implemented

- Added a versioned bundled JSON catalogue with 10 original geometric
  vector samples and a repeatable thumbnail generator. Each sample has an
  English fallback, generic geometry tags, a WebP thumbnail, null region
  and tradition, and pending content-review status.
- Added typed catalogue models and validation for identifiers, localized
  text, difficulty/review values, grids, thumbnail paths, and vector points;
  duplicate IDs are rejected.
- Implemented offline loading, case-insensitive localized-name/description
  and keyword search, combined filters, and recommended/name/difficulty
  sorting.
- Added an Explore gallery with visible unassigned/pending-review guidance.
  Region, tradition, and dot-grid filters explain when no reviewed choices
  exist instead of inventing categories.
- Added version-1 SQLite favourites and a Saved favourites view. My
  Creations remains explicitly deferred.
- Added English, Telugu, and Tamil UI strings for Explore, filters, sorting,
  favourites, and loading/error states.
- Added `sqflite` and test-only `sqflite_common_ffi`. Installed Pillow for
  local generation of original WebP thumbnails; Python tooling requirements
  are listed in `tools/requirements.txt`.

### Validation

- `flutter pub get` — passed.
- `flutter gen-l10n` — completed using the project `l10n.yaml`.
- `dart format lib test` — passed.
- `flutter analyze` — passed with no issues.
- `flutter test --reporter expanded` — passed; all 8 repository, database,
  and widget tests succeeded.
- `python tools\generate_sample_catalog.py` — generated 10 vector-backed
  catalogue entries and 10 WebP thumbnails.
- `flutter build apk --debug` — passed; installed on `emulator-5554`.
- Emulator verification confirmed the Explore gallery, thumbnails,
  unassigned/review-pending messaging, filter sheet empty-category guidance,
  and a favourite retained in Saved after restarting the app.
- `git diff --check` — passed.

### Limitations and deferred work

- These are generic geometric samples, not verified Muggu, Kolam, or
  Rangoli works. All are intentionally unassigned and pending human review.
  Regional/tradition/dot-grid filter choices will appear only when reviewed
  catalogue data provides them.
- Design details, lessons, drawing, tracing, user creations, and other later
  sprint work remain out of scope.

## 2026-11-21 - Sprint 3 design detail and vector preview

### Implemented

- Added design detail routes for catalogue cards.
- Added a bundled-vector preview renderer that preserves normalized catalogue
  proportions and shows stroke order.
- Added previous, next, play/pause and restart controls for stroke playback.
- Added English, Telugu and Tamil detail, lesson and metadata labels.
- Clearly labeled vector playback as an original preview rather than a
  culturally verified lesson.
- Kept unverified region and tradition metadata hidden behind an explicit
  unassigned state.

### Validation

- `dart format lib test` - passed.
- `flutter analyze` - passed with no issues.
- `flutter test --reporter expanded` - passed; all 10 tests succeeded.
- `flutter build apk --debug --target-platform android-x64` - passed.
- APK:
  `build\app\outputs\flutter-apk\app-debug.apk`

### Limitations

- The existing 10 catalogue entries are original geometric samples with
  pending cultural review, so this sprint provides a vector playback preview,
  not verified traditional lessons.
- Step instructions are generic until authenticated regional content and
  human-reviewed lesson metadata are available.

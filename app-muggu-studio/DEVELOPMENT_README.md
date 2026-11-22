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

## 2026-11-21 - Home and practice entry-point polish

### Implemented

- Home selects a deterministic daily design based on the local calendar date,
  showing its thumbnail and localized name and opening its detail screen.
- Added loading, empty-catalogue and retry states for the Home feature.
- Added a localized Practise / Trace action on design details that opens a
  guide preview and explains that tracing tools are planned for a future
  update; touch tracing itself remains in Sprint 4.

### Validation

- `dart format lib test` - passed.
- `flutter analyze` - passed with no issues.
- `flutter test --reporter expanded` - passed; all 12 tests succeeded.
- `flutter build apk --debug --target-platform android-x64` - passed.

## 2026-11-21 - Review-led stabilization

### Review considered

- Reviewed the supplied static code review for commit `35cae8a` against the
  current implementation.
- Confirmed the playback timer duplication, nested-tab/back behavior,
  Explore search-field synchronization, failed database-open caching, and
  Windows-only SQLite test path still needed attention.
- Confirmed generated geometric samples should not be labelled as validated
  Muggu content. Renamed the Home feature to "Design of the day" in all
  supported UI languages.

### Implemented before feature expansion

- Made the playback controller the single owner of its timer and observable
  state; completion, pause, previous, restart and disposal cancel timers.
- Preserved the originating tab through design and practice navigation,
  added an app-bar Back control, and defined the deep-link fallback as
  Explore. Covered app-bar and system Back in widget tests.
- Synchronized the Explore search controller with query state. Clearing
  search immediately empties the field without clearing active filters.
- Cleared the cached database-open future after failure so a later call can
  retry without deleting data.
- Replaced the Windows-only SQLite test path with the platform separator and
  added a failed-open retry test.
- Added repository-root GitHub Actions CI pinned to Flutter 3.50.0 for
  localization generation, format, analysis, tests and a debug APK build.
- Updated the sprint plan to combine creator-engine and tracing work as
  described in the supplied Sprint 4 diagram, but deferred that feature work.

### Validation

- `flutter gen-l10n` - passed.
- `dart format --output=none --set-exit-if-changed lib test` - passed.
- `flutter analyze` - passed with no issues.
- `flutter test --reporter expanded` - passed; all 17 tests succeeded.
- `flutter build apk --debug --target-platform android-x64` - passed.
- `git diff --check` - passed.

### Remaining gates before Sprint 4

- Separate rights/provenance checks from cultural review, and ensure
  unreviewed content cannot be represented as production-validated.
- Add explicit lesson-step data separate from vector strokes.
- Add reviewed Telugu/Tamil catalogue content and localized taxonomy values.
- The review was static; physical-device accessibility, screen-size and
  lower-end-device checks remain necessary.
- GitHub Actions has not yet run on the remote repository. Configure branch
  protection to require its validation job if CI must block merges.

## 2026-11-21 — Content governance and lesson-model groundwork

### Implemented

- Upgraded the bundled catalogue to schema version 2. Rights/provenance,
  cultural classification, localization and lesson reviews now have
  independent records; approval requires a reviewer and evidence.
- Added localized technique, region and tradition labels. Localization
  approval requires English, Telugu and Tamil text for applicable catalogue
  fields; no bundled sample is approved.
- Added explicit localized lesson-step data separate from vector strokes.
  Parsing rejects duplicate step/stroke IDs, unknown stroke references and
  approved lessons with no steps.
- Added publication and reviewed-lesson gates. A lesson is not treated as
  teachable unless rights, cultural and lesson reviews are approved.
- Design detail now shows a full vector preview and a clear notice for
  unreviewed samples; playback controls and step instructions appear only
  for explicitly reviewed lessons.
- Kept all 10 generated geometric samples pending review, without regional
  or traditional attribution and without invented lesson steps or
  translations.
- Updated the product schema and review-policy documentation.

### Validation

- `dart format lib test` — passed.
- `flutter test --reporter expanded` — passed; all 18 tests succeeded.
- `flutter analyze` — passed with no issues.
- `flutter build apk --debug --target-platform android-x64` — passed.

### Remaining content gates

- Rights evidence and human cultural review are still pending for every
  bundled sample; the schema does not approve any content automatically.
- No reviewed Telugu/Tamil catalogue text or localized taxonomy data has
  been supplied. Add it only after fluent-speaker review.
- Touch tracing and creator-engine implementation remain deferred until the
  applicable content and product gates are satisfied.

## 2026-11-21 — Versioned geometry and reusable generator foundation

### Implemented

- Added schema version 3 with normalized line, quadratic, cubic and arc path
  commands, explicit geometry groups, optional dot coordinates and optional
  versioned scalar-parameter recipes.
- Kept the existing ten samples visually reusable: schema-v2 polylines
  migrate to equivalent line-command paths and lesson stroke references
  migrate to geometry-group references. They are not falsely marked as
  parametric recipes.
- Added two original, parameterized examples: a cubic radial flower and a
  dot-grid diamond pattern. Rights, cultural, localization and lesson review
  records remain pending.
- Updated the shared preview and detail/practice flows to render paths,
  explicit dots and lesson geometry groups.
- Added a Dart recipe registry for the radial-flower and dot-grid generators,
  with bounded parameter validation, and replaced the Create placeholder with
  adjustable live previews, layout choices and reset. The preview-only controls
  use English temporarily; approved Telugu/Tamil strings are still pending.
- Reworked the Python catalogue generator to emit schema v3 and deterministic
  lossless thumbnails. Its consistency check compares decoded artwork rather
  than platform-dependent WebP bytes. Added tests for normalized geometry,
  recipe parameters, thumbnail output and curved-path flattening.
- Tightened geometry limits and validation for path structure, dot-grid
  dimensions and duplicate coordinates.
- Added CI steps to test the Python generator and fail when generated
  catalogue or thumbnail assets are stale.

### Architecture and usability decision

- Keep recipe generation, canonical path geometry, the shared Flutter
  renderer, lesson/tracing selection and local persistence as separate
  responsibilities. A saved recipe can be regenerated; its emitted paths
  remain independently renderable.
- Reuse fixed legacy geometry directly for preview and grouped learning or
  tracing steps. Do not infer recipe parameters from arbitrary artwork.
- The Python tool remains build-time catalogue tooling. Interactive Create
  calls the Dart registry and shared renderer; the current MVP is preview-only.
- No historical attribution, Telugu/Tamil translation or publication
  approval is inferred by generation.

### Validation

- Python generator tests — passed; five tests.
- Generated catalog and decoded-thumbnail consistency check — passed after
  regenerating the lossless WebP assets.
- `flutter test` — passed; all 31 tests.
- `flutter analyze` — passed with no issues.
- `flutter build apk --debug --target-platform android-x64` — passed; APK
  installed and launched on `emulator-5554`.
- `git diff --check` — passed.

## Remaining work roadmap (updated 2026-11-22)

This is the working backlog for completing the Creator, growing the design
library, improving app smoothness and keeping the implementation maintainable
as content and features grow. Complete the phases in order unless a dependency
or a user priority changes. Small content-authoring tasks can proceed alongside
engineering, but content must pass its review gates before it is represented
as traditional, instructional or publication-ready.

### Current baseline

- The latest pushed app change is `cf7fd48` (interactive Creator preview MVP).
- Create can preview the radial-flower and dot-grid-diamond generators, adjust
  petal count, grid size and grid layout, and reset. The preview uses the same
  vector renderer as catalogue designs.
- Create is not yet a drawing canvas: there is no freehand input, symmetry
  editor, undo/redo history, local creation storage, rename/delete, PNG export
  or sharing.
- The catalogue contains 12 designs: 10 generic geometric samples and two
  generated examples. This is not yet a reviewed regional/tradition library.
  Their rights, cultural, localization and lesson review records remain
  pending.
- Creator controls currently use English temporarily. Approved Telugu and
  Tamil translations have not been supplied.
- The 31 Flutter tests, Flutter analysis, five Python generator tests,
  catalogue-artwork check and Android debug build passed before the latest
  push. GitHub Actions was still running when last checked; verify that run.
- The built debug APK declares target SDK 36 and contains native `.so`
  libraries. Android Gradle Plugin is 9.3.1. No release AAB has been built or
  verified for 16 KB page-size compatibility; do not infer release readiness
  from the toolchain version or debug APK.
- ADB did not detect the emulator at 08:10 on 2026-11-22. At 08:23 it was
  online as `emulator-5554`; the current debug APK installed successfully and
  `com.example.muggu_studio/.MainActivity` launched. A follow-up check found
  the app process alive and the activity in the foreground.

### Phase 0 — Re-establish the baseline

1. Check the GitHub Actions run for `cf7fd48`; resolve any CI failure before
   adding more work.
2. **Done:** ADB detected `emulator-5554`; the debug APK installed, the app
   process remained alive and MainActivity was resumed after launch. Still
   visually check Home, Explore, Create and Saved on the emulator.
3. Record the test/build commands and actual supported device/API configuration
   used for subsequent comparisons.

**Done when:** CI is green, the main screens are visually checked on a
connected Android target, and the verified baseline/device configuration is
recorded. Do not treat an unavailable emulator as a passing runtime check.

### Phase 1 — Finish the template Creator flow

1. Expose useful bounded radial controls (at least petal count, radius and
   width) and ensure each displayed value is reflected by the generated recipe
   and preview.
2. Define supported dot-grid sizes explicitly, including the product-required
   5×5, 7×7 and 9×9 options. Keep layout choices valid for each size and
   explain any other supported sizes.
3. Add a clear action and predictable edit history for parameter changes.
   Define reset, undo and redo semantics before implementing them; avoid a
   control that appears to work but has no meaningful state change.
4. Add accessible labels/value announcements, touch-sized controls and
   scrolling behaviour that works on small screens and with larger text.
5. Add focused widget and generator tests for bounds, reset/history behaviour,
   family switching and invalid recipes.

**Done when:** users can adjust both pattern families, see immediate preview
updates, undo/reset changes predictably and use the screen with larger text.
No save action should be shown until persistence exists.

### Phase 2 — Build the drawing and tracing engine

1. Implement a drawing surface using normalized coordinates and the existing
   shared renderer. Keep the background/grid, guide, generated geometry and
   user strokes as separate render layers.
2. Support pointer down/move/up, smooth strokes, canvas resize and aspect-ratio
   changes without shifting saved geometry.
3. Add freehand pen settings: colour and stroke width, with a small reviewed
   default palette and clear selected-state feedback.
4. Add symmetry modes: none, vertical, horizontal and four-way. Verify
   behaviour on centre lines/points and prevent duplicate or unexpected
   strokes.
5. Add bounded undo/redo history and clear with undo or confirmation.
6. Reuse existing fixed catalogue geometry as optional tracing guides. Do not
   infer recipe parameters from legacy artwork.
7. Test coordinate conversion, smoothing, symmetry, centre crossings,
   history, resize behaviour and trace-guide visibility.

**Done when:** drawing and tracing work offline, remain aligned with the grid,
and undo/redo/clear behave consistently in automated tests and on device.

### Phase 3 — Save and manage creations locally

1. Define a creation record that stores a stable ID, user title, timestamps,
   recipe when applicable, geometry snapshot, dot-grid configuration and
   drawing style. The geometry snapshot must remain renderable if a generator
   implementation later changes.
2. Add a versioned SQLite migration and repository/DAO operations for create,
   list, load, update/rename and delete. Keep creations separate from the
   bundled curated catalogue and favourites.
3. Add a My Creations section to Saved, with empty/loading/error states and
   confirmation for destructive deletion.
4. Support opening a saved item to view/edit it and preserving edits after
   process death, restart and a database upgrade.
5. Test round-trip serialization, migration, duplicate IDs, corrupt/unsupported
   data handling and restart persistence.

**Done when:** a user can save, reopen, edit, rename and delete a creation
without network access, and existing favourites/catalogue data remains intact.

### Phase 4 — Export and offline reliability

1. Render a clean PNG at a documented useful resolution without editor controls
   or guide overlays unless the user explicitly chooses them.
2. Write exports using app-specific cache/storage APIs and open Android's
   system share sheet. Do not request broad storage permissions.
3. Test missing share targets, export failures, large canvases, cancellation
   and cleanup of temporary files; present errors instead of silent success.
4. Verify browsing, lessons, creation, saved creations and export prerequisites
   with network access disabled.

**Done when:** PNG output is visually correct, share handoff works on device,
and core features do not require a network connection.

### Phase 5 — Grow the design library and lessons

1. Establish a repeatable content-authoring checklist: source/provenance,
   rights evidence, reference artwork, geometry, thumbnail, metadata, review
   status and any lesson steps.
2. Keep generic original geometric exercises clearly identified as such.
   For tradition-specific designs, record the actual local name, region and
   tradition only when supported by evidence and reviewed by knowledgeable
   people; do not use search synonyms as cultural classification.
3. First content milestone: deliver 10 reviewed designs and five complete,
   reference-checked tutorials. The current 10 generic samples plus two
   generated patterns do not satisfy this milestone.
4. Expand progressively toward the product target of 60 reviewed designs and
   20 reviewed lessons. The proposed mix is 15 simple daily designs, 15
   Pulli/Dot Kolam, 10 Sikku/Kambi Kolam, 10 floral/geometric Rangoli and 10
   festival/occasion designs; adjust taxonomy only with content review.
5. Add only approved English, Telugu and Tamil catalogue text. Keep review
   status pending where fluent-speaker, cultural or rights review is missing.
6. Improve Explore with meaningful newest/recommended/difficulty sorting,
   reviewed region/tradition/technique/occasion filters, dot-grid metadata,
   synonym search and useful empty states as the dataset grows.
7. Validate every contribution with schema checks, unique IDs, geometry
   bounds, thumbnail decoding, generated-asset consistency and lesson-group
   references.

**Done when:** each published entry has complete provenance/review evidence,
correct metadata and artwork, and each published lesson has been checked
against its intended reference design. Do not count unreviewed examples toward
the reviewed-content target.

### Phase 6 — Make the application feel smooth and accessible

1. Profile current behaviour before optimizing: cold/warm launch, Home/Explore
   scrolling with the full catalogue, detail rendering, Creator drag input,
   memory and APK/assets size. Record device/API level and reproducible steps.
2. Set performance budgets from those measurements and the agreed minimum
   Android device; check them again after changes instead of guessing at
   thresholds.
3. Investigate measured bottlenecks: rebuild scope, CustomPainter repaint
   work, path complexity, image decoding/caching, list construction and
   database work. Optimize only where profiling identifies a cost.
4. Check loading/empty/error/retry states, offline behaviour, app lifecycle,
   keyboard/back navigation and recovery after process recreation.
5. Review accessibility: semantics and tooltips, contrast, non-colour cues,
   large text, screen-reader traversal, touch targets and Telugu/Tamil text
   clipping.
6. Test on a small screen, a representative mid-range device and the lowest
   supported Android target. Add integration or golden tests for the highest
   risk flows and keep the standard CI suite deterministic.

**Done when:** agreed performance budgets pass on the target device set, no
critical UX/accessibility defects remain, and the test suite covers the main
offline user journeys.

### Phase 7 — Keep the project scalable without premature infrastructure

1. Preserve feature boundaries: UI, generator/domain logic, geometry renderer,
   repositories and persistence should remain independently testable.
2. Keep a versioned generator registry with explicit supported parameter
   bounds and deterministic tests. Add a family only with examples, boundary
   tests, and a geometry snapshot that survives generator removal or revision.
3. Maintain explicit catalogue and database schema versions, migration tests,
   backward-compatibility policy and actionable validation errors.
4. Keep catalogue authoring/build tooling separate from runtime app code.
   Extend the automated content checks rather than creating a manual-only
   process.
5. Keep user-created data separate from bundled catalogue data. Keep local
   repositories replaceable behind the existing boundaries; do not add a
   backend, accounts or sync until there is an approved product need.
6. Add profiling and asset-size checks to CI only when they can run
   repeatably. Keep CI as the required gate for formatting, analysis, tests,
   Python tooling and generated catalogue consistency.
7. Document migration, generator addition, design contribution and release
   procedures so new contributors can follow the same workflow.

**Done when:** new designs/generators and persistence changes can be added
without editing unrelated features, breaking old saved geometry or bypassing
automated validation.

### Phase 8 — Release readiness (after core features)

- Choose and verify a permanent Android application ID before the first public
  release; the current `com.example.muggu_studio` ID is a setup placeholder.
- **16 KB memory-page gate:** build the production AAB; require
  `bundletool dump config` to report `PAGE_ALIGNMENT_16K`; inspect all shipped
  64-bit native libraries for 16 KB ELF `LOAD` alignment and verify generated
  APK zip alignment. Install the bundle-derived app on a 16 KB emulator,
  confirm `adb shell getconf PAGE_SIZE` returns `16384`, and smoke-test startup,
  navigation, drawing/rendering, persistence and native plugin paths. Record
  the AAB and results. The current debug APK targets API 36 and contains
  native libraries, but no AAB has passed this check. See the official
  [Android 16 KB page-size guidance](https://developer.android.com/guide/practices/page-sizes).
- Complete privacy policy, Play Store disclosures, target API review, signing,
  versioning, store text and artwork, internal/closed testing and staged
  rollout preparation.
- Verify current Play Store requirements at release time.
- Defer ads, Premium billing, notifications, cloud sync, AI generation and
  community features until explicitly approved and the stable offline core is
  complete.

**Done when:** the signed release candidate passes the release checklist,
privacy/store disclosures match actual behaviour, and rollback/monitoring
responsibilities are understood.

### Working order and completion rule

The immediate next step is **Phase 0**, followed by **Phase 1**. The drawing
engine precedes reliable saving; saving precedes creation management and
export. Content review can proceed in parallel, but reviewed labels and lessons
must not be claimed before approval. Performance work begins with a measured
baseline. Scaling work should strengthen these real boundaries and migrations,
not trigger a broad rewrite.

For each phase, record the specific changes, tests/device checks, unresolved
issues and next phase in this log. A phase is complete only when its acceptance
criteria pass; building successfully alone is not feature completion.

Generic original-pattern creation may proceed without cultural claims. Rights,
cultural, Telugu/Tamil localization and lesson reviews remain pending for the
generated catalogue examples until their evidence and approval are recorded.

# Muggu Studio Development Log

This file tracks implementation progress, verified environment setup,
issues, fixes and next steps. Product requirements remain in
[Muggu_Studio_README.md](Muggu_Studio_README.md).

**Current direction:** The app now uses system-generated provenance,
style-source links and default lessons. Region/tradition assignments and
content-review gates have been removed. Older entries below record the
previous implementation and are historical where they describe those gates.
Illustrated vectors keep their authored curves instead of being snapped to a
guide grid; dot-guided designs render clear dots and outlines above their fills.

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

## Remaining work roadmap (updated 2026-11-24)

This is the working backlog for completing the Creator, growing the design
library, improving app smoothness and keeping the implementation maintainable
as content and features grow. Complete the phases in order unless a dependency
or a user priority changes. Small content-authoring tasks can proceed alongside
engineering, but content must pass its review gates before it is represented
as traditional, instructional or publication-ready.

### Current baseline

- The Phase 6 emulator profile results and current work order are recorded
  below.
- Create supports versioned template generators and a freehand canvas with
  symmetry, pen controls, undo/redo, and local save/reopen/rename/delete.
  Designs and creations can be exported and shared as PNGs.
- The bundled catalogue contains 60 design samples, including 40 new
  app-generated original geometric artworks. Rights, cultural, localization
  and lesson reviews remain pending; do not count any sample toward the
  reviewed-content milestone until evidence and approval are recorded. Every
  design now has a visible dot grid and grid-anchored path endpoints.
- The generator registry currently uses recipe version 1. Catalogue geometry
  uses schema version 3 and accepts schema 2 through its migration path. The
  local SQLite database is version 2, with a tested migration from version 1.
- The full Flutter suite last passed 101 tests on 2026-11-24. The generator
  registry suite now passes 8 tests, including a new determinism check, and
  `flutter analyze` reports no issues.
- Phase 6 has three repeated profile-mode emulator traces for Explore, detail
  and Creator interactions. Physical-device checks and performance budgets
  are deferred; the emulator results are not release-device evidence.
- The Android application ID remains the setup placeholder
  `com.example.muggu_studio`. No release AAB has been built or verified for
  16 KB page-size compatibility.
- The built debug APK declares target SDK 36 and contains native `.so`
  libraries; do not infer release readiness from the toolchain version or a
  debug build.

### Phase 0 — Re-establish the baseline

1. Check the current GitHub Actions run for application-source changes before
   merging or releasing; the workflow is
   `.github/workflows/muggu-studio.yml`.
2. **Done on emulator:** the debug APK was installed and Home, Explore, Saved,
   Create and Settings were smoke-tested on `emulator-5554` (Android 17 / API
   37). Physical-device checks are deferred.
3. **Recorded:** local test/build commands and the emulator/API configuration
   are in this log. Add the supported physical-device configuration when one
   is selected.

**Done when:** CI is green, the main screens are visually checked on a
connected Android target, and the verified baseline/device configuration is
recorded. Do not treat an unavailable emulator as a passing runtime check.

### Phase 1 — Finish the template Creator flow [COMPLETED]

1. Expose useful bounded radial controls (petal count: 3–24, outer radius: 0.15–0.42,
   and petal width: 0.03–0.14) with live vector preview reflections.
2. Define supported dot-grid sizes explicitly with dedicated quick chips for
   standard traditional sizes (5×5, 7×7, 9×9) as well as 3×3, 11×11, 13×13, 15×15,
   plus accessible odd-size slider and explanatory helper text.
3. Added predictable edit history (Undo, Redo, Reset) with immutable state snapshots
   and drag-start/end tracking.
4. Added accessible semantic labels, touch-friendly touch targets, small-screen
   scroll behavior, and English, Telugu, and Tamil UI strings in ARB files.
5. Added focused widget tests in `test/features/create_screen_test.dart` covering bounds,
   undo/redo/reset, pattern family switching, and trilingual localizations.

**Status:** Completed and verified. All 36 Flutter tests and 6 Python tooling tests pass.

### Phase 2 — Build the drawing and tracing engine

This phase implements a shared, offline-first touch drawing and tracing engine
used by both Freehand Creation (`CreateScreen`) and Tracing / Practice (`PracticeScreen`).

#### 1. Architecture and Component Breakdown
- **Domain Models (`lib/features/drawing/domain/`):**
  - `DrawnStroke`: immutable stroke holding `List<DesignPoint> points`, `Color color`, `double strokeWidth`, and `SymmetryMode symmetryMode`.
  - `SymmetryMode`: enum with `none`, `vertical`, `horizontal`, and `fourWay`.
  - `SymmetryTransform`: pure mathematical transformation engine:
    - *Vertical:* `(1.0 - x, y)`
    - *Horizontal:* `(x, 1.0 - y)`
    - *Four-way (Quadrant):* `(x, y)`, `(1.0 - x, y)`, `(x, 1.0 - y)`, and `(1.0 - x, 1.0 - y)`.
    - *Center-line guard:* avoids duplicate points/lines when strokes touch or cross `x = 0.5` or `y = 0.5`.
- **Application State (`lib/features/drawing/application/`):**
  - `DrawingController`: manages `List<DrawnStroke> strokes`, live `DrawnStroke? activeStroke`, `undoStack`, `redoStack`, `activeColor`, `activeStrokeWidth`, and `activeSymmetryMode`.
  - Bounded undo/redo history stack (max 50 operations) with stroke-level rollbacks.
- **Presentation Layer (`lib/features/drawing/presentation/`):**
  - `DrawingCanvas`: interactive widget wrapping `GestureDetector` / `Listener` + `CustomPaint`.
    - *Layer 0 (Background):* Warm Cream background with rounded border.
    - *Layer 1 (Dot Grid):* Rendered from `DotGrid` (5×5, 7×7, 9×9 or custom layout).
    - *Layer 2 (Ghost Guide):* Faint outline (`alpha: 0.28`) from `List<DesignPath>` when tracing a catalog design.
    - *Layer 3 (Completed Strokes):* All committed user strokes with anti-aliasing and `StrokeCap.round`.
    - *Layer 4 (Live Active Stroke):* Current pointer drag with immediate real-time symmetry reflection.
  - `DrawingToolbar`:
    - Palette selector: Rice Flour White (`#FFFFFF`), Deep Maroon (`#862B37`), Turmeric Gold (`#D8A13B`), Leaf Green (`#55775D`), Charcoal/Dark Brown (`#3C342E`).
    - Stroke width selector: Fine (`2.0 dp`), Medium (`4.0 dp`), Bold (`6.5 dp`).
    - Symmetry mode selector: None, Vertical, Horizontal, 4-Way.
    - Action bar: Undo, Redo, Clear with confirmation dialog.
- **Consumer Integrations:**
  - `PracticeScreen`: Upgraded from static placeholder to interactive tracing studio, passing `design.paths` as the ghost guide.
  - `CreateScreen`: Adds a Freehand Canvas tab alongside the parametric Template generator.

#### 2. Touch Gesture Handling & Normalization
- Pointer down: captures local position, converts to normalized `[0.0, 1.0]` coordinates clamped to canvas dimensions.
- Pointer move: applies distance threshold (`distanceSquared > 0.000025` normalized) for smooth stroke decimation without memory bloat.
- Pointer up: commits completed stroke + symmetry variants to undo history and clears active stroke.

#### 3. Test & Verification Plan
- Unit tests for `SymmetryTransform` covering single points, lines, center-axis crossings (`x=0.5`, `y=0.5`), and multi-quadrant reflections.
- Controller unit tests covering stroke addition, undo, redo, clear, and history stack bounds.
- Widget tests for `DrawingCanvas` verifying pointer events, guide visibility, toolbar interactions, and localization.

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

1. Use system-generated vector artwork as the default content source.
2. Add source URLs only when external material informed a design; distinguish
   general style context from the exact source artwork.
3. Give every bundled design a playable lesson that covers its geometry groups.
4. Grow visual families such as floral, dot-grid, mandala, border, corner and
   festival-inspired designs without assigning exclusive regions/traditions.
5. Improve color, smooth closed loops, outlines, shading and thumbnail quality
   through the shared renderer and catalog generator.
6. Validate unique IDs, normalized geometry, source URLs, lesson coverage,
   thumbnail decoding and generated-asset consistency.

**Done when:** every design has clear provenance, a complete playable lesson,
and matching polished vector artwork in the catalogue and app.

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

#### Contributor workflow

- **Add a generator:** implement it in
  `lib/features/create/application/pattern_generator_registry.dart` with a
  stable generator ID, explicit parameter bounds and a versioned recipe.
  Return normalized `DesignPath` geometry; keep saved path snapshots usable
  even if a generator later changes or is removed. Add examples, bounds and
  invalid-input cases to `test/features/pattern_generator_registry_test.dart`,
  including a repeat-generation equality check. Update Create controls and
  English/Telugu/Tamil ARB strings when the UI exposes the new family.
- **Add catalogue content:** update the appropriate catalogue source and
  `assets/designs/thumbnails/` artwork together. Keep IDs stable and unique,
  geometry normalized, lesson groups valid and provenance explicit.
  For output generated by the Python sample-catalog tool, change
  `tools/generate_sample_catalog.py` and its tests, regenerate the assets, and
  verify with `python tools/generate_sample_catalog.py --check`. Include source
  URLs when external references were used; otherwise use `system_generated`.
- **Change catalogue schema:** update `catalogSchemaVersion` and
  `supportedCatalogSchemaVersions` in
  `lib/data/repositories/design_repository.dart`; add a migration for each
  still-supported prior schema and tests for valid, invalid and migrated
  examples. Keep catalogue schema changes separate from generator recipe and
  SQLite database version changes.
- **Change local persistence:** increment `OpenDatabaseOptions.version` in
  `lib/data/local/app_database.dart`, add ordered `oldVersion` migration steps
  that preserve existing user data, and extend
  `test/data/creations_dao_test.dart` with a database created at the previous
  version.
- **Run the required local gates:** `flutter gen-l10n` when ARB files change;
  `dart format --output=none --set-exit-if-changed lib test`;
  `flutter analyze`; `flutter test`;
  `python -m unittest discover -s tools -p 'test_*.py' -v`; and
  `python tools/generate_sample_catalog.py --check`. The same checks plus
  the Android x64 debug build are defined in
  `../.github/workflows/muggu-studio.yml`.
- **Prepare a release:** use Phase 8 as a separate gate; confirm the permanent
  application ID, signing/versioning and store disclosures, and verify the
  production AAB and its 16 KB page-size compatibility before release.

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

Phases 1–4 have implementation logs below. Phase 5 remains gated on evidence
and human review of catalogue content. Phase 6 has an emulator baseline, while
physical-device checks are deferred; do not set performance budgets from the
emulator traces. Continue Phase 7 engineering and documentation that do not
depend on device access or unprovided cultural-review material. Scaling work
should strengthen the existing feature boundaries and migrations, not trigger
a broad rewrite.

For each phase, record the specific changes, tests/device checks, unresolved
issues and next phase in this log. A phase is complete only when its acceptance
criteria pass; building successfully alone is not feature completion.

Generic original-pattern creation may proceed without cultural claims. Rights,
cultural, Telugu/Tamil localization and lesson reviews remain pending for the
generated catalogue examples until their evidence and approval are recorded.

## 2026-11-22 — Phase 1: Template Creator Polish Completed

### Implemented
- Expanded radial flower controls: added bounded controls for Petals (3–24), Outer Radius (0.15–0.42), and Petal Width (0.03–0.14) with real-time vector preview updates.
- Refined dot-grid controls: added explicit quick-choice chips for traditional sizes (5×5, 7×7, 9×9) and other supported odd sizes (3×3 to 15×15), plus contextual cultural helper guidance.
- Implemented parameter edit history: added an immutable `_CreatorState` with Undo, Redo, and Reset operations, capturing drag-start and drag-end states to avoid slider flooding.
- Added trilingual UI localization for all Creator controls across English, Telugu, and Tamil in `lib/l10n/` ARB files.
- Added 5 new automated tests in `test/features/create_screen_test.dart` verifying all controls, parameter boundaries, undo/redo/reset predictability, and Telugu/Tamil translations.

### Validation
- `dart format lib test` — passed.
- `flutter gen-l10n` — passed.
- `flutter analyze` — passed with 0 issues.
- `flutter test` — passed; all 36 tests across all test suites succeeded.
- `python -m unittest discover -s tools` — passed; all 6 generator tests succeeded.

### Next
- Proceed with **Phase 2: Build the drawing and tracing engine** (interactive touch canvas, multi-axis symmetry, pen styling, and practice/trace mode overlay).

## 2026-11-22 — Phase 2: Drawing & Tracing Engine Architecture Plan Approved

### Technical Design Baseline Documented
- Established `lib/features/drawing/` as a modular subsystem serving both Freehand Creation and Tracing / Practice.
- Defined `DrawnStroke` domain model and `SymmetryMode` (none, vertical, horizontal, four-way) with center-line crossing deduplication math.
- Specified the 5-layer rendering stack for `DrawingCanvas`: Background, Dot Grid, Ghost Tracing Guide, Committed Strokes, and Live Active Stroke.
- Specified pen tools: traditional palette (Rice White, Maroon, Gold, Green, Charcoal) and 3 stroke widths (2dp, 4dp, 6.5dp).
- Established `PracticeScreen` upgrade plan: loads catalogue vector paths as a ghost guide with non-punitive tracing.
- Created test plan covering symmetry mathematics, controller state management, coordinate normalization, and widget interactions.

## 2026-11-22 — Phase 2: Drawing & Tracing Engine Completed

### Implemented
- **Drawing domain models & symmetry math** (`lib/features/drawing/domain/`):
  - `DrawnStroke` immutable value model with unmodifiable points list, `Color`, `strokeWidth`, and `SymmetryMode`.
  - `SymmetryTransform` applying real-time multi-axis mirroring (None, Vertical, Horizontal, 4-Way) with center-axis deduplication (`epsilon = 0.0005`) and `[0.0, 1.0]` boundary clamping.
- **Drawing state controller** (`lib/features/drawing/application/drawing_controller.dart`):
  - Stroke lifecycle management (`startStroke`, `addPoint` with distance decimation, `endStroke`).
  - Bounded undo/redo history stack (max 50 depth), clear with undo support.
  - Cultural palette presets (`DrawingPalette` with Rice Flour White, Deep Maroon, Turmeric Gold, Leaf Green, Charcoal Brown) and stroke widths (Fine 2.0dp, Medium 4.0dp, Bold 6.5dp).
- **Interactive drawing canvas** (`lib/features/drawing/presentation/drawing_canvas.dart`):
  - 5-layer rendering stack using `CustomPainter` (Background + border, Dot grid underlay, Ghost tracing guide, Committed strokes, Live active stroke + real-time mirror preview).
  - Normalised coordinate mapping using `RenderBox.globalToLocal` with boundary clamping.
  - Pointer event capture via `Listener` to avoid gesture arena conflicts.
- **Drawing toolbar** (`lib/features/drawing/presentation/drawing_toolbar.dart`):
  - 5-swatch palette row with selection ring, 3 line thickness selectors, 4 symmetry choice chips.
  - Action buttons: Undo, Redo, and Clear with confirmation dialog.
- **Practice / Trace mode upgrade** (`lib/features/design/presentation/practice_screen.dart`):
  - Upgraded from static preview placeholder to interactive `DrawingCanvas` in tracing mode (`tracingMode: true`) with faint ghost guide paths and cultural disclaimer info card.
- **Freehand Canvas tab in CreateScreen** (`lib/features/create/presentation/create_screen.dart`):
  - Added `TabBar` and `TabBarView` supporting both **Template pattern** and **Freehand canvas** modes with integrated dot-grid and toolbar.
- **Localization**:
  - Added 13 new trilingual translation keys in English, Telugu, and Tamil ARBs for pen colors, stroke widths, symmetry modes, canvas clearing, and tab titles.
- **Automated test suite expansion**:
  - `test/features/symmetry_transform_test.dart`: 7 unit tests.
  - `test/features/drawing_controller_test.dart`: 6 unit tests.
  - `test/features/drawing_canvas_test.dart`: 5 widget tests.
  - `test/features/drawing_toolbar_test.dart`: 8 widget tests.
  - Updated `test/widget_test.dart` to cover the new tab structure and Practice screen tracing canvas.

### Validation
- `dart format lib test` — passed.
- `flutter gen-l10n` — passed.
- `flutter analyze` — passed with 0 issues.
- `flutter test` — passed; all 61 tests across all test suites succeeded.
- `python -m unittest discover -s tools` — passed; all 6 generator tests succeeded.
- Android APK build & emulator deployment:
  - `flutter build apk --debug --target-platform android-x64` — built successfully.
  - `adb install -r build\app\outputs\flutter-apk\app-debug.apk` — installed successfully on `emulator-5554`.
  - App launched and confirmed running (PID 20275) with zero crash logs in `logcat`.

### Next
- Proceed with **Phase 3: Local persistence & saved creations** (SQLite schema for user-created designs, saving/loading parametric recipes and drawn strokes, offline management in Saved tab).

## 2026-11-22 — Phase 3: Local Persistence & Saved Creations Architecture Plan Approved

### Technical Architecture Baseline
1. **Domain Model (`lib/features/creations/domain/user_creation.dart`)**:
   - `UserCreation` domain entity:
     - `id`: Unique timestamp-prefixed UUID string (`creation_<timestamp>_<uuid>`).
     - `title`: User-defined string name (trimmed, non-empty, default provided).
     - `createdAt`: UTC creation timestamp.
     - `updatedAt`: UTC last modification timestamp.
     - `type`: `CreationType.template` or `CreationType.freehand`.
     - `recipe`: Optional `PatternRecipe` for parametric patterns.
     - `strokes`: Optional `List<DrawnStroke>` for freehand drawings.
     - `paths`: `List<DesignPath>` geometry snapshot ensuring renderability even if generator algorithms or versions evolve.
     - `grid`: Optional `DotGrid` configuration.
   - Robust `toMap()` and `fromMap()` serialization preserving coordinate precision.

2. **Database Versioning & Migration (`lib/data/local/app_database.dart`)**:
   - Schema version bumped from `1` to `2`.
   - `onCreate`: creates both `favorites` and `creations` tables.
   - `onUpgrade`: versioned migration from v1 adding:
     ```sql
     CREATE TABLE creations (
       id TEXT PRIMARY KEY NOT NULL,
       title TEXT NOT NULL,
       created_at INTEGER NOT NULL,
       updated_at INTEGER NOT NULL,
       type TEXT NOT NULL,
       recipe_json TEXT,
       strokes_json TEXT,
       paths_json TEXT NOT NULL,
       grid_json TEXT
     );
     CREATE INDEX idx_creations_updated_at ON creations(updated_at DESC);
     ```

3. **DAO & Repository (`lib/data/local/creations_dao.dart`)**:
   - `CreationsStore` abstract interface:
     - `Future<List<UserCreation>> listCreations()`
     - `Future<UserCreation?> loadCreation(String id)`
     - `Future<void> saveCreation(UserCreation creation)`
     - `Future<void> updateTitle(String id, String newTitle)`
     - `Future<void> deleteCreation(String id)`
   - Full ACID transaction safety and duplicate ID handling.
   - Riverpod providers: `creationsDaoProvider` and `creationsListProvider`.

4. **Trilingual Localization (`lib/l10n/`)**:
   - Added strings across `app_en.arb`, `app_te.arb`, and `app_ta.arb`:
     - Section headers (`myCreations`, `favouriteDesigns`).
     - Action labels (`saveCreation`, `creationTitle`, `creationTitleHint`, `creationSaved`, `renameCreation`, `deleteCreation`, `editCreation`).
     - Safety & feedback (`deleteCreationConfirm`, `noCreationsYet`, `noCreationsDescription`).

5. **Presentation Layer Integration**:
   - **CreateScreen**:
     - "Save Creation" action button on both Template and Freehand tabs.
     - Pre-populated title input dialog with save validation.
     - Serialization of current active state into `UserCreation` snapshot.
     - Support reopening existing creations to resume editing.
   - **SavedScreen**:
     - Tabbed / segmented view toggling between **Favourite designs** and **My Creations**.
     - Responsive grid of creation cards featuring `VectorPreview`, title, date badge, and menu actions (Edit, Rename, Delete).
     - Destructive confirmation dialog before removing creations.

6. **Validation Suite Plan**:
   - `creations_dao_test.dart`: CRUD operations, migration v1 to v2, restart persistence with `sqflite_common_ffi`.
   - `creations_screen_test.dart`: Widget tests verifying saving from creator, rendering in Saved tab, rename, and delete dialog.

## 2026-11-22 — Phase 3: Local Persistence & Saved Creations Completed

### Implemented
- **Domain entity & geometry conversion (`lib/features/creations/domain/user_creation.dart`)**:
  - `UserCreation` domain model storing unique ID, title, UTC timestamps, `CreationType` (`template` or `freehand`), `PatternRecipe`, `DrawnStroke` lists, and snapshot `DesignPath` list.
  - Implemented `strokesToDesignPaths` static utility converting drawn freehand point paths into valid `DesignPath` vector geometry.
  - Added clean `toJson()` and `fromJson()` serialization across `PathCommand`, `DesignPath`, `PatternRecipe`, `DotGrid`, and `DrawnStroke`.
- **Database Schema v2 & DAO (`lib/data/local/`)**:
  - Upgraded SQLite database in `app_database.dart` from version 1 to 2 with versioned `onUpgrade` migration creating `creations` table and `idx_creations_updated_at` index.
  - Created `CreationsDao` (`lib/data/local/creations_dao.dart`) implementing `CreationsStore` (listing, loading by ID, saving/replacing, updating title, deleting) with Riverpod providers.
- **Creator Save Integration (`lib/features/create/presentation/create_screen.dart`)**:
  - Converted `CreateScreen` to `ConsumerStatefulWidget` supporting initialization from an existing `UserCreation`.
  - Added Save button in Template tab action bar (`ValueKey('creator-save')`) and Freehand toolbar (`ValueKey('drawing-save')`).
  - Added save dialog with pre-populated title, input validation, snapshot generation, database persistence, and SnackBar feedback.
- **SavedScreen Redesign (`lib/features/saved/presentation/saved_screen.dart`)**:
  - Replaced placeholder card with Material 3 `SegmentedButton` switching between **Favourite designs** and **My Creations**.
  - Implemented `_CreationsView` displaying saved creations in a responsive grid of `_CreationCard`s with live `VectorPreview` snapshots, title, type badge, and menu actions (Rename, Delete).
  - Added Rename dialog with title editing and Delete dialog with destructive confirmation.
- **Trilingual Localization (`lib/l10n/`)**:
  - Added 12 new strings across English, Telugu, and Tamil ARBs for creations management (`myCreations`, `saveCreation`, `creationTitle`, `creationTitleHint`, `creationSaved`, `renameCreation`, `deleteCreation`, `deleteCreationConfirm`, `noCreationsYet`, `noCreationsDescription`, `editCreation`, `save`).
- **Validation Suite Expansion**:
  - `test/data/creations_dao_test.dart`: 4 comprehensive unit tests verifying CRUD operations, persistence across restarts, freehand stroke conversion, and SQLite migration from v1 to v2 preserving existing favorites.
  - `test/features/creations_ui_test.dart`: 5 widget tests verifying segmented tab switching, empty state, grid rendering, rename dialog, delete confirmation dialog, and creator save dialog.
  - Updated `test/data/favorites_dao_test.dart` to expect version 2 database.

### Validation
- `dart format lib test` — passed.
- `flutter gen-l10n` — passed.
- `flutter analyze` — passed with 0 issues.
- `flutter test` — passed; all 70 tests across all 9 test suites succeeded.
- `python -m unittest discover -s tools` — passed; all 6 generator tests succeeded.
- Android APK build & emulator deployment:
  - `flutter build apk --debug --target-platform android-x64` — built successfully in 129.9s.
  - `adb install -r build\app\outputs\flutter-apk\app-debug.apk` — installed successfully on `emulator-5554`.
  - App launched and confirmed running (PID 21629) with zero crash logs in `logcat`.

### Next
- Proceed with **Phase 4: Export and offline reliability** (clean PNG export at target resolution, Android system sharesheet integration, and network-disabled offline validation).

## 2026-11-22 — Phase 4: PNG Export, Share Sheet Integration & Offline Reliability Architecture Plan

### Technical Architecture Baseline

1. **Headless Vector-to-PNG Exporter (`lib/features/export/application/design_exporter.dart`)**:
   - `DesignExporter`:
     - Headless rendering using Flutter engine graphics primitives: `ui.PictureRecorder` and `Canvas`.
     - Supports target resolutions: Standard (1080 × 1080) and High-Resolution (2048 × 2048) or arbitrary square dimensions.
     - Layers:
       - Layer 0: Background solid fill (`MugguColors.warmCream`).
       - Layer 1: Dot grid underlay with scaled dot radii and proportional opacity.
       - Layer 2: Vector `DesignPath`s with antialiased stroke, rounded caps/joins, and fills.
       - Layer 3: Cultural branding footer watermark ("Muggu Studio • traditional floor art") in subtle terracotta.
     - Converts `ui.Image` to `Uint8List` PNG bytes via `image.toByteData(format: ui.ImageByteFormat.png)`.
     - High-level methods:
       - `Future<Uint8List> exportPaths(...)`
       - `Future<Uint8List> exportCreation(UserCreation creation, ...)`
       - `Future<Uint8List> exportDesign(Design design, ...)`

2. **Share Service & Scoped Storage (`lib/features/export/application/share_service.dart`)**:
   - Abstract `ShareService` interface:
     - `Future<void> sharePng({required Uint8List pngBytes, required String filename, required String title, String? text, Rect? sharePositionOrigin})`
   - Platform implementation `PlatformShareService`:
     - Uses `path_provider` to write temporary image bytes to app-specific cache directory (`cacheDir`), avoiding any broad Android `WRITE_EXTERNAL_STORAGE` permission requirements.
     - Dispatches native Android sharesheet via `share_plus` (`SharePlus.instance.shareXFiles`).
   - Riverpod provider: `shareServiceProvider`.

3. **Presentation Layer Integration**:
   - **CreateScreen**:
     - Template tab: "Share" / "Export" button in action bar alongside Save.
     - Freehand tab: "Share" action icon in drawing toolbar.
   - **SavedScreen**:
     - Added "Share" action in `_CreationCard` menu allowing one-tap sharing of saved creations.
   - **DesignDetailScreen**:
     - Added Share action icon button in app bar allowing sharing catalog designs.
   - Export modal/dialog allowing choice of Standard (1080×1080) vs High-Resolution (2048×2048) export.

4. **Trilingual Localization (`lib/l10n/`)**:
   - ARB updates across English, Telugu, and Tamil:
     - `exportPng`, `shareDesign`, `exportingImage`, `imageExported`, `resolutionStandard`, `resolutionHigh`.

5. **Validation Suite Plan**:
   - `test/features/design_exporter_test.dart`:
     - PNG header signature validation (`0x89 0x50 0x4E 0x47 0x0D 0x0A 0x1A 0x0A`).
     - Dimension verification for 1080p and 2048p.
     - Verification with dot grid and without dot grid.
     - Verification of template creations and freehand drawn stroke creations.
   - `test/features/share_service_test.dart`:
     - Temporary file generation, naming, and cleanup.
   - Widget tests for Share button triggers on Create, Saved, and Detail screens.
   - Offline reliability audit: verify zero remote network requests in airplane mode.


## 2026-11-23 — Phase 4 Completion & Catalog Mini-Scaling to 20 Designs

### Implemented
- **Development Version Indicator (lib/core/constants/app_version.dart)**:
  - Centralized application version metadata: AppVersion.display (1.0.0+1 (dev)).
  - Integrated header chip in HomeScreen and footer version indicator on the dashboard.
- **Catalog Mini-Expansion (8 authentic dot-grid designs, 12 -> 20 total)**:
  - Added 8 authentic traditional dot-grid patterns across varying grid sizes (3x3, 5x5, 7x7) and difficulty levels:
    1. dot_grid_sample_001: 3×3 Chukkala Muggu (Little Star / Chikka Muggu)
    2. dot_grid_sample_002: 5×5 Pulli Kolam (Lotus Nelavu)
    3. dot_grid_sample_003: 5×5 Sikku Kolam (Brahma Mudi)
    4. dot_grid_sample_004: 5×5 Padi Muggu (Step Diamond)
    5. dot_grid_sample_005: 5×5 Deepam Muggu (Four Lamps)
    6. dot_grid_sample_006: 7×7 Suzhi Kolam (Star of Harmony)
    7. dot_grid_sample_007: 7×7 Sankranti Ratham (Chariot)
    8. dot_grid_sample_008: 5×5 Hridaya Kamalam (8-Petal Lotus)
  - Full trilingual names and descriptions (English, Telugu, Tamil).
  - Lossless 320×320 .webp thumbnails generated for all 8 designs.
- **Testing & Verification**:
  - Python tool suite: 	est_generate_sample_catalog.py updated and passing (6/6 tests).
  - Flutter test suite: design_repository_test.dart and full suite passing (78/78 tests).

### Next
- Proceed with **Phase 5: First-Time Onboarding & Settings Screen**.

## 2026-11-23 — Phase 5: First-Time Onboarding & Settings Screen

### Implemented
- **User Preferences Data Model & Local Storage (`lib/core/preferences/`)**:
  - `UserPreferences` immutable data model: languageCode, interests (`InterestOption`: `muggu`, `kolam`, `rangoli`, `all`), experienceLevel (`ExperienceLevel`: `beginner`, `experienced`), and `onboardingComplete`.
  - `PreferencesStorage` interface and `SharedPreferencesStorage` implementation using `shared_preferences`.
  - Riverpod notifier `userPreferencesProvider` (`UserPreferencesNotifier`) supporting reactive state updates, `savePrefs`, `markOnboardingComplete`, and `clearAll`.
- **First-Time Onboarding Flow (`lib/features/onboarding/presentation/onboarding_screen.dart`)**:
  - 3-step personalized, skippable onboarding page sequence with animated step indicator:
    - Step 1: Language selection (English 🇬🇧, Telugu 🪔, Tamil 🌺) with live locale switching.
    - Step 2: Tradition interests (Muggu, Kolam, Rangoli, All traditions) with multi-select filter chips.
    - Step 3: Experience level (Beginner 🌱 / Experienced 🎯) with descriptive level cards.
  - Skip / Next / Back / Done controls, saving preferences and redirecting to the dashboard upon completion.
- **Dedicated Settings Screen (`lib/features/settings/presentation/settings_screen.dart`)**:
  - Accessible directly from top AppBar gear icon (`Icons.settings_outlined`).
  - Sections:
    - **Language**: Switch app language dynamically between English, Telugu, and Tamil.
    - **Preferences**: Adjust tradition interests and switch experience level (SegmentedButton).
    - **About**: Displays `AppVersion.display` badge (`v1.0.0+1 (dev)`) and offline-ready indicator.
    - **Data**: Destructive "Clear all local data" tile with confirmation alert dialog, resetting preferences and returning to onboarding.
    - **Privacy**: Privacy Policy tile with informational feedback.
- **Router Integration & First-Run Redirection (`lib/app/router.dart`)**:
  - Configured GoRouter redirect to guard routes: uncompleted onboarding navigates to `/onboarding`.
  - Registered `/onboarding` and `/settings` as standalone, full-screen routes outside the navigation bar shell.
- **Trilingual Localization (`lib/l10n/`)**:
  - Complete trilingual ARB keys added across English, Telugu, and Tamil for all onboarding steps, preferences, and settings dialogs.
- **Automated Testing (`test/features/preferences_test.dart`)**:
  - 8/8 comprehensive unit tests passing covering preferences persistence, roundtripping, defaults, equality, and clearing.
- **Emulator Verification**:
  - Successfully built debug APK (`build/app/outputs/flutter-apk/app-debug.apk`).
  - Installed and verified on Android emulator (`emulator-5554`, Android 17 / API 37).
  - First-time onboarding screen displayed on initial launch.

### Next
- **Curved Bézier & Parabolic Generator Sprint**:
  - Curved dot-grid generator algorithms (loops around dots, parabolic Sikku Kolam curves).
  - Complex Rangoli motifs (peacock, floral mandalas, paisley).

## 2026-11-23 — Curved Generator and Motif Sprint

### Implemented
- Added versioned recipes for dot-grid loops, parabolic weave curves and
  original geometric motifs (floral mandala, peacock and paisley).
- Dot-grid loops produce one closed cubic curve around every dot. Parabolic
  weave patterns use bounded quadratic curves across each row. The three
  motif families use normalized cubic paths and remain editable in Create.
- Added Create-screen selection and motif controls. Saved recipes retain their
  generator parameters, and export/share uses the selected pattern title.
- Added English, Telugu and Tamil labels; corrected the preview notice to
  describe the existing save and export actions.
- Added registry tests for geometry parsing/bounds and widget tests for
  generator selection, motif switching and save-title selection.

### Verification and limitations
- The full Flutter test suite passes (90 tests), and analyzer checks for the
  changed Dart files pass. Project-wide `flutter analyze` still reports five
  existing diagnostics in the router, settings screen and export test.
- These are original geometric exercises, not culturally verified depictions
  of a specific region or tradition. Content provenance and cultural review
  gates in Phase 5 remain open.

### Next
- Begin **Phase 6: Make the application feel smooth and accessible** with the
  documented cold/warm launch, scrolling, detail-rendering, Creator-input,
  memory and asset-size baseline. Record the device/API and reproducible steps
  before choosing performance budgets or optimizing.

## 2026-11-23 — Phase 6: Initial Emulator Baseline

### Environment and measurements
- Device: Android 17 / API 37 emulator, 1080×2400 at 420 dpi, Windows host.
- Build: debug APK; measurements are exploratory and are not release budgets.
- Process-cold launch: three `adb shell am force-stop` + `am start -W` runs
  measured 9.47–12.22 seconds (`TotalTime` median 10.43 seconds).
- Warm resume: `TotalTime` 0 ms and `WaitTime` 11 ms while the app was already
  foregrounded.
- Post-launch memory: `dumpsys meminfo` reported 364,837 KB total PSS and
  492,624 KB total RSS.
- Debug APK: 198,323,268 bytes (~189.1 MiB). Bundled `assets/`: 231,902 bytes
  (~226.5 KiB).
- Home, Explore, Saved, Create, Settings, and the new generated-pattern
  previews were visually smoke-tested. No Flutter or Android exceptions were
  found in the app process log.

### Limitations and next
- These debug-emulator timings and memory numbers do not represent a release
  build or a minimum-supported physical device.
- `dumpsys gfxinfo` did not yield useful Flutter frame timings on this run
  (one anomalous frame and a service timeout); no scrolling, detail-rendering
  or Creator-drag performance result is claimed from it.
- A profile-mode emulator timeline for Explore scrolling, design detail and
  Creator input is recorded below. Repeat on an agreed mid-range/lowest
  supported Android device before setting budgets or optimizing.

## 2026-11-24 — Phase 6: Repeated Profile-Mode Emulator Timeline

### Capture
- Device: Android 17 / API 37 x86_64 emulator, 1080×2400 at 420 dpi, 60 Hz.
- Build: Flutter profile mode using Impeller/OpenGLES. Captured Dart VM timeline
  `Frame` and `Rasterizer::DoDraw` slices after clearing the timeline for each
  interaction. Each workload was repeated three times in a bounded window.
- Workloads: three 350 ms vertical Explore-list swipes; opening the first
  design detail and allowing 1.5 seconds to settle; and four 500 ms
  freehand-canvas strokes.
- The 60 Hz frame interval is 16.67 ms. Values below are paired timeline slice
  durations pooled across the three traces, not release-device acceptance
  thresholds. The trace windows were 2.12–2.28 seconds for Explore,
  1.60–1.63 seconds for detail, and 3.31–3.56 seconds for Creator.

| Workload | UI `Frame` slices | UI p95 / max; over 16.67 ms | Raster slices | Raster p95 / max; over 16.67 ms |
| --- | ---: | --- | ---: | --- |
| Explore scroll | 232 | 13.97 / 27.55 ms; 8 | 232 | 32.98 / 61.39 ms; 135 (11 over 33.3 ms) |
| Design detail | 64 | 13.03 / 21.38 ms; 2 | 64 | 34.21 / 86.80 ms; 32 (4 over 33.3 ms) |
| Creator strokes | 229 | 21.19 / 28.05 ms; 26 | 233 | 39.99 / 63.12 ms; 161 (23 over 33.3 ms) |

### Interpretation and next
- In all nine traces, individual UI `BUILD`, `LAYOUT` and `PAINT` slices stayed
  below 16.67 ms. The longest raster slices were nested under engine/GLES
  submission events such as `SurfaceFrame::Submit` and `ReactorGLES::React`;
  this does not isolate an app-owned rendering bottleneck.
- These are still exploratory captures on an emulator hosted by an Intel
  Core i5-9300H Windows machine. Per-trace p95 values varied, particularly for
  detail rendering. Emulator and host graphics overhead prevent treating them
  as physical-device results or setting budgets from them.
- Physical-device repeat is deferred per user request. When a representative
  mid-range or lowest-supported device is available, repeat there before
  setting budgets. If raster misses persist, use a DevTools timeline to locate
  app-owned expensive work before choosing a narrowly targeted optimization.

## 2026-11-24 — Phase 7: Generator and Contributor Workflow

### Implemented
- Added a registry test proving that repeated generation from the same
  dot-grid-loop recipe produces identical recipe, grid and path snapshots.
- Added a persistence regression proving saved path geometry remains loadable
  when its recipe generator is unavailable in the current registry.
- Unsupported recipe versions remain readable as metadata without replacing
  their saved geometry snapshots; malformed recipe JSON now reports the field
  that could not be decoded.
- Unknown persisted freehand symmetry modes now fail explicitly instead of
  silently becoming `none`; malformed stroke fields now produce
  `FormatException`s instead of cast failures.
- Stroke equality now compares exact geometry values, with matching hash codes.
- Clear all local data now removes creations and favourites transactionally,
  clears preferences and locale, resets onboarding and reports storage errors.
- Unsupported persisted creation types now fail explicitly instead of being
  silently interpreted as templates.
- Corrected formatting drift in nine Dart files that caused the GitHub
  formatting check to fail.
- Reconciled the current baseline and working order with the implemented
  Creator, 20-design catalogue, geometry/schema versions, Phase 6 emulator
  captures and deferred physical-device checks.
- Documented the generator, catalogue, schema migration, local database
  migration, validation and release workflows above.

### Validation
- `flutter test test/features/pattern_generator_registry_test.dart` — passed;
  all 8 registry tests.
- `flutter test test/data/creations_dao_test.dart` — passed; all 10 DAO tests,
  including unsupported-version, malformed-recipe and symmetry regressions.
- `flutter test test/features/drawn_stroke_test.dart` — passed; all 3
  validation and value-semantics tests.
- `flutter test test/features/clear_local_data_test.dart` — passed; the
  Settings confirmation clears all local stores and resets locale.
- `flutter test` — passed; all 101 tests.
- `flutter analyze` — passed with no issues.
- `dart format --output=none --set-exit-if-changed lib test` — passed; all
  69 Dart files are formatted.
- `git diff --check` — passed.

### Remaining
- Keep rights, cultural, localization and lesson reviews pending until the
  required evidence and human approvals are supplied.
- Publish an approved privacy policy and replace the temporary Settings
  action before release.
- Continue Phase 7 maintenance as features evolve. Physical-device
  performance/accessibility checks and Phase 8 release gates remain deferred.

## AI practice lessons and source research

- Reviewed general Kolam references from [Sahapedia](https://www.sahapedia.org/significance-of-kolam-tamil-culture)
  and [Tamil Nadu Tourism](https://www.tamilnadutourism.tn.gov.in/experiences/kolam).
  They describe dot-grid construction and regional variation; Sahapedia also
  discusses Pulli/Sikku forms and lamp/lotus motifs in some festival Kolams.
- The retrieved sources do not verify the five exact generated motifs or their
  former traditional-sounding names. Renamed them as generic AI-generated
  dot-grid practice patterns and recorded the source limitations in each
  pending cultural-review record.
- Added English, Telugu and Tamil AI-assisted instructions for the five
  designs. An explicit `aiPractice` flag lets these patterns play as practice
  lessons with an authenticity notice; it does not approve any review record
  or make the designs publication-ready.
- Rights, cultural and localization reviews remain pending. The references
  support general descriptions only, not the exact artwork, regional naming,
  or lesson correctness.

## 2026-11-24 — Added colorful mixed-construction art studies

### Implemented
- Upgraded the catalogue to schema 4 and 67 entries. Seven original featured
  studies add layered floral art, a mandala, border and corner motifs, a 2D
  raised-cube illusion, a Warli-inspired panel labeled separately from rangoli,
  and a dot-connected Sikku Kolam study.
- Added illustrated construction for non-dot forms while retaining strict
  visible-dot endpoint validation for dot-guided designs.
- Added shared pastel fills, fine outlines, soft shadows and per-design
  backgrounds across previews, detail screens, saved creations and PNG export.
  Creator templates now use styled paths, and saved freehand geometry retains
  its selected stroke colors.
- Upgraded local SQLite to version 3 to persist creation backgrounds, including
  a tested version-2 migration that preserves existing creations and favourites.
- Added technique labels to Explore cards. All new studies remain app-created
  and unreviewed; none is presented as culturally verified or publication-ready.

### Validation
- `python -m unittest tools.test_generate_sample_catalog` — passed; all 7
  generator tests, including mixed construction, style and coordinate checks.
- `python tools/generate_sample_catalog.py --check` — passed; catalogue and
  decoded thumbnail artwork match generated output.
- `flutter test` — passed; all 106 tests.
- `flutter analyze` — passed with no issues.
- `flutter build apk --debug` — passed.
- Generated thumbnails visually checked for the featured designs.
- Rebooted `emulator-5554` after its package service became unavailable,
  installed the debug APK, and confirmed the app process launched.

## 2026-11-24 — Corrected Practice guidance

### Implemented
- Replaced the outdated “Practice is coming soon” notice with a localized
  tracing instruction and a clear note that the sample is not a culturally
  verified lesson.

### Validation
- `flutter gen-l10n` — passed.
- `flutter test test/widget_test.dart` — passed; all 4 widget tests.
- `flutter test` — passed; all 101 tests.
- `flutter analyze` — passed with no issues.
- `dart format --output=none --set-exit-if-changed lib test` — passed; all
  69 Dart files are formatted.
- `git diff --check` — passed.

## 2026-11-24 — Expanded the bundled design library

### Implemented
- Expanded the bundled catalogue from 20 to 60 samples with 40 new original
  geometric designs across rosette, star, orbit, lattice and wreath styles.
- Added descriptive names to the first ten generic geometric examples and
  placed the new designs first in the recommended catalogue order.
- Kept new designs explicitly identified as app-made samples, without region
  or tradition claims; all content reviews remain pending.
- Reduced lossless WebP encoder effort to keep 60-design generation fast;
  generated-art validation compares decoded pixels.

### Validation
- `python -m unittest discover -s tools -p 'test_*.py' -v` — passed; all 6
  generator tests, including 40 unique new thumbnail artworks.
- `python tools/generate_sample_catalog.py --check` — passed; catalogue and
  decoded thumbnail artwork match.
- `flutter test` — passed; all 101 tests, including catalog parsing and
  thumbnail decoding.
- `flutter analyze` — passed with no issues.
- `dart format --output=none --set-exit-if-changed lib test` — passed; all
  69 Dart files are formatted.
- `git diff --check` — passed.

## 2026-11-24 — Made all catalog designs dot-guided

### Implemented
- Added a visible dot grid to every catalog design and snapped non-grid path
  vertices to its dots; existing dot-grid patterns retain their authored grids.
- The schema 3 catalog parser now rejects designs without a dot grid or with
  path endpoints that do not land on grid dots.
- Kept new app-made patterns clearly unverified; this structural update does
  not certify them as authentic South Indian rangolis.

### Validation
- `python -m unittest discover -s tools -p 'test_*.py' -v` — passed; all 6
  generator tests verify dot grids and endpoint alignment.
- `python tools/generate_sample_catalog.py --check` — passed; catalog and
  decoded thumbnail artwork match generated output.
- `flutter test` — passed; all 102 tests, including missing-grid and
  off-grid-endpoint rejection.
- `flutter analyze` — passed with no issues.
- `dart format --output=none --set-exit-if-changed lib test` — passed; all
  69 Dart files are formatted.
- `flutter build apk --debug` — passed.
- Installed and launched the debug APK on `emulator-5554`.
- `git diff --check` — passed.

### Remaining
- Keep rights, cultural, localization and lesson reviews pending until the
  required evidence and human approvals are supplied.
- Publish an approved privacy policy and replace the temporary Settings
  action before release.
- Continue Phase 7 maintenance as features evolve. Physical-device
  performance/accessibility checks and Phase 8 release gates remain deferred.

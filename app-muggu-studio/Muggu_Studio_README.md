# Muggu Studio --- Product & Development Requirements

**Document purpose:** Source of truth for product scope, UX,
architecture, content, implementation rules and release acceptance.

**Status:** Sprint 1–3 foundations and prototypes are implemented; review-led
stabilization is underway before the planned combined Sprint 4 Creator and
Tracing Engine. See the Development Log for verified implementation status.

**Working product name:** Muggu Studio\
**Platform:** Android first\
**Framework:** Flutter\
**Initial languages:** English, Telugu and Tamil\
**Business model:** Free with non-intrusive ads + optional one-time
Premium unlock\
**Development model:** Solo, AI-assisted, local-first

> This document describes the intended product. It does not claim that
> planned features are already implemented. The separate Development Log
> records verified implementation progress, commands, test results,
> issues and environment-specific fixes.

------------------------------------------------------------------------

## 1. Product vision

Muggu Studio is a beginner-friendly creative and learning app for
traditional Indian floor art. It helps people discover regional designs,
understand how they are made, learn them step by step, practise tracing
and create their own patterns.

The app must be understandable to people who do not know the word
"Muggu".

### Brand positioning

**Muggu Studio**\
**Rangoli • Kolam • Muggu • Indian Floor Art**

Suggested tagline: **Create. Learn. Preserve. Share.**

Suggested product promise:

> Discover beautiful traditional floor-art designs, learn them step by
> step, practise at your own pace and create your own patterns.

Keep Muggu Studio as the distinctive working brand. Use Rangoli, Kolam
and Indian Floor Art prominently in onboarding, store listing,
descriptions and discovery metadata. Do not rename the product solely to
chase keywords.

### Product principles

1.  Regional traditions must be represented accurately and respectfully.
2.  Learning is the central differentiator; the creator is an important
    supporting feature.
3.  The basic experience must work offline.
4.  No registration or account is required.
5.  Original or properly licensed content only.
6.  Keep the app simple enough for one developer to maintain.
7.  Build and validate in small increments; do not build the entire
    product at once.

------------------------------------------------------------------------

## 2. Audience and regional strategy

### Initial audience

-   People who create Muggu, Kolam or Rangoli at home.
-   Beginners who want simple, guided instructions.
-   People looking for daily, festival and occasion-based inspiration.
-   Families who want to preserve and teach traditional designs.
-   International users interested in Indian floor art and geometric
    patterns.

### Regional content strategy

Treat regional names and styles as related but distinct traditions. Do
not label every design as interchangeable Rangoli or Kolam.

Initial launch focus:

1.  Andhra Pradesh and Telangana: Muggu / Muggulu and relevant dot-based
    traditions.
2.  Tamil Nadu: Pulli Kolam, Sikku Kolam and other verified Kolam forms.
3.  A carefully curated general Rangoli collection for broader
    discovery.

Later expansion, only after research and native/regional review:

-   Karnataka: relevant local Rangoli and dot-design traditions.
-   Maharashtra and Gujarat: regional Rangoli styles.
-   Bengal: Alpana.
-   Rajasthan: Mandana.
-   Other regional traditions, including Aripana and Chowk Purana, only
    with knowledgeable content review.

For every design, record its actual tradition, region, local name and
technique. Do not infer origin from appearance alone.

### Language strategy

Initial UI languages: English, Telugu and Tamil.

-   Language choice must be independent of the selected regional
    collection.
-   A Telugu-speaking user must be able to browse Tamil Kolam designs,
    and an English-speaking user must be able to explore Muggu.
-   Add Hindi, Kannada, Marathi, Gujarati and other languages only when
    translations can be reviewed by fluent speakers.
-   Use appropriate fonts and test actual rendering on Android devices.
-   Avoid machine-translated cultural instructions without human review.

### Search terminology

Search should recognise localized names and synonyms, including common
English spellings and transliterations. Examples include Muggu, Muggulu,
Rangoli, Kolam, Pulli Kolam, Sikku Kolam, Chukkala Muggu and Chukki
Rangoli.

Synonyms are discovery aids, not a reason to misclassify the design's
regional origin.

------------------------------------------------------------------------

## 3. MVP scope

### P0 --- Required for first useful release

#### Home

-   Daily design or rotating featured design.
-   Clear entry points to Explore, Learn and Create.
-   Regional collections and beginner-friendly collections.
-   Festival/occasion collection entry points when relevant.
-   Recently viewed or saved designs where useful.
-   No login prompt.

#### Explore and gallery

-   Initial target: 60 original or properly licensed designs, added
    progressively.
-   Search by localized name, English name, technique, region and
    synonyms.
-   Filters: region/tradition, style/technique, difficulty, dot-grid
    size and occasion.
-   Sort by recommended, newest and difficulty where meaningful.
-   Clear empty and no-results states.
-   Favourites.

#### Design detail

-   Large, clear preview.
-   Localized name and description.
-   Region/tradition and technique.
-   Difficulty, dot-grid dimensions and estimated learning time when
    known.
-   Actions: Learn, Trace/Practise, Favourite, Save or Share.
-   Do not show metadata that has not been verified.

#### Guided learning

-   Initial target: 20 verified tutorials; begin implementation with 5
    complete lessons.
-   Step-by-step drawing order.
-   Previous/next, play/pause, replay and restart.
-   Current step and total step count.
-   Localized short instructions.
-   Optional tracing/guide overlay.
-   Allow users to learn at their own pace; no punitive scoring.
-   A lesson must be checked against the intended original design before
    it is published.

#### Practice / tracing

-   Display a faint guide.
-   Accept touch input over the guide.
-   Forgiving guidance; do not require pixel-perfect tracing.
-   Clear, undo and restart.
-   Explain the next action in simple language.
-   Keep the guide and user drawing visually distinguishable.

#### Creator

-   Dot-grid sizes initially: 5×5, 7×7 and 9×9.
-   Touch drawing with smooth paths.
-   Symmetry: none, vertical, horizontal and four-way.
-   Palette selection and stroke-size control.
-   Undo, redo and clear.
-   Save locally, reopen, rename and delete.
-   Export PNG and share using the Android system share sheet.
-   Do not request broad storage permissions.

#### Saved

-   Separate Favourites and My Creations.
-   Open, edit, rename, delete and share saved creations.
-   Persist across app restarts and app upgrades.

#### Settings

-   English/Telugu/Tamil language selection.
-   App information, privacy policy and Premium entry.
-   Clear local user data action with confirmation.
-   Accessible controls and text scaling.

#### Offline

-   Core catalogue, thumbnails, lessons, creator and saved data must
    work offline.
-   No network dependency for basic browsing, learning or drawing.

### P1 --- After core experience is stable

-   AdMob monetization.
-   One-time Premium purchase and restore.
-   Festival calendar and seasonal collections.
-   Additional regional content and languages.
-   Colour-palette inspiration and preview.
-   Daily design notification, opt-in only.
-   More tutorial packs.

### P2 --- Defer until user demand is demonstrated

-   AI pattern generation.
-   Cloud backup or account sync.
-   Community submissions and public profiles.
-   Social feed, comments or messaging.
-   User-uploaded public galleries.
-   Backend services and custom APIs.
-   Complex gamification or leaderboards.

Do not add P1/P2 features during Sprint 1 or Sprint 2 unless explicitly
approved.

------------------------------------------------------------------------

## 4. UX and navigation

### Bottom navigation

Use four primary destinations:

1.  Home
2.  Explore
3.  Create
4.  Saved

Settings, language and Premium should be accessible from Home/app bar or
an appropriate menu, not as additional bottom tabs.

### First-time onboarding

Use a short, skippable onboarding flow:

1.  Choose app language: English, Telugu or Tamil.
2.  Choose interests: Muggu, Kolam, Rangoli or all.
3.  Choose experience level: Beginner or Experienced.

Persist choices locally. Do not require an account. Do not block users
from changing these choices later.

### Home screen

-   Brand and language access.
-   Featured/daily design.
-   "Learn this design" action.
-   "Create your own" action.
-   Regional collections.
-   Beginner lessons.
-   Seasonal collection when relevant.
-   Recently viewed/saved section when useful.

Daily selection can be deterministic and local; no backend is needed.

### Explore screen

-   Search field.
-   Region/tradition, technique, difficulty and dot-grid filters.
-   Clear filter state.
-   Design cards with readable titles and useful thumbnails.
-   Search across synonyms and localized metadata.

### Design detail screen

-   Preview with zoom where useful.
-   Name, region, technique and difficulty.
-   Learn and Practise actions.
-   Favourite and share.
-   Explain unfamiliar terms briefly.

### Learning screen

-   Large drawing canvas.
-   Current step / total.
-   Previous, next, play/pause, replay and restart.
-   Localized instruction.
-   Optional guide/tracing mode.
-   Completion state with option to practise again or save.

### Creator screen

-   Canvas and visible dot grid.
-   Grid-size selection.
-   Drawing tool and symmetry controls.
-   Colour palette and stroke size.
-   Undo/redo and clear.
-   Save, export and share.
-   Controls must remain usable on small Android screens and must not
    obscure the drawing surface.

### Saved screen

-   Favourites and My Creations.
-   Empty states with useful links back to Explore/Create.
-   Edit, rename, delete and share for user creations.

------------------------------------------------------------------------

## 5. Content model and artwork requirements

### Content targets

Initial content plan:

-   15 simple daily Muggu designs.
-   15 Pulli/Dot Kolam designs.
-   10 Sikku/Kambi Kolam designs.
-   10 floral/geometric Rangoli designs.
-   10 festival/occasion designs.

These are planning targets, not permission to mislabel regional styles.
Reallocate categories when content review shows a better classification.

Build content in stages: - First milestone: 10 verified designs and 5
complete tutorials. - MVP target: 60 verified designs and 20 complete
tutorials.

Accuracy and usability matter more than reaching the target count
quickly.

### Artwork rights

-   Create original designs or obtain explicit permission/licences.
-   Do not scrape or copy competitor apps, Pinterest, Instagram or other
    creators.
-   Do not reproduce copyrighted illustrations or screenshots.
-   Keep source files, creator details, licence/permission and
    attribution records.
-   Obtain permission before using a contributor's design.
-   Preserve editable vector source data.

### Design data format

Prefer vector path data over image-only content so the same design can
support preview, tutorial animation, tracing and editing.

Suggested model:

``` json
{
  "id": "muggu_001",
  "localizedName": {
    "en": "Simple Floral Muggu",
    "te": "సులభమైన పూల ముగ్గు",
    "ta": "எளிய மலர் கோலம்"
  },
  "localizedDescription": {
    "en": "A beginner-friendly floral dot design."
  },
  "region": "andhra_pradesh",
  "tradition": "muggu",
  "technique": "dot_muggu",
  "difficulty": "easy",
  "grid": {
    "rows": 5,
    "columns": 5
  },
  "estimatedMinutes": 5,
  "occasionTags": ["daily"],
  "searchTags": ["muggu", "muggulu", "rangoli"],
  "isPremium": false,
  "thumbnail": "assets/designs/thumbnails/muggu_001.webp",
  "strokes": [
    {
      "id": "stroke_01",
      "points": [[0.50, 0.10], [0.65, 0.25], [0.50, 0.40]],
      "type": "curve"
    }
  ],
  "steps": [
    {
      "step": 1,
      "strokeIds": ["stroke_01"],
      "instruction": {
        "en": "Draw the first curved line."
      }
    }
  ],
  "contentReview": {
    "status": "pending",
    "reviewer": "",
    "sourceOrPermission": ""
  }
}
```

This is an illustrative schema only. Coordinates, regional attribution,
instructions and artwork must be verified before publication. Add schema
versioning and validation. Missing translations should use a safe
fallback rather than crashing.

### Content review

Each published design must be checked for: - Correct
regional/traditional label. - Accurate local name and spelling. -
Correct dot layout and stroke order. - Clear preview and thumbnail. -
Beginner difficulty assessment. - Tutorial instructions that match the
design. - Rights/permission record. - Human review of Telugu/Tamil
wording where applicable.

------------------------------------------------------------------------

## 6. Drawing and tutorial engine

Use Flutter CustomPainter/Canvas and normalized vector coordinates.

### Rendering

-   Render background, dot grid, guide paths, user strokes and overlays
    as separate layers.
-   Preserve aspect ratio.
-   Convert touch positions to normalized coordinates.
-   Smooth user paths.
-   Keep drawing responsive on lower-end Android devices.

### Symmetry

-   None.
-   Vertical reflection.
-   Horizontal reflection.
-   Four-way reflection.

Test centre-line and centre-point behaviour carefully to avoid duplicate
or unexpected strokes.

### History

-   Undo/redo using a predictable command or snapshot history.
-   Clear with confirmation or undo support.
-   Save/load must preserve paths, colours, grid and symmetry settings.

### Tutorial playback

-   Steps reference stroke IDs.
-   Animate strokes in the correct order.
-   Support pause, resume, previous, next and restart.
-   Do not depend on network access.

### Export

-   Render a clean image without editing controls.
-   Export PNG at a useful resolution.
-   Use app-specific storage/cache and Android Sharesheet.
-   Avoid broad external-storage permissions.

### Required tests

-   Normalized coordinate conversion.
-   Canvas aspect ratio.
-   Grid rendering and touch mapping.
-   Vertical, horizontal and four-way symmetry.
-   Strokes crossing the centre line.
-   Undo/redo sequences.
-   Serialization and restoration.
-   Tutorial stroke order.
-   PNG export.

------------------------------------------------------------------------

## 7. Architecture and technology

Keep the current Flutter local-first architecture. Do not introduce a
backend for the first release.

### Stack

-   Flutter / Dart with Material 3.
-   Riverpod for state management.
-   GoRouter for navigation.
-   Flutter CustomPainter/Canvas for drawing.
-   Bundled JSON catalogue and vector data.
-   WebP thumbnails.
-   SQLite (`sqflite`) for favourites, saved creations and progress.
-   SharedPreferences for language and lightweight settings.
-   `path_provider` for app-specific file paths.
-   `share_plus` for sharing.
-   Flutter localization / ARB.
-   `google_mobile_ads` when monetization is approved.
-   `in_app_purchase` for Premium when monetization is approved.
-   `flutter_test` and `integration_test`.

Use package versions compatible with the verified installed Flutter/Dart
SDK. Check current package maintenance and compatibility before adding
dependencies.

### Suggested structure

``` text
muggu_studio/
├── assets/
│   ├── designs/
│   │   ├── catalog.json
│   │   ├── thumbnails/
│   │   └── vectors/
│   ├── icons/
│   └── illustrations/
├── lib/
│   ├── main.dart
│   ├── app/
│   │   ├── app.dart
│   │   └── router.dart
│   ├── core/
│   │   ├── theme/
│   │   ├── localization/
│   │   ├── storage/
│   │   └── widgets/
│   ├── features/
│   │   ├── home/
│   │   ├── gallery/
│   │   ├── design_detail/
│   │   ├── learning/
│   │   ├── practice/
│   │   ├── creator/
│   │   ├── saved/
│   │   ├── premium/
│   │   └── settings/
│   └── data/
│       ├── models/
│       ├── repositories/
│       └── local/
├── test/
├── integration_test/
├── pubspec.yaml
└── README.md
```

Adapt this to the existing repository rather than restructuring files
unnecessarily.

### Engineering requirements

-   Separate UI, domain logic and persistence.
-   Keep widgets small and testable.
-   Use repository abstractions for local data.
-   Avoid unnecessary global mutable state.
-   Handle loading, empty and error states.
-   Add catalogue schema validation.
-   Version local database migrations and catalogue format.
-   Compress assets and avoid oversized images.
-   Never commit secrets, signing keys or production ad IDs.
-   Document environment-specific build workarounds.
-   Add GitHub Actions CI for format, analysis and tests when the core
    workflow is stable.

------------------------------------------------------------------------

## 8. Design system and accessibility

### Brand palette

-   Deep Maroon: `#862B37`
-   Warm Cream: `#FFF5E8`
-   Turmeric Gold: `#D8A13B`
-   Leaf Green: `#55775D`
-   Dark Brown: `#3C342E`

Use a warm, traditional but modern visual style. Keep screens
uncluttered. Material 3.

### Typography

-   English: Roboto or Noto Sans.
-   Telugu: Noto Sans Telugu.
-   Tamil: Noto Sans Tamil.

Verify actual glyph rendering, line wrapping and clipping on Android
devices.

### Accessibility

-   Large touch targets.
-   Sufficient colour contrast.
-   Screen-reader labels for controls.
-   Support Android font scaling.
-   Avoid relying on colour alone to communicate state.
-   Provide clear labels for drawing tools.
-   Test on small screens and different display densities.

------------------------------------------------------------------------

## 9. Monetization

Do not implement monetization until the core user experience works.

### Proposed model

Free with ads + one-time lifetime Premium. No subscription initially.

Indicative experiment only: ₹149 lifetime Premium. Do not hardcode this
price; use the localized price returned by Google Play Billing and
validate willingness to pay.

### Free tier proposal

-   40 basic designs.
-   8 guided tutorials.
-   Basic creator and palette.
-   Favourites, local saving and sharing.
-   Ads.

### Premium proposal

-   60+ designs and future premium packs.
-   All 20+ tutorials.
-   Advanced palettes and premium content.
-   Remove ads.

Keep the basic creator useful in the free tier.

### Advertising safeguards

-   Use test ad IDs during development.
-   Never click live ads during testing.
-   Use non-intrusive placements, such as a reserved banner area on
    Home/Explore.
-   Clearly label ads.
-   No ads on the drawing canvas or during tutorial steps.
-   Avoid accidental-click layouts and excessive interstitials.
-   Use the current consent flow (UMP) where required.
-   Follow current AdMob and Google Play policies.

### Billing safeguards

-   One-time non-consumable product.
-   Product ID configured in Play Console.
-   Query product details and show live localized price.
-   Handle pending, success, cancellation and failure.
-   Restore purchases.
-   Persist entitlement safely and handle reinstall/device change.
-   Test with Play license testers and internal testing.
-   Never claim a purchase succeeded until the store confirms it.

------------------------------------------------------------------------

## 10. Privacy and security

The first release should collect as little data as possible.

-   No account, name, email, phone or location collection by the app.
-   No contacts, camera or microphone permissions.
-   No broad storage permission.
-   User creations remain on-device.
-   Use Android Sharesheet and app-specific storage.
-   Disclose data processed by third-party SDKs such as ads and billing.
-   Privacy policy and Play Data Safety answers must match actual SDK
    behaviour.
-   Do not claim "no data collected" without checking all integrated
    SDKs.
-   Provide a way to delete locally stored user data.
-   Add consent controls where legally or platform-required.

------------------------------------------------------------------------

## 11. Updated roadmap

Assumption: one developer, approximately 8--10 hours per week. Estimates
are planning aids, not deadlines.

### Sprint 1 --- Foundation (completed; see Development Log)

-   Flutter scaffold.
-   Material 3 theme.
-   English/Telugu/Tamil localization.
-   Language selector with local persistence.
-   Home, Explore, Create and Saved navigation.
-   Placeholder screens.
-   Android label, launcher icon and launch screen.
-   Formatting, analysis, widget tests and Android debug APK verified.

### Sprint 2 --- Catalogue and Explore

Goal: users can browse and find real designs.

-   Finalize catalogue schema and validation.
-   Add 10 authentic, reviewed designs initially.
-   Add thumbnails and localized metadata.
-   Implement Explore gallery, search, filters and sorting.
-   Add regional/tradition categories.
-   Add synonym search.
-   Implement favourites and local persistence.
-   Add empty/error states.
-   Do not implement the full drawing engine in this sprint.

Acceptance: - Catalogue loads offline. - All 10 designs display correct
metadata and images. - Search works for localized names and synonyms. -
Filters can be combined and cleared. - Favourites persist after app
restart. - No broken thumbnails or empty category links. - Tests cover
repository, search, filters and favourites.

### Sprint 3 --- Design detail and learning engine

Goal: a user can open a design and follow a complete lesson.

-   Design detail screen.
-   Vector rendering foundation.
-   First 5 verified lessons.
-   Correct stroke order and instructions.
-   Previous/next, play/pause and restart.
-   Localized lesson instructions.

Acceptance: - Lesson matches the verified reference design. - Playback
controls work. - Rendering preserves proportions. - Lesson works
offline. - Tests cover stroke ordering and playback state.

### Sprint 4 --- Practice and tracing

Goal: provide a basic offline drawing engine for both creation and guided
practice. This scope combines the creator engine and tracing work shown in
the Sprint 4 architecture diagram; stabilization and content governance
must be completed first. Before implementation, also finish the reviewed
lesson-step model and catalogue-localization groundwork so practice and
future lessons do not treat vector strokes as teaching steps.

-   CustomPainter drawing engine with normalized pointer-down/move/up input.
-   Dot-grid overlays for 5×5, 7×7 and 9×9.
-   Symmetry: none, vertical, horizontal and four-way.
-   Command history with undo and redo.
-   Practice/tracing mode with a faint design guide and touch drawing.
-   Clear and restart; forgiving, non-scoring guidance.
-   Small-screen and lower-end device performance checks.

Acceptance: - Touch mapping aligns with the guide. - User can practise
without network. - All symmetry modes render correctly. - Undo and redo
are reliable. - No punitive scoring. - Tests cover coordinate conversion,
path handling and history.

### Sprint 5 --- Creator polish and persistence

Goal: let users customize, save and reopen original dot-grid designs.

-   Colour and stroke-size selection.
-   Save and reopen locally.
-   Rename and delete saved creations.

Acceptance: - All symmetry modes behave correctly. - Undo/redo are
reliable. - Saved creations reopen correctly after restart. - Drawing
remains responsive on a lower-end Android device.

### Sprint 6 --- Export, sharing and offline hardening

-   PNG export.
-   Android Sharesheet.
-   Saved creations management.
-   Database migration/versioning.
-   Offline and process-restart testing.
-   Integration tests.

Acceptance: - Exported PNG has correct dimensions and no editing
controls. - Sharing opens Android's system sheet. - User data survives
restart and app upgrade. - Core app works in airplane mode.

### Sprint 7 --- Content expansion and release candidate

-   Expand toward 60 reviewed designs and 20 lessons.
-   Regional content and language review.
-   Accessibility, performance and device testing.
-   Store listing assets and privacy policy draft.
-   Resolve critical defects.

### Sprint 8 --- Monetization and publishing

-   AdMob integration and consent.
-   Billing, restore and entitlement handling.
-   Privacy and Data Safety disclosures.
-   Play Console testing and production preparation.
-   Staged rollout and monitoring.

Do not delay a stable core release solely to add AI or community
features.

------------------------------------------------------------------------

## 12. QA and release acceptance

### Functional

-   Offline launch and browsing.
-   Language selection and persistence.
-   Search, synonyms and filters.
-   Design details and metadata.
-   Favourites.
-   Correct tutorial stroke order.
-   Pause, replay and restart.
-   Tracing input.
-   Dot-grid selection.
-   Drawing, symmetry, undo and redo.
-   Save, reopen, rename and delete.
-   PNG export and share.
-   Purchase and restore, when implemented.
-   Ads and consent, when implemented.

### Non-functional

-   No clipped Telugu/Tamil text.
-   No broken thumbnails or dead navigation.
-   Responsive drawing on budget Android hardware.
-   No network dependency for core functionality.
-   Safe process death/restart and database upgrades.
-   Reasonable app size and compressed assets.
-   Test small, mid-range and lower-memory Android phones.
-   Test supported Android versions, font scaling and display densities.

### Release quality

-   No known critical data-loss or navigation defect.
-   No critical crash in release testing.
-   Target crash-free sessions above 99.5% once sufficient production
    data exists; this is a monitoring target, not a pre-launch
    guarantee.
-   All published designs have rights and content-review records.
-   Store listing and privacy declarations match actual app behaviour.

### Metrics after launch

-   Store impressions and install conversion.
-   DAU/MAU and D1/D7 retention.
-   Designs opened per session.
-   Tutorial starts and completions.
-   Creator sessions.
-   Saves, exports and shares.
-   Premium conversion.
-   Ad impressions/revenue.
-   Crashes and ANRs.

Use actual behaviour and reviews to decide what to build next. Do not
treat target metrics as guaranteed outcomes.

------------------------------------------------------------------------

## 13. Play Store preparation

Before release, verify current Google Play requirements rather than
relying on old tutorials.

Checklist: - Final permanent application ID / package name. - Play
Console account and identity/contact verification. - Required target API
level at release time. - Signed Android App Bundle (AAB) and Play App
Signing. - Versioning and release build configuration. - App title,
short/full description, icon, feature graphic and screenshots. -
Category, tags, content rating and target audience. - Ads declaration. -
Public privacy policy. - Accurate Data Safety form. - App access
instructions if any gated functionality exists. - AdMob configuration
and consent. - Premium product and purchase/restore tests. -
Internal/closed testing and production-access requirements applicable to
the account. - Policy warnings resolved. - Staged rollout and
post-release monitoring.

The app ID is currently `com.example.muggu_studio` according to the
development log. Choose the permanent publisher namespace before release
and update Android configuration consistently. Do not change the
application ID casually after publication.

------------------------------------------------------------------------

## 14. AI coding-agent operating instructions

You are the senior Flutter engineer implementing Muggu Studio.

1.  Read this entire document before making changes.
2.  Treat it as the product source of truth. The Development Log is the
    source of truth for verified progress and environment history.
3.  Inspect the existing repository before editing. Do not assume files
    or implementation details.
4.  Sprint 1 is complete. Do not recreate it.
5.  Work only on the sprint explicitly requested. Do not implement the
    entire app in one attempt.
6.  For Sprint 2, implement only the catalogue and Explore scope
    described above.
7.  Propose the exact files to create or modify before implementation.
8.  Use stable, maintained packages compatible with the installed
    Flutter/Dart SDK.
9.  Preserve existing architecture unless there is a clear, documented
    reason to change it.
10. Do not add backend, login, AI APIs, cloud sync, ads or billing
    without explicit approval and the relevant sprint.
11. Do not use copied competitor artwork or scraped images.
12. Do not invent regional attribution, translations or tutorial steps.
13. Keep UI, domain logic and persistence separated.
14. Handle loading, empty and error states.
15. Use null-safe Dart and small, testable widgets.
16. Never commit secrets, signing keys or production ad IDs.
17. Never hardcode Google Play Billing prices.
18. Never use live AdMob IDs in development.
19. Run `dart format`, `flutter analyze` and relevant tests after
    changes.
20. Report the exact commands run and actual results. Do not claim a
    test passed unless it was executed and checked.
21. Fix issues introduced by the change before declaring the sprint
    complete.
22. Update this document only for approved product/scope decisions.
    Update the Development Log with implementation details, commands,
    test results, issues, fixes and known limitations.
23. Stop at the requested sprint's acceptance criteria and wait for
    approval.

### Required implementation response format

For each sprint or feature, report:

-   Existing implementation inspected.
-   Scope being implemented.
-   Exact files to create/modify.
-   Design/architecture approach.
-   Implementation completed.
-   Commands executed and actual results.
-   Tests added and outcomes.
-   Known issues and limitations.
-   Documentation updated.
-   Items deliberately deferred.

Do not claim a feature is complete based only on code generation or a
successful build. Verify the user-visible behaviour where practical.

------------------------------------------------------------------------

## 15. Sprint 2 task prompt

Use this prompt in the IDE coding agent after placing this document in
the repository:

> You are the senior Flutter engineer implementing Muggu Studio.
>
> Read the complete `Muggu_Studio_README.md` and the current Development
> Log before editing. Inspect the repository and current implementation.
> Sprint 1 is complete; do not recreate or unnecessarily refactor it.
>
> Implement **Sprint 2 only: Catalogue and Explore**.
>
> The product is a regional Indian floor-art discovery and learning app.
> It must be understandable to people who do not know the word Muggu.
> Keep Muggu Studio as the brand and make Muggu, Rangoli and Kolam
> discoverable. Do not misrepresent distinct regional traditions.
>
> Start with 10 original or properly licensed designs. Each design must
> have a stable ID, localized name/description where available, verified
> region/tradition, technique, difficulty, grid metadata where relevant,
> search tags, thumbnail path and content-review status. Use clearly
> marked original sample/vector designs only; do not scrape or copy
> artwork. Do not invent cultural attribution.
>
> Implement the catalogue model/repository, schema validation, offline
> loading, Explore gallery, search across localized names and synonyms,
> regional/technique/difficulty/grid filters, sorting where appropriate,
> design cards, useful empty states and favourites persisted locally.
>
> Keep English, Telugu and Tamil working. Language choice must remain
> independent of regional collection choice. Do not implement the
> drawing engine, tutorials, tracing, ads, billing, backend, accounts or
> AI in this sprint.
>
> Before coding, report the current repository structure, the existing
> relevant files, proposed changes and any compatibility risks. Then
> implement the smallest coherent slice.
>
> Run `dart format`, `flutter analyze`, `flutter test` and the relevant
> Android build. Add tests for catalogue parsing/validation, search
> synonyms, filters and favourite persistence. Report actual command
> results and any limitations. Update the Development Log. Stop after
> Sprint 2 acceptance criteria and wait for approval.

------------------------------------------------------------------------

## 16. Decision log

  -----------------------------------------------------------------------
  Decision                            Current choice
  ----------------------------------- -----------------------------------
  Product                             Muggu Studio

  Positioning                         Rangoli, Kolam, Muggu and Indian
                                      Floor Art

  Platform                            Android first

  Framework                           Flutter

  Initial languages                   English, Telugu, Tamil

  Initial regional focus              Andhra/Telangana, Tamil Nadu,
                                      general Rangoli

  Core experience                     Discover + Learn + Practise +
                                      Create

  Initial content milestone           10 designs, 5 tutorials

  MVP content target                  60 designs, 20 tutorials

  Architecture                        Local-first, no backend

  Navigation                          Home, Explore, Create, Saved

  Monetization                        Ads + one-time Premium, after core
                                      validation

  Indicative Premium test             ₹149 lifetime; validate and use
                                      live store price

  Budget                              ₹5,000--₹15,000 overall planning
                                      budget; verify actual costs

  Development                         Solo, AI-assisted

  Sprint 1                            Completed and verified on 13
                                      November 2026

  Next step                           Complete review-led stabilization,
                                      content governance and lesson-model
                                      groundwork before Sprint 4 Creator
                                      and Tracing Engine
  -----------------------------------------------------------------------

------------------------------------------------------------------------

## 17. Final product direction

Build a small, useful and trustworthy app. Do not compete on the number
of pictures alone.

The strongest initial experience is:

**Discover a regional design. Understand its tradition. Learn it step by
step. Practise it. Create your own.**

Prioritize content accuracy, beginner usability, offline reliability and
a smooth drawing experience. Launch the core product, observe real usage
and reviews, then expand only where users demonstrate a need.

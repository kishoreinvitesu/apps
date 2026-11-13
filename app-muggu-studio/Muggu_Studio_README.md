# Muggu Studio --- Product, Engineering & Play Store Launch Blueprint

**Document type:** Product requirements + technical implementation
guide\
**Product:** Muggu Studio --- Rangoli, Muggu & Kolam\
**Platform:** Android first (Flutter)\
**Initial languages:** Telugu, Tamil, English\
**Business model:** Free with advertising + one-time Premium unlock\
**Audience:** Indian home, leisure, cultural-art and creative users;
international users interested in Rangoli/Kolam\
**Status:** Ready for implementation planning\
**Version:** 1.0

------------------------------------------------------------------------

## 1. Executive summary

Muggu Studio is an offline-first Android application for discovering,
learning, practising and creating traditional Indian floor-art designs:
Muggu, Rangoli and Kolam.

It must not be just another static image gallery. The product combines:

1.  A curated, searchable library of original designs.
2.  Beginner-friendly, step-by-step drawing lessons.
3.  A tracing/practice mode.
4.  An interactive dot-grid and freehand creator.
5.  Local saving, PNG export and Android sharing.
6.  Telugu, Tamil and English user interfaces and localized design
    metadata.

The first release should be deliberately small, polished and reliable.
It should not require user registration, a cloud backend, AI APIs,
social networking or ongoing server costs.

### Product promise

**Browse beautiful designs. Learn every step. Create your own.**

Suggested brand line:

-   Telugu: మన ముగ్గులు
-   Tamil: நம் கோலங்கள்
-   English: Our Traditions

" M ug gu Studio" is a working product name only. Check trademark,
domain and Google Play availability before publication.

------------------------------------------------------------------------

## 2. Product goals and non-goals

### 2.1 Goals

-   Make traditional Muggu/Kolam patterns accessible to beginners and
    regular practitioners.
-   Make it easy to find a design by category, difficulty, dot count or
    language.
-   Teach the sequence of drawing, rather than showing only a finished
    picture.
-   Let users practise by tracing a guide.
-   Let users create, save and share original patterns.
-   Work offline for the catalogue, lessons, favourites and creator.
-   Support Telugu, Tamil and English from the initial release.
-   Monetize without interrupting the creative experience.
-   Keep the app maintainable by one developer using Flutter and AI
    coding assistance.

### 2.2 Non-goals for version 1

Do not build these in the first release:

-   User accounts or login.
-   Cloud synchronization or backup.
-   Community uploads, comments or social feeds.
-   AI image generation.
-   Subscription billing.
-   WhatsApp/Telegram bots.
-   A web dashboard.
-   A backend API or custom server.
-   Complex 3D room/floor visualization.
-   Video time-lapse export.
-   Unmoderated user-generated content.

These can be reconsidered only after usage data demonstrates demand.

------------------------------------------------------------------------

## 3. Target users and use cases

### Primary audience

-   People who draw Muggu/Kolam/Rangoli at home.
-   Beginners who want simple instructions.
-   People looking for daily doorstep designs.
-   Festival users preparing Pongal, Sankranti, Diwali and other
    celebrations.
-   Creative leisure users who enjoy drawing patterns.
-   Users who want to save or share designs with family and friends.

This is a general-audience lifestyle app, not a child-directed app.

### Core user stories

1.  As a user, I can open the app and immediately see a useful daily
    design.
2.  As a Telugu user, I can browse and read design details in Telugu.
3.  As a Tamil user, I can browse and read design details in Tamil.
4.  As a user, I can find simple designs suitable for my skill level.
5.  As a beginner, I can follow one drawing step at a time.
6.  As a learner, I can trace a faint guide with my finger.
7.  As a creator, I can choose a dot grid and draw a symmetrical
    pattern.
8.  As a user, I can undo, redo, change colours and clear the canvas.
9.  As a user, I can save my creation locally and reopen it later.
10. As a user, I can export a clean PNG and share it through Android's
    share sheet.
11. As a user, I can use the core app without an internet connection.
12. As a Premium user, I can remove ads and unlock premium content.
13. As a previous purchaser, I can restore my Premium entitlement.

------------------------------------------------------------------------

## 4. Market position and competitor differentiation

The category has existing apps with meaningful adoption. The product
must not claim that the market is empty.

Competitor examples identified during initial research:

-   **Kolangal by Nithra:** established design collection, categories,
    favourites and offline-oriented use. Its listing has shown 100K+
    installs and a high rating.
-   **Rangoli by Drik Panchang:** festival-oriented collections and
    drawing instructions; its listing has shown 100K+ installs.
-   **Dot Kolam:** a direct interactive-creator competitor with dot
    grids, symmetry, drawing, colour and saving features. Its listing
    showed a comparatively small install badge at the time of the
    initial audit.

Store figures change over time and vary by region. Recheck current
listings, reviews, feature sets and policies before launch. Downloads
and ratings are adoption signals, not proof of profitability.

### Differentiation strategy

Do not compete only on number of designs or the existence of a dot-grid
canvas.

Differentiate through the combined experience:

1.  **Regional-first content:** Telugu, Tamil and English names,
    descriptions, instructions and search synonyms.
2.  **Learn + trace:** verified stroke-by-stroke tutorials and a
    practice mode.
3.  **Daily inspiration:** a useful daily design and seasonal
    collections.
4.  **One integrated creator:** start from a blank canvas or open a
    library design and modify it.
5.  **Offline-first:** no account or network required for core features.
6.  **Beginner-friendly UX:** clear controls, large touch targets and
    simple difficulty filters.
7.  **Authentic content:** original or properly licensed artwork with
    manually verified drawing sequences.

### Competitor research checklist

Before release, manually revisit the relevant Google Play listings and
record:

-   Current install range and rating.
-   Number and recency of reviews.
-   Recent negative reviews and recurring complaints.
-   Languages supported.
-   Offline functionality.
-   Tutorial quality.
-   Creator capabilities.
-   Advertising frequency and user complaints.
-   Premium pricing and unlock model.
-   App size, update cadence and compatibility.

Do not copy competitor artwork, descriptions, branding, screenshots or
proprietary content.

------------------------------------------------------------------------

## 5. MVP scope

### P0 --- required for first usable release

  -----------------------------------------------------------------------
  Area                                Required functionality
  ----------------------------------- -----------------------------------
  Home                                Daily design, key categories, Learn
                                      and Create entry points

  Gallery                             Browse 60 designs, category
                                      filters, search and sorting

  Design detail                       Preview, name, category,
                                      difficulty, dot count and estimated
                                      time

  Learning                            20 verified step-by-step lessons

  Tracing                             Display a faint guide and accept
                                      finger tracing

  Creator                             Dot grid, touch drawing, basic
                                      symmetry, colour, undo/redo

  Saved                               Favourites and locally saved user
                                      creations

  Export                              PNG image export and Android share
                                      sheet

  Localization                        Telugu, Tamil and English UI and
                                      content

  Offline                             Core content, lessons, creator and
                                      saved designs work offline

  Settings                            Language, privacy policy, app
                                      version and restore purchase
  -----------------------------------------------------------------------

### P1 --- include only after the core experience is stable

-   AdMob advertising.
-   One-time Premium purchase.
-   Premium design packs.
-   Advanced colour palettes.
-   Additional creator templates.
-   Optional daily reminder.

### P2 --- future possibilities, not release blockers

-   More Indian languages.
-   More design collections.
-   Cloud backup.
-   User-submitted designs with moderation.
-   AI-assisted pattern generation.
-   Time-lapse export.
-   Web version.
-   Community challenges.

### Initial content target

Start with 60 original designs:

  Collection                       Target count
  ------------------------------ --------------
  Simple daily Muggu                         15
  Pulli / Dot Kolam                          15
  Sikku / Kambi Kolam                        10
  Flower and geometric Rangoli               10
  Pongal / Sankranti / Diwali                10
  **Total**                              **60**

At least 20 designs should have complete, verified step sequences in
version 1. The remaining designs can be gallery-only initially.

Do not publish empty or placeholder categories merely to meet a content
count.

------------------------------------------------------------------------

## 6. Navigation and screen requirements

Use four primary bottom-navigation destinations:

1.  Home
2.  Explore
3.  Create
4.  Saved

Settings, language and Premium can be reached from the Home app bar or a
menu.

### 6.1 Home screen

Required elements:

-   Muggu Studio logo/title.
-   Language selector.
-   Daily Muggu feature card.
-   "Learn this design" action.
-   "Create your own" action.
-   Category cards: Daily Muggu, Pulli Kolam, Sikku Kolam, Flower
    Rangoli and Festivals.
-   Recently added designs.
-   Optional seasonal collection.

The daily design should be selected locally from bundled content using a
deterministic date-based rule. It must not require a backend or daily
push notification.

### 6.2 Explore screen

Required elements:

-   Search field.
-   Category chips.
-   Difficulty filter: Easy, Medium, Advanced.
-   Dot-count filter where applicable.
-   Grid/list presentation.
-   Sort: Recommended, Newest, Easy first.
-   Design card with thumbnail, localized title and favourite action.

Search should match localized names and synonyms. For example, Telugu
searches for "ముగ్గులు" should find relevant entries tagged with Muggu,
Kolam and Rangoli synonyms.

### 6.3 Design detail screen

Required elements:

-   Large design preview.
-   Localized title and description.
-   Category, difficulty, dot grid and estimated drawing time.
-   Start Learning.
-   Practice / Trace.
-   Edit This Design.
-   Favourite.
-   Share.

### 6.4 Learning screen

Required elements:

-   Full or large canvas.
-   Current step number and total.
-   Previous/Next controls.
-   Play/Pause animation.
-   Restart lesson.
-   Optional short localized instruction.
-   Tracing mode with faint guide.
-   Completion state and Save/Share actions.

A tutorial must represent a valid sequence of strokes. Do not create
fake lessons by splitting an unrelated static image.

### 6.5 Creator screen

Required elements:

-   Canvas.
-   Grid selector: 5x5, 7x7 and 9x9 initially.
-   Draw mode.
-   Basic line/curve stroke support.
-   Symmetry options: none, vertical, horizontal and four-way where
    appropriate.
-   Colour palette.
-   Stroke size.
-   Undo and redo.
-   Clear canvas with confirmation.
-   Save.
-   Export PNG.
-   Share.

Keep the first creator intentionally simple. Avoid complex polygon
filling, layers, pressure sensitivity and advanced vector editing until
the basic drawing flow is reliable.

### 6.6 Saved screen

Sections:

-   Favourites from the catalogue.
-   My Creations.
-   Open/edit.
-   Rename.
-   Delete with confirmation.
-   Share/export.

### 6.7 Settings and Premium

Settings:

-   Language.
-   Privacy policy.
-   About.
-   App version.
-   Restore purchase.
-   Contact/support route, if configured.

Premium page:

-   Remove ads.
-   Unlock Premium designs and tutorials.
-   Show exact one-time price returned by Google Play Billing.
-   Restore purchase.
-   Explain that purchases are linked to the user's Google Play account.

------------------------------------------------------------------------

## 7. Visual design system

### Design direction

Traditional, warm and modern. Avoid clutter and excessive gradients.

Suggested palette:

  Token           Hex         Use
  --------------- ----------- ------------------------------
  Deep Maroon     `#862B37`   Primary actions and branding
  Warm Cream      `#FFF5E8`   Main background
  Turmeric Gold   `#D8A13B`   Accent
  Leaf Green      `#55775D`   Secondary accent
  Dark Brown      `#3C342E`   Primary text

Use Material 3 components with a custom theme.

### Typography

-   English: Roboto or Noto Sans.
-   Telugu: Noto Sans Telugu.
-   Tamil: Noto Sans Tamil.

Verify font rendering on real Android devices. Avoid hard-coded text
widths that clip regional scripts.

### Accessibility and usability

-   Large touch targets.
-   Adequate contrast.
-   Readable font sizes.
-   Support system font scaling.
-   Clear empty states.
-   Confirm destructive actions.
-   Avoid relying only on colour to communicate status.
-   Test on low-resolution and budget Android devices.

Light theme is the initial priority. Dark mode can follow after launch.

------------------------------------------------------------------------

## 8. Technical architecture

### Architecture decision

Use a **local-first Flutter application**. The core product does not
need a custom backend.

High-level flow:

``` text
Flutter UI
  |
  +-- Home / Explore / Detail / Learn / Creator / Saved
  |
  +-- Riverpod state management
  |
  +-- Repository layer
       |
       +-- Bundled catalogue JSON
       +-- Bundled WebP thumbnails/assets
       +-- Local SQLite database
       +-- Local design files
  |
  +-- Android integrations
       +-- Google Mobile Ads
       +-- Google Play Billing
       +-- Android share sheet
       +-- PNG export
```

### Recommended stack

  Concern            Technology
  ------------------ --------------------------------------
  Language           Dart
  App framework      Flutter
  State management   Riverpod (`flutter_riverpod`)
  Navigation         GoRouter
  UI                 Material 3
  Drawing            Flutter `CustomPainter` / Canvas
  Catalogue          Bundled JSON
  Artwork            WebP thumbnails + vector stroke data
  Local database     SQLite (`sqflite`)
  Preferences        `shared_preferences`
  File paths         `path_provider`
  Sharing            `share_plus`
  Localization       Flutter localization / ARB
  Ads                `google_mobile_ads`
  Billing            `in_app_purchase`
  Tests              `flutter_test`, integration tests

Use stable package versions compatible with the installed Flutter SDK.
Do not blindly pin old versions from this document.

### No backend in version 1

Do not add Firebase, Supabase, a VPS or an API server unless a
demonstrated requirement emerges.

Core content and user drawings stay on the device. Ads and purchase
verification use their respective SDK/service flows.

------------------------------------------------------------------------

## 9. Project structure

Recommended starting structure:

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
│   │   ├── ads/
│   │   ├── billing/
│   │   └── widgets/
│   ├── features/
│   │   ├── home/
│   │   ├── gallery/
│   │   ├── design_detail/
│   │   ├── learning/
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

Keep UI, domain logic and persistence separate. Avoid putting all app
logic in `main.dart` or a single giant widget.

------------------------------------------------------------------------

## 10. Muggu design data model

Prefer structured vector instructions over storing every design only as
a bitmap.

A design should support localized metadata, a dot grid, strokes,
tutorial steps, difficulty, tags and Premium status.

Example catalogue entry:

``` json
{
  "id": "muggu_001",
  "name": {
    "en": "Simple Floral Muggu",
    "te": "సులభమైన పూల ముగ్గు",
    "ta": "எளிய மலர் கோலம்"
  },
  "description": {
    "en": "A beginner-friendly floral dot-grid design.",
    "te": "ప్రారంభకులకు అనువైన పూల ముగ్గు.",
    "ta": "தொடக்கநிலைக்கு ஏற்ற மலர் கோலம்."
  },
  "category": "dot_muggu",
  "difficulty": "easy",
  "grid": {
    "rows": 5,
    "columns": 5
  },
  "estimatedMinutes": 5,
  "isPremium": false,
  "tags": [
    "daily",
    "floral",
    "beginner",
    "muggu",
    "kolam",
    "rangoli"
  ],
  "thumbnail": "assets/designs/thumbnails/muggu_001.webp",
  "steps": [
    {
      "step": 1,
      "instruction": {
        "en": "Start at the top centre.",
        "te": "పై మధ్య భాగంలో ప్రారంభించండి.",
        "ta": "மேல் மையத்தில் தொடங்கவும்."
      },
      "strokeIds": ["stroke_01"]
    },
    {
      "step": 2,
      "instruction": {
        "en": "Continue the left curve.",
        "te": "ఎడమ వంపును కొనసాగించండి.",
        "ta": "இடது வளைவைத் தொடரவும்."
      },
      "strokeIds": ["stroke_02"]
    }
  ],
  "strokes": [
    {
      "id": "stroke_01",
      "points": [
        [0.50, 0.10],
        [0.65, 0.25],
        [0.50, 0.40]
      ],
      "type": "curve"
    },
    {
      "id": "stroke_02",
      "points": [
        [0.50, 0.40],
        [0.35, 0.55],
        [0.50, 0.70]
      ],
      "type": "curve"
    }
  ]
}
```

The example coordinates are illustrative only. Content creators must
supply accurate paths and verified step sequences for each real design.

### Coordinate system

-   Store normalized coordinates from `0.0` to `1.0`.
-   Map normalized points into the available canvas rectangle.
-   Preserve aspect ratio.
-   Apply symmetry transforms around the relevant canvas axes.
-   Keep dot-grid geometry separate from stroke geometry.

### Suggested core models

-   `MugguDesign`
-   `LocalizedText`
-   `DotGrid`
-   `DrawingStroke`
-   `TutorialStep`
-   `SavedCreation`
-   `UserPreferences`
-   `PurchaseEntitlement`

### Local persistence

Use SQLite for:

-   Favourite design IDs.
-   Saved user creations.
-   Creation metadata.
-   Optional local learning progress.

Store larger exported PNGs in app-specific storage. Store language and
simple preferences in SharedPreferences.

------------------------------------------------------------------------

## 11. Creator and tutorial engine requirements

This is the key custom engineering component.

### Rendering

Use Flutter `CustomPainter` to render:

1.  Background.
2.  Dot grid.
3.  Reference design or guide.
4.  User strokes.
5.  Selection/interaction overlays.

### Drawing input

-   Convert touch positions into normalized canvas coordinates.
-   Capture pointer down, move and up.
-   Smooth strokes where appropriate.
-   Store strokes as reusable data.
-   Support undo and redo with a command/history stack.
-   Keep drawing responsive on lower-end devices.

### Symmetry

Initial modes:

-   None.
-   Vertical mirror.
-   Horizontal mirror.
-   Four-way mirror.

The symmetry engine should transform user strokes around the canvas
centre. Test edge cases where a stroke crosses the centre line to avoid
duplicated or discontinuous lines.

### Tutorial animation

-   Each step references one or more stroke IDs.
-   Animate only the relevant stroke(s).
-   Allow pause, resume, previous, next and restart.
-   Provide a static guide if animation is disabled or reduced-motion
    settings are used.
-   Keep instructions localized.

### Tracing

-   Render the target stroke in a faint guide colour.
-   Accept user pointer input.
-   Give simple visual feedback.
-   Do not require exact pixel-perfect matching in the first version.
-   Avoid shaming or punitive scoring; the goal is practice.

### Export

Render a clean image without editor controls:

-   Use a dedicated export canvas.
-   Export PNG at a useful resolution.
-   Preserve transparent or selected background as appropriate.
-   Save in app-specific storage or use the system sharing flow.
-   Do not request broad storage permissions unnecessarily.

------------------------------------------------------------------------

## 12. Localization and content management

Support locales:

-   `en`
-   `te`
-   `ta`

Use Flutter ARB localization files for app UI strings:

``` text
lib/l10n/app_en.arb
lib/l10n/app_te.arb
lib/l10n/app_ta.arb
```

Design catalogue content can use localized JSON fields as shown above.

### Search synonyms

Each design should have language-aware synonyms, for example:

-   English: Rangoli, Kolam, Muggu, dots, floral.
-   Telugu: ముగ్గు, ముగ్గులు, చుక్కల ముగ్గు.
-   Tamil: கோலம், புள்ளி கோலம், சிக்கு கோலம்.

Have fluent Telugu and Tamil reviewers verify spelling, natural wording,
cultural usage and drawing instructions. Do not rely solely on machine
translation for final published content.

### Content rights

-   Create original designs or obtain written licences.
-   Keep a content attribution/rights record for each externally sourced
    asset.
-   Do not scrape competitor apps or copy Pinterest/Instagram images.
-   Do not assume an image is free to reuse because it is publicly
    visible.
-   Keep original editable/vector source files.
-   Review festival and religious content for cultural accuracy.

------------------------------------------------------------------------

## 13. Monetization

### Initial model

Free application supported by advertising, with a one-time Premium
unlock.

Suggested price to test:

-   Free: ₹0.
-   Premium lifetime: initially test ₹149, with localized pricing
    determined by Google Play.

The price is a hypothesis. Check willingness to pay and actual purchase
conversion after launch.

### Free tier

-   40 basic designs.
-   Basic gallery and filters.
-   8 guided tutorials.
-   Creator and basic colour palette.
-   Favourites.
-   Save and share.
-   Non-intrusive ads.

### Premium tier

-   All 60+ designs.
-   All 20+ guided tutorials.
-   Premium collections.
-   Advanced colour palettes.
-   No advertisements.
-   Future premium content included, subject to the product's stated
    terms.

Do not lock basic creator functionality behind Premium. The free version
must remain useful.

### Advertising placement

Use Google Mobile Ads / AdMob.

Suggested placement:

-   Banner ad at the bottom of Home or Explore, with reserved layout
    space.
-   Optional native ad in a clearly labelled gallery position if
    implemented correctly.
-   Rewarded ad to unlock a clearly identified temporary content pack
    only if it adds value.

Avoid:

-   Ads over the drawing canvas.
-   Ads during a tutorial step.
-   Ads immediately after every navigation action.
-   Misleading ad close buttons.
-   Accidental-click layouts.
-   Excessive interstitials.

Follow current AdMob policies and Google Play requirements. Use test ad
unit IDs during development; never click live ads yourself.

### Billing

Use Google Play Billing through the supported Flutter package.

Requirements:

-   Product ID configured in Play Console.
-   Query product details from the store.
-   Display the price returned by Google Play, not a hard-coded currency
    value.
-   Handle pending, successful, cancelled and failed purchases.
-   Verify purchase status appropriately.
-   Persist entitlement safely.
-   Restore purchases.
-   Unlock Premium only when entitlement is valid.
-   Test with license testers and Play internal testing.

A one-time non-consumable product is the intended purchase type. Confirm
current Play Billing requirements before release.

### Revenue expectations

Do not promise revenue. Model it using actual usage after launch.

For planning only, an example advertising assumption is ₹30 per 1,000
impressions. This is not a guaranteed eCPM.

    Monthly active users   Monthly impressions   Illustrative ad revenue
  ---------------------- --------------------- -------------------------
                   1,000                15,000                      ₹450
                   5,000                75,000                    ₹2,250
                  10,000               150,000                    ₹4,500
                  50,000               750,000                   ₹22,500
                 100,000             1,500,000                   ₹45,000

Actual revenue varies by country, ad format, fill rate, user engagement,
seasonality and policy compliance. Premium sales are additional, less
store fees, taxes, refunds and other costs.

------------------------------------------------------------------------

## 14. Privacy, permissions and security

The app should collect as little data as possible.

### Initial privacy approach

-   No account.
-   No name, email or phone number collection by the app.
-   User creations stored locally.
-   No cloud upload of drawings.
-   No location permission.
-   No contacts permission.
-   No microphone or camera permission.
-   No broad file-storage permission unless a justified feature requires
    it.

### Third-party SDKs

AdMob and billing SDKs may process device or transaction-related data.
The privacy policy and Google Play Data Safety declaration must
accurately describe the actual SDKs, data processing, sharing and
retention.

Use the Google consent flow where required for advertising. Review
applicable privacy rules for the regions in which the app is
distributed.

### Privacy policy

Publish a publicly accessible privacy policy before production. It must:

-   Identify the developer/publisher.
-   Explain local storage.
-   Explain third-party advertising and billing SDKs.
-   Explain any data collected or shared by those SDKs.
-   Explain retention and deletion.
-   Provide a contact route.
-   Match actual app behaviour and Play Console declarations.

Do not publish a generic policy that claims "no data is collected"
without reviewing SDK behaviour.

------------------------------------------------------------------------

## 15. Testing strategy and acceptance criteria

### Functional tests

  Test                    Expected result
  ----------------------- ---------------------------------------------
  Launch app offline      Home and bundled content load
  Change language         UI and content change correctly
  Search localized term   Relevant designs appear
  Filter category         Only matching designs appear
  Open detail             Correct preview and metadata
  Start tutorial          Correct stroke sequence appears
  Pause/restart lesson    Animation state behaves correctly
  Trace design            Touch input is responsive
  Change dot grid         Grid updates without layout overflow
  Draw strokes            Strokes appear in correct coordinates
  Symmetry                Mirrored strokes are correct
  Undo/redo               History is restored correctly
  Save creation           Design persists after restart
  Export PNG              Clean image is produced
  Share                   Android share sheet opens
  Purchase Premium        Premium entitlement unlocks
  Restore purchase        Valid entitlement is restored
  Ads                     No ads appear in prohibited/poor placements

### Non-functional targets

-   Crash-free sessions target: greater than 99.5% after sufficient
    usage data.
-   Smooth drawing on representative budget Android devices.
-   No blocking network requirement for core functionality.
-   No clipped Telugu/Tamil text.
-   No broken thumbnails or empty categories.
-   Reasonable app download size; compress artwork.
-   Handle process death and app restart safely.
-   No loss of saved creations during normal app upgrades.

### Device coverage

Test at minimum:

-   Small-screen Android phone.
-   Typical mid-range Android phone.
-   Lower-memory device if available.
-   Current Android version.
-   At least one older supported Android version.
-   Different display densities and font scaling.

------------------------------------------------------------------------

## 16. Analytics and product metrics

Use privacy-conscious, aggregated analytics only if needed and disclosed
correctly. The first release can begin with basic Play Console and AdMob
reporting.

Track:

-   Installations and store conversion.
-   Daily and monthly active users.
-   Day-1 and Day-7 retention.
-   Designs opened per session.
-   Tutorial starts and completions.
-   Creator sessions.
-   Designs saved.
-   PNG exports and shares.
-   Premium purchase conversion.
-   Ad impressions and estimated revenue.
-   Crashes and ANRs.

### Initial product hypotheses

These are targets to evaluate, not guarantees:

-   Users should reach a design in a few taps.
-   A meaningful share of users should open multiple designs.
-   Tutorials should have measurable completion.
-   Some users should save or share creations.
-   Retention should improve after adding useful daily and festival
    content.

Do not add more features just because they sound attractive. Prioritize
based on actual user behaviour, reviews and support issues.

------------------------------------------------------------------------

## 17. Development roadmap

Assumption: one developer, AI-assisted, approximately 8--10 hours per
week. The schedule is a planning estimate, not a deadline guarantee.

### Week 1 --- foundation

-   Install Flutter and Android Studio.
-   Verify `flutter doctor`.
-   Create Git repository.
-   Create Flutter app.
-   Add theme and routing.
-   Add localization scaffolding.
-   Build Home screen and bottom navigation.

**Deliverable:** App runs on an Android device with three selectable
languages.

### Week 2 --- catalogue

-   Define models.
-   Create catalogue JSON.
-   Add original thumbnails.
-   Build Explore screen.
-   Add categories, filters and search.
-   Add favourites.

**Deliverable:** Offline gallery with real content.

### Week 3 --- learning

-   Implement vector renderer.
-   Implement stroke sequence model.
-   Add animation controls.
-   Build lesson detail.
-   Add tracing mode.
-   Add and verify initial lessons.

**Deliverable:** At least 5 complete working lessons; expand toward 20.

### Week 4 --- creator

-   Implement dot grid.
-   Implement pointer drawing.
-   Implement symmetry transforms.
-   Implement undo/redo.
-   Add colours and stroke sizes.
-   Add clear/reset.

**Deliverable:** Functional creator.

### Week 5 --- persistence and sharing

-   Add SQLite repositories.
-   Save and reopen creations.
-   Add PNG export.
-   Add Android share sheet.
-   Test offline and restart behaviour.

**Deliverable:** Complete core app workflow.

### Week 6 --- monetization and release preparation

-   Configure AdMob test IDs.
-   Implement ad placements.
-   Implement one-time billing.
-   Implement entitlement and restore.
-   Add consent handling.
-   Write privacy policy.
-   Complete store listing draft.

**Deliverable:** Release candidate.

### Weeks 7--8 --- testing and Play Store release

-   Test on physical devices.
-   Fix crashes, rendering and localization bugs.
-   Verify ads and purchases using test accounts.
-   Prepare screenshots, icon and feature graphic.
-   Run closed testing as required.
-   Apply for production access where applicable.
-   Submit for review.

**Deliverable:** Production submission, subject to Google Play approval.

------------------------------------------------------------------------

## 18. Budget

Target budget: ₹5,000--₹15,000.

Planning allocation:

  -----------------------------------------------------------------------
  Expense                                                        Estimate
  ------------------------------ ----------------------------------------
  Google Play developer            US\$25 one-time; INR equivalent varies
  registration

  Domain/privacy policy                                      ₹800--₹1,200

  Branding/assets                                            ₹500--₹1,000

  Development tools                                          ₹0 initially

  Backend hosting                                                      ₹0

  Testing/miscellaneous                                      ₹500--₹1,000

  Contingency                                              ₹3,000--₹5,000
  -----------------------------------------------------------------------

Use original artwork and free development tooling initially. Do not pay
for AI image APIs, cloud servers or extra subscriptions before they are
demonstrably necessary.

Actual costs may vary with exchange rates, taxes and vendor pricing.

------------------------------------------------------------------------

## 19. Google Play publishing checklist

Google Play requirements change. Recheck official documentation and Play
Console notices at the time of submission.

### Developer account

-   [ ] Create/verify Play Console developer account.
-   [ ] Complete identity and contact verification.
-   [ ] Pay registration fee.
-   [ ] Determine whether the account is subject to the new
    personal-account testing requirement.
-   [ ] Set developer name and support contact.

### App build

-   [ ] Finalize unique application ID/package name.
-   [ ] Configure app version and build number.
-   [ ] Configure target API level required at submission time.
-   [ ] Build a signed Android App Bundle (`.aab`).
-   [ ] Configure Play App Signing.
-   [ ] Remove test ad IDs and debug settings.
-   [ ] Test release build, not just debug build.

### Store listing

-   [ ] App name.
-   [ ] Short description.
-   [ ] Full description.
-   [ ] App icon.
-   [ ] Feature graphic.
-   [ ] Phone screenshots.
-   [ ] Correct category and tags.
-   [ ] Support email or contact route.
-   [ ] Public privacy-policy URL.
-   [ ] Accurate content rating.
-   [ ] Accurate target-audience declaration.
-   [ ] Ads declaration.
-   [ ] Data Safety form.
-   [ ] App access instructions if any restricted access exists (not
    expected for this app).

### Monetization

-   [ ] Configure AdMob app and ad units.
-   [ ] Use test ads during development.
-   [ ] Configure consent management.
-   [ ] Configure one-time Premium product.
-   [ ] Test purchase and restore flows.
-   [ ] Check current Play billing and service-fee requirements.

### Testing and publication

-   [ ] Internal testing.
-   [ ] Closed testing if required.
-   [ ] Recruit the required testers if the account is subject to that
    rule.
-   [ ] Meet the required continuous testing duration.
-   [ ] Apply for production access if required.
-   [ ] Resolve Play Console policy warnings.
-   [ ] Submit for review.
-   [ ] Monitor staged rollout, crashes, ANRs and reviews.

### Important policy checks

At the time of the earlier planning research, new apps were required to
target Android 16 / API 36 from August 31, 2026. Verify the current
target API requirement before building the final release, because Google
updates this periodically.

New personal developer accounts created after November 13, 2023 may be
required to run a closed test with at least 12 continuously opted-in
testers for 14 days before applying for production access. Confirm the
requirement shown in the actual Play Console account.

Official resources:

-   Google Play Console: https://play.google.com/console/
-   Play Console testing:
    https://support.google.com/googleplay/android-developer/
-   Android target API requirements:
    https://developer.android.com/google/play/requirements/target-sdk
-   AdMob: https://admob.google.com/
-   Google Mobile Ads Flutter guide:
    https://developers.google.com/admob/flutter/quick-start
-   Flutter: https://docs.flutter.dev/
-   Flutter localization:
    https://docs.flutter.dev/ui/accessibility-and-internationalization/internationalization
-   Google Play Billing:
    https://developer.android.com/google/play/billing

------------------------------------------------------------------------

## 20. AI coding-agent working agreement

The IDE agent must follow these rules throughout implementation.

### General rules

1.  Read this entire README before changing code.
2.  Treat this document as the product requirements baseline.
3.  Build incrementally; do not generate the entire application in one
    response.
4.  Do not invent features outside the agreed MVP without asking.
5.  Prefer stable, maintained Flutter packages.
6.  Check package compatibility with the installed Flutter/Dart
    versions.
7.  Keep code modular and testable.
8.  Do not hard-code prices returned by Google Play.
9.  Do not use live AdMob ad IDs during development.
10. Do not add a backend unless an explicit requirement justifies it.
11. Do not use copyrighted competitor artwork or scraped images.
12. Never claim a feature is complete without running relevant tests.
13. Update this README when an approved product decision changes.
14. Maintain a `CHANGELOG.md` and a list of known issues.
15. Ask before making decisions that affect product scope, privacy,
    billing or content rights.

### Required workflow for every feature

1.  Explain the intended implementation briefly.
2.  Identify files to create or modify.
3.  Implement the smallest working slice.
4.  Run `dart format`.
5.  Run `flutter analyze`.
6.  Run relevant unit/widget tests.
7.  Report commands executed and results.
8.  List remaining limitations.
9.  Update documentation.

### Code quality expectations

-   Null-safe Dart.
-   Clear naming.
-   Small reusable widgets.
-   Separation of UI and business logic.
-   Repository abstraction for persistence.
-   No unnecessary global mutable state.
-   Error and empty states.
-   Tests for core logic, especially drawing transforms and persistence.
-   No secrets or private keys committed to Git.

### Drawing engine test cases

At minimum, test:

-   Normalized coordinate conversion.
-   Canvas aspect-ratio handling.
-   Vertical mirror.
-   Horizontal mirror.
-   Four-way mirror.
-   Strokes crossing the centre.
-   Undo and redo ordering.
-   Save/load serialization.
-   PNG export dimensions.

------------------------------------------------------------------------

## 21. First implementation sprint

Do not begin by implementing ads, billing or the drawing engine. Start
with a working app scaffold.

### Sprint 1 outcome

A Flutter Android app that:

-   Opens without crashing.
-   Shows Muggu Studio branding.
-   Supports English, Telugu and Tamil selection.
-   Displays a Home screen.
-   Has Home, Explore, Create and Saved bottom navigation.
-   Uses the agreed colour palette.
-   Has a clean project structure.
-   Runs on a physical Android device or emulator.

### Initial setup commands

Check Flutter installation first:

``` bash
flutter doctor
flutter --version
```

Create the app (replace the example organization ID with the final
publisher namespace):

``` bash
flutter create --org com.example muggu_studio
cd muggu_studio
```

Add the initial dependencies:

``` bash
flutter pub add flutter_riverpod
flutter pub add go_router
flutter pub add shared_preferences
flutter pub add sqflite
flutter pub add path_provider
flutter pub add share_plus
flutter pub add intl
```

Monetization dependencies can be added in the later monetization sprint:

``` bash
flutter pub add google_mobile_ads
flutter pub add in_app_purchase
```

Run:

``` bash
flutter analyze
flutter test
flutter run
```

Do not assume the sample organization ID is suitable for publication.
Choose a unique permanent application ID before publishing; changing it
after release is disruptive.

------------------------------------------------------------------------

## 22. Copy/paste prompt for the IDE coding agent

Use the following as the first instruction after opening this project in
your IDE:

> You are the senior Flutter engineer responsible for implementing Muggu
> Studio.
>
> First, read the complete `README.md`. It is the source of truth for
> product scope, architecture, UX, localization, monetization and
> release requirements.
>
> We are starting Sprint 1 only. Do not implement the entire
> application.
>
> First inspect the current repository and Flutter environment. Report:
>
> 1.  Flutter and Dart versions.
> 2.  Whether Android tooling is correctly configured.
> 3.  Current repository structure.
> 4.  Any compatibility issues.
>
> Then propose the exact files you will create or modify for Sprint 1.
>
> Implement:
>
> -   Flutter app scaffold.
> -   Material 3 theme using the documented Muggu Studio colour palette.
> -   English, Telugu and Tamil localization scaffolding.
> -   Language selection.
> -   Home, Explore, Create and Saved navigation.
> -   Placeholder screens with polished, consistent layouts.
> -   Responsive UI and basic accessibility.
>
> Do not implement ads, purchases, a backend, user login, AI features or
> the drawing engine in this sprint.
>
> After implementation:
>
> -   Run `dart format`.
> -   Run `flutter analyze`.
> -   Run `flutter test`.
> -   Fix all errors introduced by your changes.
> -   Explain how to run the app on an Android device.
> -   Update this README if any implementation detail differs from the
>     requirements.
>
> Do not claim that a command succeeded unless you actually ran it and
> inspected its result. Stop after Sprint 1 and wait for approval before
> proceeding.

------------------------------------------------------------------------

## 23. Definition of a successful first release

Muggu Studio version 1 is ready for production consideration when:

-   The core app works offline.
-   The catalogue contains original, properly licensed designs.
-   Telugu, Tamil and English are reviewed.
-   Users can discover and favourite designs.
-   At least 20 lessons have accurate step sequences.
-   Users can trace a guide.
-   Users can create symmetrical dot-grid designs.
-   Users can undo/redo, save and export.
-   Premium purchase and restore work.
-   Ads follow applicable policies and do not disrupt learning or
    drawing.
-   Privacy disclosures match actual SDK behaviour.
-   Play Store listing and testing requirements are satisfied.
-   No critical crashes, data-loss defects or broken navigation remain.

**The priority is a small, useful, trustworthy app---not a large feature
list.** Launch the core experience, observe real usage, read reviews,
and expand only where users demonstrate a need.

------------------------------------------------------------------------

## 24. Project decision log

  Decision                       Current choice
  ------------------------------ -----------------------------------------------
  Product                        Muggu Studio
  Category                       Rangoli / Muggu / Kolam
  Platform                       Android first
  Framework                      Flutter
  Initial locales                Telugu, Tamil, English
  Core experience                Gallery + learning/tracing + creator
  Architecture                   Local-first, no custom backend
  Content target                 60 designs, 20 guided lessons
  Monetization                   Ads + one-time Premium
  Suggested Premium test price   ₹149 lifetime
  Target development budget      ₹5,000--₹15,000
  Development model              Solo, AI-assisted
  Initial navigation             Home, Explore, Create, Saved
  First sprint                   App scaffold, theme, localization, navigation
  Working name                   Muggu Studio; availability not yet verified

**End of product and engineering blueprint.**

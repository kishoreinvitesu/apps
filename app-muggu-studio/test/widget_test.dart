import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:muggu_studio/app/app.dart';
import 'package:muggu_studio/core/localization/locale_controller.dart';
import 'package:muggu_studio/core/preferences/preferences_storage.dart';
import 'package:muggu_studio/core/preferences/user_preferences.dart';
import 'package:muggu_studio/data/local/favorites_dao.dart';
import 'package:muggu_studio/data/models/muggu_design.dart';
import 'package:muggu_studio/data/repositories/design_repository.dart';

class _MemoryLocaleStorage implements LocaleStorage {
  String? languageCode;

  @override
  Future<String?> readLanguageCode() async => languageCode;

  @override
  Future<void> writeLanguageCode(String languageCode) async {
    this.languageCode = languageCode;
  }

  @override
  Future<void> clearLanguageCode() async {
    languageCode = null;
  }
}

class _MemoryFavorites implements FavoritesStore {
  final Set<String> _ids = {};

  @override
  Future<List<String>> favoriteDesignIds() async => _ids.toList();

  @override
  Future<bool> toggleFavorite(String designId) async {
    if (_ids.remove(designId)) {
      return false;
    }
    _ids.add(designId);
    return true;
  }
}

class _CompletedOnboardingStorage implements PreferencesStorage {
  UserPreferences _preferences = const UserPreferences(
    onboardingComplete: true,
  );

  @override
  Future<UserPreferences> readPreferences() async => _preferences;

  @override
  Future<void> savePreferences(UserPreferences prefs) async {
    _preferences = prefs;
  }

  @override
  Future<void> clearPreferences() async {
    _preferences = const UserPreferences();
  }
}

void main() {
  testWidgets('all primary destinations are reachable', (tester) async {
    final storage = _MemoryLocaleStorage();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          preferencesStorageProvider.overrideWithValue(
            _CompletedOnboardingStorage(),
          ),
          localeStorageProvider.overrideWithValue(storage),
          initialLocaleProvider.overrideWithValue(const Locale('en')),
          favoritesDaoProvider.overrideWithValue(_MemoryFavorites()),
          catalogProvider.overrideWith((ref) async => _testCatalog()),
        ],
        child: const MugguStudioApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Muggu Studio'), findsOneWidget);
    expect(
      find.text('Rangoli • Kolam • Muggu • Indian Floor Art'),
      findsOneWidget,
    );
    expect(find.text('Design of the day'), findsOneWidget);
    expect(find.text('Geometric Sample 01'), findsOneWidget);

    await tester.ensureVisible(find.text('Learn this design'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Learn this design'));
    await tester.pumpAndSettle();
    expect(find.text('Geometric Sample 01'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Draw the highlighted design'),
      200,
    );
    expect(find.text('Draw the highlighted design'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Next'), 200);
    expect(find.text('Next'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Design details'), 250);
    await tester.pumpAndSettle();
    expect(find.text('Design details'), findsOneWidget);
    expect(
      tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
      0,
    );

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.text('Design of the day'), findsOneWidget);
    await tester.ensureVisible(find.text('Learn this design'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Learn this design'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Practise / Trace'), 250);
    await tester.ensureVisible(find.text('Practise / Trace'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Practise / Trace'));
    await tester.pumpAndSettle();
    // Verify the tracing guidance is visible.
    expect(
      find.text('Trace the faint guide, then add your own colors and details.'),
      findsOneWidget,
    );
    expect(
      tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
      0,
    );
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Design details'), findsOneWidget);

    await tester.tap(find.text('Home').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Explore').last);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Geometric Sample 01'), findsOneWidget);
    final designCard = find.byKey(
      const ValueKey('design-card-geometric_sample_001'),
    );
    await tester.ensureVisible(designCard);
    await tester.pumpAndSettle();
    await tester.tap(designCard);
    await tester.pumpAndSettle();
    expect(
      tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
      1,
    );
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
      1,
    );

    await tester.tap(find.text('Create').last);
    await tester.pumpAndSettle();
    // CreateScreen now has Template pattern / Freehand canvas tabs.
    expect(find.text('Template pattern'), findsOneWidget);
    expect(find.text('Freehand canvas'), findsOneWidget);
    expect(find.text('Create a pattern'), findsOneWidget);
    expect(find.text('Radial flower'), findsOneWidget);
    expect(find.byKey(const ValueKey('pattern-preview')), findsOneWidget);
    final dotGridChoice = find.byKey(
      const ValueKey('generator-dot_grid_diamonds'),
    );
    await tester.ensureVisible(dotGridChoice);
    await tester.tap(dotGridChoice);
    await tester.pumpAndSettle();
    // Scroll the template tab ListView to find grid controls.
    // scrollUntilVisible requires a Scrollable finder, not a ListView finder.
    // The first Scrollable in the tab view is the template ListView's internal Scrollable.
    final templateScrollable = find.descendant(
      of: find.byType(ListView).first,
      matching: find.byType(Scrollable),
    );
    await tester.scrollUntilVisible(
      find.text('Dot layout'),
      300,
      scrollable: templateScrollable,
    );
    expect(find.text('Grid size: 5 × 5'), findsOneWidget);
    final staggeredChip = find.byKey(const ValueKey('grid-layout-staggered'));
    await tester.scrollUntilVisible(
      staggeredChip,
      200,
      scrollable: templateScrollable,
    );
    await tester.ensureVisible(staggeredChip);
    await tester.pumpAndSettle();
    await tester.tap(staggeredChip);
    await tester.pumpAndSettle();
    expect(find.text('Dot layout'), findsOneWidget);
    final resetButton = find.byKey(const ValueKey('creator-reset'));
    await tester.scrollUntilVisible(
      resetButton,
      300,
      scrollable: templateScrollable,
    );
    await tester.tap(resetButton);
    await tester.pumpAndSettle();
    expect(find.text('Petals: 8'), findsOneWidget);

    await tester.tap(find.text('Saved').last);
    await tester.pumpAndSettle();
    expect(find.text('Nothing saved yet'), findsOneWidget);

    await tester.tap(find.text('Home').last);
    await tester.pumpAndSettle();
    expect(find.text('Design of the day'), findsOneWidget);
  });

  testWidgets('language changes update the UI and persist', (tester) async {
    final storage = _MemoryLocaleStorage();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          preferencesStorageProvider.overrideWithValue(
            _CompletedOnboardingStorage(),
          ),
          localeStorageProvider.overrideWithValue(storage),
          initialLocaleProvider.overrideWithValue(const Locale('en')),
          favoritesDaoProvider.overrideWithValue(_MemoryFavorites()),
          catalogProvider.overrideWith((ref) async => _testCatalog()),
        ],
        child: const MugguStudioApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Choose language'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('தமிழ்'));
    await tester.pumpAndSettle();

    expect(find.text('Muggu Studio'), findsOneWidget);
    expect(
      find.text('Rangoli • Kolam • Muggu • Indian Floor Art'),
      findsOneWidget,
    );
    expect(storage.languageCode, 'ta');

    await tester.tap(find.byTooltip('மொழியைத் தேர்ந்தெடுக்கவும்'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('తెలుగు'));
    await tester.pumpAndSettle();

    expect(find.text('Muggu Studio'), findsOneWidget);
    expect(
      find.text('Rangoli • Kolam • Muggu • Indian Floor Art'),
      findsOneWidget,
    );
    expect(find.text('నేటి డిజైన్'), findsOneWidget);
    expect(storage.languageCode, 'te');
  });

  testWidgets('design lessons play without approval gates', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          preferencesStorageProvider.overrideWithValue(
            _CompletedOnboardingStorage(),
          ),
          localeStorageProvider.overrideWithValue(_MemoryLocaleStorage()),
          initialLocaleProvider.overrideWithValue(const Locale('en')),
          favoritesDaoProvider.overrideWithValue(_MemoryFavorites()),
          catalogProvider.overrideWith((ref) async => _testCatalog()),
        ],
        child: const MugguStudioApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Learn this design'));
    await tester.tap(find.text('Learn this design'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Draw the highlighted design'),
      200,
    );
    expect(find.text('Draw the highlighted design'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Next'), 200);
    expect(find.text('Next'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('System-generated vector design'),
      200,
    );
    expect(find.text('System-generated vector design'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('example.com'), 200);
    expect(find.text('example.com'), findsOneWidget);
  });

  testWidgets('Explore clear empties the search field and restores results', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          preferencesStorageProvider.overrideWithValue(
            _CompletedOnboardingStorage(),
          ),
          localeStorageProvider.overrideWithValue(_MemoryLocaleStorage()),
          initialLocaleProvider.overrideWithValue(const Locale('en')),
          favoritesDaoProvider.overrideWithValue(_MemoryFavorites()),
          catalogProvider.overrideWith((ref) async => _testCatalog()),
        ],
        child: const MugguStudioApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Explore').last);
    await tester.pumpAndSettle();

    final searchField = find.byType(TextField);
    await tester.enterText(searchField, 'no matching design');
    await tester.pumpAndSettle();
    expect(find.text('No designs found'), findsOneWidget);

    await tester.tap(find.byTooltip('Clear'));
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(searchField).controller!.text, isEmpty);
    expect(find.text('Geometric Sample 01'), findsOneWidget);
  });

  testWidgets('favourites appear in Saved and can be removed', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          preferencesStorageProvider.overrideWithValue(
            _CompletedOnboardingStorage(),
          ),
          localeStorageProvider.overrideWithValue(_MemoryLocaleStorage()),
          initialLocaleProvider.overrideWithValue(const Locale('en')),
          favoritesDaoProvider.overrideWithValue(_MemoryFavorites()),
          catalogProvider.overrideWith((ref) async => _testCatalog()),
        ],
        child: const MugguStudioApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Explore').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Add to favourites').first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Saved').last);
    await tester.pumpAndSettle();
    expect(find.text('Favourite designs'), findsOneWidget);
    expect(find.text('Geometric Sample 01'), findsOneWidget);

    await tester.tap(find.byTooltip('Remove from favourites').first);
    await tester.pumpAndSettle();
    expect(find.text('Nothing saved yet'), findsOneWidget);
  });
}

List<MugguDesign> _testCatalog() => DesignRepository.parseCatalog('''
  {
    "schemaVersion": 2,
    "designs": [
      {
        "id": "geometric_sample_001",
        "localizedName": {"en": "Geometric Sample 01"},
        "localizedDescription": {
          "en": "A system-generated geometric vector design."
        },
        "technique": "geometric_lines",
        "localizedTechnique": {"en": "Geometric lines"},
        "provenance": {
          "origin": "system_generated",
          "sources": ["https://example.com/art"],
          "note": "Fixture reference."
        },
        "difficulty": "easy",
        "grid": null,
        "searchTags": ["geometric", "sample"],
        "thumbnail": "assets/designs/thumbnails/geometric_sample_001.webp",
        "strokes": [
          {"id": "stroke_01", "points": [[0.1, 0.1], [0.9, 0.9]]}
        ],
        "lessonSteps": [{
          "id": "step_01",
          "strokeIds": ["stroke_01"],
          "instruction": {"en": "Draw the highlighted design"}
        }]
      }
    ]
  }
''');

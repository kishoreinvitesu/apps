import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:muggu_studio/app/app.dart';
import 'package:muggu_studio/core/localization/locale_controller.dart';
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

void main() {
  testWidgets('all primary destinations are reachable', (tester) async {
    final storage = _MemoryLocaleStorage();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
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
    expect(find.text('Daily Muggu'), findsOneWidget);
    expect(find.text('Geometric Sample 01'), findsOneWidget);

    await tester.ensureVisible(find.text('Learn this design'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Learn this design'));
    await tester.pumpAndSettle();
    expect(find.text('Geometric Sample 01'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Design details'), 250);
    await tester.pumpAndSettle();
    expect(find.text('Design details'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Practise / Trace'), 250);
    await tester.tap(find.text('Practise / Trace'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Practice is coming soon'), 250);
    expect(find.text('Practice is coming soon'), findsOneWidget);

    await tester.tap(find.text('Home').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Explore').last);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.textContaining('original geometric samples'), findsOneWidget);
    expect(find.text('Geometric Sample 01'), findsOneWidget);

    await tester.tap(find.text('Create').last);
    await tester.pumpAndSettle();
    expect(find.text('Your creative space is coming'), findsOneWidget);

    await tester.tap(find.text('Saved').last);
    await tester.pumpAndSettle();
    expect(find.text('Nothing saved yet'), findsOneWidget);

    await tester.tap(find.text('Home').last);
    await tester.pumpAndSettle();
    expect(find.text('Daily Muggu'), findsOneWidget);
  });

  testWidgets('language changes update the UI and persist', (tester) async {
    final storage = _MemoryLocaleStorage();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
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
    expect(find.text('నేటి ముగ్గు'), findsOneWidget);
    expect(storage.languageCode, 'te');
  });

  testWidgets('favourites appear in Saved and can be removed', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
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
    "schemaVersion": 1,
    "designs": [
      {
        "id": "geometric_sample_001",
        "localizedName": {"en": "Geometric Sample 01"},
        "localizedDescription": {
          "en": "An original geometric vector sample; cultural classification is unassigned and pending review."
        },
        "region": null,
        "tradition": null,
        "technique": "geometric_lines",
        "difficulty": "easy",
        "grid": null,
        "searchTags": ["geometric", "sample"],
        "thumbnail": "assets/designs/thumbnails/geometric_sample_001.webp",
        "strokes": [
          {"id": "stroke_01", "points": [[0.1, 0.1], [0.9, 0.9]]}
        ],
        "contentReview": {
          "status": "pending",
          "reviewer": "",
          "sourceOrPermission": "Original widget-test fixture."
        }
      }
    ]
  }
''');

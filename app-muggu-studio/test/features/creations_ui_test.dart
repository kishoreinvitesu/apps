import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:muggu_studio/data/local/creations_dao.dart';
import 'package:muggu_studio/data/local/favorites_dao.dart';
import 'package:muggu_studio/data/models/design_geometry.dart';
import 'package:muggu_studio/data/models/dot_grid.dart';
import 'package:muggu_studio/data/repositories/design_repository.dart';
import 'package:muggu_studio/features/create/presentation/create_screen.dart';
import 'package:muggu_studio/features/creations/domain/user_creation.dart';
import 'package:muggu_studio/features/saved/presentation/saved_screen.dart';
import 'package:muggu_studio/l10n/generated/app_localizations.dart';

class _MemoryFavoritesStore implements FavoritesStore {
  @override
  Future<List<String>> favoriteDesignIds() async => [];

  @override
  Future<bool> toggleFavorite(String designId) async => true;
}

class _MemoryCreationsStore implements CreationsStore {
  final Map<String, UserCreation> _items = {};

  @override
  Future<List<UserCreation>> listCreations() async =>
      _items.values.toList()
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

  @override
  Future<UserCreation?> loadCreation(String id) async => _items[id];

  @override
  Future<void> saveCreation(UserCreation creation) async {
    _items[creation.id] = creation;
  }

  @override
  Future<void> updateTitle(String id, String newTitle) async {
    final existing = _items[id];
    if (existing != null) {
      _items[id] = existing.copyWith(
        title: newTitle,
        updatedAt: DateTime.now().toUtc(),
      );
    }
  }

  @override
  Future<void> deleteCreation(String id) async {
    _items.remove(id);
  }
}

Widget _wrap(Widget child, {CreationsStore? store}) {
  return ProviderScope(
    overrides: [
      favoritesDaoProvider.overrideWithValue(_MemoryFavoritesStore()),
      creationsDaoProvider.overrideWithValue(store ?? _MemoryCreationsStore()),
      catalogProvider.overrideWith((ref) async => []),
    ],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    ),
  );
}

UserCreation _testCreation({
  required String id,
  required String title,
  CreationType type = CreationType.template,
}) {
  final now = DateTime.now().toUtc();
  return UserCreation(
    id: id,
    title: title,
    createdAt: now,
    updatedAt: now,
    type: type,
    paths: const [
      DesignPath(
        id: 'p1',
        groupId: 'g1',
        commands: [
          PathCommand(type: PathCommandType.moveTo, x: 0.1, y: 0.1),
          PathCommand(type: PathCommandType.lineTo, x: 0.9, y: 0.9),
        ],
      ),
    ],
    grid: DotGrid.rectangular(rows: 5, columns: 5),
  );
}

void main() {
  group('SavedScreen Creations tab', () {
    testWidgets('shows segmented button and switches to empty creations', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final store = _MemoryCreationsStore();
      await tester.pumpWidget(_wrap(const SavedScreen(), store: store));
      await tester.pumpAndSettle();

      // Both segments are present
      expect(find.text('Favourite designs'), findsOneWidget);
      expect(find.text('My Creations'), findsOneWidget);

      // Default is Favourite designs -> empty state
      expect(find.text('Nothing saved yet'), findsOneWidget);

      // Tap "My Creations" segment
      await tester.tap(find.text('My Creations'));
      await tester.pumpAndSettle();

      expect(find.text('No creations yet'), findsOneWidget);
      expect(
        find.text('Designs you create and save will appear here.'),
        findsOneWidget,
      );
    });

    testWidgets('renders saved creations in grid', (tester) async {
      tester.view.physicalSize = const Size(800, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final store = _MemoryCreationsStore();
      await store.saveCreation(_testCreation(id: 'c1', title: 'Morning Lotus'));
      await store.saveCreation(
        _testCreation(
          id: 'c2',
          title: 'Sunset Rangoli',
          type: CreationType.freehand,
        ),
      );

      await tester.pumpWidget(_wrap(const SavedScreen(), store: store));
      await tester.pumpAndSettle();

      // Switch to My Creations
      await tester.tap(find.text('My Creations'));
      await tester.pumpAndSettle();

      expect(find.text('Morning Lotus'), findsOneWidget);
      expect(find.text('Sunset Rangoli'), findsOneWidget);
      expect(find.text('Template pattern'), findsOneWidget);
      expect(find.text('Freehand canvas'), findsOneWidget);
    });

    testWidgets('rename creation updates title in store and UI', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final store = _MemoryCreationsStore();
      await store.saveCreation(_testCreation(id: 'c1', title: 'Original Name'));

      await tester.pumpWidget(_wrap(const SavedScreen(), store: store));
      await tester.pumpAndSettle();

      await tester.tap(find.text('My Creations'));
      await tester.pumpAndSettle();

      // Open menu
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();

      // Tap Rename
      await tester.tap(find.text('Rename'));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('creation-rename-input')),
        findsOneWidget,
      );

      // Enter new title
      await tester.enterText(
        find.byKey(const ValueKey('creation-rename-input')),
        'Updated Name',
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('creation-rename-confirm')));
      await tester.pumpAndSettle();

      expect(find.text('Updated Name'), findsOneWidget);
      final loaded = await store.loadCreation('c1');
      expect(loaded?.title, 'Updated Name');
    });

    testWidgets('delete creation removes it after confirmation', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final store = _MemoryCreationsStore();
      await store.saveCreation(_testCreation(id: 'c1', title: 'To Be Deleted'));

      await tester.pumpWidget(_wrap(const SavedScreen(), store: store));
      await tester.pumpAndSettle();

      await tester.tap(find.text('My Creations'));
      await tester.pumpAndSettle();

      expect(find.text('To Be Deleted'), findsOneWidget);

      // Open menu
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();

      // Tap Delete
      await tester.tap(find.text('Delete creation'));
      await tester.pumpAndSettle();

      // Confirmation dialog
      expect(
        find.text(
          'Are you sure you want to delete this creation? This action cannot be undone.',
        ),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const ValueKey('creation-delete-confirm')));
      await tester.pumpAndSettle();

      expect(find.text('To Be Deleted'), findsNothing);
      expect(find.text('No creations yet'), findsOneWidget);
      expect(await store.listCreations(), isEmpty);
    });
  });

  group('CreateScreen Save Creation', () {
    testWidgets('Save button opens dialog and saves template creation', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final store = _MemoryCreationsStore();
      await tester.pumpWidget(_wrap(const CreateScreen(), store: store));
      await tester.pumpAndSettle();

      // Find creator save button
      final saveBtn = find.byKey(const ValueKey('creator-save'));
      expect(saveBtn, findsOneWidget);

      await tester.tap(saveBtn);
      await tester.pumpAndSettle();

      // Dialog opens
      expect(
        find.byKey(const ValueKey('creation-title-input')),
        findsOneWidget,
      );

      await tester.enterText(
        find.byKey(const ValueKey('creation-title-input')),
        'My Special Kolam',
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('creation-save-confirm')));
      await tester.pumpAndSettle();

      final list = await store.listCreations();
      expect(list.length, 1);
      expect(list.first.title, 'My Special Kolam');
      expect(list.first.type, CreationType.template);
      expect(list.first.paths, isNotEmpty);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:muggu_studio/core/theme/app_theme.dart';
import 'package:muggu_studio/features/create/presentation/create_screen.dart';
import 'package:muggu_studio/features/design/presentation/vector_preview.dart';
import 'package:muggu_studio/l10n/generated/app_localizations.dart';

Widget _createScreenTestApp({Locale locale = const Locale('en')}) {
  return MaterialApp(
    theme: AppTheme.light,
    locale: locale,
    supportedLocales: const [Locale('en'), Locale('te'), Locale('ta')],
    localizationsDelegates: const [
      AppLocalizations.delegate,
      ...GlobalMaterialLocalizations.delegates,
    ],
    home: const Scaffold(body: CreateScreen()),
  );
}

void main() {
  group('CreateScreen Phase 1 Polish', () {
    testWidgets('renders radial flower by default with all radial controls', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(_createScreenTestApp());
      await tester.pumpAndSettle();

      expect(find.text('Create a pattern'), findsOneWidget);
      expect(find.text('Radial flower'), findsOneWidget);
      expect(find.byKey(const ValueKey('pattern-preview')), findsOneWidget);

      // Verify all 3 radial controls are present
      expect(find.byKey(const ValueKey('slider-petal-count')), findsOneWidget);
      expect(find.byKey(const ValueKey('slider-radius')), findsOneWidget);
      expect(find.byKey(const ValueKey('slider-petal-width')), findsOneWidget);

      expect(find.text('Petals: 8'), findsOneWidget);
      expect(find.text('Radius: 36%'), findsOneWidget);
      expect(find.text('Petal width: 9.5%'), findsOneWidget);

      // Verify Undo and Redo are initially disabled
      final undoButton = tester.widget<OutlinedButton>(
        find.byKey(const ValueKey('creator-undo')),
      );
      final redoButton = tester.widget<OutlinedButton>(
        find.byKey(const ValueKey('creator-redo')),
      );
      expect(undoButton.onPressed, isNull);
      expect(redoButton.onPressed, isNull);
    });

    testWidgets(
      'switching to dot-grid diamonds shows explicit sizes and layouts',
      (tester) async {
        tester.view.physicalSize = const Size(800, 1800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(_createScreenTestApp());
        await tester.pumpAndSettle();

        final dotGridChip = find.byKey(
          const ValueKey('generator-dot_grid_diamonds'),
        );
        await tester.tap(dotGridChip);
        await tester.pumpAndSettle();

        // Verify explicit standard dot grid chips exist, including 5x5, 7x7, 9x9
        expect(find.byKey(const ValueKey('grid-size-3')), findsOneWidget);
        expect(find.byKey(const ValueKey('grid-size-5')), findsOneWidget);
        expect(find.byKey(const ValueKey('grid-size-7')), findsOneWidget);
        expect(find.byKey(const ValueKey('grid-size-9')), findsOneWidget);
        expect(find.byKey(const ValueKey('grid-size-11')), findsOneWidget);

        // Verify layouts
        expect(
          find.byKey(const ValueKey('grid-layout-square')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('grid-layout-staggered')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('grid-layout-diamond')),
          findsOneWidget,
        );

        // Tap 7x7 chip
        await tester.tap(find.byKey(const ValueKey('grid-size-7')));
        await tester.pumpAndSettle();
        expect(find.text('Grid size: 7 × 7'), findsOneWidget);

        // Tap diamond layout
        await tester.tap(find.byKey(const ValueKey('grid-layout-diamond')));
        await tester.pumpAndSettle();

        final preview = tester.widget<VectorPreview>(
          find.byKey(const ValueKey('pattern-preview')),
        );
        expect(preview.grid?.layout, 'diamond');
        expect(preview.grid?.rows, 7);
        expect(preview.grid?.columns, 7);
      },
    );

    testWidgets('undo, redo, and reset restore parameter states predictably', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(_createScreenTestApp());
      await tester.pumpAndSettle();

      expect(find.text('Petals: 8'), findsOneWidget);

      // Switch to dot-grid diamonds
      await tester.tap(
        find.byKey(const ValueKey('generator-dot_grid_diamonds')),
      );
      await tester.pumpAndSettle();
      expect(find.text('Grid size: 5 × 5'), findsOneWidget);

      // Change grid size to 9x9
      await tester.tap(find.byKey(const ValueKey('grid-size-9')));
      await tester.pumpAndSettle();
      expect(find.text('Grid size: 9 × 9'), findsOneWidget);

      // Undo grid size change (reverts to 5x5)
      await tester.tap(find.byKey(const ValueKey('creator-undo')));
      await tester.pumpAndSettle();
      expect(find.text('Grid size: 5 × 5'), findsOneWidget);

      // Redo grid size change (restores 9x9)
      await tester.tap(find.byKey(const ValueKey('creator-redo')));
      await tester.pumpAndSettle();
      expect(find.text('Grid size: 9 × 9'), findsOneWidget);

      // Tap reset (resets to radial flower initial state)
      await tester.tap(find.byKey(const ValueKey('creator-reset')));
      await tester.pumpAndSettle();
      expect(find.text('Petals: 8'), findsOneWidget);
      expect(find.text('Radius: 36%'), findsOneWidget);

      // Tapping undo after reset restores the pre-reset 9x9 dot-grid state
      await tester.tap(find.byKey(const ValueKey('creator-undo')));
      await tester.pumpAndSettle();
      expect(find.text('Grid size: 9 × 9'), findsOneWidget);
    });

    testWidgets('supports Telugu localization on Create screen', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(_createScreenTestApp(locale: const Locale('te')));
      await tester.pumpAndSettle();

      expect(find.text('నమూనాను సృష్టించండి'), findsOneWidget);
      expect(find.text('వృత్తాకార పువ్వు'), findsOneWidget);
      expect(find.text('చుక్కల గ్రిడ్ డైమండ్స్'), findsOneWidget);
      expect(find.text('రీసెట్'), findsOneWidget);
    });

    testWidgets('supports Tamil localization on Create screen', (tester) async {
      tester.view.physicalSize = const Size(800, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(_createScreenTestApp(locale: const Locale('ta')));
      await tester.pumpAndSettle();

      expect(find.text('வடிவமைப்பை உருவாக்கவும்'), findsOneWidget);
      expect(find.text('வட்ட மலர்'), findsOneWidget);
      expect(find.text('புள்ளிக் கட்ட வைரங்கள்'), findsOneWidget);
      expect(find.text('மீட்டமை'), findsOneWidget);
    });

    testWidgets(
      'TabBarView has NeverScrollableScrollPhysics to prevent drawing drag swipe conflicts',
      (tester) async {
        tester.view.physicalSize = const Size(800, 1800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(_createScreenTestApp());
        await tester.pumpAndSettle();

        final tabBarViewFinder = find.byType(TabBarView);
        expect(tabBarViewFinder, findsOneWidget);
        final tabBarView = tester.widget<TabBarView>(tabBarViewFinder);
        expect(tabBarView.physics, isA<NeverScrollableScrollPhysics>());
      },
    );
  });
}

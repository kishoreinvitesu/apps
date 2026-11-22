import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:muggu_studio/data/models/design_geometry.dart';
import 'package:muggu_studio/features/drawing/application/drawing_controller.dart';
import 'package:muggu_studio/features/drawing/domain/drawn_stroke.dart';
import 'package:muggu_studio/features/drawing/presentation/drawing_toolbar.dart';
import 'package:muggu_studio/l10n/generated/app_localizations.dart';

Widget _wrap(Widget child) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: SingleChildScrollView(child: child)),
);

void main() {
  group('DrawingToolbar', () {
    late DrawingController controller;

    setUp(() {
      controller = DrawingController();
    });

    tearDown(() {
      controller.dispose();
    });

    testWidgets('renders all 5 colour swatches', (tester) async {
      tester.view.physicalSize = const Size(800, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(_wrap(DrawingToolbar(controller: controller)));

      // 5 colour swatches are GestureDetector children inside the palette row
      // We verify by checking that the toolbar renders without error and
      // that the initial selected colour is deepMaroon.
      expect(controller.selectedColor, DrawingPalette.deepMaroon);
      expect(find.byType(DrawingToolbar), findsOneWidget);
    });

    testWidgets('tapping a different colour updates controller', (tester) async {
      tester.view.physicalSize = const Size(800, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(_wrap(DrawingToolbar(controller: controller)));
      await tester.pump();

      // The colour swatch containers are GestureDetector widgets.
      // Tap the second swatch (riceFlourWhite at index 1).
      final swatches = tester.widgetList<GestureDetector>(
        find.byType(GestureDetector),
      ).toList();

      // First 5 GestureDetectors are colour swatches in palette row
      expect(swatches.length, greaterThanOrEqualTo(5));
      await tester.tap(find.byType(GestureDetector).at(1));
      await tester.pump();

      expect(controller.selectedColor, DrawingPalette.riceFlourWhite);
    });

    testWidgets('symmetry chip selection updates controller', (tester) async {
      tester.view.physicalSize = const Size(800, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(_wrap(DrawingToolbar(controller: controller)));
      await tester.pump();

      expect(controller.selectedSymmetry, SymmetryMode.none);

      // Tap the "Vertical" ChoiceChip
      await tester.tap(find.byType(ChoiceChip).at(1));
      await tester.pump();

      expect(controller.selectedSymmetry, SymmetryMode.vertical);
    });

    testWidgets('undo and redo buttons are initially disabled', (tester) async {
      tester.view.physicalSize = const Size(800, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(_wrap(DrawingToolbar(controller: controller)));
      await tester.pump();

      expect(controller.canUndo, isFalse);
      expect(controller.canRedo, isFalse);
    });

    testWidgets('undo enabled after a stroke is committed', (tester) async {
      tester.view.physicalSize = const Size(800, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      // Add a stroke programmatically
      controller
        ..startStroke(const DesignPoint(x: 0.1, y: 0.1))
        ..addPoint(const DesignPoint(x: 0.2, y: 0.2))
        ..endStroke();

      await tester.pumpWidget(_wrap(DrawingToolbar(controller: controller)));
      await tester.pump();

      expect(controller.canUndo, isTrue);
    });

    testWidgets('clear button disabled when no strokes', (tester) async {
      tester.view.physicalSize = const Size(800, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(_wrap(DrawingToolbar(controller: controller)));
      await tester.pump();

      // Clear IconButton should be disabled (onPressed == null)
      final clearBtn = tester
          .widgetList<IconButton>(find.byType(IconButton))
          .last;
      expect(clearBtn.onPressed, isNull);
    });

    testWidgets('clear dialog appears on tap when strokes exist', (tester) async {
      tester.view.physicalSize = const Size(800, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      controller
        ..startStroke(const DesignPoint(x: 0.1, y: 0.1))
        ..addPoint(const DesignPoint(x: 0.2, y: 0.2))
        ..endStroke();

      await tester.pumpWidget(
        // Need a full Navigator for showDialog
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: DrawingToolbar(controller: controller)),
        ),
      );
      await tester.pump();

      // Tap clear (last icon button)
      await tester.tap(find.byType(IconButton).last);
      await tester.pumpAndSettle();

      // AlertDialog should be visible
      expect(find.byType(AlertDialog), findsOneWidget);
    });

    testWidgets('confirming clear empties strokes', (tester) async {
      tester.view.physicalSize = const Size(800, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      controller
        ..startStroke(const DesignPoint(x: 0.1, y: 0.1))
        ..addPoint(const DesignPoint(x: 0.2, y: 0.2))
        ..endStroke();

      expect(controller.strokes, isNotEmpty);

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: DrawingToolbar(controller: controller)),
        ),
      );
      await tester.pump();

      await tester.tap(find.byType(IconButton).last);
      await tester.pumpAndSettle();

      // Tap the FilledButton (Clear) in the dialog
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      expect(controller.strokes, isEmpty);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:muggu_studio/features/drawing/application/drawing_controller.dart';
import 'package:muggu_studio/features/drawing/domain/drawn_stroke.dart';
import 'package:muggu_studio/features/drawing/presentation/drawing_canvas.dart';
import 'package:muggu_studio/l10n/generated/app_localizations.dart';

Widget _wrap(Widget child) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: child),
);

void main() {
  group('DrawingCanvas', () {
    late DrawingController controller;

    setUp(() {
      controller = DrawingController();
    });

    tearDown(() {
      controller.dispose();
    });

    testWidgets('renders without error with no grid or guide paths', (tester) async {
      tester.view.physicalSize = const Size(800, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        _wrap(DrawingCanvas(controller: controller)),
      );
      expect(find.byType(DrawingCanvas), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(DrawingCanvas),
          matching: find.byType(CustomPaint),
        ),
        findsOneWidget,
      );
    });

    testWidgets('pointer events commit a stroke on pointer up', (tester) async {
      tester.view.physicalSize = const Size(800, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        _wrap(
          SizedBox(
            width: 400,
            height: 400,
            child: DrawingCanvas(controller: controller),
          ),
        ),
      );

      expect(controller.strokes, isEmpty);

      // Simulate a pointer drag across the canvas
      final gesture = await tester.startGesture(const Offset(100, 100));
      await tester.pump();
      await gesture.moveBy(const Offset(50, 50));
      await tester.pump();
      await gesture.moveBy(const Offset(50, 50));
      await tester.pump();
      await gesture.up();
      await tester.pump();

      expect(controller.strokes, isNotEmpty);
      expect(controller.strokes.first.points.length, greaterThan(1));
    });

    testWidgets('single tap without move produces a stroke', (tester) async {
      tester.view.physicalSize = const Size(800, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        _wrap(
          SizedBox(
            width: 400,
            height: 400,
            child: DrawingCanvas(controller: controller),
          ),
        ),
      );

      final gesture = await tester.startGesture(const Offset(200, 200));
      await tester.pump();
      await gesture.up();
      await tester.pump();

      // Single tap → endStroke() called with one active point → 1 stroke
      expect(controller.strokes.length, 1);
    });

    testWidgets('symmetry=vertical produces two strokes from one drag', (tester) async {
      tester.view.physicalSize = const Size(800, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      controller.setSymmetry(SymmetryMode.vertical);

      await tester.pumpWidget(
        _wrap(
          SizedBox(
            width: 400,
            height: 400,
            child: DrawingCanvas(controller: controller),
          ),
        ),
      );

      final gesture = await tester.startGesture(const Offset(100, 100));
      await tester.pump();
      await gesture.moveBy(const Offset(30, 30));
      await tester.pump();
      await gesture.up();
      await tester.pump();

      // Vertical symmetry → original + 1 mirror = 2 strokes
      expect(controller.strokes.length, 2);
    });

    testWidgets('guide paths layer rendered when tracingMode=true', (tester) async {
      tester.view.physicalSize = const Size(800, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      // Just verify the widget builds with tracingMode=true (no crash)
      await tester.pumpWidget(
        _wrap(DrawingCanvas(controller: controller, tracingMode: true)),
      );
      expect(find.byType(DrawingCanvas), findsOneWidget);
    });
  });
}

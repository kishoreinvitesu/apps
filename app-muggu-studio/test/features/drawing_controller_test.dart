import 'package:flutter_test/flutter_test.dart';
import 'package:muggu_studio/data/models/design_geometry.dart';
import 'package:muggu_studio/features/drawing/application/drawing_controller.dart';
import 'package:muggu_studio/features/drawing/domain/drawn_stroke.dart';

void main() {
  group('DrawingController', () {
    test('starts with empty strokes and default tools', () {
      final controller = DrawingController();

      expect(controller.strokes, isEmpty);
      expect(controller.activePoints, isEmpty);
      expect(controller.canUndo, isFalse);
      expect(controller.canRedo, isFalse);
      expect(controller.selectedColor, DrawingPalette.deepMaroon);
      expect(controller.selectedStrokeWidth, DrawingPalette.mediumWidth);
      expect(controller.selectedSymmetry, SymmetryMode.none);
    });

    test('stroke drawing commits points to strokes on endStroke', () {
      final controller = DrawingController();

      controller.startStroke(const DesignPoint(x: 0.1, y: 0.1));
      expect(controller.isDrawing, isTrue);

      controller.addPoint(const DesignPoint(x: 0.2, y: 0.2));
      controller.endStroke();

      expect(controller.isDrawing, isFalse);
      expect(controller.strokes, hasLength(1));
      expect(controller.strokes.first.points, hasLength(2));
      expect(controller.canUndo, isTrue);
      expect(controller.canRedo, isFalse);
    });

    test(
      'four-way symmetry generates four mirrored strokes upon endStroke',
      () {
        final controller = DrawingController(
          initialSymmetry: SymmetryMode.fourWay,
        );

        controller.startStroke(const DesignPoint(x: 0.1, y: 0.2));
        controller.addPoint(const DesignPoint(x: 0.3, y: 0.4));
        controller.endStroke();

        expect(controller.strokes, hasLength(4));
      },
    );

    test('undo, redo, and clear cycle restores state predictably', () {
      final controller = DrawingController();

      controller.startStroke(const DesignPoint(x: 0.1, y: 0.1));
      controller.addPoint(const DesignPoint(x: 0.2, y: 0.2));
      controller.endStroke();
      expect(controller.strokes, hasLength(1));

      // Undo
      controller.undo();
      expect(controller.strokes, isEmpty);
      expect(controller.canUndo, isFalse);
      expect(controller.canRedo, isTrue);

      // Redo
      controller.redo();
      expect(controller.strokes, hasLength(1));
      expect(controller.canUndo, isTrue);
      expect(controller.canRedo, isFalse);

      // Clear
      controller.clear();
      expect(controller.strokes, isEmpty);
      expect(controller.canUndo, isTrue);

      // Undo clear
      controller.undo();
      expect(controller.strokes, hasLength(1));
    });

    test('decimates duplicate or too close points', () {
      final controller = DrawingController();

      controller.startStroke(const DesignPoint(x: 0.5, y: 0.5));
      // Extremely tiny delta
      controller.addPoint(const DesignPoint(x: 0.50001, y: 0.50001));
      expect(controller.activePoints, hasLength(1));

      // Meaningful delta
      controller.addPoint(const DesignPoint(x: 0.52, y: 0.52));
      expect(controller.activePoints, hasLength(2));
    });

    test('tool setters update state and notify listeners', () {
      final controller = DrawingController();
      var notifications = 0;
      controller.addListener(() => notifications++);

      controller.setColor(DrawingPalette.turmericGold);
      expect(controller.selectedColor, DrawingPalette.turmericGold);

      controller.setStrokeWidth(DrawingPalette.boldWidth);
      expect(controller.selectedStrokeWidth, DrawingPalette.boldWidth);

      controller.setSymmetry(SymmetryMode.vertical);
      expect(controller.selectedSymmetry, SymmetryMode.vertical);

      expect(notifications, 3);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:muggu_studio/data/models/design_geometry.dart';
import 'package:muggu_studio/features/drawing/domain/drawn_stroke.dart';
import 'package:muggu_studio/features/drawing/domain/symmetry_transform.dart';

void main() {
  group('SymmetryTransform', () {
    test('none returns the original stroke unaltered', () {
      const points = [DesignPoint(x: 0.1, y: 0.2), DesignPoint(x: 0.3, y: 0.4)];

      final result = SymmetryTransform.apply(points, SymmetryMode.none);

      expect(result, hasLength(1));
      expect(result.first, points);
    });

    test('vertical mirrors x coordinates across center axis x=0.5', () {
      const points = [DesignPoint(x: 0.2, y: 0.3), DesignPoint(x: 0.4, y: 0.6)];

      final result = SymmetryTransform.apply(points, SymmetryMode.vertical);

      expect(result, hasLength(2));
      // Original
      expect(result[0][0].x, closeTo(0.2, 0.0001));
      expect(result[0][0].y, closeTo(0.3, 0.0001));
      // Mirrored across 0.5 (1.0 - 0.2 = 0.8)
      expect(result[1][0].x, closeTo(0.8, 0.0001));
      expect(result[1][0].y, closeTo(0.3, 0.0001));
      expect(result[1][1].x, closeTo(0.6, 0.0001));
      expect(result[1][1].y, closeTo(0.6, 0.0001));
    });

    test(
      'vertical deduplicates strokes lying entirely on the vertical axis',
      () {
        const centerPoints = [
          DesignPoint(x: 0.5, y: 0.1),
          DesignPoint(x: 0.5, y: 0.9),
        ];

        final result = SymmetryTransform.apply(
          centerPoints,
          SymmetryMode.vertical,
        );

        expect(result, hasLength(1));
      },
    );

    test('horizontal mirrors y coordinates across center axis y=0.5', () {
      const points = [DesignPoint(x: 0.2, y: 0.3), DesignPoint(x: 0.4, y: 0.1)];

      final result = SymmetryTransform.apply(points, SymmetryMode.horizontal);

      expect(result, hasLength(2));
      // Mirrored across 0.5 (1.0 - 0.3 = 0.7, 1.0 - 0.1 = 0.9)
      expect(result[1][0].x, closeTo(0.2, 0.0001));
      expect(result[1][0].y, closeTo(0.7, 0.0001));
      expect(result[1][1].x, closeTo(0.4, 0.0001));
      expect(result[1][1].y, closeTo(0.9, 0.0001));
    });

    test(
      'horizontal deduplicates strokes lying entirely on the horizontal axis',
      () {
        const centerPoints = [
          DesignPoint(x: 0.1, y: 0.5),
          DesignPoint(x: 0.9, y: 0.5),
        ];

        final result = SymmetryTransform.apply(
          centerPoints,
          SymmetryMode.horizontal,
        );

        expect(result, hasLength(1));
      },
    );

    test('fourWay returns four quadrant reflections for asymmetric input', () {
      const points = [
        DesignPoint(x: 0.1, y: 0.2),
        DesignPoint(x: 0.25, y: 0.35),
      ];

      final result = SymmetryTransform.apply(points, SymmetryMode.fourWay);

      expect(result, hasLength(4));

      // 1. Original (0.1, 0.2)
      expect(result[0][0].x, closeTo(0.1, 0.0001));
      expect(result[0][0].y, closeTo(0.2, 0.0001));

      // 2. Vertical (0.9, 0.2)
      expect(result[1][0].x, closeTo(0.9, 0.0001));
      expect(result[1][0].y, closeTo(0.2, 0.0001));

      // 3. Horizontal (0.1, 0.8)
      expect(result[2][0].x, closeTo(0.1, 0.0001));
      expect(result[2][0].y, closeTo(0.8, 0.0001));

      // 4. Diagonal (0.9, 0.8)
      expect(result[3][0].x, closeTo(0.9, 0.0001));
      expect(result[3][0].y, closeTo(0.8, 0.0001));
    });

    test('clamps coordinates at edge boundaries [0.0, 1.0]', () {
      const edgePoints = [
        DesignPoint(x: 0.0, y: 0.0),
        DesignPoint(x: 1.0, y: 1.0),
      ];

      final result = SymmetryTransform.apply(edgePoints, SymmetryMode.fourWay);

      for (final stroke in result) {
        for (final pt in stroke) {
          expect(pt.x, inInclusiveRange(0.0, 1.0));
          expect(pt.y, inInclusiveRange(0.0, 1.0));
        }
      }
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:muggu_studio/data/models/design_geometry.dart';
import 'package:muggu_studio/features/drawing/domain/drawn_stroke.dart';

Map<String, dynamic> _validStrokeJson() => {
  'points': [
    [0.2, 0.2],
    [0.8, 0.8],
  ],
  'color': 0xFF862B37,
  'strokeWidth': 4.0,
  'symmetryMode': 'vertical',
};

void main() {
  group('DrawnStroke.fromJson', () {
    test('rejects malformed persisted fields with format errors', () {
      final invalidValues = [
        {'points': 'not-a-list'},
        {
          'points': [
            ['x', 0.5],
          ],
        },
        {'color': 'not-an-integer'},
        {'color': -1},
        {'color': 0x100000000},
        {'strokeWidth': 0},
        {'strokeWidth': -1.0},
        {'strokeWidth': double.nan},
        {'symmetryMode': 7},
        {'symmetryMode': 'diagonal'},
      ];

      for (final invalid in invalidValues) {
        expect(
          () => DrawnStroke.fromJson({..._validStrokeJson(), ...invalid}),
          throwsFormatException,
          reason: '$invalid',
        );
      }
    });

    test('preserves the legacy default symmetry when the field is absent', () {
      final json = _validStrokeJson()..remove('symmetryMode');

      expect(DrawnStroke.fromJson(json).symmetryMode, SymmetryMode.none);
    });
  });

  test('equality and hash codes use consistent exact geometry values', () {
    final first = DrawnStroke(
      points: const [DesignPoint(x: 0.5, y: 0.5)],
      color: const Color(0xFF862B37),
      strokeWidth: 1.0049,
    );
    final identical = DrawnStroke(
      points: const [DesignPoint(x: 0.5, y: 0.5)],
      color: const Color(0xFF862B37),
      strokeWidth: 1.0049,
    );
    final nearWidth = DrawnStroke(
      points: const [DesignPoint(x: 0.5, y: 0.5)],
      color: const Color(0xFF862B37),
      strokeWidth: 1.0055,
    );

    expect(first, identical);
    expect(first.hashCode, identical.hashCode);
    expect(first, isNot(equals(nearWidth)));
  });
}

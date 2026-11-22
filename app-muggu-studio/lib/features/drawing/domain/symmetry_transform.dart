import '../../../data/models/design_geometry.dart';
import 'drawn_stroke.dart';

abstract final class SymmetryTransform {
  static const double epsilon = 0.0005;

  /// Returns all mirrored point sequences for the given [points] under [mode].
  static List<List<DesignPoint>> apply(
    List<DesignPoint> points,
    SymmetryMode mode,
  ) {
    if (points.isEmpty) return const [];

    switch (mode) {
      case SymmetryMode.none:
        return [List.unmodifiable(points)];

      case SymmetryMode.vertical:
        final original = List<DesignPoint>.unmodifiable(points);
        final mirrored = List<DesignPoint>.unmodifiable(
          points.map(
            (p) => DesignPoint(x: (1.0 - p.x).clamp(0.0, 1.0), y: p.y),
          ),
        );
        if (_areStrokesEquivalent(original, mirrored)) {
          return [original];
        }
        return [original, mirrored];

      case SymmetryMode.horizontal:
        final original = List<DesignPoint>.unmodifiable(points);
        final mirrored = List<DesignPoint>.unmodifiable(
          points.map(
            (p) => DesignPoint(x: p.x, y: (1.0 - p.y).clamp(0.0, 1.0)),
          ),
        );
        if (_areStrokesEquivalent(original, mirrored)) {
          return [original];
        }
        return [original, mirrored];

      case SymmetryMode.fourWay:
        final original = List<DesignPoint>.unmodifiable(points);
        final vertical = List<DesignPoint>.unmodifiable(
          points.map(
            (p) => DesignPoint(x: (1.0 - p.x).clamp(0.0, 1.0), y: p.y),
          ),
        );
        final horizontal = List<DesignPoint>.unmodifiable(
          points.map(
            (p) => DesignPoint(x: p.x, y: (1.0 - p.y).clamp(0.0, 1.0)),
          ),
        );
        final both = List<DesignPoint>.unmodifiable(
          points.map(
            (p) => DesignPoint(
              x: (1.0 - p.x).clamp(0.0, 1.0),
              y: (1.0 - p.y).clamp(0.0, 1.0),
            ),
          ),
        );

        final candidates = [original, vertical, horizontal, both];
        final uniqueStrokes = <List<DesignPoint>>[];

        for (final candidate in candidates) {
          final alreadyPresent = uniqueStrokes.any(
            (existing) => _areStrokesEquivalent(existing, candidate),
          );
          if (!alreadyPresent) {
            uniqueStrokes.add(candidate);
          }
        }
        return uniqueStrokes;
    }
  }

  /// Checks if two point sequences are effectively identical within tolerance.
  static bool _areStrokesEquivalent(
    List<DesignPoint> first,
    List<DesignPoint> second,
  ) {
    if (first.length != second.length) return false;
    for (var i = 0; i < first.length; i++) {
      if ((first[i].x - second[i].x).abs() > epsilon ||
          (first[i].y - second[i].y).abs() > epsilon) {
        return false;
      }
    }
    return true;
  }
}

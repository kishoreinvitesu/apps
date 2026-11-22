import 'package:material_ui/material_ui.dart';

import '../../../data/models/design_geometry.dart';

enum SymmetryMode {
  none,
  vertical,
  horizontal,
  fourWay;

  String get label => switch (this) {
    SymmetryMode.none => 'None',
    SymmetryMode.vertical => 'Vertical',
    SymmetryMode.horizontal => 'Horizontal',
    SymmetryMode.fourWay => '4-Way',
  };
}

class DrawnStroke {
  DrawnStroke({
    required List<DesignPoint> points,
    required this.color,
    required this.strokeWidth,
    this.symmetryMode = SymmetryMode.none,
  }) : points = List.unmodifiable(points);

  final List<DesignPoint> points;
  final Color color;
  final double strokeWidth;
  final SymmetryMode symmetryMode;

  DrawnStroke copyWith({
    List<DesignPoint>? points,
    Color? color,
    double? strokeWidth,
    SymmetryMode? symmetryMode,
  }) {
    return DrawnStroke(
      points: points ?? this.points,
      color: color ?? this.color,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      symmetryMode: symmetryMode ?? this.symmetryMode,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DrawnStroke &&
          runtimeType == other.runtimeType &&
          color.toARGB32() == other.color.toARGB32() &&
          (strokeWidth - other.strokeWidth).abs() < 0.001 &&
          symmetryMode == other.symmetryMode &&
          points.length == other.points.length &&
          _pointsEqual(points, other.points);

  @override
  int get hashCode => Object.hash(
    color.toARGB32(),
    strokeWidth.toStringAsFixed(2),
    symmetryMode,
    points.length,
  );

  static bool _pointsEqual(List<DesignPoint> a, List<DesignPoint> b) {
    for (var i = 0; i < a.length; i++) {
      if ((a[i].x - b[i].x).abs() > 0.0001 || (a[i].y - b[i].y).abs() > 0.0001) {
        return false;
      }
    }
    return true;
  }
}

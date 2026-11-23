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

  Map<String, dynamic> toJson() => {
    'points': [for (final p in points) p.toJson()],
    'color': color.toARGB32(),
    'strokeWidth': strokeWidth,
    'symmetryMode': symmetryMode.name,
  };

  factory DrawnStroke.fromJson(Map<String, dynamic> json) {
    final rawPoints = json['points'];
    if (rawPoints is! List) {
      throw FormatException('points must be a list.');
    }
    final points = [
      for (var i = 0; i < rawPoints.length; i++)
        DesignPoint.fromJson(rawPoints[i], 'points[$i]'),
    ];
    final rawColor = json['color'];
    if (rawColor is! int || rawColor < 0 || rawColor > 0xFFFFFFFF) {
      throw FormatException('color must be a 32-bit ARGB integer.');
    }
    final rawStrokeWidth = json['strokeWidth'];
    if (rawStrokeWidth is! num ||
        !rawStrokeWidth.isFinite ||
        rawStrokeWidth <= 0) {
      throw FormatException('strokeWidth must be a positive finite number.');
    }
    final strokeWidth = rawStrokeWidth.toDouble();
    final rawMode = json['symmetryMode'];
    if (rawMode != null && rawMode is! String) {
      throw FormatException('symmetryMode must be a string.');
    }
    final modeName = rawMode ?? 'none';
    final symmetryMode = switch (modeName) {
      'none' => SymmetryMode.none,
      'vertical' => SymmetryMode.vertical,
      'horizontal' => SymmetryMode.horizontal,
      'fourWay' => SymmetryMode.fourWay,
      _ => throw FormatException('Unsupported symmetryMode: $modeName.'),
    };
    return DrawnStroke(
      points: points,
      color: Color(rawColor),
      strokeWidth: strokeWidth,
      symmetryMode: symmetryMode,
    );
  }

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
          strokeWidth == other.strokeWidth &&
          symmetryMode == other.symmetryMode &&
          points.length == other.points.length &&
          _pointsEqual(points, other.points);

  @override
  int get hashCode => Object.hash(
    color.toARGB32(),
    strokeWidth,
    symmetryMode,
    Object.hashAll(points.map((point) => Object.hash(point.x, point.y))),
  );

  static bool _pointsEqual(List<DesignPoint> a, List<DesignPoint> b) {
    for (var i = 0; i < a.length; i++) {
      if (a[i].x != b[i].x || a[i].y != b[i].y) {
        return false;
      }
    }
    return true;
  }
}

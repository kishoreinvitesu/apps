import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/design_geometry.dart';
import '../../../data/models/dot_grid.dart';
import 'geometry_path_builder.dart';

void paintDesignBackground(Canvas canvas, Size size, Color color) {
  canvas.drawRect(Offset.zero & size, Paint()..color = color);
}

void paintDotGrid(
  Canvas canvas,
  Size size,
  DotGrid? grid, {
  Color color = MugguColors.leafGreen,
  double opacity = 0.58,
  double radiusFactor = 0.008,
}) {
  if (grid == null) {
    return;
  }
  final radius = math.min(size.width, size.height) * radiusFactor;
  final paint = Paint()..color = color.withValues(alpha: opacity);
  for (final dot in grid.dots) {
    canvas.drawCircle(
      Offset(dot.x * size.width, dot.y * size.height),
      radius,
      paint,
    );
  }
}

void paintDesignPath(
  Canvas canvas,
  Size size,
  DesignPath designPath, {
  required Color defaultStrokeColor,
  double defaultStrokeWidth = 0.0065,
  Color? strokeOverride,
  double opacity = 1,
  bool drawFill = true,
  bool drawShadow = true,
}) {
  final path = buildDesignPath(designPath, size);
  final minDimension = math.min(size.width, size.height);

  final shadowColor = designPath.shadowColor;
  if (drawShadow && shadowColor != null) {
    canvas.save();
    canvas.translate(minDimension * 0.008, minDimension * 0.012);
    canvas.drawPath(
      path,
      Paint()
        ..color = designColorFromHex(shadowColor)
            .withValues(alpha: opacity * 0.3)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, minDimension * 0.012),
    );
    canvas.restore();
  }

  final fillColor = designPath.fillColor;
  if (drawFill && fillColor != null) {
    canvas.drawPath(
      path,
      Paint()..color = designColorFromHex(fillColor).withValues(alpha: opacity),
    );
  }

  final strokeColor =
      strokeOverride ??
      (designPath.strokeColor == null
          ? defaultStrokeColor
          : designColorFromHex(designPath.strokeColor!));
  final strokeWidth = designPath.strokeWidth ?? defaultStrokeWidth;
  canvas.drawPath(
    path,
    Paint()
      ..color = strokeColor.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = minDimension * strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
}

Color designColorFromHex(String value) =>
    Color(int.parse(value.substring(1), radix: 16) | 0xFF000000);

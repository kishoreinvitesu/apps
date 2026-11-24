import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/design_geometry.dart';
import '../../../data/models/dot_grid.dart';
import 'geometry_path_builder.dart';

void paintDesignBackground(Canvas canvas, Size size, Color color) {
  canvas.drawRect(
    Offset.zero & size,
    Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color.lerp(Colors.white, color, 0.92)!, color],
      ).createShader(Offset.zero & size),
  );
}

void paintDotGrid(
  Canvas canvas,
  Size size,
  DotGrid? grid, {
  Color color = MugguColors.leafGreen,
  double opacity = 0.58,
  double radiusFactor = 0.008,
  Color? haloColor,
}) {
  if (grid == null) {
    return;
  }
  final radius = math.min(size.width, size.height) * radiusFactor;
  final haloPaint = Paint()..color = haloColor ?? Colors.transparent;
  final paint = Paint()..color = color.withValues(alpha: opacity);
  for (final dot in grid.dots) {
    final center = Offset(dot.x * size.width, dot.y * size.height);
    if (haloColor != null) {
      canvas.drawCircle(center, radius * 1.8, haloPaint);
    }
    canvas.drawCircle(center, radius, paint);
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
  bool drawStroke = true,
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
    final baseColor = designColorFromHex(fillColor);
    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(baseColor, Colors.white, 0.25)!,
            baseColor,
            Color.lerp(baseColor, Colors.black, 0.1)!,
          ],
          stops: const [0, 0.62, 1],
        ).createShader(path.getBounds())
        ..color = Colors.white.withValues(alpha: opacity),
    );
  }

  if (!drawStroke) {
    return;
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

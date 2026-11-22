import 'dart:ui' as ui;

import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/design_geometry.dart';
import '../../../data/models/dot_grid.dart';
import '../../design/application/geometry_path_builder.dart';
import '../application/drawing_controller.dart';
import '../domain/drawn_stroke.dart';
import '../domain/symmetry_transform.dart';

/// An interactive freehand drawing canvas with optional dot-grid underlay and
/// ghost guide paths for tracing mode.
///
/// Layout coordinates are normalised [0, 1]. Pointer events are converted using
/// the [RenderBox] local coordinate system and clamped before forwarding to
/// [DrawingController].
class DrawingCanvas extends StatefulWidget {
  const DrawingCanvas({
    required this.controller,
    this.grid,
    this.guideDesignPaths = const [],
    this.tracingMode = false,
    super.key,
  });

  final DrawingController controller;
  final DotGrid? grid;
  final List<DesignPath> guideDesignPaths;
  final bool tracingMode;

  @override
  State<DrawingCanvas> createState() => _DrawingCanvasState();
}

class _DrawingCanvasState extends State<DrawingCanvas> {
  Size? _canvasSize;

  DesignPoint _toNormalized(Offset local) {
    final size = _canvasSize ?? Size.zero;
    final x = (local.dx / size.width).clamp(0.0, 1.0);
    final y = (local.dy / size.height).clamp(0.0, 1.0);
    return DesignPoint(x: x, y: y);
  }

  void _onPointerDown(PointerDownEvent event) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;
    final local = box.globalToLocal(event.position);
    widget.controller.startStroke(_toNormalized(local));
  }

  void _onPointerMove(PointerMoveEvent event) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;
    final local = box.globalToLocal(event.position);
    widget.controller.addPoint(_toNormalized(local));
  }

  void _onPointerUp(PointerUpEvent event) {
    widget.controller.endStroke();
  }

  void _onPointerCancel(PointerCancelEvent event) {
    widget.controller.endStroke();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: _onPointerDown,
      onPointerMove: _onPointerMove,
      onPointerUp: _onPointerUp,
      onPointerCancel: _onPointerCancel,
      child: LayoutBuilder(
        builder: (context, constraints) {
          _canvasSize = Size(constraints.maxWidth, constraints.maxHeight);
          return ListenableBuilder(
            listenable: widget.controller,
            builder: (context, _) {
              return CustomPaint(
                size: _canvasSize!,
                painter: _DrawingCanvasPainter(
                  strokes: widget.controller.strokes,
                  activePoints: widget.controller.activePoints,
                  symmetryMode: widget.controller.selectedSymmetry,
                  activeColor: widget.controller.selectedColor,
                  activeWidth: widget.controller.selectedStrokeWidth,
                  grid: widget.grid,
                  guideDesignPaths: widget.guideDesignPaths,
                  tracingMode: widget.tracingMode,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _DrawingCanvasPainter extends CustomPainter {
  _DrawingCanvasPainter({
    required this.strokes,
    required this.activePoints,
    required this.symmetryMode,
    required this.activeColor,
    required this.activeWidth,
    required this.grid,
    required this.guideDesignPaths,
    required this.tracingMode,
  });

  final List<DrawnStroke> strokes;
  final List<DesignPoint> activePoints;
  final SymmetryMode symmetryMode;
  final Color activeColor;
  final double activeWidth;
  final DotGrid? grid;
  final List<DesignPath> guideDesignPaths;
  final bool tracingMode;

  static const _dotRadius = 3.0;
  static const _dotColor = Color(0x55862B37); // deep maroon at 33% alpha
  static const _guideAlpha = 0.28;
  static const _borderRadius = 16.0;

  @override
  void paint(Canvas canvas, Size size) {
    // --- Layer 0: Background + rounded border ---
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(_borderRadius),
    );
    canvas.drawRRect(rrect, Paint()..color = MugguColors.warmCream);
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = MugguColors.darkBrown.withValues(alpha: 0.14)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Clip subsequent layers to rounded rect
    canvas.save();
    canvas.clipRRect(rrect);

    // --- Layer 1: Dot grid ---
    final localGrid = grid;
    if (localGrid != null) {
      final dotPaint = Paint()..color = _dotColor;
      for (final dot in localGrid.dots) {
        canvas.drawCircle(
          Offset(dot.x * size.width, dot.y * size.height),
          _dotRadius,
          dotPaint,
        );
      }
    }

    // --- Layer 2: Ghost guide paths ---
    if (tracingMode && guideDesignPaths.isNotEmpty) {
      for (final designPath in guideDesignPaths) {
        final guidePath = buildDesignPath(designPath, size);
        final fillHex = designPath.fillColor;
        if (fillHex != null) {
          final fillColor = _hexToColor(fillHex).withValues(alpha: _guideAlpha);
          canvas.drawPath(guidePath, Paint()..color = fillColor);
        }
        canvas.drawPath(
          guidePath,
          Paint()
            ..color = MugguColors.deepMaroon.withValues(alpha: _guideAlpha)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.0
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round,
        );
      }
    }

    // --- Layer 3: Committed strokes ---
    for (final stroke in strokes) {
      _paintStroke(canvas, size, stroke.points, stroke.color, stroke.strokeWidth);
    }

    // --- Layer 4: Active stroke + live symmetry preview ---
    if (activePoints.isNotEmpty) {
      final mirrorSequences = SymmetryTransform.apply(activePoints, symmetryMode);
      for (var i = 0; i < mirrorSequences.length; i++) {
        final isMirror = i > 0;
        final mirrorColor = isMirror
            ? activeColor.withValues(alpha: 0.5)
            : activeColor;
        _paintStroke(canvas, size, mirrorSequences[i], mirrorColor, activeWidth);
      }
    }

    canvas.restore();
  }

  void _paintStroke(
    Canvas canvas,
    Size size,
    List<DesignPoint> points,
    Color color,
    double strokeWidth,
  ) {
    if (points.length < 2) {
      if (points.length == 1) {
        // Single tap → draw a dot
        canvas.drawCircle(
          Offset(points[0].x * size.width, points[0].y * size.height),
          strokeWidth / 2,
          Paint()..color = color,
        );
      }
      return;
    }
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = ui.Path();
    path.moveTo(points[0].x * size.width, points[0].y * size.height);
    for (var i = 1; i < points.length; i++) {
      path.lineTo(points[i].x * size.width, points[i].y * size.height);
    }
    canvas.drawPath(path, paint);
  }

  static Color _hexToColor(String hex) {
    final value = int.tryParse(hex.replaceFirst('#', 'FF'), radix: 16);
    return value != null ? Color(value) : MugguColors.deepMaroon;
  }

  @override
  bool shouldRepaint(_DrawingCanvasPainter oldDelegate) {
    return oldDelegate.strokes.length != strokes.length ||
        oldDelegate.activePoints.length != activePoints.length ||
        oldDelegate.symmetryMode != symmetryMode ||
        oldDelegate.activeColor != activeColor ||
        oldDelegate.activeWidth != activeWidth ||
        oldDelegate.tracingMode != tracingMode;
  }
}

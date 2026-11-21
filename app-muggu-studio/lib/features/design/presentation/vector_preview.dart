import 'package:material_ui/material_ui.dart';

import '../../../data/models/muggu_design.dart';

class VectorPreview extends StatelessWidget {
  const VectorPreview({
    required this.design,
    required this.visibleStrokeCount,
    super.key,
  });

  final MugguDesign design;
  final int visibleStrokeCount;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        child: CustomPaint(
          painter: _VectorPreviewPainter(
            strokes: design.strokes,
            visibleStrokeCount: visibleStrokeCount,
            color: Theme.of(context).colorScheme.primary,
            guideColor: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
      ),
    );
  }
}

class _VectorPreviewPainter extends CustomPainter {
  const _VectorPreviewPainter({
    required this.strokes,
    required this.visibleStrokeCount,
    required this.color,
    required this.guideColor,
  });

  final List<DesignStroke> strokes;
  final int visibleStrokeCount;
  final Color color;
  final Color guideColor;

  @override
  void paint(Canvas canvas, Size size) {
    final guidePaint = Paint()
      ..color = guideColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..color = guideColor.withValues(alpha: 0.08)
        ..style = PaintingStyle.fill,
    );

    for (var index = 0; index < strokes.length; index++) {
      final stroke = strokes[index];
      final path = _buildPath(stroke, size);
      canvas.drawPath(path, guidePaint);
      if (index < visibleStrokeCount) {
        canvas.drawPath(
          path,
          Paint()
            ..color = color
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round,
        );
      }
    }
  }

  Path _buildPath(DesignStroke stroke, Size size) {
    final path = Path();
    for (var index = 0; index < stroke.points.length; index++) {
      final point = stroke.points[index];
      final offset = Offset(point.x * size.width, point.y * size.height);
      if (index == 0) {
        path.moveTo(offset.dx, offset.dy);
      } else {
        path.lineTo(offset.dx, offset.dy);
      }
    }
    if (stroke.closed) {
      path.close();
    }
    return path;
  }

  @override
  bool shouldRepaint(covariant _VectorPreviewPainter oldDelegate) =>
      oldDelegate.visibleStrokeCount != visibleStrokeCount ||
      oldDelegate.strokes != strokes ||
      oldDelegate.color != color;
}

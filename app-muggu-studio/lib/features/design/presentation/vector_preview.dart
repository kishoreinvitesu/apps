import 'package:material_ui/material_ui.dart';

import '../../../data/models/design_geometry.dart';
import '../../../data/models/dot_grid.dart';
import '../application/geometry_path_builder.dart';

class VectorPreview extends StatelessWidget {
  const VectorPreview({
    required this.paths,
    required this.grid,
    this.visibleGroupIds,
    this.showAllPaths = true,
    super.key,
  });

  final List<DesignPath> paths;
  final DotGrid? grid;
  final Set<String>? visibleGroupIds;
  final bool showAllPaths;

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
            paths: paths,
            grid: grid,
            visibleGroupIds: visibleGroupIds,
            showAllPaths: showAllPaths,
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
    required this.paths,
    required this.grid,
    required this.visibleGroupIds,
    required this.showAllPaths,
    required this.color,
    required this.guideColor,
  });

  final List<DesignPath> paths;
  final DotGrid? grid;
  final Set<String>? visibleGroupIds;
  final bool showAllPaths;
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

    final dots = grid?.dots ?? const <DesignPoint>[];
    final dotPaint = Paint()
      ..color = color.withValues(alpha: 0.48)
      ..style = PaintingStyle.fill;
    for (final dot in dots) {
      canvas.drawCircle(
        Offset(dot.x * size.width, dot.y * size.height),
        3,
        dotPaint,
      );
    }

    for (final designPath in paths) {
      final path = buildDesignPath(designPath, size);
      canvas.drawPath(path, guidePaint);
      final isVisible =
          showAllPaths ||
          (visibleGroupIds?.contains(designPath.groupId) ?? false);
      if (isVisible) {
        final fillColor = designPath.fillColor;
        if (fillColor != null) {
          canvas.drawPath(path, Paint()..color = _parseColor(fillColor));
        }
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

  Color _parseColor(String value) =>
      Color(int.parse(value.substring(1), radix: 16) | 0xFF000000);

  @override
  bool shouldRepaint(covariant _VectorPreviewPainter oldDelegate) =>
      oldDelegate.visibleGroupIds != visibleGroupIds ||
      oldDelegate.showAllPaths != showAllPaths ||
      oldDelegate.paths != paths ||
      oldDelegate.grid != grid ||
      oldDelegate.color != color ||
      oldDelegate.guideColor != guideColor;
}

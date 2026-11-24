import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/design_geometry.dart';
import '../../../data/models/dot_grid.dart';
import '../application/design_renderer.dart';

class VectorPreview extends StatelessWidget {
  const VectorPreview({
    required this.paths,
    required this.grid,
    this.visibleGroupIds,
    this.showAllPaths = true,
    this.backgroundColor = MugguColors.warmCream,
    super.key,
  });

  final List<DesignPath> paths;
  final DotGrid? grid;
  final Set<String>? visibleGroupIds;
  final bool showAllPaths;
  final Color backgroundColor;

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
            backgroundColor: backgroundColor,
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
    required this.backgroundColor,
    required this.color,
    required this.guideColor,
  });

  final List<DesignPath> paths;
  final DotGrid? grid;
  final Set<String>? visibleGroupIds;
  final bool showAllPaths;
  final Color backgroundColor;
  final Color color;
  final Color guideColor;

  @override
  void paint(Canvas canvas, Size size) {
    paintDesignBackground(canvas, size, backgroundColor);

    for (final designPath in paths) {
      final isVisible =
          showAllPaths ||
          (visibleGroupIds?.contains(designPath.groupId) ?? false);
      paintDesignPath(
        canvas,
        size,
        designPath,
        defaultStrokeColor: color,
        strokeOverride: isVisible ? null : guideColor,
        opacity: isVisible ? 1 : 0.42,
        drawFill: isVisible,
        drawShadow: isVisible,
        drawStroke: false,
      );
    }

    for (final designPath in paths) {
      final isVisible =
          showAllPaths ||
          (visibleGroupIds?.contains(designPath.groupId) ?? false);
      paintDesignPath(
        canvas,
        size,
        designPath,
        defaultStrokeColor: color,
        strokeOverride: isVisible ? null : guideColor,
        opacity: isVisible ? 1 : 0.42,
        drawFill: false,
        drawShadow: false,
      );
    }

    paintDotGrid(canvas, size, grid, haloColor: Colors.white);
  }

  @override
  bool shouldRepaint(covariant _VectorPreviewPainter oldDelegate) =>
      oldDelegate.visibleGroupIds != visibleGroupIds ||
      oldDelegate.showAllPaths != showAllPaths ||
      oldDelegate.paths != paths ||
      oldDelegate.grid != grid ||
      oldDelegate.backgroundColor != backgroundColor ||
      oldDelegate.color != color ||
      oldDelegate.guideColor != guideColor;
}

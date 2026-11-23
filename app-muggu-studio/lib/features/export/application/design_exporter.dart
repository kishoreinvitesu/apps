import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/design_geometry.dart';
import '../../../data/models/dot_grid.dart';
import '../../../data/models/muggu_design.dart';
import '../../creations/domain/user_creation.dart';
import '../../design/application/geometry_path_builder.dart';

/// Resolution preset for exporting Muggu and Kolam designs.
enum ExportResolution {
  /// Standard 1080 × 1080 square format (optimal for messaging & social sharing).
  standard(1080),

  /// High-resolution 2048 × 2048 square format (optimal for printing or archiving).
  high(2048);

  const ExportResolution(this.dimension);
  final int dimension;
}

/// Headless vector-to-raster PNG exporter for Muggu and Kolam designs.
///
/// Renders authentic vector paths, optional dot grid underlays, and subtle
/// cultural branding attribution directly using Flutter engine canvas primitives
/// without requiring widget tree captures or screen dependencies.
class DesignExporter {
  const DesignExporter();

  /// Export arbitrary [DesignPath] geometry and optional [DotGrid] to PNG bytes.
  Future<Uint8List> exportToPngBytes({
    required List<DesignPath> paths,
    DotGrid? grid,
    int targetResolution = 1080,
    Color backgroundColor = MugguColors.warmCream,
    Color strokeColor = MugguColors.deepMaroon,
    bool includeBranding = true,
    String? title,
  }) async {
    final size = ui.Size(
      targetResolution.toDouble(),
      targetResolution.toDouble(),
    );
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(
      recorder,
      ui.Rect.fromLTWH(0, 0, size.width, size.height),
    );

    // --- Layer 0: Background Solid Fill ---
    canvas.drawRect(
      ui.Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = backgroundColor,
    );

    // --- Layer 1: Dot Grid Underlay ---
    if (grid != null && grid.dots.isNotEmpty) {
      final dotRadius = size.width * 0.005; // ~5.4px at 1080p, ~10.2px at 2048p
      final dotPaint = Paint()
        ..color = strokeColor.withValues(alpha: 0.35)
        ..style = PaintingStyle.fill;

      for (final dot in grid.dots) {
        canvas.drawCircle(
          Offset(dot.x * size.width, dot.y * size.height),
          dotRadius,
          dotPaint,
        );
      }
    }

    // --- Layer 2: Vector Paths ---
    final baseStrokeWidth =
        size.width * 0.0055; // ~6px at 1080p, ~11px at 2048p
    for (final designPath in paths) {
      final path = buildDesignPath(designPath, size);

      // Fill if the path specifies a fill colour
      if (designPath.fillColor != null) {
        final fillColor = _parseHexColor(designPath.fillColor!);
        canvas.drawPath(path, Paint()..color = fillColor);
      }

      // Stroke — DesignPath has no per-path strokeColor, use caller-supplied default
      final strokePaint = Paint()
        ..color = strokeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = baseStrokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      canvas.drawPath(path, strokePaint);
    }

    // --- Layer 3: Cultural Branding / Attribution Footer ---
    if (includeBranding) {
      final attributionText = title != null && title.isNotEmpty
          ? '$title • Muggu Studio'
          : 'Muggu Studio • traditional floor art';

      final paragraphStyle = ui.ParagraphStyle(
        textAlign: TextAlign.center,
        fontSize: size.width * 0.022, // ~24px at 1080p
      );
      final paragraphBuilder = ui.ParagraphBuilder(paragraphStyle)
        ..pushStyle(
          ui.TextStyle(
            color: MugguColors.darkBrown.withValues(alpha: 0.65),
            fontWeight: FontWeight.w500,
          ),
        )
        ..addText(attributionText);

      final paragraph = paragraphBuilder.build()
        ..layout(ui.ParagraphConstraints(width: size.width - 32));

      final footerY = size.height - paragraph.height - (size.height * 0.025);
      canvas.drawParagraph(paragraph, Offset(16, footerY));
    }

    final picture = recorder.endRecording();
    final image = await picture.toImage(targetResolution, targetResolution);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      throw StateError('Failed to encode raster canvas into PNG bytes');
    }
    return byteData.buffer.asUint8List();
  }

  /// Export a [UserCreation] to PNG bytes.
  Future<Uint8List> exportCreation(
    UserCreation creation, {
    ExportResolution resolution = ExportResolution.standard,
    bool includeBranding = true,
  }) {
    return exportToPngBytes(
      paths: creation.paths,
      grid: creation.grid,
      targetResolution: resolution.dimension,
      title: creation.title,
      includeBranding: includeBranding,
    );
  }

  /// Export a catalog [MugguDesign] to PNG bytes.
  Future<Uint8List> exportDesign(
    MugguDesign design, {
    ExportResolution resolution = ExportResolution.standard,
    String? languageCode,
    bool includeBranding = true,
  }) {
    return exportToPngBytes(
      paths: design.paths,
      grid: design.grid,
      targetResolution: resolution.dimension,
      title: design.nameFor(languageCode ?? 'en'),
      includeBranding: includeBranding,
    );
  }

  static Color _parseHexColor(String hex) {
    var clean = hex.replaceFirst('#', '');
    if (clean.length == 6) {
      clean = 'FF$clean';
    }
    final val = int.tryParse(clean, radix: 16);
    return val != null ? Color(val) : MugguColors.deepMaroon;
  }
}

/// Provider for [DesignExporter].
final designExporterProvider = Provider<DesignExporter>((ref) {
  return const DesignExporter();
});

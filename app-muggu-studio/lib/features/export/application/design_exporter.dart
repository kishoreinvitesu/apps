import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/design_geometry.dart';
import '../../../data/models/dot_grid.dart';
import '../../../data/models/muggu_design.dart';
import '../../creations/domain/user_creation.dart';
import '../../design/application/design_renderer.dart';

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
    paintDesignBackground(canvas, size, backgroundColor);

    for (final designPath in paths) {
      paintDesignPath(
        canvas,
        size,
        designPath,
        defaultStrokeColor: strokeColor,
        defaultStrokeWidth: 0.0055,
        drawStroke: false,
      );
    }

    for (final designPath in paths) {
      paintDesignPath(
        canvas,
        size,
        designPath,
        defaultStrokeColor: strokeColor,
        defaultStrokeWidth: 0.0055,
        drawFill: false,
        drawShadow: false,
      );
    }

    paintDotGrid(
      canvas,
      size,
      grid,
      color: strokeColor,
      opacity: 0.35,
      radiusFactor: 0.005,
      haloColor: Color.lerp(Colors.white, backgroundColor, 0.92)!,
    );

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
    try {
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw StateError('Failed to encode raster canvas into PNG bytes');
      }
      return byteData.buffer.asUint8List();
    } finally {
      image.dispose();
    }
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
      backgroundColor: designColorFromHex(creation.backgroundColor),
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
      backgroundColor: designColorFromHex(design.backgroundColor),
      title: design.nameFor(languageCode ?? 'en'),
      includeBranding: includeBranding,
    );
  }
}

/// Provider for [DesignExporter].
final designExporterProvider = Provider<DesignExporter>((ref) {
  return const DesignExporter();
});

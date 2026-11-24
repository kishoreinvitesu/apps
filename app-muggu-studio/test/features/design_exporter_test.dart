import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:material_ui/material_ui.dart' show Color;
import 'package:flutter_test/flutter_test.dart';
import 'package:muggu_studio/data/models/design_geometry.dart';
import 'package:muggu_studio/data/models/dot_grid.dart';
import 'package:muggu_studio/features/creations/domain/user_creation.dart';
import 'package:muggu_studio/features/drawing/domain/drawn_stroke.dart';
import 'package:muggu_studio/features/export/application/design_exporter.dart';

void main() {
  group('DesignExporter', () {
    const exporter = DesignExporter();

    // A minimal pair of paths that form a triangle
    final trianglePaths = [
      DesignPath.fromJson({
        'id': 'p1',
        'groupId': 'g1',
        'commands': [
          {'type': 'moveTo', 'x': 0.1, 'y': 0.1},
          {'type': 'lineTo', 'x': 0.9, 'y': 0.1},
          {'type': 'lineTo', 'x': 0.5, 'y': 0.9},
          {'type': 'close'},
        ],
      }, 'p1'),
    ];

    final dotGrid = DotGrid.rectangular(rows: 5, columns: 5);

    test('standard resolution produces valid PNG bytes (1080×1080)', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      final bytes = await exporter.exportToPngBytes(
        paths: trianglePaths,
        targetResolution: ExportResolution.standard.dimension,
      );
      _expectValidPng(bytes, 1080);
    });

    test('high resolution produces valid PNG bytes (2048×2048)', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      final bytes = await exporter.exportToPngBytes(
        paths: trianglePaths,
        targetResolution: ExportResolution.high.dimension,
      );
      _expectValidPng(bytes, 2048);
    });

    test('export with dot grid does not throw', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      final bytes = await exporter.exportToPngBytes(
        paths: trianglePaths,
        grid: dotGrid,
        targetResolution: 512,
      );
      _expectValidPng(bytes, 512);
    });

    test('export without paths (empty canvas) produces valid PNG', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      final bytes = await exporter.exportToPngBytes(
        paths: const [],
        targetResolution: 512,
        includeBranding: false,
      );
      _expectValidPng(bytes, 512);
    });

    test('export applies layered fills and the selected background', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      const background = Color(0xFF123456);
      final path = DesignPath.fromJson({
        'id': 'filled_triangle',
        'groupId': 'flower',
        'fillColor': '#F4CBD2',
        'strokeColor': '#80535E',
        'strokeWidth': 0.02,
        'shadowColor': '#B48275',
        'commands': [
          {'type': 'moveTo', 'x': 0.25, 'y': 0.25},
          {'type': 'lineTo', 'x': 0.75, 'y': 0.25},
          {'type': 'lineTo', 'x': 0.5, 'y': 0.75},
          {'type': 'close'},
        ],
      }, 'fixture.path');
      final png = await exporter.exportToPngBytes(
        paths: [path],
        targetResolution: 64,
        backgroundColor: background,
        includeBranding: false,
      );
      final codec = await ui.instantiateImageCodec(png);
      final image = (await codec.getNextFrame()).image;
      final pixels = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      expect(pixels, isNotNull);
      final pixelData = pixels!;

      List<int> pixelAt(int x, int y) {
        final offset = (y * 64 + x) * 4;
        return [
          pixelData.getUint8(offset),
          pixelData.getUint8(offset + 1),
          pixelData.getUint8(offset + 2),
          pixelData.getUint8(offset + 3),
        ];
      }

      try {
        expect(pixelAt(2, 2), [0x24, 0x43, 0x63, 0xFF]);
        expect(pixelAt(32, 32), [
          closeTo(0xF4, 3),
          closeTo(0xCB, 3),
          closeTo(0xD2, 3),
          0xFF,
        ]);
      } finally {
        image.dispose();
        codec.dispose();
      }
    });

    test('exportCreation encodes a freehand UserCreation', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      final now = DateTime.now().toUtc();
      final strokes = [
        DrawnStroke(
          points: const [
            DesignPoint(x: 0.2, y: 0.2),
            DesignPoint(x: 0.5, y: 0.5),
            DesignPoint(x: 0.8, y: 0.2),
          ],
          color: const Color(0xFF862B37),
          strokeWidth: 4.0,
        ),
      ];
      final paths = UserCreation.strokesToDesignPaths(strokes);
      final creation = UserCreation(
        id: 'test_1',
        title: 'Test freehand',
        createdAt: now,
        updatedAt: now,
        type: CreationType.freehand,
        strokes: strokes,
        paths: paths,
        grid: dotGrid,
      );

      final bytes = await exporter.exportCreation(
        creation,
        resolution: ExportResolution.standard,
      );
      _expectValidPng(bytes, 1080);
    });
  });
}

/// Verifies the PNG signature bytes and that the file is non-trivially sized.
void _expectValidPng(Uint8List bytes, int expectedDimension) {
  // PNG magic bytes: 0x89 P N G \r \n 0x1A \n
  expect(bytes.length, greaterThan(100));
  expect(bytes[0], 0x89, reason: 'PNG signature byte 0');
  expect(bytes[1], 0x50, reason: 'PNG signature byte 1 (P)');
  expect(bytes[2], 0x4E, reason: 'PNG signature byte 2 (N)');
  expect(bytes[3], 0x47, reason: 'PNG signature byte 3 (G)');
  expect(bytes[4], 0x0D, reason: 'PNG signature byte 4');
  expect(bytes[5], 0x0A, reason: 'PNG signature byte 5');
  expect(bytes[6], 0x1A, reason: 'PNG signature byte 6');
  expect(bytes[7], 0x0A, reason: 'PNG signature byte 7');

  // IHDR chunk: bytes 12-15 = width, 16-19 = height (big-endian uint32)
  final width =
      (bytes[16] << 24) | (bytes[17] << 16) | (bytes[18] << 8) | bytes[19];
  final height =
      (bytes[20] << 24) | (bytes[21] << 16) | (bytes[22] << 8) | bytes[23];
  expect(width, expectedDimension, reason: 'PNG width');
  expect(height, expectedDimension, reason: 'PNG height');
}

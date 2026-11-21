import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:muggu_studio/data/models/design_geometry.dart';
import 'package:muggu_studio/data/models/dot_grid.dart';
import 'package:muggu_studio/features/design/application/geometry_path_builder.dart';

void main() {
  test('normalized quadratic, cubic and arc commands build a Flutter path', () {
    final designPath = DesignPath.fromJson({
      'id': 'curved_path',
      'groupId': 'main',
      'commands': [
        {'type': 'moveTo', 'x': 0.1, 'y': 0.5},
        {
          'type': 'quadraticTo',
          'controlX': 0.3,
          'controlY': 0.1,
          'x': 0.5,
          'y': 0.5,
        },
        {
          'type': 'cubicTo',
          'control1X': 0.55,
          'control1Y': 0.8,
          'control2X': 0.65,
          'control2Y': 0.8,
          'x': 0.7,
          'y': 0.5,
        },
        {
          'type': 'arcTo',
          'x': 0.6,
          'y': 0.5,
          'radiusX': 0.2,
          'radiusY': 0.2,
          'startAngle': 0,
          'sweepAngle': 1.5707963267948966,
        },
        {'type': 'close'},
      ],
    }, 'fixture.path');

    final path = buildDesignPath(designPath, const ui.Size(200, 100));
    final metrics = path.computeMetrics().toList();
    final bounds = path.getBounds();

    expect(metrics, isNotEmpty);
    expect(metrics.first.length, greaterThan(0));
    expect(bounds.left, greaterThanOrEqualTo(0));
    expect(bounds.top, greaterThanOrEqualTo(0));
    expect(bounds.right, lessThanOrEqualTo(200));
    expect(bounds.bottom, lessThanOrEqualTo(100));
  });

  test('arcs scale radii by canvas axes and join the preceding point', () {
    final designPath = DesignPath.fromJson({
      'id': 'arc_path',
      'groupId': 'main',
      'commands': [
        {'type': 'moveTo', 'x': 0.1, 'y': 0.5},
        {
          'type': 'arcTo',
          'x': 0.6,
          'y': 0.5,
          'radiusX': 0.2,
          'radiusY': 0.2,
          'startAngle': 0,
          'sweepAngle': 1.5707963267948966,
        },
      ],
    }, 'fixture.path');
    final path = buildDesignPath(designPath, const ui.Size(200, 100));
    final metric = path.computeMetrics().single;

    expect(path.getBounds().right, 160);
    expect(path.getBounds().bottom, 70);
    expect(metric.length, greaterThan(140));
  });

  test('a path without a drawing segment is rejected', () {
    expect(
      () => DesignPath.fromJson({
        'id': 'empty_path',
        'groupId': 'main',
        'commands': [
          {'type': 'moveTo', 'x': 0.5, 'y': 0.5},
          {'type': 'moveTo', 'x': 0.6, 'y': 0.6},
          {'type': 'close'},
        ],
      }, 'fixture.path'),
      throwsFormatException,
    );
  });

  test('filled paths and command sequences must be structurally valid', () {
    final openFilledPath = {
      'id': 'open_fill',
      'groupId': 'main',
      'fillColor': '#862B37',
      'commands': [
        {'type': 'moveTo', 'x': 0.1, 'y': 0.1},
        {'type': 'lineTo', 'x': 0.9, 'y': 0.9},
      ],
    };
    final closeWithoutSegment = {
      'id': 'close_without_segment',
      'groupId': 'main',
      'commands': [
        {'type': 'moveTo', 'x': 0.1, 'y': 0.1},
        {'type': 'close'},
        {'type': 'lineTo', 'x': 0.9, 'y': 0.9},
      ],
    };

    expect(
      () => DesignPath.fromJson(openFilledPath, 'fixture.path'),
      throwsFormatException,
    );
    expect(
      () => DesignPath.fromJson(closeWithoutSegment, 'fixture.path'),
      throwsFormatException,
    );
  });

  test('path command count is bounded', () {
    final commands = [
      {'type': 'moveTo', 'x': 0.1, 'y': 0.1},
      for (var index = 1; index <= maxPathCommandCount; index++)
        {'type': 'lineTo', 'x': 0.9, 'y': 0.9},
    ];

    expect(
      () => DesignPath.fromJson({
        'id': 'too_complex',
        'groupId': 'main',
        'commands': commands,
      }, 'fixture.path'),
      throwsFormatException,
    );
  });

  test('rectangular grid factory rejects non-finite margins', () {
    expect(
      () => DotGrid.rectangular(rows: 5, columns: 5, margin: double.nan),
      throwsArgumentError,
    );
  });

  test('dot-grid dimensions must match unique coordinates', () {
    expect(
      () => DotGrid.fromJson({
        'layout': 'square',
        'rows': 2,
        'columns': 2,
        'dots': [
          [0.1, 0.1],
          [0.9, 0.1],
          [0.1, 0.9],
        ],
      }, 'fixture.grid'),
      throwsFormatException,
    );
    expect(
      () => DotGrid.fromJson({
        'layout': 'square',
        'rows': 2,
        'columns': 3,
        'dots': [
          [0.1, 0.1],
          [0.5, 0.1],
          [0.9, 0.1],
          [0.1, 0.9],
          [0.5, 0.9],
          [0.9, 0.9],
        ],
      }, 'fixture.grid'),
      throwsFormatException,
    );
    expect(
      () => DotGrid.fromJson({
        'layout': 'rectangular',
        'rows': 2,
        'columns': 2,
        'dots': [
          [0.1, 0.1],
          [0.1, 0.1],
          [0.1, 0.9],
          [0.9, 0.9],
        ],
      }, 'fixture.grid'),
      throwsFormatException,
    );
  });

  test('staggered and diamond layouts retain explicit dot coordinates', () {
    final layouts = {
      'staggered': [
        [0.1, 0.1],
        [0.5, 0.1],
        [0.9, 0.1],
        [0.26, 0.5],
        [0.58, 0.5],
        [0.9, 0.5],
        [0.1, 0.9],
        [0.5, 0.9],
        [0.9, 0.9],
      ],
      'diamond': [
        [0.5, 0.1],
        [0.3, 0.3],
        [0.7, 0.3],
        [0.1, 0.5],
        [0.5, 0.5],
        [0.9, 0.5],
        [0.3, 0.7],
        [0.7, 0.7],
        [0.5, 0.9],
      ],
    };

    for (final entry in layouts.entries) {
      final grid = DotGrid.fromJson({
        'layout': entry.key,
        'rows': 3,
        'columns': 3,
        'dots': entry.value,
      }, 'fixture.grid');

      expect(grid.layout, entry.key);
      expect(grid.dots, hasLength(9));
    }
  });
}

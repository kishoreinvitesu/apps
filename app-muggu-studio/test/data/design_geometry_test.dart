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

  test('rectangular grid factory rejects non-finite margins', () {
    expect(
      () => DotGrid.rectangular(rows: 5, columns: 5, margin: double.nan),
      throwsArgumentError,
    );
  });
}

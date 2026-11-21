import 'design_geometry.dart';

const maxDotGridDimension = 31;
const maxDotGridDots = maxDotGridDimension * maxDotGridDimension;

class DotGrid {
  const DotGrid({
    required this.layout,
    required this.rows,
    required this.columns,
    required this.dots,
  });

  final String layout;
  final int rows;
  final int columns;
  final List<DesignPoint> dots;

  factory DotGrid.fromJson(Object? value, String fieldName) {
    if (value is! Map<String, dynamic>) {
      throw FormatException('$fieldName must be an object or null.');
    }
    final layout = value['layout'];
    final rows = value['rows'];
    final columns = value['columns'];
    if (layout is! String ||
        !const [
          'square',
          'rectangular',
          'staggered',
          'diamond',
          'custom',
        ].contains(layout) ||
        rows is! int ||
        rows < 1 ||
        rows > maxDotGridDimension ||
        columns is! int ||
        columns < 1 ||
        columns > maxDotGridDimension) {
      throw FormatException(
        '$fieldName requires a supported layout and row/column counts up to $maxDotGridDimension.',
      );
    }
    if (layout == 'square' && rows != columns) {
      throw FormatException('$fieldName square layouts need equal dimensions.');
    }
    final rawDots = value['dots'];
    if (rawDots is! List ||
        rawDots.isEmpty ||
        rawDots.length > maxDotGridDots ||
        (layout != 'custom' && rawDots.length != rows * columns)) {
      throw FormatException('$fieldName.dots must contain grid coordinates.');
    }
    final dots = List<DesignPoint>.unmodifiable([
      for (var index = 0; index < rawDots.length; index++)
        DesignPoint.fromJson(rawDots[index], '$fieldName.dots[$index]'),
    ]);
    if (layout == 'custom' && dots.length < 2) {
      throw FormatException(
        '$fieldName custom layouts need at least two dots.',
      );
    }
    final coordinates = <(double, double)>{};
    if (dots.any((dot) => !coordinates.add((dot.x, dot.y)))) {
      throw FormatException('$fieldName.dots must not contain duplicates.');
    }
    return DotGrid(layout: layout, rows: rows, columns: columns, dots: dots);
  }

  factory DotGrid.rectangular({
    required int rows,
    required int columns,
    double margin = 0.12,
  }) {
    if (rows < 2 ||
        rows > maxDotGridDimension ||
        columns < 2 ||
        columns > maxDotGridDimension ||
        !margin.isFinite ||
        margin < 0 ||
        margin >= 0.5) {
      throw ArgumentError('Grid dimensions and margin are out of range.');
    }
    final dots = <DesignPoint>[];
    for (var row = 0; row < rows; row++) {
      for (var column = 0; column < columns; column++) {
        dots.add(
          DesignPoint(
            x: margin + (1 - 2 * margin) * column / (columns - 1),
            y: margin + (1 - 2 * margin) * row / (rows - 1),
          ),
        );
      }
    }
    return DotGrid(
      layout: rows == columns ? 'square' : 'rectangular',
      rows: rows,
      columns: columns,
      dots: List.unmodifiable(dots),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is DotGrid &&
      other.layout == layout &&
      other.rows == rows &&
      other.columns == columns &&
      _sameDots(other.dots, dots);

  @override
  int get hashCode => Object.hash(layout, rows, columns, Object.hashAll(dots));

  static bool _sameDots(List<DesignPoint> left, List<DesignPoint> right) {
    if (left.length != right.length) {
      return false;
    }
    for (var index = 0; index < left.length; index++) {
      if (left[index].x != right[index].x || left[index].y != right[index].y) {
        return false;
      }
    }
    return true;
  }
}

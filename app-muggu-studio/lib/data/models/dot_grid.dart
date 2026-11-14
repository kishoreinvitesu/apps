class DotGrid {
  const DotGrid({required this.rows, required this.columns});

  final int rows;
  final int columns;

  factory DotGrid.fromJson(Object? value, String fieldName) {
    if (value is! Map<String, dynamic>) {
      throw FormatException('$fieldName must be an object or null.');
    }
    final rows = value['rows'];
    final columns = value['columns'];
    if (rows is! int || rows < 1 || columns is! int || columns < 1) {
      throw FormatException(
        '$fieldName rows and columns must be positive integers.',
      );
    }
    return DotGrid(rows: rows, columns: columns);
  }

  @override
  bool operator ==(Object other) =>
      other is DotGrid && other.rows == rows && other.columns == columns;

  @override
  int get hashCode => Object.hash(rows, columns);
}

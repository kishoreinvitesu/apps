import 'dart:math' as math;

import '../../../data/models/design_geometry.dart';
import '../../../data/models/dot_grid.dart';

class GeneratedPattern {
  const GeneratedPattern({
    required this.recipe,
    required this.paths,
    required this.grid,
  });

  final PatternRecipe recipe;
  final List<DesignPath> paths;
  final DotGrid? grid;
}

class PatternGeneratorRegistry {
  const PatternGeneratorRegistry();

  static const radialFlowerId = 'radial_flower';
  static const dotGridDiamondsId = 'dot_grid_diamonds';
  static const recipeVersion = 1;

  GeneratedPattern generate(PatternRecipe recipe) {
    if (recipe.version != recipeVersion) {
      throw FormatException(
        'Unsupported ${recipe.generatorId} recipe version ${recipe.version}.',
      );
    }
    return switch (recipe.generatorId) {
      radialFlowerId => _radialFlower(recipe),
      dotGridDiamondsId => _dotGridDiamonds(recipe),
      _ => throw FormatException(
        'Unsupported pattern generator: ${recipe.generatorId}.',
      ),
    };
  }

  GeneratedPattern _radialFlower(PatternRecipe recipe) {
    final petalCount = _integerParameter(
      recipe,
      'petalCount',
      minimum: 3,
      maximum: 24,
    );
    final outerRadius = _numberParameter(
      recipe,
      'outerRadius',
      minimum: 0.15,
      maximum: 0.42,
    );
    final petalWidth = _numberParameter(
      recipe,
      'petalWidth',
      minimum: 0.03,
      maximum: 0.14,
    );
    const center = DesignPoint(x: 0.5, y: 0.5);
    final paths = <DesignPath>[];

    for (var index = 0; index < petalCount; index++) {
      final angle = -math.pi / 2 + index * 2 * math.pi / petalCount;
      final axisX = math.cos(angle);
      final axisY = math.sin(angle);
      final normalX = -axisY;
      final normalY = axisX;
      final tip = DesignPoint(
        x: center.x + outerRadius * axisX,
        y: center.y + outerRadius * axisY,
      );
      final firstControl = DesignPoint(
        x: center.x + outerRadius * 0.42 * axisX + petalWidth * 0.55 * normalX,
        y: center.y + outerRadius * 0.42 * axisY + petalWidth * 0.55 * normalY,
      );
      final secondControl = DesignPoint(
        x: tip.x - outerRadius * 0.28 * axisX + petalWidth * 0.2 * normalX,
        y: tip.y - outerRadius * 0.28 * axisY + petalWidth * 0.2 * normalY,
      );
      final thirdControl = DesignPoint(
        x: tip.x - outerRadius * 0.28 * axisX - petalWidth * 0.2 * normalX,
        y: tip.y - outerRadius * 0.28 * axisY - petalWidth * 0.2 * normalY,
      );
      final fourthControl = DesignPoint(
        x: center.x + outerRadius * 0.42 * axisX - petalWidth * 0.55 * normalX,
        y: center.y + outerRadius * 0.42 * axisY - petalWidth * 0.55 * normalY,
      );
      final suffix = (index + 1).toString().padLeft(2, '0');
      paths.add(
        DesignPath(
          id: 'petal_path_$suffix',
          groupId: 'petal_$suffix',
          commands: List.unmodifiable([
            _pointCommand(PathCommandType.moveTo, center),
            _cubicCommand(firstControl, secondControl, tip),
            _cubicCommand(thirdControl, fourthControl, center),
            const PathCommand(type: PathCommandType.close),
          ]),
        ),
      );
    }

    return GeneratedPattern(
      recipe: PatternRecipe(
        generatorId: radialFlowerId,
        version: recipeVersion,
        parameters: Map.unmodifiable({
          'petalCount': petalCount,
          'outerRadius': outerRadius,
          'petalWidth': petalWidth,
        }),
      ),
      paths: List.unmodifiable(paths),
      grid: null,
    );
  }

  GeneratedPattern _dotGridDiamonds(PatternRecipe recipe) {
    final rows = _integerParameter(recipe, 'rows', minimum: 3, maximum: 15);
    final columns = _integerParameter(
      recipe,
      'columns',
      minimum: 3,
      maximum: 15,
    );
    if (rows.isEven || columns.isEven) {
      throw const FormatException(
        'Dot-grid diamond recipes require odd row and column counts.',
      );
    }
    final layout = _stringParameter(recipe, 'layout');
    if (!const [
      'square',
      'rectangular',
      'staggered',
      'diamond',
    ].contains(layout)) {
      throw FormatException('Unsupported dot-grid layout: $layout.');
    }
    final margin = _numberParameter(
      recipe,
      'margin',
      minimum: 0,
      maximum: 0.29,
    );
    final dots = <DesignPoint>[];
    for (var row = 0; row < rows; row++) {
      final rowOffset = layout == 'staggered' && row.isOdd ? 0.5 : 0.0;
      final rowWidth = columns - 1 + rowOffset;
      for (var column = 0; column < columns; column++) {
        var x =
            margin +
            (1 - 2 * margin) *
                (column + rowOffset) /
                (rowWidth == 0 ? 1 : rowWidth);
        var y = margin + (1 - 2 * margin) * row / (rows - 1);
        if (layout == 'diamond') {
          final offsetX = x - 0.5;
          final offsetY = y - 0.5;
          x = 0.5 + (offsetX + offsetY) * 0.5;
          y = 0.5 + (offsetY - offsetX) * 0.5;
        }
        dots.add(DesignPoint(x: x, y: y));
      }
    }
    final resolvedLayout = layout == 'square'
        ? (rows == columns ? 'square' : 'rectangular')
        : layout;
    final grid = DotGrid(
      layout: resolvedLayout,
      rows: rows,
      columns: columns,
      dots: List.unmodifiable(dots),
    );
    final centerRow = rows ~/ 2;
    final centerColumn = columns ~/ 2;
    final paths = <DesignPath>[];
    for (var depth = 1; depth <= math.min(centerRow, centerColumn); depth++) {
      final points = [
        dots[(centerRow - depth) * columns + centerColumn],
        dots[centerRow * columns + centerColumn + depth],
        dots[(centerRow + depth) * columns + centerColumn],
        dots[centerRow * columns + centerColumn - depth],
      ];
      final suffix = depth.toString().padLeft(2, '0');
      paths.add(
        DesignPath(
          id: 'ring_${suffix}_path',
          groupId: 'ring_$suffix',
          commands: List.unmodifiable([
            for (var index = 0; index < points.length; index++)
              _pointCommand(
                index == 0 ? PathCommandType.moveTo : PathCommandType.lineTo,
                points[index],
              ),
            const PathCommand(type: PathCommandType.close),
          ]),
        ),
      );
    }

    return GeneratedPattern(
      recipe: PatternRecipe(
        generatorId: dotGridDiamondsId,
        version: recipeVersion,
        parameters: Map.unmodifiable({
          'rows': rows,
          'columns': columns,
          'layout': resolvedLayout,
          'margin': margin,
        }),
      ),
      paths: List.unmodifiable(paths),
      grid: grid,
    );
  }

  static PathCommand _pointCommand(PathCommandType type, DesignPoint point) =>
      PathCommand(type: type, x: point.x, y: point.y);

  static PathCommand _cubicCommand(
    DesignPoint firstControl,
    DesignPoint secondControl,
    DesignPoint end,
  ) => PathCommand(
    type: PathCommandType.cubicTo,
    control1X: firstControl.x,
    control1Y: firstControl.y,
    control2X: secondControl.x,
    control2Y: secondControl.y,
    x: end.x,
    y: end.y,
  );

  static int _integerParameter(
    PatternRecipe recipe,
    String key, {
    required int minimum,
    required int maximum,
  }) {
    final value = recipe.parameters[key];
    if (value is! int || value < minimum || value > maximum) {
      throw FormatException(
        '${recipe.generatorId}.$key must be an integer between $minimum and $maximum.',
      );
    }
    return value;
  }

  static double _numberParameter(
    PatternRecipe recipe,
    String key, {
    required double minimum,
    required double maximum,
  }) {
    final value = recipe.parameters[key];
    if (value is! num ||
        !value.isFinite ||
        value < minimum ||
        value > maximum) {
      throw FormatException(
        '${recipe.generatorId}.$key must be between $minimum and $maximum.',
      );
    }
    return value.toDouble();
  }

  static String _stringParameter(PatternRecipe recipe, String key) {
    final value = recipe.parameters[key];
    if (value is! String || value.isEmpty) {
      throw FormatException('${recipe.generatorId}.$key must be a string.');
    }
    return value;
  }
}

import 'dart:math' as math;

import '../../../data/models/design_geometry.dart';
import '../../../data/models/dot_grid.dart';

const _pastelPalette = [
  '#F4CBD2',
  '#F4A99B',
  '#FFD991',
  '#C7DEB8',
  '#A9D7D1',
  '#D8C9EC',
];
const _softOutline = '#80535E';

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

class _ResolvedDotGrid {
  const _ResolvedDotGrid({
    required this.rows,
    required this.columns,
    required this.margin,
    required this.grid,
  });

  final int rows;
  final int columns;
  final double margin;
  final DotGrid grid;
}

class PatternGeneratorRegistry {
  const PatternGeneratorRegistry();

  static const radialFlowerId = 'radial_flower';
  static const dotGridDiamondsId = 'dot_grid_diamonds';
  static const dotGridLoopsId = 'dot_grid_loops';
  static const parabolicSikkuId = 'parabolic_sikku';
  static const rangoliMotifsId = 'rangoli_motifs';
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
      dotGridLoopsId => _dotGridLoops(recipe),
      parabolicSikkuId => _parabolicSikku(recipe),
      rangoliMotifsId => _rangoliMotifs(recipe),
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
    final paths = _petalRing(
      center: center,
      petalCount: petalCount,
      outerRadius: outerRadius,
      petalWidth: petalWidth,
      pathPrefix: 'petal',
    );

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
    final resolved = _resolveDotGrid(recipe);
    final rows = resolved.rows;
    final columns = resolved.columns;
    final grid = resolved.grid;
    final centerRow = rows ~/ 2;
    final centerColumn = columns ~/ 2;
    final paths = <DesignPath>[];
    for (var depth = 1; depth <= math.min(centerRow, centerColumn); depth++) {
      final points = [
        grid.dots[(centerRow - depth) * columns + centerColumn],
        grid.dots[centerRow * columns + centerColumn + depth],
        grid.dots[(centerRow + depth) * columns + centerColumn],
        grid.dots[centerRow * columns + centerColumn - depth],
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
          strokeColor: _softOutline,
          strokeWidth: 0.006,
          shadowColor: '#B48275',
        ),
      );
    }

    return GeneratedPattern(
      recipe: _dotGridRecipe(dotGridDiamondsId, resolved),
      paths: List.unmodifiable(paths),
      grid: grid,
    );
  }

  GeneratedPattern _dotGridLoops(PatternRecipe recipe) {
    final resolved = _resolveDotGrid(recipe);
    final stepX = (1 - 2 * resolved.margin) / (resolved.columns - 1);
    final stepY = (1 - 2 * resolved.margin) / (resolved.rows - 1);
    final edgeClearance = resolved.grid.dots
        .map(
          (dot) =>
              math.min(math.min(dot.x, 1 - dot.x), math.min(dot.y, 1 - dot.y)),
        )
        .reduce(math.min);
    if (edgeClearance <= 0) {
      throw const FormatException(
        'Dot-grid loop recipes require a positive edge margin.',
      );
    }
    final radius = math.min(
      math.min(stepX, stepY) * 0.22,
      edgeClearance * 0.85,
    );
    final paths = <DesignPath>[];

    for (var index = 0; index < resolved.grid.dots.length; index++) {
      final center = resolved.grid.dots[index];
      final suffix = (index + 1).toString().padLeft(3, '0');
      paths.add(
        DesignPath(
          id: 'dot_loop_$suffix',
          groupId: 'dot_$suffix',
          commands: List.unmodifiable([
            _pointCommand(
              PathCommandType.moveTo,
              DesignPoint(x: center.x, y: center.y - radius),
            ),
            _cubicCommand(
              DesignPoint(x: center.x + radius * 0.55, y: center.y - radius),
              DesignPoint(x: center.x + radius, y: center.y - radius * 0.55),
              DesignPoint(x: center.x + radius, y: center.y),
            ),
            _cubicCommand(
              DesignPoint(x: center.x + radius, y: center.y + radius * 0.55),
              DesignPoint(x: center.x + radius * 0.55, y: center.y + radius),
              DesignPoint(x: center.x, y: center.y + radius),
            ),
            _cubicCommand(
              DesignPoint(x: center.x - radius * 0.55, y: center.y + radius),
              DesignPoint(x: center.x - radius, y: center.y + radius * 0.55),
              DesignPoint(x: center.x - radius, y: center.y),
            ),
            _cubicCommand(
              DesignPoint(x: center.x - radius, y: center.y - radius * 0.55),
              DesignPoint(x: center.x - radius * 0.55, y: center.y - radius),
              DesignPoint(x: center.x, y: center.y - radius),
            ),
            const PathCommand(type: PathCommandType.close),
          ]),
          strokeColor: _pastelPalette[index % _pastelPalette.length],
          strokeWidth: 0.007,
        ),
      );
    }

    return GeneratedPattern(
      recipe: _dotGridRecipe(dotGridLoopsId, resolved),
      paths: List.unmodifiable(paths),
      grid: resolved.grid,
    );
  }

  GeneratedPattern _parabolicSikku(PatternRecipe recipe) {
    final resolved = _resolveDotGrid(recipe);
    final stepY = (1 - 2 * resolved.margin) / (resolved.rows - 1);
    final amplitude = stepY * 0.28;
    final paths = <DesignPath>[];

    for (var row = 0; row < resolved.rows; row++) {
      final suffix = (row + 1).toString().padLeft(2, '0');
      final commands = <PathCommand>[
        _pointCommand(
          PathCommandType.moveTo,
          resolved.grid.dots[row * resolved.columns],
        ),
      ];
      for (var column = 0; column < resolved.columns - 1; column++) {
        final start = resolved.grid.dots[row * resolved.columns + column];
        final end = resolved.grid.dots[row * resolved.columns + column + 1];
        final midY = (start.y + end.y) / 2;
        final direction = (row + column).isEven ? -1 : 1;
        final controlY = (midY + direction * amplitude)
            .clamp(0.02, 0.98)
            .toDouble();
        commands.add(
          _quadraticCommand(
            DesignPoint(x: (start.x + end.x) / 2, y: controlY),
            end,
          ),
        );
      }
      paths.add(
        DesignPath(
          id: 'sikku_row_$suffix',
          groupId: 'sikku_row_$suffix',
          commands: List.unmodifiable(commands),
          strokeColor: _pastelPalette[row % _pastelPalette.length],
          strokeWidth: 0.007,
        ),
      );
    }

    return GeneratedPattern(
      recipe: _dotGridRecipe(parabolicSikkuId, resolved),
      paths: List.unmodifiable(paths),
      grid: resolved.grid,
    );
  }

  GeneratedPattern _rangoliMotifs(PatternRecipe recipe) {
    final motif = _stringParameter(recipe, 'motif');
    final paths = switch (motif) {
      'floral_mandala' => [
        ..._petalRing(
          center: const DesignPoint(x: 0.5, y: 0.5),
          petalCount: 12,
          outerRadius: 0.34,
          petalWidth: 0.055,
          pathPrefix: 'mandala_outer',
        ),
        ..._petalRing(
          center: const DesignPoint(x: 0.5, y: 0.5),
          petalCount: 8,
          outerRadius: 0.22,
          petalWidth: 0.04,
          pathPrefix: 'mandala_inner',
        ),
        ..._petalRing(
          center: const DesignPoint(x: 0.5, y: 0.5),
          petalCount: 6,
          outerRadius: 0.1,
          petalWidth: 0.025,
          pathPrefix: 'mandala_center',
        ),
      ],
      'peacock' => _peacockMotif(),
      'paisley' => _paisleyMotif(),
      _ => throw FormatException('Unsupported Rangoli motif: $motif.'),
    };

    return GeneratedPattern(
      recipe: PatternRecipe(
        generatorId: rangoliMotifsId,
        version: recipeVersion,
        parameters: Map.unmodifiable({'motif': motif}),
      ),
      paths: List.unmodifiable(paths),
      grid: null,
    );
  }

  _ResolvedDotGrid _resolveDotGrid(PatternRecipe recipe) {
    final rows = _integerParameter(recipe, 'rows', minimum: 3, maximum: 15);
    final columns = _integerParameter(
      recipe,
      'columns',
      minimum: 3,
      maximum: 15,
    );
    if (rows.isEven || columns.isEven) {
      throw const FormatException(
        'Dot-grid recipes require odd row and column counts.',
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
    return _ResolvedDotGrid(
      rows: rows,
      columns: columns,
      margin: margin,
      grid: DotGrid(
        layout: resolvedLayout,
        rows: rows,
        columns: columns,
        dots: List.unmodifiable(dots),
      ),
    );
  }

  PatternRecipe _dotGridRecipe(String generatorId, _ResolvedDotGrid resolved) =>
      PatternRecipe(
        generatorId: generatorId,
        version: recipeVersion,
        parameters: Map.unmodifiable({
          'rows': resolved.rows,
          'columns': resolved.columns,
          'layout': resolved.grid.layout,
          'margin': resolved.margin,
        }),
      );

  List<DesignPath> _petalRing({
    required DesignPoint center,
    required int petalCount,
    required double outerRadius,
    required double petalWidth,
    required String pathPrefix,
  }) {
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
          id: '${pathPrefix}_path_$suffix',
          groupId: '${pathPrefix}_$suffix',
          commands: List.unmodifiable([
            _pointCommand(PathCommandType.moveTo, center),
            _cubicCommand(firstControl, secondControl, tip),
            _cubicCommand(thirdControl, fourthControl, center),
            const PathCommand(type: PathCommandType.close),
          ]),
          fillColor: _pastelPalette[index % _pastelPalette.length],
          strokeColor: _softOutline,
          strokeWidth: 0.006,
          shadowColor: '#B48275',
        ),
      );
    }
    return paths;
  }

  List<DesignPath> _peacockMotif() {
    const tailBase = DesignPoint(x: 0.56, y: 0.67);
    final paths = <DesignPath>[
      DesignPath(
        id: 'peacock_body_path',
        groupId: 'peacock_body',
        commands: List.unmodifiable([
          _pointCommand(
            PathCommandType.moveTo,
            const DesignPoint(x: 0.29, y: 0.68),
          ),
          _cubicCommand(
            const DesignPoint(x: 0.2, y: 0.55),
            const DesignPoint(x: 0.31, y: 0.42),
            const DesignPoint(x: 0.43, y: 0.43),
          ),
          _cubicCommand(
            const DesignPoint(x: 0.45, y: 0.31),
            const DesignPoint(x: 0.5, y: 0.26),
            const DesignPoint(x: 0.55, y: 0.34),
          ),
          _cubicCommand(
            const DesignPoint(x: 0.59, y: 0.36),
            const DesignPoint(x: 0.62, y: 0.34),
            const DesignPoint(x: 0.65, y: 0.3),
          ),
          _pointCommand(
            PathCommandType.lineTo,
            const DesignPoint(x: 0.68, y: 0.32),
          ),
          _cubicCommand(
            const DesignPoint(x: 0.65, y: 0.39),
            const DesignPoint(x: 0.62, y: 0.42),
            const DesignPoint(x: 0.59, y: 0.44),
          ),
          _cubicCommand(
            const DesignPoint(x: 0.72, y: 0.53),
            const DesignPoint(x: 0.72, y: 0.64),
            const DesignPoint(x: 0.63, y: 0.7),
          ),
          _cubicCommand(
            const DesignPoint(x: 0.51, y: 0.76),
            const DesignPoint(x: 0.38, y: 0.75),
            const DesignPoint(x: 0.29, y: 0.68),
          ),
          const PathCommand(type: PathCommandType.close),
        ]),
        fillColor: '#A9D7D1',
        strokeColor: _softOutline,
        strokeWidth: 0.006,
        shadowColor: '#719F96',
      ),
    ];

    for (var index = 0; index < 7; index++) {
      final angle = -math.pi * 0.88 + index * math.pi * 0.76 / 6;
      final directionX = math.cos(angle);
      final directionY = math.sin(angle);
      final normalX = -directionY;
      final normalY = directionX;
      const length = 0.34;
      const width = 0.024;
      final tip = DesignPoint(
        x: tailBase.x + length * directionX,
        y: tailBase.y + length * directionY,
      );
      final suffix = (index + 1).toString().padLeft(2, '0');
      paths.add(
        DesignPath(
          id: 'peacock_feather_$suffix',
          groupId: 'peacock_tail',
          commands: List.unmodifiable([
            _pointCommand(PathCommandType.moveTo, tailBase),
            _cubicCommand(
              DesignPoint(
                x: tailBase.x + length * 0.42 * directionX + width * normalX,
                y: tailBase.y + length * 0.42 * directionY + width * normalY,
              ),
              DesignPoint(
                x: tip.x - length * 0.18 * directionX + width * normalX,
                y: tip.y - length * 0.18 * directionY + width * normalY,
              ),
              tip,
            ),
            _cubicCommand(
              DesignPoint(
                x: tip.x - length * 0.18 * directionX - width * normalX,
                y: tip.y - length * 0.18 * directionY - width * normalY,
              ),
              DesignPoint(
                x: tailBase.x + length * 0.42 * directionX - width * normalX,
                y: tailBase.y + length * 0.42 * directionY - width * normalY,
              ),
              tailBase,
            ),
            const PathCommand(type: PathCommandType.close),
          ]),
          fillColor: _pastelPalette[index % _pastelPalette.length],
          strokeColor: _softOutline,
          strokeWidth: 0.0055,
          shadowColor: '#B48275',
        ),
      );
    }
    return paths;
  }

  List<DesignPath> _paisleyMotif() => [
    DesignPath(
      id: 'paisley_outline',
      groupId: 'paisley_body',
      commands: List.unmodifiable([
        _pointCommand(
          PathCommandType.moveTo,
          const DesignPoint(x: 0.49, y: 0.12),
        ),
        _cubicCommand(
          const DesignPoint(x: 0.69, y: 0.12),
          const DesignPoint(x: 0.86, y: 0.29),
          const DesignPoint(x: 0.82, y: 0.5),
        ),
        _cubicCommand(
          const DesignPoint(x: 0.79, y: 0.68),
          const DesignPoint(x: 0.63, y: 0.84),
          const DesignPoint(x: 0.45, y: 0.88),
        ),
        _cubicCommand(
          const DesignPoint(x: 0.3, y: 0.91),
          const DesignPoint(x: 0.18, y: 0.8),
          const DesignPoint(x: 0.2, y: 0.66),
        ),
        _cubicCommand(
          const DesignPoint(x: 0.22, y: 0.52),
          const DesignPoint(x: 0.37, y: 0.45),
          const DesignPoint(x: 0.51, y: 0.5),
        ),
        _cubicCommand(
          const DesignPoint(x: 0.61, y: 0.54),
          const DesignPoint(x: 0.69, y: 0.5),
          const DesignPoint(x: 0.67, y: 0.41),
        ),
        _cubicCommand(
          const DesignPoint(x: 0.65, y: 0.34),
          const DesignPoint(x: 0.59, y: 0.31),
          const DesignPoint(x: 0.54, y: 0.34),
        ),
        _cubicCommand(
          const DesignPoint(x: 0.58, y: 0.24),
          const DesignPoint(x: 0.57, y: 0.18),
          const DesignPoint(x: 0.49, y: 0.12),
        ),
        const PathCommand(type: PathCommandType.close),
      ]),
      fillColor: '#F4CBD2',
      strokeColor: _softOutline,
      strokeWidth: 0.006,
      shadowColor: '#B48275',
    ),
    DesignPath(
      id: 'paisley_inner_swirl',
      groupId: 'paisley_detail',
      commands: List.unmodifiable([
        _pointCommand(
          PathCommandType.moveTo,
          const DesignPoint(x: 0.36, y: 0.71),
        ),
        _cubicCommand(
          const DesignPoint(x: 0.34, y: 0.6),
          const DesignPoint(x: 0.44, y: 0.54),
          const DesignPoint(x: 0.54, y: 0.58),
        ),
        _cubicCommand(
          const DesignPoint(x: 0.64, y: 0.62),
          const DesignPoint(x: 0.63, y: 0.72),
          const DesignPoint(x: 0.55, y: 0.74),
        ),
        _cubicCommand(
          const DesignPoint(x: 0.48, y: 0.76),
          const DesignPoint(x: 0.45, y: 0.69),
          const DesignPoint(x: 0.5, y: 0.66),
        ),
      ]),
      strokeColor: '#B7884E',
      strokeWidth: 0.007,
    ),
  ];

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

  static PathCommand _quadraticCommand(DesignPoint control, DesignPoint end) =>
      PathCommand(
        type: PathCommandType.quadraticTo,
        controlX: control.x,
        controlY: control.y,
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

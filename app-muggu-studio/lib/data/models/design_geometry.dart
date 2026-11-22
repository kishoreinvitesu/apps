class DesignPoint {
  const DesignPoint({required this.x, required this.y});

  final double x;
  final double y;

  factory DesignPoint.fromJson(Object? value, String fieldName) {
    if (value is! List || value.length != 2) {
      throw FormatException('$fieldName must contain an x and y coordinate.');
    }
    final x = value[0];
    final y = value[1];
    if (x is! num || y is! num || !x.isFinite || !y.isFinite) {
      throw FormatException('$fieldName coordinates must be finite numbers.');
    }
    if (x < 0 || x > 1 || y < 0 || y > 1) {
      throw FormatException('$fieldName coordinates must be between 0 and 1.');
    }
    return DesignPoint(x: x.toDouble(), y: y.toDouble());
  }

  List<double> toJson() => [x, y];
}

enum PathCommandType { moveTo, lineTo, quadraticTo, cubicTo, arcTo, close }

const maxPathCommandCount = 4096;

class PathCommand {
  const PathCommand({
    required this.type,
    this.x,
    this.y,
    this.controlX,
    this.controlY,
    this.control1X,
    this.control1Y,
    this.control2X,
    this.control2Y,
    this.radiusX,
    this.radiusY,
    this.startAngle,
    this.sweepAngle,
  });

  final PathCommandType type;
  final double? x;
  final double? y;
  final double? controlX;
  final double? controlY;
  final double? control1X;
  final double? control1Y;
  final double? control2X;
  final double? control2Y;
  final double? radiusX;
  final double? radiusY;
  final double? startAngle;
  final double? sweepAngle;

  factory PathCommand.fromJson(Object? value, String fieldName) {
    if (value is! Map<String, dynamic>) {
      throw FormatException('$fieldName must be an object.');
    }
    final type = switch (value['type']) {
      'moveTo' => PathCommandType.moveTo,
      'lineTo' => PathCommandType.lineTo,
      'quadraticTo' => PathCommandType.quadraticTo,
      'cubicTo' => PathCommandType.cubicTo,
      'arcTo' => PathCommandType.arcTo,
      'close' => PathCommandType.close,
      _ => throw FormatException('$fieldName.type is unsupported.'),
    };

    double readCoordinate(String key) {
      final coordinate = value[key];
      if (coordinate is! num || !coordinate.isFinite) {
        throw FormatException('$fieldName.$key must be a finite number.');
      }
      final result = coordinate.toDouble();
      if (key == 'startAngle' || key == 'sweepAngle') {
        return result;
      }
      if (result < 0 || result > 1) {
        throw FormatException('$fieldName.$key must be between 0 and 1.');
      }
      return result;
    }

    bool hasFields(List<String> fields) => fields.every(value.containsKey);
    final requiredFields = switch (type) {
      PathCommandType.moveTo || PathCommandType.lineTo => ['x', 'y'],
      PathCommandType.quadraticTo => ['controlX', 'controlY', 'x', 'y'],
      PathCommandType.cubicTo => [
        'control1X',
        'control1Y',
        'control2X',
        'control2Y',
        'x',
        'y',
      ],
      PathCommandType.arcTo => [
        'x',
        'y',
        'radiusX',
        'radiusY',
        'startAngle',
        'sweepAngle',
      ],
      PathCommandType.close => const <String>[],
    };
    if (!hasFields(requiredFields)) {
      throw FormatException('$fieldName is missing required coordinates.');
    }

    final coordinates = <String, double>{
      for (final key in requiredFields) key: readCoordinate(key),
    };
    if (type == PathCommandType.arcTo &&
        (coordinates['radiusX'] == 0 || coordinates['radiusY'] == 0)) {
      throw FormatException('$fieldName arc radii must be greater than zero.');
    }
    return PathCommand(
      type: type,
      x: coordinates['x'],
      y: coordinates['y'],
      controlX: coordinates['controlX'],
      controlY: coordinates['controlY'],
      control1X: coordinates['control1X'],
      control1Y: coordinates['control1Y'],
      control2X: coordinates['control2X'],
      control2Y: coordinates['control2Y'],
      radiusX: coordinates['radiusX'],
      radiusY: coordinates['radiusY'],
      startAngle: coordinates['startAngle'],
      sweepAngle: coordinates['sweepAngle'],
    );
  }

  Map<String, dynamic> toJson() => {
    'type': type.name,
    if (x != null) 'x': x,
    if (y != null) 'y': y,
    if (controlX != null) 'controlX': controlX,
    if (controlY != null) 'controlY': controlY,
    if (control1X != null) 'control1X': control1X,
    if (control1Y != null) 'control1Y': control1Y,
    if (control2X != null) 'control2X': control2X,
    if (control2Y != null) 'control2Y': control2Y,
    if (radiusX != null) 'radiusX': radiusX,
    if (radiusY != null) 'radiusY': radiusY,
    if (startAngle != null) 'startAngle': startAngle,
    if (sweepAngle != null) 'sweepAngle': sweepAngle,
  };
}

class DesignPath {
  const DesignPath({
    required this.id,
    required this.groupId,
    required this.commands,
    this.fillColor,
  });

  final String id;
  final String groupId;
  final List<PathCommand> commands;
  final String? fillColor;

  factory DesignPath.fromJson(Object? value, String fieldName) {
    if (value is! Map<String, dynamic>) {
      throw FormatException('$fieldName must be an object.');
    }
    final id = value['id'];
    final groupId = value['groupId'];
    final rawCommands = value['commands'];
    final fillColor = value['fillColor'];
    if (id is! String ||
        !RegExp(r'^[a-z0-9_]+$').hasMatch(id) ||
        groupId is! String ||
        !RegExp(r'^[a-z0-9_]+$').hasMatch(groupId)) {
      throw FormatException(
        '$fieldName requires stable id and groupId values.',
      );
    }
    if (rawCommands is! List ||
        rawCommands.length < 2 ||
        rawCommands.length > maxPathCommandCount) {
      throw FormatException('$fieldName.commands must contain path commands.');
    }
    if (fillColor != null &&
        (fillColor is! String ||
            !RegExp(r'^#[0-9a-fA-F]{6}$').hasMatch(fillColor))) {
      throw FormatException('$fieldName.fillColor must be a #RRGGBB value.');
    }
    final commands = List<PathCommand>.unmodifiable([
      for (var index = 0; index < rawCommands.length; index++)
        PathCommand.fromJson(rawCommands[index], '$fieldName.commands[$index]'),
    ]);
    var hasDrawingSegment = false;
    var currentSubpathHasSegment = false;
    var currentSubpathIsClosed = false;
    for (var index = 0; index < commands.length; index++) {
      final command = commands[index];
      switch (command.type) {
        case PathCommandType.moveTo:
          if (fillColor != null &&
              currentSubpathHasSegment &&
              !currentSubpathIsClosed) {
            throw FormatException(
              '$fieldName filled subpaths must be closed before moveTo.',
            );
          }
          currentSubpathHasSegment = false;
          currentSubpathIsClosed = false;
        case PathCommandType.lineTo ||
            PathCommandType.quadraticTo ||
            PathCommandType.cubicTo ||
            PathCommandType.arcTo:
          if (index == 0) {
            throw FormatException(
              '$fieldName drawing commands must follow moveTo.',
            );
          }
          hasDrawingSegment = true;
          currentSubpathHasSegment = true;
          currentSubpathIsClosed = false;
        case PathCommandType.close:
          if (!currentSubpathHasSegment || currentSubpathIsClosed) {
            throw FormatException(
              '$fieldName close commands must follow an open subpath.',
            );
          }
          currentSubpathIsClosed = true;
      }
    }
    if (!hasDrawingSegment) {
      throw FormatException(
        '$fieldName.commands must start with moveTo and draw a segment.',
      );
    }
    if (fillColor != null && !currentSubpathIsClosed) {
      throw FormatException('$fieldName filled paths must be closed.');
    }
    return DesignPath(
      id: id,
      groupId: groupId,
      commands: commands,
      fillColor: fillColor as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'groupId': groupId,
    'commands': [for (final c in commands) c.toJson()],
    if (fillColor != null) 'fillColor': fillColor,
  };
}

class PatternRecipe {
  const PatternRecipe({
    required this.generatorId,
    required this.version,
    required this.parameters,
  });

  final String generatorId;
  final int version;
  final Map<String, Object?> parameters;

  factory PatternRecipe.fromJson(Object? value, String fieldName) {
    if (value is! Map<String, dynamic>) {
      throw FormatException('$fieldName must be an object.');
    }
    final generatorId = value['generatorId'];
    final version = value['version'];
    final rawParameters = value['parameters'];
    if (generatorId is! String ||
        !RegExp(r'^[a-z0-9_]+$').hasMatch(generatorId) ||
        version is! int ||
        version < 1 ||
        rawParameters is! Map<String, dynamic>) {
      throw FormatException(
        '$fieldName requires a generatorId, positive version and parameters.',
      );
    }
    for (final entry in rawParameters.entries) {
      final parameter = entry.value;
      if (parameter != null &&
          parameter is! String &&
          parameter is! bool &&
          parameter is! num) {
        throw FormatException(
          '$fieldName.parameters.${entry.key} must be a scalar value.',
        );
      }
      if (parameter is num && !parameter.isFinite) {
        throw FormatException(
          '$fieldName.parameters.${entry.key} must be finite.',
        );
      }
    }
    return PatternRecipe(
      generatorId: generatorId,
      version: version,
      parameters: Map.unmodifiable(rawParameters),
    );
  }

  Map<String, dynamic> toJson() => {
    'generatorId': generatorId,
    'version': version,
    'parameters': parameters,
  };
}

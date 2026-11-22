import 'dart:convert';

import '../../../data/models/design_geometry.dart';
import '../../../data/models/dot_grid.dart';
import '../../drawing/domain/drawn_stroke.dart';

enum CreationType {
  template,
  freehand;

  static CreationType fromName(String name) => switch (name) {
    'freehand' => CreationType.freehand,
    _ => CreationType.template,
  };
}

class UserCreation {
  UserCreation({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    required this.type,
    this.recipe,
    this.strokes,
    required List<DesignPath> paths,
    this.grid,
  }) : paths = List.unmodifiable(paths);

  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;
  final CreationType type;
  final PatternRecipe? recipe;
  final List<DrawnStroke>? strokes;
  final List<DesignPath> paths;
  final DotGrid? grid;

  UserCreation copyWith({
    String? id,
    String? title,
    DateTime? createdAt,
    DateTime? updatedAt,
    CreationType? type,
    PatternRecipe? recipe,
    List<DrawnStroke>? strokes,
    List<DesignPath>? paths,
    DotGrid? grid,
  }) {
    return UserCreation(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      type: type ?? this.type,
      recipe: recipe ?? this.recipe,
      strokes: strokes ?? this.strokes,
      paths: paths ?? this.paths,
      grid: grid ?? this.grid,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'created_at': createdAt.toUtc().microsecondsSinceEpoch,
    'updated_at': updatedAt.toUtc().microsecondsSinceEpoch,
    'type': type.name,
    'recipe_json': recipe != null ? jsonEncode(recipe!.toJson()) : null,
    'strokes_json': strokes != null
        ? jsonEncode([for (final s in strokes!) s.toJson()])
        : null,
    'paths_json': jsonEncode([for (final p in paths) p.toJson()]),
    'grid_json': grid != null ? jsonEncode(grid!.toJson()) : null,
  };

  factory UserCreation.fromMap(Map<String, dynamic> map) {
    final id = map['id'] as String;
    final title = map['title'] as String;
    final createdAt = DateTime.fromMicrosecondsSinceEpoch(
      map['created_at'] as int,
      isUtc: true,
    );
    final updatedAt = DateTime.fromMicrosecondsSinceEpoch(
      map['updated_at'] as int,
      isUtc: true,
    );
    final type = CreationType.fromName(map['type'] as String);

    PatternRecipe? recipe;
    if (map['recipe_json'] != null) {
      final recipeMap = jsonDecode(map['recipe_json'] as String);
      recipe = PatternRecipe.fromJson(recipeMap, 'recipe');
    }

    List<DrawnStroke>? strokes;
    if (map['strokes_json'] != null) {
      final strokeList = jsonDecode(map['strokes_json'] as String) as List;
      strokes = [
        for (final item in strokeList)
          DrawnStroke.fromJson(item as Map<String, dynamic>),
      ];
    }

    final pathList = jsonDecode(map['paths_json'] as String) as List;
    final paths = [
      for (var i = 0; i < pathList.length; i++)
        DesignPath.fromJson(pathList[i], 'paths[$i]'),
    ];

    DotGrid? grid;
    if (map['grid_json'] != null) {
      final gridMap = jsonDecode(map['grid_json'] as String);
      grid = DotGrid.fromJson(gridMap, 'grid');
    }

    return UserCreation(
      id: id,
      title: title,
      createdAt: createdAt,
      updatedAt: updatedAt,
      type: type,
      recipe: recipe,
      strokes: strokes,
      paths: paths,
      grid: grid,
    );
  }

  /// Converts a sequence of freehand drawn strokes into valid [DesignPath] geometry.
  static List<DesignPath> strokesToDesignPaths(List<DrawnStroke> strokes) {
    final result = <DesignPath>[];
    for (var i = 0; i < strokes.length; i++) {
      final stroke = strokes[i];
      if (stroke.points.isEmpty) continue;

      final commands = <PathCommand>[];
      commands.add(
        PathCommand(
          type: PathCommandType.moveTo,
          x: stroke.points.first.x,
          y: stroke.points.first.y,
        ),
      );

      if (stroke.points.length == 1) {
        commands.add(
          PathCommand(
            type: PathCommandType.lineTo,
            x: stroke.points.first.x,
            y: stroke.points.first.y,
          ),
        );
      } else {
        for (var p = 1; p < stroke.points.length; p++) {
          commands.add(
            PathCommand(
              type: PathCommandType.lineTo,
              x: stroke.points[p].x,
              y: stroke.points[p].y,
            ),
          );
        }
      }

      result.add(
        DesignPath(
          id: 'stroke_path_$i',
          groupId: 'user_strokes',
          commands: List.unmodifiable(commands),
        ),
      );
    }
    return List.unmodifiable(result);
  }
}

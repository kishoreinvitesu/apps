import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/design_geometry.dart';
import '../models/dot_grid.dart';
import '../models/muggu_design.dart';

const catalogAssetPath = 'assets/designs/catalog.json';
const catalogSchemaVersion = 3;
const supportedCatalogSchemaVersions = {2, catalogSchemaVersion};

enum DesignSort { recommended, name, difficulty }

class DesignFilters {
  const DesignFilters({
    this.region,
    this.tradition,
    this.technique,
    this.difficulty,
    this.grid,
  });

  final String? region;
  final String? tradition;
  final String? technique;
  final DesignDifficulty? difficulty;
  final DotGrid? grid;

  bool get isEmpty =>
      region == null &&
      tradition == null &&
      technique == null &&
      difficulty == null &&
      grid == null;

  int get activeCount => [
    region,
    tradition,
    technique,
    difficulty,
    grid,
  ].where((value) => value != null).length;

  bool matches(MugguDesign design) {
    return (region == null || design.region == region) &&
        (tradition == null || design.tradition == tradition) &&
        (technique == null || design.technique == technique) &&
        (difficulty == null || design.difficulty == difficulty) &&
        (grid == null || design.grid == grid);
  }
}

class DesignRepository {
  DesignRepository({AssetBundle? assetBundle})
    : _assetBundle = assetBundle ?? rootBundle;

  final AssetBundle _assetBundle;

  Future<List<MugguDesign>> loadCatalog() async {
    final source = await _assetBundle.loadString(catalogAssetPath);
    return parseCatalog(source);
  }

  static List<MugguDesign> parseCatalog(String source) {
    final Object? decoded;
    try {
      decoded = jsonDecode(source);
    } on FormatException catch (error) {
      throw FormatException('Invalid catalogue JSON: ${error.message}');
    }
    if (decoded is! Map<String, dynamic> ||
        decoded['schemaVersion'] is! int ||
        !supportedCatalogSchemaVersions.contains(decoded['schemaVersion']) ||
        decoded['designs'] is! List) {
      throw const FormatException(
        'Catalogue must have a supported schemaVersion and a designs list.',
      );
    }

    final schemaVersion = decoded['schemaVersion'] as int;
    final rawDesigns = decoded['designs'] as List;
    final designs = <MugguDesign>[];
    final ids = <String>{};
    for (var index = 0; index < rawDesigns.length; index++) {
      final rawDesign = rawDesigns[index];
      final normalizedDesign = schemaVersion == 2
          ? _migrateV2Design(rawDesign, 'designs[$index]')
          : rawDesign;
      final design = MugguDesign.fromJson(normalizedDesign, 'designs[$index]');
      if (!ids.add(design.id)) {
        throw FormatException('Duplicate design id: ${design.id}.');
      }
      designs.add(design);
    }
    return List.unmodifiable(designs);
  }

  static Object? _migrateV2Design(Object? value, String fieldName) {
    if (value is! Map<String, dynamic>) {
      return value;
    }
    final rawStrokes = value['strokes'];
    if (rawStrokes is! List) {
      throw FormatException('$fieldName.strokes must be a list in schema 2.');
    }
    final migratedPaths = <Map<String, Object?>>[];
    for (var index = 0; index < rawStrokes.length; index++) {
      final stroke = rawStrokes[index];
      if (stroke is! Map<String, dynamic> ||
          stroke['id'] is! String ||
          stroke['points'] is! List) {
        throw FormatException('$fieldName.strokes[$index] is invalid.');
      }
      final strokeId = stroke['id'] as String;
      final points = stroke['points'] as List;
      final commands = <Map<String, Object?>>[];
      for (var pointIndex = 0; pointIndex < points.length; pointIndex++) {
        final point = DesignPoint.fromJson(
          points[pointIndex],
          '$fieldName.strokes[$index].points[$pointIndex]',
        );
        commands.add({
          'type': pointIndex == 0 ? 'moveTo' : 'lineTo',
          'x': point.x,
          'y': point.y,
        });
      }
      if (stroke['closed'] == true) {
        commands.add({'type': 'close'});
      }
      migratedPaths.add({
        'id': strokeId,
        'groupId': strokeId,
        'commands': commands,
      });
    }

    final migratedSteps = <Map<String, Object?>>[];
    final rawSteps = value['lessonSteps'];
    if (rawSteps is! List) {
      throw FormatException('$fieldName.lessonSteps must be a list.');
    }
    for (var index = 0; index < rawSteps.length; index++) {
      final step = rawSteps[index];
      if (step is! Map<String, dynamic> || step['strokeIds'] is! List) {
        throw FormatException('$fieldName.lessonSteps[$index] is invalid.');
      }
      migratedSteps.add(
        {...step, 'groupIds': step['strokeIds']}..remove('strokeIds'),
      );
    }

    final migratedGrid = _migrateV2Grid(value['grid'], fieldName);
    return {
      ...value,
      'paths': migratedPaths,
      'lessonSteps': migratedSteps,
      'grid': migratedGrid,
      'recipe': null,
    }..remove('strokes');
  }

  static Object? _migrateV2Grid(Object? value, String fieldName) {
    if (value == null) {
      return null;
    }
    if (value is! Map<String, dynamic> ||
        value['rows'] is! int ||
        value['columns'] is! int) {
      throw FormatException('$fieldName.grid is invalid in schema 2.');
    }
    final rows = value['rows'] as int;
    final columns = value['columns'] as int;
    if (rows < 1 || columns < 1) {
      throw FormatException('$fieldName.grid dimensions must be positive.');
    }
    final margin = 0.12;
    final dots = <List<double>>[
      for (var row = 0; row < rows; row++)
        for (var column = 0; column < columns; column++)
          [
            columns == 1
                ? 0.5
                : margin + (1 - 2 * margin) * column / (columns - 1),
            rows == 1 ? 0.5 : margin + (1 - 2 * margin) * row / (rows - 1),
          ],
    ];
    return {
      'layout': rows == columns ? 'square' : 'rectangular',
      'rows': rows,
      'columns': columns,
      'dots': dots,
    };
  }

  static List<MugguDesign> query({
    required List<MugguDesign> designs,
    String searchQuery = '',
    DesignFilters filters = const DesignFilters(),
    DesignSort sort = DesignSort.recommended,
    String languageCode = 'en',
  }) {
    final terms = _normalize(searchQuery).split(RegExp(r'\s+'))
      ..removeWhere((term) => term.isEmpty);
    final result = designs.where((design) {
      if (!filters.matches(design)) {
        return false;
      }
      if (terms.isEmpty) {
        return true;
      }
      final searchableText = _normalize(
        [
          ...design.localizedName.values.values,
          ...design.localizedDescription.values.values,
          ...design.localizedTechnique.values.values,
          ...?design.localizedRegion?.values.values,
          ...?design.localizedTradition?.values.values,
          ...design.searchTags,
        ].join(' '),
      );
      return terms.every(searchableText.contains);
    }).toList();

    switch (sort) {
      case DesignSort.recommended:
        break;
      case DesignSort.name:
        result.sort(
          (left, right) => left
              .nameFor(languageCode)
              .toLowerCase()
              .compareTo(right.nameFor(languageCode).toLowerCase()),
        );
      case DesignSort.difficulty:
        result.sort(
          (left, right) =>
              left.difficulty.index.compareTo(right.difficulty.index),
        );
    }
    return result;
  }

  static String _normalize(String value) => value.trim().toLowerCase();
}

final designRepositoryProvider = Provider<DesignRepository>(
  (ref) => DesignRepository(),
);

final catalogProvider = FutureProvider<List<MugguDesign>>(
  (ref) => ref.watch(designRepositoryProvider).loadCatalog(),
);

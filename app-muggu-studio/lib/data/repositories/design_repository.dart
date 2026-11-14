import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/dot_grid.dart';
import '../models/muggu_design.dart';

const catalogAssetPath = 'assets/designs/catalog.json';

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
        decoded['schemaVersion'] != 1 ||
        decoded['designs'] is! List) {
      throw const FormatException(
        'Catalogue must have schemaVersion 1 and a designs list.',
      );
    }

    final rawDesigns = decoded['designs'] as List;
    final designs = <MugguDesign>[];
    final ids = <String>{};
    for (var index = 0; index < rawDesigns.length; index++) {
      final design = MugguDesign.fromJson(rawDesigns[index], 'designs[$index]');
      if (!ids.add(design.id)) {
        throw FormatException('Duplicate design id: ${design.id}.');
      }
      designs.add(design);
    }
    return List.unmodifiable(designs);
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

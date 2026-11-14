import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muggu_studio/data/models/dot_grid.dart';
import 'package:muggu_studio/data/models/muggu_design.dart';
import 'package:muggu_studio/data/repositories/design_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'bundled catalog has ten unassigned samples and decodable thumbnails',
    () async {
      final designs = await DesignRepository().loadCatalog();

      expect(designs, hasLength(10));
      for (final design in designs) {
        expect(design.region, isNull);
        expect(design.tradition, isNull);
        expect(design.contentReviewStatus, ContentReviewStatus.pending);
        expect(design.sourceOrPermission, contains('Original'));

        final bytes = await rootBundle.load(design.thumbnail);
        final codec = await ui.instantiateImageCodec(
          bytes.buffer.asUint8List(),
        );
        final frame = await codec.getNextFrame();
        expect(frame.image.width, 320);
        expect(frame.image.height, 320);
        codec.dispose();
      }
    },
  );

  test('search matches synonym tags and combined filters', () async {
    final designs = await DesignRepository().loadCatalog();

    final results = DesignRepository.query(
      designs: designs,
      searchQuery: 'TRIANGLE',
      filters: const DesignFilters(
        technique: 'geometric_lines',
        difficulty: DesignDifficulty.intermediate,
      ),
    );

    expect(results.map((design) => design.id), ['geometric_sample_005']);
    expect(
      DesignRepository.query(
        designs: designs,
        searchQuery: 'Geometric Sample 01',
      ).map((design) => design.id),
      ['geometric_sample_001'],
    );
  });

  test('catalog rejects duplicate IDs and invalid vector coordinates', () {
    const design = {
      'id': 'fixture_design',
      'localizedName': {'en': 'Fixture'},
      'localizedDescription': {'en': 'Test vector.'},
      'region': null,
      'tradition': null,
      'technique': 'geometric_lines',
      'difficulty': 'easy',
      'grid': {'rows': 5, 'columns': 5},
      'searchTags': ['fixture'],
      'thumbnail': 'assets/designs/thumbnails/fixture.webp',
      'strokes': [
        {
          'id': 'stroke_01',
          'points': [
            [0, 0],
            [1, 1],
          ],
          'closed': false,
        },
      ],
      'contentReview': {
        'status': 'pending',
        'reviewer': '',
        'sourceOrPermission': 'Test fixture.',
      },
    };
    final invalidDesign = {
      ...design,
      'strokes': [
        {
          'id': 'stroke_01',
          'points': [
            [0, 0],
            [1.2, 1],
          ],
          'closed': false,
        },
      ],
    };

    expect(
      () => DesignRepository.parseCatalog(
        jsonEncode({
          'schemaVersion': 1,
          'designs': [design, design],
        }),
      ),
      throwsFormatException,
    );
    expect(
      () => DesignRepository.parseCatalog(
        jsonEncode({
          'schemaVersion': 1,
          'designs': [invalidDesign],
        }),
      ),
      throwsFormatException,
    );
  });

  test('filters support region, tradition and dot-grid metadata', () async {
    const source = '''
      {
        "schemaVersion": 1,
        "designs": [
          {
            "id": "fixture_design",
            "localizedName": {"en": "Fixture"},
            "localizedDescription": {"en": "Test vector."},
            "region": "fixture-region",
            "tradition": "fixture-tradition",
            "technique": "geometric_lines",
            "difficulty": "easy",
            "grid": {"rows": 5, "columns": 5},
            "searchTags": ["fixture"],
            "thumbnail": "assets/designs/thumbnails/fixture.webp",
            "strokes": [
              {"id": "stroke_01", "points": [[0, 0], [1, 1]]}
            ],
            "contentReview": {
              "status": "reviewed",
              "reviewer": "test",
              "sourceOrPermission": "Test fixture."
            }
          }
        ]
      }
    ''';
    final designs = DesignRepository.parseCatalog(source);

    final matching = DesignRepository.query(
      designs: designs,
      filters: const DesignFilters(
        region: 'fixture-region',
        tradition: 'fixture-tradition',
        technique: 'geometric_lines',
        difficulty: DesignDifficulty.easy,
        grid: DotGrid(rows: 5, columns: 5),
      ),
    );
    final excluded = DesignRepository.query(
      designs: designs,
      filters: const DesignFilters(region: 'other-region'),
    );

    expect(matching, hasLength(1));
    expect(excluded, isEmpty);
  });
}

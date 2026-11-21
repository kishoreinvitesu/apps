import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muggu_studio/data/models/content_review.dart';
import 'package:muggu_studio/data/models/muggu_design.dart';
import 'package:muggu_studio/data/repositories/design_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'bundled catalog has twelve unassigned samples and decodable thumbnails',
    () async {
      final designs = await DesignRepository().loadCatalog();

      expect(designs, hasLength(12));
      for (final design in designs) {
        expect(design.region, isNull);
        expect(design.tradition, isNull);
        expect(design.rightsReview.status, ReviewStatus.pending);
        expect(design.culturalReview.status, ReviewStatus.pending);
        expect(design.isPublicationReady, isFalse);
        expect(design.hasReviewedLesson, isFalse);
        expect(design.lessonSteps, isEmpty);

        final bytes = await rootBundle.load(design.thumbnail);
        final codec = await ui.instantiateImageCodec(
          bytes.buffer.asUint8List(),
        );
        final frame = await codec.getNextFrame();
        expect(frame.image.width, 320);
        expect(frame.image.height, 320);
        codec.dispose();
      }
      final radialDesign = designs.singleWhere(
        (design) => design.id == 'generated_radial_001',
      );
      expect(radialDesign.recipe?.generatorId, 'radial_flower');
      expect(
        radialDesign.paths.first.commands.any(
          (command) => command.type.name == 'cubicTo',
        ),
        isTrue,
      );
      final dotGridDesign = designs.singleWhere(
        (design) => design.id == 'generated_dot_grid_001',
      );
      expect(dotGridDesign.grid?.dots, hasLength(25));
      expect(dotGridDesign.recipe?.generatorId, 'dot_grid_diamonds');
    },
  );

  test('search matches synonym tags and combined filters', () async {
    final designs = await DesignRepository().loadCatalog();

    final results = DesignRepository.query(
      designs: designs,
      searchQuery: 'TRIANGLE',
      filters: DesignFilters(
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
      'localizedName': {
        'en': 'Fixture',
        'te': 'Fixture Telugu test',
        'ta': 'Fixture Tamil test',
      },
      'localizedDescription': {
        'en': 'Test vector.',
        'te': 'Test vector Telugu',
        'ta': 'Test vector Tamil',
      },
      'region': null,
      'tradition': null,
      'technique': 'geometric_lines',
      'localizedTechnique': {'en': 'Geometric lines'},
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
      'rightsReview': {
        'status': 'pending',
        'reviewer': '',
        'evidence': 'Test fixture.',
      },
      'culturalReview': {'status': 'pending', 'reviewer': '', 'evidence': ''},
      'localizationReview': {
        'status': 'pending',
        'reviewer': '',
        'evidence': '',
      },
      'lessonReview': {'status': 'pending', 'reviewer': '', 'evidence': ''},
      'lessonSteps': [],
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
          'schemaVersion': 2,
          'designs': [design, design],
        }),
      ),
      throwsFormatException,
    );
    expect(
      () => DesignRepository.parseCatalog(
        jsonEncode({
          'schemaVersion': 2,
          'designs': [invalidDesign],
        }),
      ),
      throwsFormatException,
    );
  });

  test('filters support region, tradition and dot-grid metadata', () async {
    const source = '''
      {
        "schemaVersion": 2,
        "designs": [
          {
            "id": "fixture_design",
            "localizedName": {"en": "Fixture"},
            "localizedDescription": {"en": "Test vector."},
            "region": "fixture-region",
            "localizedRegion": {"en": "Fixture region"},
            "tradition": "fixture-tradition",
            "localizedTradition": {"en": "Fixture tradition"},
            "technique": "geometric_lines",
            "localizedTechnique": {"en": "Geometric lines"},
            "difficulty": "easy",
            "grid": {"rows": 5, "columns": 5},
            "searchTags": ["fixture"],
            "thumbnail": "assets/designs/thumbnails/fixture.webp",
            "strokes": [
              {"id": "stroke_01", "points": [[0, 0], [1, 1]]}
            ],
            "rightsReview": {
              "status": "approved",
              "reviewer": "test",
              "evidence": "Test fixture."
            },
            "culturalReview": {
              "status": "approved",
              "reviewer": "test",
              "evidence": "Test fixture."
            },
            "localizationReview": {
              "status": "pending",
              "reviewer": "",
              "evidence": ""
            },
            "lessonReview": {
              "status": "pending",
              "reviewer": "",
              "evidence": ""
            },
            "lessonSteps": []
          }
        ]
      }
    ''';
    final designs = DesignRepository.parseCatalog(source);

    final matching = DesignRepository.query(
      designs: designs,
      filters: DesignFilters(
        region: 'fixture-region',
        tradition: 'fixture-tradition',
        technique: 'geometric_lines',
        difficulty: DesignDifficulty.easy,
        grid: designs.single.grid,
      ),
    );
    final excluded = DesignRepository.query(
      designs: designs,
      filters: const DesignFilters(region: 'other-region'),
    );

    expect(matching, hasLength(1));
    expect(matching.single.isPublicationReady, isFalse);
    expect(excluded, isEmpty);
  });

  test('migrated lesson steps reference reusable geometry groups', () {
    final catalog = {
      'schemaVersion': 2,
      'designs': [
        {
          'id': 'fixture_design',
          'localizedName': {
            'en': 'Fixture',
            'te': 'Fixture Telugu test',
            'ta': 'Fixture Tamil test',
          },
          'localizedDescription': {
            'en': 'Test vector.',
            'te': 'Test vector Telugu',
            'ta': 'Test vector Tamil',
          },
          'region': null,
          'tradition': null,
          'technique': 'geometric_lines',
          'localizedTechnique': {
            'en': 'Geometric lines',
            'te': 'Geometric lines Telugu test',
            'ta': 'Geometric lines Tamil test',
          },
          'difficulty': 'easy',
          'grid': null,
          'searchTags': ['fixture'],
          'thumbnail': 'assets/designs/thumbnails/fixture.webp',
          'strokes': [
            {
              'id': 'stroke_01',
              'points': [
                [0, 0],
                [1, 1],
              ],
            },
            {
              'id': 'stroke_02',
              'points': [
                [0, 1],
                [1, 0],
              ],
            },
          ],
          'rightsReview': {
            'status': 'approved',
            'reviewer': 'test',
            'evidence': 'Test permission record.',
          },
          'culturalReview': {
            'status': 'approved',
            'reviewer': 'test',
            'evidence': 'Test review record.',
          },
          'localizationReview': {
            'status': 'approved',
            'reviewer': 'test',
            'evidence': 'Test localization review.',
          },
          'lessonReview': {
            'status': 'approved',
            'reviewer': 'test',
            'evidence': 'Test lesson validation.',
          },
          'lessonSteps': [
            {
              'id': 'step_01',
              'strokeIds': ['stroke_02'],
              'instruction': {
                'en': 'Fixture instruction.',
                'te': 'Fixture instruction Telugu',
                'ta': 'Fixture instruction Tamil',
              },
            },
          ],
        },
      ],
    };

    final design = DesignRepository.parseCatalog(jsonEncode(catalog)).single;
    expect(design.paths, hasLength(2));
    expect(design.lessonSteps, hasLength(1));
    expect(design.lessonSteps.single.groupIds, ['stroke_02']);
    expect(design.paths.last.groupId, 'stroke_02');
    expect(design.paths.last.commands.last.type.name, 'lineTo');
    expect(design.hasReviewedLesson, isTrue);

    final invalid = jsonDecode(jsonEncode(catalog)) as Map<String, dynamic>;
    final designs = invalid['designs'] as List<dynamic>;
    final rawDesign = designs.single as Map<String, dynamic>;
    final steps = rawDesign['lessonSteps'] as List<dynamic>;
    final step = steps.single as Map<String, dynamic>;
    step['strokeIds'] = ['unknown_stroke'];
    expect(
      () => DesignRepository.parseCatalog(jsonEncode(invalid)),
      throwsFormatException,
    );

    final missingTranslation =
        jsonDecode(jsonEncode(catalog)) as Map<String, dynamic>;
    final localizedDesigns = missingTranslation['designs'] as List<dynamic>;
    final localizedDesign = localizedDesigns.single as Map<String, dynamic>;
    final localizedName =
        localizedDesign['localizedName'] as Map<String, dynamic>;
    localizedName.remove('ta');
    expect(
      () => DesignRepository.parseCatalog(jsonEncode(missingTranslation)),
      throwsFormatException,
    );
  });
}

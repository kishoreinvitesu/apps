import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muggu_studio/data/models/muggu_design.dart';
import 'package:muggu_studio/data/repositories/design_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'all bundled designs have lessons, provenance, and decodable thumbnails',
    () async {
      final designs = await DesignRepository().loadCatalog();
      const referencedDesignIds = {
        'dot_grid_sample_001',
        'dot_grid_sample_002',
        'dot_grid_sample_003',
        'dot_grid_sample_004',
        'dot_grid_sample_005',
      };

      expect(designs, hasLength(67));
      for (final design in designs) {
        expect(design.isLessonPlayable, isTrue);
        expect(design.lessonSteps, isNotEmpty);
        expect(design.provenance.isSystemGenerated, isTrue);
        expect(
          design.provenance.sources.isNotEmpty,
          referencedDesignIds.contains(design.id),
        );
        final lessonGroups = design.lessonSteps
            .expand((step) => step.groupIds)
            .toSet();
        expect(lessonGroups, containsAll(design.geometryGroupIds));

        if (design.construction == DesignConstruction.dotGuided) {
          expect(design.grid, isNotNull);
          final gridDots = design.grid!.dots;
          for (final path in design.paths) {
            if (path.commands.any((command) => command.type.name == 'close')) {
              expect(path.fillColor, isNotNull);
            }
            for (final command in path.commands) {
              if (command.type.name == 'close') {
                continue;
              }
              expect(command.type.name, anyOf('moveTo', 'lineTo', 'cubicTo'));
              expect(
                gridDots.any((dot) => dot.x == command.x && dot.y == command.y),
                isTrue,
              );
            }
          }
        } else {
          expect(design.grid, isNull);
        }
        for (final step in design.lessonSteps) {
          expect(step.groupIds, isNotEmpty);
          expect(design.geometryGroupIds, containsAll(step.groupIds));
          expect(step.instruction.values.keys.toSet(), {'en', 'te', 'ta'});
        }

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
      expect(radialDesign.grid?.dots, hasLength(169));
      expect(radialDesign.recipe, isNull);
      final dotGridDesign = designs.singleWhere(
        (design) => design.id == 'generated_dot_grid_001',
      );
      expect(dotGridDesign.grid?.dots, hasLength(25));
      expect(dotGridDesign.recipe?.generatorId, 'dot_grid_diamonds');
      final pookalam = designs.singleWhere(
        (design) => design.id == 'art_pookalam_lotus_dawn',
      );
      expect(pookalam.construction, DesignConstruction.illustrated);
      expect(pookalam.paths.any((path) => path.fillColor != null), isTrue);
      expect(pookalam.backgroundColor, '#FFF8EE');
    },
  );

  test('catalog requires playable lessons and valid provenance URLs', () async {
    final catalog = jsonDecode(
      await rootBundle.loadString(catalogAssetPath),
    ) as Map<String, dynamic>;
    final designs = (catalog['designs'] as List).cast<Map<String, dynamic>>();
    final firstDesign = Map<String, dynamic>.from(designs.first);

    expect(
      () => DesignRepository.parseCatalog(
        jsonEncode({
          ...catalog,
          'designs': [
            {...firstDesign, 'lessonSteps': <Object>[]},
          ],
        }),
      ),
      throwsFormatException,
    );

    expect(
      () => DesignRepository.parseCatalog(
        jsonEncode({
          ...catalog,
          'designs': [
            {
              ...firstDesign,
              'provenance': {
                'origin': 'system_generated',
                'sources': ['javascript:alert(1)'],
              },
            },
          ],
        }),
      ),
      throwsFormatException,
    );
  });

  test(
    'dot-guided schema 5 requires every path endpoint to use a grid dot',
    () async {
      final catalog = jsonDecode(
        await rootBundle.loadString(catalogAssetPath),
      ) as Map<String, dynamic>;
      final catalogDesigns = catalog['designs'] as List;
      final firstDesign = Map<String, dynamic>.from(
        catalogDesigns.cast<Map<String, dynamic>>().firstWhere(
          (design) => design['construction'] == 'dot_guided',
        ),
      );

      expect(
        () => DesignRepository.parseCatalog(
          jsonEncode({
            ...catalog,
            'designs': [
              {...firstDesign, 'grid': null},
            ],
          }),
        ),
        throwsFormatException,
      );

      final firstPath = Map<String, dynamic>.from(
        (firstDesign['paths'] as List).first as Map,
      );
      final commands = [
        for (final command in firstPath['commands'] as List)
          Map<String, dynamic>.from(command as Map),
      ];
      commands[0] = {...commands[0], 'x': 0.123, 'y': 0.123};
      firstPath['commands'] = commands;
      firstDesign['paths'] = [firstPath];

      expect(
        () => DesignRepository.parseCatalog(
          jsonEncode({
            ...catalog,
            'designs': [firstDesign],
          }),
        ),
        throwsFormatException,
      );
    },
  );

  test(
    'schema 3 infers illustrated construction when a design has no grid',
    () async {
      final catalog = jsonDecode(
        await rootBundle.loadString(catalogAssetPath),
      ) as Map<String, dynamic>;
      final rawDesigns = catalog['designs'] as List;
      final illustrated = Map<String, dynamic>.from(
        rawDesigns.cast<Map<String, dynamic>>().firstWhere(
          (design) => design['construction'] == 'illustrated',
        ),
      )..remove('construction');

      final migrated = DesignRepository.parseCatalog(
        jsonEncode({
          ...catalog,
          'schemaVersion': 3,
          'designs': [illustrated],
        }),
      ).single;

      expect(migrated.construction, DesignConstruction.illustrated);
      expect(migrated.grid, isNull);
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

    expect(results.map((design) => design.id), [
      'geometric_sample_005',
      'geometric_sample_006',
    ]);
    expect(
      DesignRepository.query(
        designs: designs,
        searchQuery: 'Eight-Point Compass',
      ).map((design) => design.id),
      ['geometric_sample_002'],
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
      'technique': 'geometric_lines',
      'localizedTechnique': {'en': 'Geometric lines'},
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
          'closed': false,
        },
      ],
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

  test('filters support technique, difficulty and dot-grid metadata', () async {
    const source = '''
      {
        "schemaVersion": 2,
        "designs": [
          {
            "id": "fixture_design",
            "localizedName": {"en": "Fixture"},
            "localizedDescription": {"en": "Test vector."},
            "technique": "geometric_lines",
            "localizedTechnique": {"en": "Geometric lines"},
            "difficulty": "easy",
            "grid": {"rows": 1, "columns": 2},
            "searchTags": ["fixture"],
            "thumbnail": "assets/designs/thumbnails/fixture.webp",
            "strokes": [
              {"id": "stroke_01", "points": [[0.12, 0.5], [0.88, 0.5]]}
            ],
            "lessonSteps": []
          }
        ]
      }
    ''';
    final designs = DesignRepository.parseCatalog(source);

    final matching = DesignRepository.query(
      designs: designs,
      filters: DesignFilters(
        technique: 'geometric_lines',
        difficulty: DesignDifficulty.easy,
        grid: designs.single.grid,
      ),
    );
    final excluded = DesignRepository.query(
      designs: designs,
      filters: const DesignFilters(technique: 'other-technique'),
    );

    expect(matching, hasLength(1));
    expect(matching.single.isLessonPlayable, isFalse);
    expect(excluded, isEmpty);
  });

  test('legacy lessons migrate and use the English translation fallback', () {
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
    expect(design.isLessonPlayable, isTrue);

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
    final fallbackDesign = DesignRepository.parseCatalog(
      jsonEncode(missingTranslation),
    ).single;
    expect(fallbackDesign.nameFor('ta'), 'Fixture');
  });
}

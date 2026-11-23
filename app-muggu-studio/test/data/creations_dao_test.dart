import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:muggu_studio/data/local/app_database.dart';
import 'package:muggu_studio/data/local/creations_dao.dart';
import 'package:muggu_studio/data/local/favorites_dao.dart';
import 'package:muggu_studio/data/models/design_geometry.dart';
import 'package:muggu_studio/data/models/dot_grid.dart';
import 'package:muggu_studio/features/create/application/pattern_generator_registry.dart';
import 'package:muggu_studio/features/creations/domain/user_creation.dart';
import 'package:muggu_studio/features/drawing/application/drawing_controller.dart';
import 'package:muggu_studio/features/drawing/domain/drawn_stroke.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(sqfliteFfiInit);

  UserCreation createSampleCreation({
    required String id,
    String title = 'Sample Muggu',
    CreationType type = CreationType.template,
  }) {
    final now = DateTime.now().toUtc();
    return UserCreation(
      id: id,
      title: title,
      createdAt: now,
      updatedAt: now,
      type: type,
      recipe: const PatternRecipe(
        generatorId: 'radial_flower',
        version: 1,
        parameters: {'petalCount': 8, 'outerRadius': 0.36, 'petalWidth': 0.095},
      ),
      paths: const [
        DesignPath(
          id: 'path_1',
          groupId: 'group_1',
          commands: [
            PathCommand(type: PathCommandType.moveTo, x: 0.1, y: 0.1),
            PathCommand(type: PathCommandType.lineTo, x: 0.9, y: 0.9),
          ],
        ),
      ],
      grid: DotGrid.rectangular(rows: 5, columns: 5),
    );
  }

  group('CreationsDao CRUD & persistence', () {
    test('save, list, load, update title and delete creations', () async {
      final directory = await Directory.systemTemp.createTemp(
        'muggu_creations_test_',
      );
      final databasePath =
          '${directory.path}${Platform.pathSeparator}creations.db';
      final database = AppDatabase(
        factory: databaseFactoryFfi,
        databasePath: databasePath,
      );
      addTearDown(() async {
        await database.close();
        await directory.delete(recursive: true);
      });

      final dao = CreationsDao(database);

      // Initially empty
      expect(await dao.listCreations(), isEmpty);

      // Save a creation
      final creation1 = createSampleCreation(id: 'c1', title: 'Flower 1');
      await dao.saveCreation(creation1);

      // List returns creation
      final list = await dao.listCreations();
      expect(list.length, 1);
      expect(list.first.id, 'c1');
      expect(list.first.title, 'Flower 1');
      expect(list.first.type, CreationType.template);
      expect(list.first.recipe?.generatorId, 'radial_flower');
      expect(list.first.paths.length, 1);
      expect(list.first.grid?.rows, 5);

      // Load by ID
      final loaded = await dao.loadCreation('c1');
      expect(loaded, isNotNull);
      expect(loaded!.id, 'c1');
      expect(loaded.title, 'Flower 1');

      // Non-existent ID returns null
      expect(await dao.loadCreation('unknown'), isNull);

      // Update title
      await dao.updateTitle('c1', 'Renamed Flower');
      final updated = await dao.loadCreation('c1');
      expect(updated!.title, 'Renamed Flower');

      // Delete creation
      await dao.deleteCreation('c1');
      expect(await dao.listCreations(), isEmpty);
      expect(await dao.loadCreation('c1'), isNull);
    });

    test(
      'saved geometry loads when its generator is no longer available',
      () async {
        final directory = await Directory.systemTemp.createTemp(
          'muggu_retired_generator_test_',
        );
        final databasePath =
            '${directory.path}${Platform.pathSeparator}creations.db';
        final database = AppDatabase(
          factory: databaseFactoryFfi,
          databasePath: databasePath,
        );
        addTearDown(() async {
          await database.close();
          await directory.delete(recursive: true);
        });

        final creation = createSampleCreation(id: 'retired_generator').copyWith(
          recipe: const PatternRecipe(
            generatorId: 'retired_generator',
            version: 1,
            parameters: {},
          ),
        );
        final dao = CreationsDao(database);
        await dao.saveCreation(creation);

        final loaded = await dao.loadCreation(creation.id);
        expect(loaded, isNotNull);
        final restored = loaded!;
        expect(
          () => const PatternGeneratorRegistry().generate(restored.recipe!),
          throwsFormatException,
        );
        expect(
          restored.paths.map((path) => path.toJson()).toList(),
          equals(creation.paths.map((path) => path.toJson()).toList()),
        );
      },
    );

    test(
      'unsupported recipe versions preserve saved geometry snapshots',
      () async {
        final directory = await Directory.systemTemp.createTemp(
          'muggu_unsupported_recipe_version_test_',
        );
        final databasePath =
            '${directory.path}${Platform.pathSeparator}creations.db';
        final database = AppDatabase(
          factory: databaseFactoryFfi,
          databasePath: databasePath,
        );
        addTearDown(() async {
          await database.close();
          await directory.delete(recursive: true);
        });

        final creation = createSampleCreation(id: 'unsupported_recipe_version')
            .copyWith(
              recipe: const PatternRecipe(
                generatorId: PatternGeneratorRegistry.radialFlowerId,
                version: PatternGeneratorRegistry.recipeVersion + 1,
                parameters: {'petalCount': 8},
              ),
            );
        final dao = CreationsDao(database);
        await dao.saveCreation(creation);

        final loaded = await dao.loadCreation(creation.id);
        expect(loaded, isNotNull);
        final restored = loaded!;
        expect(
          restored.recipe?.version,
          PatternGeneratorRegistry.recipeVersion + 1,
        );
        expect(
          () => const PatternGeneratorRegistry().generate(restored.recipe!),
          throwsFormatException,
        );
        expect(
          restored.paths.map((path) => path.toJson()).toList(),
          equals(creation.paths.map((path) => path.toJson()).toList()),
        );
      },
    );

    test('malformed persisted recipe JSON reports its field', () async {
      final directory = await Directory.systemTemp.createTemp(
        'muggu_invalid_recipe_json_test_',
      );
      final databasePath =
          '${directory.path}${Platform.pathSeparator}creations.db';
      final database = AppDatabase(
        factory: databaseFactoryFfi,
        databasePath: databasePath,
      );
      addTearDown(() async {
        await database.close();
        await directory.delete(recursive: true);
      });

      final dao = CreationsDao(database);
      final creation = createSampleCreation(id: 'invalid_recipe_json');
      await dao.saveCreation(creation);
      await (await database.database).update(
        'creations',
        {'recipe_json': '{invalid-json'},
        where: 'id = ?',
        whereArgs: [creation.id],
      );

      await expectLater(
        dao.loadCreation(creation.id),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'message',
            contains('recipe_json is invalid'),
          ),
        ),
      );
    });

    test('unsupported persisted creation types are rejected', () async {
      final directory = await Directory.systemTemp.createTemp(
        'muggu_invalid_creation_type_test_',
      );
      final databasePath =
          '${directory.path}${Platform.pathSeparator}creations.db';
      final database = AppDatabase(
        factory: databaseFactoryFfi,
        databasePath: databasePath,
      );
      addTearDown(() async {
        await database.close();
        await directory.delete(recursive: true);
      });

      final dao = CreationsDao(database);
      final creation = createSampleCreation(id: 'invalid_type');
      await dao.saveCreation(creation);
      await (await database.database).update(
        'creations',
        {'type': 'unrecognized'},
        where: 'id = ?',
        whereArgs: [creation.id],
      );

      await expectLater(dao.loadCreation(creation.id), throwsFormatException);
    });

    test('unsupported persisted stroke symmetry modes are rejected', () async {
      final directory = await Directory.systemTemp.createTemp(
        'muggu_invalid_stroke_symmetry_test_',
      );
      final databasePath =
          '${directory.path}${Platform.pathSeparator}creations.db';
      final database = AppDatabase(
        factory: databaseFactoryFfi,
        databasePath: databasePath,
      );
      addTearDown(() async {
        await database.close();
        await directory.delete(recursive: true);
      });

      final dao = CreationsDao(database);
      final creation = createSampleCreation(id: 'invalid_stroke_symmetry');
      await dao.saveCreation(creation);
      await (await database.database).update(
        'creations',
        {
          'strokes_json':
              '[{"points":[[0.2,0.2],[0.8,0.8]],"color":4294967295,'
              '"strokeWidth":4.0,"symmetryMode":"diagonal"}]',
        },
        where: 'id = ?',
        whereArgs: [creation.id],
      );

      await expectLater(
        dao.loadCreation(creation.id),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'message',
            contains('symmetryMode'),
          ),
        ),
      );
    });

    test('creations persist across database restarts', () async {
      final directory = await Directory.systemTemp.createTemp(
        'muggu_creations_restart_',
      );
      final databasePath =
          '${directory.path}${Platform.pathSeparator}restart.db';
      final db1 = AppDatabase(
        factory: databaseFactoryFfi,
        databasePath: databasePath,
      );
      final dao1 = CreationsDao(db1);

      final creation = createSampleCreation(
        id: 'restart_c',
        title: 'Persistent Muggu',
      );
      await dao1.saveCreation(creation);
      await db1.close();

      // Reopen database
      final db2 = AppDatabase(
        factory: databaseFactoryFfi,
        databasePath: databasePath,
      );
      addTearDown(() async {
        await db2.close();
        await directory.delete(recursive: true);
      });
      final dao2 = CreationsDao(db2);

      final loaded = await dao2.loadCreation('restart_c');
      expect(loaded, isNotNull);
      expect(loaded!.title, 'Persistent Muggu');
      expect(loaded.paths.length, 1);
    });

    test(
      'freehand strokes serialization and strokesToDesignPaths conversion',
      () {
        final stroke = DrawnStroke(
          points: const [
            DesignPoint(x: 0.2, y: 0.2),
            DesignPoint(x: 0.8, y: 0.8),
          ],
          color: DrawingPalette.turmericGold,
          strokeWidth: 4.0,
          symmetryMode: SymmetryMode.vertical,
        );

        final paths = UserCreation.strokesToDesignPaths([stroke]);
        expect(paths.length, 1);
        expect(paths.first.id, 'stroke_path_0');
        expect(paths.first.groupId, 'user_strokes');
        expect(paths.first.commands.length, 2);
        expect(paths.first.commands[0].type, PathCommandType.moveTo);
        expect(paths.first.commands[1].type, PathCommandType.lineTo);

        // Single point tap also produces at least 2 commands
        final dotStroke = DrawnStroke(
          points: const [DesignPoint(x: 0.5, y: 0.5)],
          color: DrawingPalette.riceFlourWhite,
          strokeWidth: 2.0,
        );
        final dotPaths = UserCreation.strokesToDesignPaths([dotStroke]);
        expect(dotPaths.first.commands.length, 2);
      },
    );

    test('database migration from v1 to v2 preserves favorites and enables creations', () async {
      final directory = await Directory.systemTemp.createTemp(
        'muggu_migration_test_',
      );
      final databasePath =
          '${directory.path}${Platform.pathSeparator}migration.db';

      // 1. Open database at Version 1 (simulate old app install)
      final rawDb = await databaseFactoryFfi.openDatabase(
        databasePath,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: (db, version) async {
            await db.execute('''
              CREATE TABLE favorites (
                design_id TEXT PRIMARY KEY NOT NULL,
                added_at INTEGER NOT NULL
              )
            ''');
          },
        ),
      );
      // Insert a favorite at v1
      await rawDb.insert('favorites', {
        'design_id': 'geometric_sample_001',
        'added_at': 1000000,
      });
      await rawDb.close();

      // 2. Open with modern AppDatabase (version 2)
      final appDb = AppDatabase(
        factory: databaseFactoryFfi,
        databasePath: databasePath,
      );
      addTearDown(() async {
        await appDb.close();
        await directory.delete(recursive: true);
      });

      // Verify favorites are preserved
      final favDao = FavoritesDao(appDb);
      expect(await favDao.favoriteDesignIds(), ['geometric_sample_001']);

      // Verify creations table is created and operational
      final creationsDao = CreationsDao(appDb);
      expect(await creationsDao.listCreations(), isEmpty);

      final creation = createSampleCreation(
        id: 'migrated_c',
        title: 'Post-Migration Creation',
      );
      await creationsDao.saveCreation(creation);
      expect(await creationsDao.listCreations(), hasLength(1));

      // Verify SQLite schema version is 2
      final rawUpgradedDb = await appDb.database;
      expect(await rawUpgradedDb.getVersion(), 2);
    });
  });
}

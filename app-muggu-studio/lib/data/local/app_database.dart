import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  AppDatabase({DatabaseFactory? factory, this.databasePath})
    : _factory = factory ?? databaseFactory;

  final DatabaseFactory _factory;
  final String? databasePath;
  Future<Database>? _database;

  Future<Database> get database async {
    final existing = _database;
    if (existing != null) {
      return existing;
    }

    final opening = _open();
    _database = opening;
    try {
      return await opening;
    } catch (error, stackTrace) {
      if (identical(_database, opening)) {
        _database = null;
      }
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  Future<Database> _open() async {
    final path = databasePath ?? '${await getDatabasesPath()}/muggu_studio.db';
    return _factory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 2,
        onCreate: (database, version) async {
          await database.execute('''
            CREATE TABLE favorites (
              design_id TEXT PRIMARY KEY NOT NULL,
              added_at INTEGER NOT NULL
            )
          ''');
          await _createCreationsTable(database);
        },
        onUpgrade: (database, oldVersion, newVersion) async {
          if (oldVersion < 2) {
            await _createCreationsTable(database);
          }
        },
      ),
    );
  }

  static Future<void> _createCreationsTable(DatabaseExecutor database) async {
    await database.execute('''
      CREATE TABLE creations (
        id TEXT PRIMARY KEY NOT NULL,
        title TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        type TEXT NOT NULL,
        recipe_json TEXT,
        strokes_json TEXT,
        paths_json TEXT NOT NULL,
        grid_json TEXT
      )
    ''');
    await database.execute('''
      CREATE INDEX idx_creations_updated_at ON creations(updated_at DESC)
    ''');
  }

  Future<void> close() async {
    final database = _database;
    if (database != null) {
      await (await database).close();
      _database = null;
    }
  }
}

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});

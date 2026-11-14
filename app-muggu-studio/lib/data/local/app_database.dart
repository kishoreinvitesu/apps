import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  AppDatabase({DatabaseFactory? factory, this.databasePath})
    : _factory = factory ?? databaseFactory;

  final DatabaseFactory _factory;
  final String? databasePath;
  Future<Database>? _database;

  Future<Database> get database => _database ??= _open();

  Future<Database> _open() async {
    final path = databasePath ?? '${await getDatabasesPath()}/muggu_studio.db';
    return _factory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (database, version) async {
          await database.execute('''
            CREATE TABLE favorites (
              design_id TEXT PRIMARY KEY NOT NULL,
              added_at INTEGER NOT NULL
            )
          ''');
        },
      ),
    );
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

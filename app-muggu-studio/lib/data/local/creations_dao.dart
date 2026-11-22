import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';

import '../../features/creations/domain/user_creation.dart';
import 'app_database.dart';

abstract interface class CreationsStore {
  Future<List<UserCreation>> listCreations();
  Future<UserCreation?> loadCreation(String id);
  Future<void> saveCreation(UserCreation creation);
  Future<void> updateTitle(String id, String newTitle);
  Future<void> deleteCreation(String id);
}

class CreationsDao implements CreationsStore {
  const CreationsDao(this._appDatabase);

  final AppDatabase _appDatabase;

  @override
  Future<List<UserCreation>> listCreations() async {
    final db = await _appDatabase.database;
    final rows = await db.query(
      'creations',
      orderBy: 'updated_at DESC',
    );
    return List.unmodifiable(rows.map((row) => UserCreation.fromMap(row)));
  }

  @override
  Future<UserCreation?> loadCreation(String id) async {
    final db = await _appDatabase.database;
    final rows = await db.query(
      'creations',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return UserCreation.fromMap(rows.first);
  }

  @override
  Future<void> saveCreation(UserCreation creation) async {
    final db = await _appDatabase.database;
    await db.insert(
      'creations',
      creation.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> updateTitle(String id, String newTitle) async {
    final db = await _appDatabase.database;
    await db.update(
      'creations',
      {
        'title': newTitle,
        'updated_at': DateTime.now().toUtc().microsecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> deleteCreation(String id) async {
    final db = await _appDatabase.database;
    await db.delete(
      'creations',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

final creationsDaoProvider = Provider<CreationsStore>(
  (ref) => CreationsDao(ref.watch(appDatabaseProvider)),
);

final creationsListProvider = FutureProvider<List<UserCreation>>(
  (ref) => ref.watch(creationsDaoProvider).listCreations(),
);

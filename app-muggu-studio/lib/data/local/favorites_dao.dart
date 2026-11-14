import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';

import 'app_database.dart';

abstract interface class FavoritesStore {
  Future<List<String>> favoriteDesignIds();
  Future<bool> toggleFavorite(String designId);
}

class FavoritesDao implements FavoritesStore {
  const FavoritesDao(this._appDatabase);

  final AppDatabase _appDatabase;

  @override
  Future<List<String>> favoriteDesignIds() async {
    final rows = await (await _appDatabase.database).query(
      'favorites',
      columns: ['design_id'],
      orderBy: 'added_at DESC',
    );
    return List.unmodifiable(rows.map((row) => row['design_id']! as String));
  }

  @override
  Future<bool> toggleFavorite(String designId) async {
    final database = await _appDatabase.database;
    return database.transaction((transaction) async {
      final existing = await transaction.query(
        'favorites',
        columns: ['design_id'],
        where: 'design_id = ?',
        whereArgs: [designId],
        limit: 1,
      );
      if (existing.isNotEmpty) {
        await transaction.delete(
          'favorites',
          where: 'design_id = ?',
          whereArgs: [designId],
        );
        return false;
      }

      await transaction.insert('favorites', {
        'design_id': designId,
        'added_at': DateTime.now().toUtc().microsecondsSinceEpoch,
      }, conflictAlgorithm: ConflictAlgorithm.abort);
      return true;
    });
  }
}

final favoritesDaoProvider = Provider<FavoritesStore>(
  (ref) => FavoritesDao(ref.watch(appDatabaseProvider)),
);

final favoriteIdsProvider = FutureProvider<List<String>>(
  (ref) => ref.watch(favoritesDaoProvider).favoriteDesignIds(),
);

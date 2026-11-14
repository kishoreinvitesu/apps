import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:muggu_studio/data/local/app_database.dart';
import 'package:muggu_studio/data/local/favorites_dao.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(sqfliteFfiInit);

  test('favourites persist across database instances and toggle off', () async {
    final directory = await Directory.systemTemp.createTemp(
      'muggu_favorites_test_',
    );
    addTearDown(() => directory.delete(recursive: true));
    final databasePath = '${directory.path}\\favorites.db';
    final firstDatabase = AppDatabase(
      factory: databaseFactoryFfi,
      databasePath: databasePath,
    );
    addTearDown(firstDatabase.close);
    final firstDao = FavoritesDao(firstDatabase);

    expect(await firstDao.favoriteDesignIds(), isEmpty);
    expect(await firstDao.toggleFavorite('geometric_sample_001'), isTrue);
    await firstDatabase.close();

    final reopenedDatabase = AppDatabase(
      factory: databaseFactoryFfi,
      databasePath: databasePath,
    );
    addTearDown(reopenedDatabase.close);
    final reopenedDao = FavoritesDao(reopenedDatabase);
    expect(await reopenedDao.favoriteDesignIds(), ['geometric_sample_001']);
    expect(await reopenedDao.toggleFavorite('geometric_sample_001'), isFalse);
    expect(await reopenedDao.favoriteDesignIds(), isEmpty);
  });
}

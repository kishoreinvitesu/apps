import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:muggu_studio/core/localization/locale_controller.dart';
import 'package:muggu_studio/core/preferences/preferences_storage.dart';
import 'package:muggu_studio/core/preferences/user_preferences.dart';
import 'package:muggu_studio/data/local/app_database.dart';
import 'package:muggu_studio/features/settings/presentation/settings_screen.dart';
import 'package:muggu_studio/l10n/generated/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class _MemoryLocaleStorage implements LocaleStorage {
  String? languageCode;

  @override
  Future<String?> readLanguageCode() async => languageCode;

  @override
  Future<void> writeLanguageCode(String languageCode) async {
    this.languageCode = languageCode;
  }

  @override
  Future<void> clearLanguageCode() async {
    languageCode = null;
  }
}

class _MemoryAppDatabase extends AppDatabase {
  _MemoryAppDatabase() : super(factory: databaseFactoryFfi);

  bool cleared = false;

  @override
  Future<void> clearUserData() async {
    cleared = true;
  }
}

void main() {
  setUpAll(sqfliteFfiInit);

  testWidgets('clear local data clears stores and resets locale', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final sharedPreferences = await SharedPreferences.getInstance();
    final preferencesStorage = SharedPreferencesStorage(sharedPreferences);
    await preferencesStorage.savePreferences(
      const UserPreferences(
        languageCode: 'te',
        interests: {InterestOption.kolam},
        onboardingComplete: true,
      ),
    );
    final localeStorage = _MemoryLocaleStorage()..languageCode = 'te';
    final database = _MemoryAppDatabase();

    final router = GoRouter(
      initialLocation: '/settings',
      routes: [
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
          path: '/onboarding',
          builder: (context, state) => Scaffold(
            body: Center(child: Text(AppLocalizations.of(context)!.getStarted)),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          preferencesStorageProvider.overrideWithValue(preferencesStorage),
          localeStorageProvider.overrideWithValue(localeStorage),
          initialLocaleProvider.overrideWithValue(const Locale('te')),
        ],
        child: Consumer(
          builder: (context, ref, _) => MaterialApp.router(
            locale: ref.watch(localeProvider),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: [
              AppLocalizations.delegate,
              ...GlobalMaterialLocalizations.delegates,
            ],
            routerConfig: router,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final localizations = AppLocalizations.of(
      tester.element(find.byType(SettingsScreen)),
    )!;
    await tester.scrollUntilVisible(find.text(localizations.dataSection), 250);
    await tester.pumpAndSettle();
    final clearAction = find.text(localizations.clearLocalData).first;
    await tester.tap(clearAction);
    await tester.pumpAndSettle();
    await tester.tap(find.text(localizations.clearLocalData).last);
    await tester.pumpAndSettle();

    expect(database.cleared, isTrue);
    expect(await preferencesStorage.readPreferences(), const UserPreferences());
    expect(await localeStorage.readLanguageCode(), isNull);
    expect(find.text('Get started'), findsOneWidget);
  });
}

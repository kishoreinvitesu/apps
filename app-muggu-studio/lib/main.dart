import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'core/localization/locale_controller.dart';
import 'core/localization/shared_preferences_locale_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final localeStorage = SharedPreferencesLocaleStorage(
    SharedPreferencesAsync(),
  );
  final storedLanguageCode = await localeStorage.readLanguageCode();
  final initialLocale = supportedLocales.firstWhere(
    (locale) => locale.languageCode == storedLanguageCode,
    orElse: () => const Locale('en'),
  );

  runApp(
    ProviderScope(
      overrides: [
        localeStorageProvider.overrideWithValue(localeStorage),
        initialLocaleProvider.overrideWithValue(initialLocale),
      ],
      child: const MugguStudioApp(),
    ),
  );
}

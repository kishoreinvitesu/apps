import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

abstract interface class LocaleStorage {
  Future<String?> readLanguageCode();

  Future<void> writeLanguageCode(String languageCode);
}

final localeStorageProvider = Provider<LocaleStorage>(
  (ref) => throw StateError('LocaleStorage must be provided at app startup.'),
);

final initialLocaleProvider = Provider<Locale>((ref) => const Locale('en'));

final localeProvider = NotifierProvider<LocaleController, Locale>(
  LocaleController.new,
);

const supportedLocales = <Locale>[Locale('en'), Locale('te'), Locale('ta')];

class LocaleController extends Notifier<Locale> {
  @override
  Locale build() => ref.watch(initialLocaleProvider);

  Future<void> setLocale(Locale locale) async {
    if (!supportedLocales.contains(locale)) {
      throw ArgumentError.value(locale, 'locale', 'Unsupported app locale.');
    }

    await ref
        .read(localeStorageProvider)
        .writeLanguageCode(locale.languageCode);
    state = locale;
  }
}

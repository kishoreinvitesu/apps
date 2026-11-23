import 'package:shared_preferences/shared_preferences.dart';

import 'locale_controller.dart';

class SharedPreferencesLocaleStorage implements LocaleStorage {
  SharedPreferencesLocaleStorage(this._preferences);

  static const _languageCodeKey = 'muggu_studio.language_code';

  final SharedPreferencesAsync _preferences;

  @override
  Future<String?> readLanguageCode() =>
      _preferences.getString(_languageCodeKey);

  @override
  Future<void> writeLanguageCode(String languageCode) =>
      _preferences.setString(_languageCodeKey, languageCode);

  @override
  Future<void> clearLanguageCode() => _preferences.remove(_languageCodeKey);
}

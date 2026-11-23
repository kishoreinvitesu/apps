import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'user_preferences.dart';

// ── Keys ──────────────────────────────────────────────────────────────────────
const _kLanguageCode = 'prefs_language_code';
const _kInterests = 'prefs_interests';
const _kExperienceLevel = 'prefs_experience_level';
const _kOnboardingComplete = 'prefs_onboarding_complete';

// ── Abstract interface ────────────────────────────────────────────────────────
abstract class PreferencesStorage {
  Future<UserPreferences> readPreferences();
  Future<void> savePreferences(UserPreferences prefs);
  Future<void> clearPreferences();
}

// ── SharedPreferences implementation ──────────────────────────────────────────
class SharedPreferencesStorage implements PreferencesStorage {
  SharedPreferencesStorage(this._prefs);

  final SharedPreferences _prefs;

  @override
  Future<UserPreferences> readPreferences() async {
    final langCode = _prefs.getString(_kLanguageCode) ?? 'en';

    final interestStrings = _prefs.getStringList(_kInterests);
    final interests = interestStrings == null
        ? const <InterestOption>{InterestOption.all}
        : interestStrings
              .map((s) => _parseInterest(s))
              .whereType<InterestOption>()
              .toSet();

    final levelStr = _prefs.getString(_kExperienceLevel);
    final level = _parseLevel(levelStr) ?? ExperienceLevel.beginner;

    final complete = _prefs.getBool(_kOnboardingComplete) ?? false;

    return UserPreferences(
      languageCode: langCode,
      interests: interests.isEmpty ? {InterestOption.all} : interests,
      experienceLevel: level,
      onboardingComplete: complete,
    );
  }

  @override
  Future<void> savePreferences(UserPreferences prefs) async {
    await _prefs.setString(_kLanguageCode, prefs.languageCode);
    await _prefs.setStringList(
      _kInterests,
      prefs.interests.map((i) => i.name).toList(),
    );
    await _prefs.setString(_kExperienceLevel, prefs.experienceLevel.name);
    await _prefs.setBool(_kOnboardingComplete, prefs.onboardingComplete);
  }

  @override
  Future<void> clearPreferences() async {
    await _prefs.remove(_kLanguageCode);
    await _prefs.remove(_kInterests);
    await _prefs.remove(_kExperienceLevel);
    await _prefs.remove(_kOnboardingComplete);
  }

  InterestOption? _parseInterest(String s) {
    try {
      return InterestOption.values.byName(s);
    } catch (_) {
      return null;
    }
  }

  ExperienceLevel? _parseLevel(String? s) {
    if (s == null) return null;
    try {
      return ExperienceLevel.values.byName(s);
    } catch (_) {
      return null;
    }
  }
}

// ── Providers ─────────────────────────────────────────────────────────────────

/// Low-level storage provider.  Requires [SharedPreferences] to be initialised.
final preferencesStorageProvider = Provider<PreferencesStorage>((ref) {
  throw UnimplementedError(
    'preferencesStorageProvider must be overridden in main() '
    'after SharedPreferences.getInstance().',
  );
});

/// Async state notifier that holds the current [UserPreferences].
class UserPreferencesNotifier extends AsyncNotifier<UserPreferences> {
  @override
  Future<UserPreferences> build() async {
    return ref.read(preferencesStorageProvider).readPreferences();
  }

  Future<void> savePrefs(UserPreferences updated) async {
    await ref.read(preferencesStorageProvider).savePreferences(updated);
    state = AsyncData(updated);
  }

  Future<void> markOnboardingComplete() async {
    final current = state.asData?.value ?? const UserPreferences();
    await savePrefs(current.copyWith(onboardingComplete: true));
  }

  Future<void> clearAll() async {
    await ref.read(preferencesStorageProvider).clearPreferences();
    state = const AsyncData(UserPreferences());
  }
}

final userPreferencesProvider =
    AsyncNotifierProvider<UserPreferencesNotifier, UserPreferences>(
      UserPreferencesNotifier.new,
    );

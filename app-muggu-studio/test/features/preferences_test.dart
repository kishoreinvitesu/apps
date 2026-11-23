import 'package:flutter_test/flutter_test.dart';
import 'package:muggu_studio/core/preferences/preferences_storage.dart';
import 'package:muggu_studio/core/preferences/user_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('SharedPreferencesStorage', () {
    test('returns default preferences when nothing stored', () async {
      final prefs = await SharedPreferences.getInstance();
      final storage = SharedPreferencesStorage(prefs);

      final result = await storage.readPreferences();

      expect(result.languageCode, 'en');
      expect(result.interests, {InterestOption.all});
      expect(result.experienceLevel, ExperienceLevel.beginner);
      expect(result.onboardingComplete, false);
    });

    test('round-trips full preferences correctly', () async {
      final prefs = await SharedPreferences.getInstance();
      final storage = SharedPreferencesStorage(prefs);

      const toSave = UserPreferences(
        languageCode: 'te',
        interests: {InterestOption.muggu, InterestOption.kolam},
        experienceLevel: ExperienceLevel.experienced,
        onboardingComplete: true,
      );

      await storage.savePreferences(toSave);
      final loaded = await storage.readPreferences();

      expect(loaded.languageCode, 'te');
      expect(loaded.interests, {InterestOption.muggu, InterestOption.kolam});
      expect(loaded.experienceLevel, ExperienceLevel.experienced);
      expect(loaded.onboardingComplete, true);
    });

    test('clearPreferences resets to defaults', () async {
      final prefs = await SharedPreferences.getInstance();
      final storage = SharedPreferencesStorage(prefs);

      await storage.savePreferences(
        const UserPreferences(languageCode: 'ta', onboardingComplete: true),
      );
      await storage.clearPreferences();
      final result = await storage.readPreferences();

      expect(result.languageCode, 'en');
      expect(result.onboardingComplete, false);
    });

    test('selecting all resets specific interests to all', () async {
      final prefs = await SharedPreferences.getInstance();
      final storage = SharedPreferencesStorage(prefs);

      await storage.savePreferences(
        const UserPreferences(interests: {InterestOption.all}),
      );
      final result = await storage.readPreferences();

      expect(result.interests, {InterestOption.all});
    });

    test('falls back to all when empty interest list stored', () async {
      SharedPreferences.setMockInitialValues({'prefs_interests': <String>[]});
      final prefs = await SharedPreferences.getInstance();
      final storage = SharedPreferencesStorage(prefs);

      final result = await storage.readPreferences();

      expect(result.interests, {InterestOption.all});
    });
  });

  group('UserPreferences', () {
    test('copyWith produces independent copy', () {
      const original = UserPreferences(
        languageCode: 'en',
        onboardingComplete: false,
      );
      final modified = original.copyWith(
        languageCode: 'te',
        onboardingComplete: true,
      );

      expect(original.languageCode, 'en');
      expect(modified.languageCode, 'te');
      expect(modified.onboardingComplete, true);
    });

    test('equality holds for identical prefs', () {
      const a = UserPreferences(
        languageCode: 'ta',
        interests: {InterestOption.kolam},
        experienceLevel: ExperienceLevel.experienced,
        onboardingComplete: true,
      );
      const b = UserPreferences(
        languageCode: 'ta',
        interests: {InterestOption.kolam},
        experienceLevel: ExperienceLevel.experienced,
        onboardingComplete: true,
      );
      expect(a, equals(b));
    });

    test('equality fails for different language codes', () {
      const a = UserPreferences(languageCode: 'en');
      const b = UserPreferences(languageCode: 'te');
      expect(a, isNot(equals(b)));
    });
  });
}

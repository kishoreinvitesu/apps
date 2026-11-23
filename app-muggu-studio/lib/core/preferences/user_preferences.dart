// Core data classes for user preferences persisted on first-run onboarding.

enum InterestOption { muggu, kolam, rangoli, all }

enum ExperienceLevel { beginner, experienced }

class UserPreferences {
  const UserPreferences({
    this.languageCode = 'en',
    this.interests = const {InterestOption.all},
    this.experienceLevel = ExperienceLevel.beginner,
    this.onboardingComplete = false,
  });

  final String languageCode;
  final Set<InterestOption> interests;
  final ExperienceLevel experienceLevel;
  final bool onboardingComplete;

  UserPreferences copyWith({
    String? languageCode,
    Set<InterestOption>? interests,
    ExperienceLevel? experienceLevel,
    bool? onboardingComplete,
  }) {
    return UserPreferences(
      languageCode: languageCode ?? this.languageCode,
      interests: interests ?? this.interests,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserPreferences &&
          runtimeType == other.runtimeType &&
          languageCode == other.languageCode &&
          _setsEqual(interests, other.interests) &&
          experienceLevel == other.experienceLevel &&
          onboardingComplete == other.onboardingComplete;

  @override
  int get hashCode => Object.hash(
        languageCode,
        Object.hashAll(interests),
        experienceLevel,
        onboardingComplete,
      );

  bool _setsEqual(Set<InterestOption> a, Set<InterestOption> b) {
    if (a.length != b.length) return false;
    return a.containsAll(b);
  }
}

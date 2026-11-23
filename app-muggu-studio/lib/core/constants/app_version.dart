/// Centralized application version metadata.
class AppVersion {
  const AppVersion._();

  /// Semantic version string matching pubspec.yaml.
  static const String version = '1.0.0';

  /// Build number matching pubspec.yaml.
  static const String buildNumber = '1';

  /// Development environment/phase label.
  static const String stage = 'dev';

  /// User-facing display string, e.g. "v1.0.0+1 (dev)".
  static const String display = 'v$version+$buildNumber ($stage)';
}

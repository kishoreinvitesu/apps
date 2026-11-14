class LocalizedText {
  const LocalizedText(this.values);

  final Map<String, String> values;

  String forLanguage(String languageCode) {
    return values[languageCode] ?? values['en'] ?? values.values.first;
  }

  factory LocalizedText.fromJson(Object? value, String fieldName) {
    if (value is! Map<String, dynamic> || value.isEmpty) {
      throw FormatException('$fieldName must be a non-empty object.');
    }

    final values = <String, String>{};
    for (final entry in value.entries) {
      if (entry.value is! String || (entry.value as String).trim().isEmpty) {
        throw FormatException(
          '$fieldName.${entry.key} must be a non-empty string.',
        );
      }
      values[entry.key] = entry.value as String;
    }
    if (!values.containsKey('en')) {
      throw FormatException('$fieldName must include an English fallback.');
    }

    return LocalizedText(Map.unmodifiable(values));
  }
}

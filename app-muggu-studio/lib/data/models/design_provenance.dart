class DesignProvenance {
  const DesignProvenance({
    required this.origin,
    required this.sources,
    this.note,
  });

  final String origin;
  final List<String> sources;
  final String? note;

  bool get isSystemGenerated => origin == 'system_generated';

  factory DesignProvenance.fromJson(Object? value, String fieldName) {
    if (value is! Map<String, dynamic>) {
      throw FormatException('$fieldName must be an object.');
    }

    final origin = value['origin'];
    final rawSources = value['sources'];
    final note = value['note'];
    if (origin is! String ||
        !{'system_generated', 'reference_based'}.contains(origin)) {
      throw FormatException(
        '$fieldName.origin must be system_generated or reference_based.',
      );
    }
    if (rawSources is! List ||
        rawSources.any((source) {
          if (source is! String) {
            return true;
          }
          return !_isHttpUrl(source);
        })) {
      throw FormatException(
        '$fieldName.sources must contain absolute HTTP or HTTPS URLs.',
      );
    }
    if (note != null && (note is! String || note.trim().isEmpty)) {
      throw FormatException('$fieldName.note must be a non-empty string.');
    }
    if (origin == 'reference_based' && rawSources.isEmpty) {
      throw FormatException(
        '$fieldName requires at least one source for reference-based artwork.',
      );
    }

    return DesignProvenance(
      origin: origin,
      sources: List.unmodifiable(rawSources.cast<String>()),
      note: note is String ? note : null,
    );
  }

  static bool _isHttpUrl(String value) {
    final uri = Uri.tryParse(value);
    return uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
  }
}

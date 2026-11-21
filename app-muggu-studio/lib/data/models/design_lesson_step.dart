import 'localized_text.dart';

class DesignLessonStep {
  const DesignLessonStep({
    required this.id,
    required this.strokeIds,
    required this.instruction,
  });

  final String id;
  final List<String> strokeIds;
  final LocalizedText instruction;

  factory DesignLessonStep.fromJson(Object? value, String fieldName) {
    if (value is! Map<String, dynamic>) {
      throw FormatException('$fieldName must be an object.');
    }
    final id = value['id'];
    final rawStrokeIds = value['strokeIds'];
    if (id is! String || !RegExp(r'^[a-z0-9_]+$').hasMatch(id)) {
      throw FormatException('$fieldName.id must be a stable identifier.');
    }
    if (rawStrokeIds is! List ||
        rawStrokeIds.isEmpty ||
        rawStrokeIds.any(
          (strokeId) => strokeId is! String || strokeId.trim().isEmpty,
        )) {
      throw FormatException(
        '$fieldName.strokeIds must contain at least one stroke id.',
      );
    }
    final strokeIds = rawStrokeIds.cast<String>();
    if (strokeIds.toSet().length != strokeIds.length) {
      throw FormatException(
        '$fieldName.strokeIds must not contain duplicates.',
      );
    }

    return DesignLessonStep(
      id: id,
      strokeIds: List.unmodifiable(strokeIds),
      instruction: LocalizedText.fromJson(
        value['instruction'],
        '$fieldName.instruction',
      ),
    );
  }
}

import 'localized_text.dart';

class DesignLessonStep {
  const DesignLessonStep({
    required this.id,
    required this.groupIds,
    required this.instruction,
  });

  final String id;
  final List<String> groupIds;
  final LocalizedText instruction;

  factory DesignLessonStep.fromJson(Object? value, String fieldName) {
    if (value is! Map<String, dynamic>) {
      throw FormatException('$fieldName must be an object.');
    }
    final id = value['id'];
    final rawGroupIds = value['groupIds'];
    if (id is! String || !RegExp(r'^[a-z0-9_]+$').hasMatch(id)) {
      throw FormatException('$fieldName.id must be a stable identifier.');
    }
    if (rawGroupIds is! List ||
        rawGroupIds.isEmpty ||
        rawGroupIds.any(
          (groupId) => groupId is! String || groupId.trim().isEmpty,
        )) {
      throw FormatException(
        '$fieldName.groupIds must contain at least one group id.',
      );
    }
    final groupIds = rawGroupIds.cast<String>();
    if (groupIds.toSet().length != groupIds.length) {
      throw FormatException('$fieldName.groupIds must not contain duplicates.');
    }

    return DesignLessonStep(
      id: id,
      groupIds: List.unmodifiable(groupIds),
      instruction: LocalizedText.fromJson(
        value['instruction'],
        '$fieldName.instruction',
      ),
    );
  }
}

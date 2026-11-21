enum ReviewStatus {
  pending,
  approved;

  static ReviewStatus parse(Object? value, String fieldName) {
    return switch (value) {
      'pending' => ReviewStatus.pending,
      'approved' => ReviewStatus.approved,
      _ => throw FormatException('$fieldName has an unsupported value.'),
    };
  }
}

class ReviewRecord {
  const ReviewRecord({
    required this.status,
    required this.reviewer,
    required this.evidence,
  });

  final ReviewStatus status;
  final String reviewer;
  final String evidence;

  bool get isApproved => status == ReviewStatus.approved;

  factory ReviewRecord.fromJson(Object? value, String fieldName) {
    if (value is! Map<String, dynamic>) {
      throw FormatException('$fieldName must be an object.');
    }

    final reviewer = value['reviewer'];
    final evidence = value['evidence'];
    if (reviewer is! String || evidence is! String) {
      throw FormatException(
        '$fieldName reviewer and evidence must be strings.',
      );
    }

    final record = ReviewRecord(
      status: ReviewStatus.parse(value['status'], '$fieldName.status'),
      reviewer: reviewer.trim(),
      evidence: evidence.trim(),
    );
    if (record.isApproved &&
        (record.reviewer.isEmpty || record.evidence.isEmpty)) {
      throw FormatException(
        '$fieldName requires a reviewer and evidence when approved.',
      );
    }
    return record;
  }
}

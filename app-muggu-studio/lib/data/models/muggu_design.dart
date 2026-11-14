import 'dot_grid.dart';
import 'localized_text.dart';

enum DesignDifficulty {
  easy,
  intermediate,
  advanced;

  static DesignDifficulty parse(Object? value, String fieldName) {
    return switch (value) {
      'easy' => DesignDifficulty.easy,
      'intermediate' => DesignDifficulty.intermediate,
      'advanced' => DesignDifficulty.advanced,
      _ => throw FormatException('$fieldName has an unsupported value.'),
    };
  }
}

enum ContentReviewStatus {
  pending,
  reviewed;

  static ContentReviewStatus parse(Object? value, String fieldName) {
    return switch (value) {
      'pending' => ContentReviewStatus.pending,
      'reviewed' => ContentReviewStatus.reviewed,
      _ => throw FormatException('$fieldName has an unsupported value.'),
    };
  }
}

class DesignPoint {
  const DesignPoint({required this.x, required this.y});

  final double x;
  final double y;

  factory DesignPoint.fromJson(Object? value, String fieldName) {
    if (value is! List || value.length != 2) {
      throw FormatException('$fieldName must contain an x and y coordinate.');
    }
    final x = value[0];
    final y = value[1];
    if (x is! num || y is! num || !x.isFinite || !y.isFinite) {
      throw FormatException('$fieldName coordinates must be finite numbers.');
    }
    if (x < 0 || x > 1 || y < 0 || y > 1) {
      throw FormatException('$fieldName coordinates must be between 0 and 1.');
    }
    return DesignPoint(x: x.toDouble(), y: y.toDouble());
  }
}

class DesignStroke {
  const DesignStroke({
    required this.id,
    required this.points,
    required this.closed,
  });

  final String id;
  final List<DesignPoint> points;
  final bool closed;

  factory DesignStroke.fromJson(Object? value, String fieldName) {
    if (value is! Map<String, dynamic>) {
      throw FormatException('$fieldName must be an object.');
    }
    final id = value['id'];
    final rawPoints = value['points'];
    final closed = value['closed'];
    if (id is! String ||
        id.trim().isEmpty ||
        rawPoints is! List ||
        rawPoints.length < 2) {
      throw FormatException(
        '$fieldName requires an id and at least two points.',
      );
    }
    if (closed != null && closed is! bool) {
      throw FormatException('$fieldName.closed must be a boolean.');
    }
    return DesignStroke(
      id: id,
      points: List.unmodifiable([
        for (var index = 0; index < rawPoints.length; index++)
          DesignPoint.fromJson(rawPoints[index], '$fieldName.points[$index]'),
      ]),
      closed: closed as bool? ?? false,
    );
  }
}

class MugguDesign {
  const MugguDesign({
    required this.id,
    required this.localizedName,
    required this.localizedDescription,
    required this.region,
    required this.tradition,
    required this.technique,
    required this.difficulty,
    required this.grid,
    required this.searchTags,
    required this.thumbnail,
    required this.strokes,
    required this.contentReviewStatus,
    required this.contentReviewer,
    required this.sourceOrPermission,
  });

  final String id;
  final LocalizedText localizedName;
  final LocalizedText localizedDescription;
  final String? region;
  final String? tradition;
  final String technique;
  final DesignDifficulty difficulty;
  final DotGrid? grid;
  final List<String> searchTags;
  final String thumbnail;
  final List<DesignStroke> strokes;
  final ContentReviewStatus contentReviewStatus;
  final String contentReviewer;
  final String sourceOrPermission;

  String nameFor(String languageCode) =>
      localizedName.forLanguage(languageCode);

  String descriptionFor(String languageCode) =>
      localizedDescription.forLanguage(languageCode);

  factory MugguDesign.fromJson(Object? value, String fieldName) {
    if (value is! Map<String, dynamic>) {
      throw FormatException('$fieldName must be an object.');
    }

    final id = value['id'];
    final technique = value['technique'];
    final thumbnail = value['thumbnail'];
    final rawTags = value['searchTags'];
    final rawStrokes = value['strokes'];
    final rawGrid = value['grid'];
    final region = _optionalString(value['region'], '$fieldName.region');
    final tradition = _optionalString(
      value['tradition'],
      '$fieldName.tradition',
    );
    if (id is! String || !RegExp(r'^[a-z0-9_]+$').hasMatch(id)) {
      throw FormatException(
        '$fieldName.id must be a stable lowercase identifier.',
      );
    }
    if (technique is! String || technique.trim().isEmpty) {
      throw FormatException('$fieldName.technique must be a non-empty string.');
    }
    if (thumbnail is! String ||
        !thumbnail.startsWith('assets/designs/thumbnails/')) {
      throw FormatException(
        '$fieldName.thumbnail must reference a bundled thumbnail.',
      );
    }
    if (rawTags is! List ||
        rawTags.any((tag) => tag is! String || tag.trim().isEmpty)) {
      throw FormatException(
        '$fieldName.searchTags must contain non-empty strings.',
      );
    }
    if (rawStrokes is! List || rawStrokes.isEmpty) {
      throw FormatException('$fieldName.strokes must contain vector paths.');
    }

    final review = value['contentReview'];
    if (review is! Map<String, dynamic>) {
      throw FormatException('$fieldName.contentReview must be an object.');
    }
    final status = ContentReviewStatus.parse(
      review['status'],
      '$fieldName.contentReview.status',
    );
    final reviewer = review['reviewer'];
    final sourceOrPermission = review['sourceOrPermission'];
    if (reviewer is! String || sourceOrPermission is! String) {
      throw FormatException(
        '$fieldName.contentReview reviewer and sourceOrPermission must be strings.',
      );
    }

    return MugguDesign(
      id: id,
      localizedName: LocalizedText.fromJson(
        value['localizedName'],
        '$fieldName.localizedName',
      ),
      localizedDescription: LocalizedText.fromJson(
        value['localizedDescription'],
        '$fieldName.localizedDescription',
      ),
      region: region,
      tradition: tradition,
      technique: technique,
      difficulty: DesignDifficulty.parse(
        value['difficulty'],
        '$fieldName.difficulty',
      ),
      grid: rawGrid == null
          ? null
          : DotGrid.fromJson(rawGrid, '$fieldName.grid'),
      searchTags: List.unmodifiable(rawTags.cast<String>()),
      thumbnail: thumbnail,
      strokes: List.unmodifiable([
        for (var index = 0; index < rawStrokes.length; index++)
          DesignStroke.fromJson(
            rawStrokes[index],
            '$fieldName.strokes[$index]',
          ),
      ]),
      contentReviewStatus: status,
      contentReviewer: reviewer,
      sourceOrPermission: sourceOrPermission,
    );
  }

  static String? _optionalString(Object? value, String fieldName) {
    if (value == null) {
      return null;
    }
    if (value is! String || value.trim().isEmpty) {
      throw FormatException('$fieldName must be a non-empty string or null.');
    }
    return value;
  }
}

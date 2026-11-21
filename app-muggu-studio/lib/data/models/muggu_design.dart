import 'content_review.dart';
import 'design_lesson_step.dart';
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
    required this.localizedTechnique,
    required this.localizedRegion,
    required this.localizedTradition,
    required this.region,
    required this.tradition,
    required this.technique,
    required this.difficulty,
    required this.grid,
    required this.searchTags,
    required this.thumbnail,
    required this.strokes,
    required this.rightsReview,
    required this.culturalReview,
    required this.localizationReview,
    required this.lessonReview,
    required this.lessonSteps,
  });

  final String id;
  final LocalizedText localizedName;
  final LocalizedText localizedDescription;
  final LocalizedText localizedTechnique;
  final LocalizedText? localizedRegion;
  final LocalizedText? localizedTradition;
  final String? region;
  final String? tradition;
  final String technique;
  final DesignDifficulty difficulty;
  final DotGrid? grid;
  final List<String> searchTags;
  final String thumbnail;
  final List<DesignStroke> strokes;
  final ReviewRecord rightsReview;
  final ReviewRecord culturalReview;
  final ReviewRecord localizationReview;
  final ReviewRecord lessonReview;
  final List<DesignLessonStep> lessonSteps;

  bool get isPublicationReady =>
      rightsReview.isApproved &&
      culturalReview.isApproved &&
      localizationReview.isApproved &&
      _supportsInitialLanguages(localizedName) &&
      _supportsInitialLanguages(localizedDescription) &&
      _supportsInitialLanguages(localizedTechnique) &&
      (localizedRegion == null ||
          _supportsInitialLanguages(localizedRegion!)) &&
      (localizedTradition == null ||
          _supportsInitialLanguages(localizedTradition!));

  bool get hasReviewedLesson =>
      isPublicationReady &&
      lessonReview.isApproved &&
      lessonSteps.isNotEmpty &&
      lessonSteps.every((step) => _supportsInitialLanguages(step.instruction));

  String nameFor(String languageCode) =>
      localizedName.forLanguage(languageCode);

  String descriptionFor(String languageCode) =>
      localizedDescription.forLanguage(languageCode);

  String techniqueFor(String languageCode) =>
      localizedTechnique.forLanguage(languageCode);

  String? regionFor(String languageCode) =>
      localizedRegion?.forLanguage(languageCode);

  String? traditionFor(String languageCode) =>
      localizedTradition?.forLanguage(languageCode);

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
    final localizedRegionValue = value['localizedRegion'];
    final localizedTraditionValue = value['localizedTradition'];
    if (id is! String || !RegExp(r'^[a-z0-9_]+$').hasMatch(id)) {
      throw FormatException(
        '$fieldName.id must be a stable lowercase identifier.',
      );
    }
    if (technique is! String || technique.trim().isEmpty) {
      throw FormatException('$fieldName.technique must be a non-empty string.');
    }
    if ((region == null) != (localizedRegionValue == null) ||
        (tradition == null) != (localizedTraditionValue == null)) {
      throw FormatException(
        '$fieldName localized region and tradition must match their identifiers.',
      );
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

    final strokes = <DesignStroke>[];
    final strokeIds = <String>{};
    for (var index = 0; index < rawStrokes.length; index++) {
      final stroke = DesignStroke.fromJson(
        rawStrokes[index],
        '$fieldName.strokes[$index]',
      );
      if (!strokeIds.add(stroke.id)) {
        throw FormatException('Duplicate stroke id: ${stroke.id}.');
      }
      strokes.add(stroke);
    }
    final immutableStrokes = List<DesignStroke>.unmodifiable(strokes);
    final rawLessonSteps = value['lessonSteps'];
    if (rawLessonSteps is! List) {
      throw FormatException('$fieldName.lessonSteps must be a list.');
    }
    final lessonSteps = <DesignLessonStep>[];
    final lessonStepIds = <String>{};
    for (var index = 0; index < rawLessonSteps.length; index++) {
      final step = DesignLessonStep.fromJson(
        rawLessonSteps[index],
        '$fieldName.lessonSteps[$index]',
      );
      if (!lessonStepIds.add(step.id)) {
        throw FormatException('Duplicate lesson step id: ${step.id}.');
      }
      for (final strokeId in step.strokeIds) {
        if (!immutableStrokes.any((stroke) => stroke.id == strokeId)) {
          throw FormatException(
            '$fieldName.lessonSteps[$index] references unknown stroke "$strokeId".',
          );
        }
      }
      lessonSteps.add(step);
    }
    final rightsReview = ReviewRecord.fromJson(
      value['rightsReview'],
      '$fieldName.rightsReview',
    );
    final culturalReview = ReviewRecord.fromJson(
      value['culturalReview'],
      '$fieldName.culturalReview',
    );
    final localizationReview = ReviewRecord.fromJson(
      value['localizationReview'],
      '$fieldName.localizationReview',
    );
    final lessonReview = ReviewRecord.fromJson(
      value['lessonReview'],
      '$fieldName.lessonReview',
    );
    if (lessonReview.isApproved && lessonSteps.isEmpty) {
      throw FormatException(
        '$fieldName.lessonReview cannot be approved without lesson steps.',
      );
    }
    if (lessonReview.isApproved &&
        lessonSteps.any(
          (step) => !_supportsInitialLanguages(step.instruction),
        )) {
      throw FormatException(
        '$fieldName.lessonReview requires reviewed English, Telugu and Tamil instructions.',
      );
    }

    final localizedName = LocalizedText.fromJson(
      value['localizedName'],
      '$fieldName.localizedName',
    );
    final localizedDescription = LocalizedText.fromJson(
      value['localizedDescription'],
      '$fieldName.localizedDescription',
    );
    final localizedTechnique = LocalizedText.fromJson(
      value['localizedTechnique'],
      '$fieldName.localizedTechnique',
    );
    final localizedRegion = localizedRegionValue == null
        ? null
        : LocalizedText.fromJson(
            localizedRegionValue,
            '$fieldName.localizedRegion',
          );
    final localizedTradition = localizedTraditionValue == null
        ? null
        : LocalizedText.fromJson(
            localizedTraditionValue,
            '$fieldName.localizedTradition',
          );
    if (localizationReview.isApproved &&
        (!_supportsInitialLanguages(localizedName) ||
            !_supportsInitialLanguages(localizedDescription) ||
            !_supportsInitialLanguages(localizedTechnique) ||
            (localizedRegion != null &&
                !_supportsInitialLanguages(localizedRegion)) ||
            (localizedTradition != null &&
                !_supportsInitialLanguages(localizedTradition)))) {
      throw FormatException(
        '$fieldName.localizationReview requires reviewed English, Telugu and Tamil catalogue text.',
      );
    }

    return MugguDesign(
      id: id,
      localizedName: localizedName,
      localizedDescription: localizedDescription,
      localizedTechnique: localizedTechnique,
      localizedRegion: localizedRegion,
      localizedTradition: localizedTradition,
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
      strokes: immutableStrokes,
      rightsReview: rightsReview,
      culturalReview: culturalReview,
      localizationReview: localizationReview,
      lessonReview: lessonReview,
      lessonSteps: List.unmodifiable(lessonSteps),
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

  static bool _supportsInitialLanguages(LocalizedText text) =>
      const ['en', 'te', 'ta'].every(text.values.containsKey);
}

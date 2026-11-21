import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/app_tab.dart';
import '../../../data/repositories/design_repository.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../application/lesson_playback.dart';
import 'vector_preview.dart';

class DesignDetailScreen extends ConsumerStatefulWidget {
  const DesignDetailScreen({
    required this.designId,
    this.originTab = AppTab.explore,
    super.key,
  });

  final String designId;
  final AppTab originTab;

  @override
  ConsumerState<DesignDetailScreen> createState() => _DesignDetailScreenState();
}

class _DesignDetailScreenState extends ConsumerState<DesignDetailScreen> {
  LessonPlaybackController? _playback;
  LessonPlaybackState _state = LessonPlaybackState.initial(0);

  @override
  void dispose() {
    _playback?.removeListener(_onPlaybackChanged);
    _playback?.dispose();
    super.dispose();
  }

  void _ensurePlayback(int stepCount) {
    if (_playback != null && _playback!.state.stepCount == stepCount) {
      return;
    }
    _playback?.dispose();
    _playback = LessonPlaybackController(stepCount: stepCount);
    _state = _playback!.state;
    _playback!.addListener(_onPlaybackChanged);
  }

  void _onPlaybackChanged() {
    if (mounted) {
      setState(() => _state = _playback!.state);
    }
  }

  void _playPause() {
    if (_state.isPlaying) {
      _playback!.pause();
    } else {
      _playback!.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    final catalog = ref.watch(catalogProvider);
    final l10n = AppLocalizations.of(context)!;
    final languageCode = Localizations.localeOf(context).languageCode;

    if (catalog.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (catalog.hasError) {
      return Center(child: Text(l10n.catalogLoadError));
    }

    final designs = catalog.requireValue;
    final matches = designs.where((design) => design.id == widget.designId);
    if (matches.isEmpty) {
      return Center(child: Text(l10n.exploreNoResultsTitle));
    }
    final design = matches.first;
    final hasReviewedLesson = design.hasReviewedLesson;
    _ensurePlayback(hasReviewedLesson ? design.lessonSteps.length : 0);
    final visibleGroupIds = hasReviewedLesson
        ? design.lessonSteps
              .take(_state.displayedStepCount)
              .expand((step) => step.groupIds)
              .toSet()
        : null;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          design.nameFor(languageCode),
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text(design.descriptionFor(languageCode)),
        const SizedBox(height: 16),
        VectorPreview(
          paths: design.paths,
          grid: design.grid,
          visibleGroupIds: visibleGroupIds,
          showAllPaths: !hasReviewedLesson,
        ),
        if (hasReviewedLesson) ...[
          const SizedBox(height: 12),
          Text(
            _state.isComplete
                ? l10n.lessonComplete
                : '${l10n.step} ${_state.step + 1} ${l10n.ofLabel} ${_state.stepCount}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          Text(
            _state.isComplete
                ? l10n.lessonComplete
                : design.lessonSteps[_state.step].instruction.forLanguage(
                    languageCode,
                  ),
          ),
        ] else ...[
          const SizedBox(height: 12),
          Card(
            color: Theme.of(context).colorScheme.secondaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline_rounded),
                  const SizedBox(width: 10),
                  Expanded(child: Text(l10n.sampleLessonNotice)),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 16),
        Text(l10n.designDetails, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        _DetailRow(
          title: l10n.technique,
          value: design.technique == 'geometric_lines'
              ? l10n.techniqueGeometricLines
              : design.techniqueFor(languageCode),
        ),
        _DetailRow(
          title: l10n.difficulty,
          value: switch (design.difficulty) {
            var difficulty when difficulty.index == 0 => l10n.easy,
            var difficulty when difficulty.index == 1 => l10n.intermediate,
            _ => l10n.advanced,
          },
        ),
        _DetailRow(
          title: l10n.region,
          value: design.regionFor(languageCode) ?? l10n.metadataUnassigned,
        ),
        _DetailRow(
          title: l10n.tradition,
          value: design.traditionFor(languageCode) ?? l10n.metadataUnassigned,
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: () => context.push(
            '/design/${design.id}/practice',
            extra: widget.originTab,
          ),
          icon: const Icon(Icons.gesture_rounded),
          label: Text(l10n.practiceDesign),
        ),
        if (hasReviewedLesson) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: _state.step == 0 ? null : _playback!.previous,
                icon: const Icon(Icons.skip_previous_rounded),
                label: Text(l10n.previous),
              ),
              FilledButton.icon(
                onPressed: _playPause,
                icon: Icon(
                  _state.isPlaying
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                ),
                label: Text(_state.isPlaying ? l10n.pause : l10n.play),
              ),
              OutlinedButton.icon(
                onPressed: _state.isComplete ? null : _playback!.advance,
                icon: const Icon(Icons.skip_next_rounded),
                label: Text(l10n.next),
              ),
              TextButton.icon(
                onPressed: _playback!.restart,
                icon: const Icon(Icons.replay_rounded),
                label: Text(l10n.restart),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(title, style: Theme.of(context).textTheme.labelLarge),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

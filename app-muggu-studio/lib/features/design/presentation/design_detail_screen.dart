import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/app_tab.dart';
import '../../../data/models/muggu_design.dart';
import '../../../data/repositories/design_repository.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../export/application/design_exporter.dart';
import '../../export/presentation/export_dialog.dart';
import '../application/lesson_playback.dart';
import '../application/design_renderer.dart';
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

  Future<void> _shareDesign(
    BuildContext context,
    MugguDesign design,
    String languageCode,
  ) async {
    final title = design.nameFor(languageCode);
    final exporter = ref.read(designExporterProvider);
    await showExportShareSheet(
      context: context,
      ref: ref,
      title: title,
      onExportBytes: (resolution) => exporter.exportDesign(
        design,
        resolution: resolution,
        languageCode: languageCode,
      ),
    );
  }

  Future<void> _openSource(String source) async {
    final opened = await launchUrl(
      Uri.parse(source),
      mode: LaunchMode.externalApplication,
    );
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.sourceOpenError)),
      );
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
    final canPlayLesson = design.isLessonPlayable;
    _ensurePlayback(canPlayLesson ? design.lessonSteps.length : 0);
    final visibleGroupIds = canPlayLesson
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
          backgroundColor: designColorFromHex(design.backgroundColor),
          visibleGroupIds: visibleGroupIds,
          showAllPaths: !canPlayLesson,
        ),
        if (canPlayLesson) ...[
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
          title: l10n.artworkSource,
          value: design.provenance.isSystemGenerated
              ? l10n.systemGeneratedArtwork
              : l10n.referenceBasedArtwork,
        ),
        if (design.provenance.note case final note?) ...[
          const SizedBox(height: 4),
          Text(note, style: Theme.of(context).textTheme.bodySmall),
        ],
        if (design.provenance.sources.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            l10n.styleReferences,
            style: Theme.of(context).textTheme.labelLarge,
          ),
          for (final source in design.provenance.sources)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton.icon(
                onPressed: () => _openSource(source),
                icon: const Icon(Icons.open_in_new_rounded),
                label: Text(Uri.parse(source).host),
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                ),
              ),
            ),
        ],
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: () => context.push(
                  '/design/${design.id}/practice',
                  extra: widget.originTab,
                ),
                icon: const Icon(Icons.gesture_rounded),
                label: Text(l10n.practiceDesign),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.outlined(
              key: const ValueKey('design-share-button'),
              tooltip: l10n.shareDesign,
              onPressed: () => _shareDesign(context, design, languageCode),
              icon: const Icon(Icons.share_rounded),
            ),
          ],
        ),
        if (canPlayLesson) ...[
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

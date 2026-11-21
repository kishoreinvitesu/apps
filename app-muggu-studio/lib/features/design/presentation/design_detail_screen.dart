import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../data/repositories/design_repository.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../application/lesson_playback.dart';
import 'vector_preview.dart';

class DesignDetailScreen extends ConsumerStatefulWidget {
  const DesignDetailScreen({required this.designId, super.key});

  final String designId;

  @override
  ConsumerState<DesignDetailScreen> createState() => _DesignDetailScreenState();
}

class _DesignDetailScreenState extends ConsumerState<DesignDetailScreen> {
  LessonPlaybackController? _playback;
  LessonPlaybackState _state = LessonPlaybackState.initial(0);
  Timer? _uiTimer;

  @override
  void dispose() {
    _uiTimer?.cancel();
    _playback?.dispose();
    super.dispose();
  }

  void _ensurePlayback(int strokeCount) {
    if (_playback != null && _playback!.state.strokeCount == strokeCount) {
      return;
    }
    _playback?.dispose();
    _playback = LessonPlaybackController(strokeCount: strokeCount);
    _state = _playback!.state;
  }

  void _syncPlayback() {
    setState(() => _state = _playback!.state);
  }

  void _playPause() {
    if (_state.isPlaying) {
      _playback!.pause();
      _syncPlayback();
      _uiTimer?.cancel();
      return;
    }
    _playback!.play();
    _syncPlayback();
    _uiTimer?.cancel();
    _uiTimer = Timer.periodic(_playback!.stepDuration, (_) {
      if (!mounted) {
        return;
      }
      _syncPlayback();
      if (_state.isComplete) {
        _uiTimer?.cancel();
      }
    });
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
    _ensurePlayback(design.strokes.length);

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
          design: design,
          visibleStrokeCount: _state.displayedStrokeCount,
        ),
        const SizedBox(height: 12),
        Text(
          _state.isComplete
              ? l10n.lessonComplete
              : '${l10n.step} ${_state.step + 1} ${l10n.ofLabel} ${_state.strokeCount}',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 6),
        Text(_state.isComplete ? l10n.lessonComplete : l10n.drawNextStroke),
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
        const SizedBox(height: 16),
        Text(l10n.designDetails, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        _DetailRow(title: l10n.technique, value: design.technique),
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
          value: design.region ?? l10n.metadataUnassigned,
        ),
        _DetailRow(
          title: l10n.tradition,
          value: design.tradition ?? l10n.metadataUnassigned,
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            OutlinedButton.icon(
              onPressed: _state.step == 0
                  ? null
                  : () {
                      _playback!.previous();
                      _uiTimer?.cancel();
                      _syncPlayback();
                    },
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
              onPressed: _state.isComplete
                  ? null
                  : () {
                      _playback!.advance();
                      _syncPlayback();
                    },
              icon: const Icon(Icons.skip_next_rounded),
              label: Text(l10n.next),
            ),
            TextButton.icon(
              onPressed: () {
                _playback!.restart();
                _uiTimer?.cancel();
                _syncPlayback();
              },
              icon: const Icon(Icons.replay_rounded),
              label: Text(l10n.restart),
            ),
          ],
        ),
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

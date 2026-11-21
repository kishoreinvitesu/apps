import 'dart:async';

import 'package:flutter/foundation.dart';

@immutable
class LessonPlaybackState {
  const LessonPlaybackState({
    required this.step,
    required this.strokeCount,
    required this.isPlaying,
  });

  factory LessonPlaybackState.initial(int strokeCount) =>
      LessonPlaybackState(step: 0, strokeCount: strokeCount, isPlaying: false);

  final int step;
  final int strokeCount;
  final bool isPlaying;

  bool get isComplete => strokeCount > 0 && step >= strokeCount;
  int get displayedStrokeCount => step.clamp(0, strokeCount);

  LessonPlaybackState next() {
    if (isComplete) {
      return copyWith(isPlaying: false);
    }
    final nextStep = (step + 1).clamp(0, strokeCount);
    return copyWith(
      step: nextStep,
      isPlaying: nextStep < strokeCount && isPlaying,
    );
  }

  LessonPlaybackState previous() =>
      copyWith(step: (step - 1).clamp(0, strokeCount));

  LessonPlaybackState copyWith({
    int? step,
    int? strokeCount,
    bool? isPlaying,
  }) => LessonPlaybackState(
    step: step ?? this.step,
    strokeCount: strokeCount ?? this.strokeCount,
    isPlaying: isPlaying ?? this.isPlaying,
  );
}

class LessonPlaybackController extends ChangeNotifier {
  LessonPlaybackController({
    required int strokeCount,
    this.stepDuration = const Duration(milliseconds: 1400),
  }) : state = LessonPlaybackState.initial(strokeCount);

  final Duration stepDuration;
  LessonPlaybackState state;
  Timer? _timer;

  @override
  void dispose() {
    _cancelTimer();
    super.dispose();
  }

  void play() {
    if (state.isComplete) {
      restart();
    }
    if (state.strokeCount == 0) {
      return;
    }
    _setState(state.copyWith(isPlaying: true));
    _cancelTimer();
    _timer = Timer.periodic(stepDuration, (_) => advance());
  }

  void pause() {
    _cancelTimer();
    _setState(state.copyWith(isPlaying: false));
  }

  void advance() {
    _setState(state.next());
    if (state.isComplete) {
      _cancelTimer();
    }
  }

  void previous() {
    pause();
    _setState(state.previous());
  }

  void restart() {
    _cancelTimer();
    _setState(LessonPlaybackState.initial(state.strokeCount));
  }

  void _setState(LessonPlaybackState next) {
    state = next;
    notifyListeners();
  }

  void _cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }
}

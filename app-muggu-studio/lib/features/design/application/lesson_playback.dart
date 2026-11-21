import 'dart:async';

import 'package:flutter/foundation.dart';

@immutable
class LessonPlaybackState {
  const LessonPlaybackState({
    required this.step,
    required this.stepCount,
    required this.isPlaying,
  });

  factory LessonPlaybackState.initial(int stepCount) =>
      LessonPlaybackState(step: 0, stepCount: stepCount, isPlaying: false);

  final int step;
  final int stepCount;
  final bool isPlaying;

  bool get isComplete => stepCount > 0 && step >= stepCount;
  int get displayedStepCount => step.clamp(0, stepCount);

  LessonPlaybackState next() {
    if (isComplete) {
      return copyWith(isPlaying: false);
    }
    final nextStep = (step + 1).clamp(0, stepCount);
    return copyWith(
      step: nextStep,
      isPlaying: nextStep < stepCount && isPlaying,
    );
  }

  LessonPlaybackState previous() =>
      copyWith(step: (step - 1).clamp(0, stepCount));

  LessonPlaybackState copyWith({int? step, int? stepCount, bool? isPlaying}) =>
      LessonPlaybackState(
        step: step ?? this.step,
        stepCount: stepCount ?? this.stepCount,
        isPlaying: isPlaying ?? this.isPlaying,
      );
}

class LessonPlaybackController extends ChangeNotifier {
  LessonPlaybackController({
    required int stepCount,
    this.stepDuration = const Duration(milliseconds: 1400),
  }) : state = LessonPlaybackState.initial(stepCount);

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
    if (state.stepCount == 0) {
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
    _setState(LessonPlaybackState.initial(state.stepCount));
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

import 'dart:async';

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

class LessonPlaybackController {
  LessonPlaybackController({
    required int strokeCount,
    this.stepDuration = const Duration(milliseconds: 1400),
  }) : state = LessonPlaybackState.initial(strokeCount);

  final Duration stepDuration;
  LessonPlaybackState state;
  Timer? _timer;

  void dispose() => _timer?.cancel();

  void play() {
    if (state.isComplete) {
      restart();
    }
    if (state.strokeCount == 0) {
      return;
    }
    state = state.copyWith(isPlaying: true);
    _timer?.cancel();
    _timer = Timer.periodic(stepDuration, (_) => advance());
  }

  void pause() {
    _timer?.cancel();
    state = state.copyWith(isPlaying: false);
  }

  void advance() {
    state = state.next();
    if (state.isComplete) {
      _timer?.cancel();
    }
  }

  void previous() {
    pause();
    state = state.previous();
  }

  void restart() {
    _timer?.cancel();
    state = LessonPlaybackState.initial(state.strokeCount);
  }
}

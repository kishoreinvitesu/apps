import 'package:flutter_test/flutter_test.dart';
import 'package:muggu_studio/features/design/application/lesson_playback.dart';

void main() {
  test('lesson playback follows stroke count and can restart', () {
    final playback = LessonPlaybackController(
      strokeCount: 3,
      stepDuration: const Duration(milliseconds: 10),
    );

    expect(playback.state.step, 0);
    expect(playback.state.isComplete, isFalse);

    playback.advance();
    expect(playback.state.step, 1);

    playback.advance();
    playback.advance();
    expect(playback.state.step, 3);
    expect(playback.state.isComplete, isTrue);

    playback.restart();
    expect(playback.state.step, 0);
    expect(playback.state.isComplete, isFalse);
  });

  test('previous does not move below the first step', () {
    final playback = LessonPlaybackController(strokeCount: 2);

    playback.previous();
    expect(playback.state.step, 0);

    playback.advance();
    playback.previous();
    expect(playback.state.step, 0);
  });

  test('play, pause, resume, and completion share one timer', () async {
    final playback = LessonPlaybackController(
      strokeCount: 3,
      stepDuration: const Duration(milliseconds: 40),
    );
    addTearDown(playback.dispose);

    playback.play();
    expect(playback.state.isPlaying, isTrue);
    await _waitUntil(() => playback.state.step > 0);
    expect(playback.state.step, greaterThan(0));
    playback.pause();
    final pausedStep = playback.state.step;
    expect(playback.state.isPlaying, isFalse);
    await Future<void>.delayed(const Duration(milliseconds: 100));
    expect(playback.state.step, pausedStep);

    playback.play();
    await _waitUntil(() => playback.state.isComplete);
    expect(playback.state.step, 3);
    expect(playback.state.isComplete, isTrue);
    expect(playback.state.isPlaying, isFalse);
    await Future<void>.delayed(const Duration(milliseconds: 60));
    expect(playback.state.step, 3);

    playback.restart();
    expect(playback.state.step, 0);
    expect(playback.state.isPlaying, isFalse);
  });

  test(
    'previous cancels automatic playback and disposal cancels timers',
    () async {
      final playback = LessonPlaybackController(
        strokeCount: 3,
        stepDuration: const Duration(milliseconds: 20),
      );

      playback.play();
      playback.advance();
      expect(playback.state.step, 1);
      playback.previous();
      expect(playback.state.step, 0);
      expect(playback.state.isPlaying, isFalse);
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(playback.state.step, 0);

      playback.play();
      playback.dispose();
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(playback.state.step, 0);
    },
  );
}

Future<void> _waitUntil(bool Function() condition) async {
  for (var attempt = 0; attempt < 40 && !condition(); attempt++) {
    await Future<void>.delayed(const Duration(milliseconds: 25));
  }
}

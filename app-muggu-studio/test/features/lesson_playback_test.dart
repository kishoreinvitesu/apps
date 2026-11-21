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
}

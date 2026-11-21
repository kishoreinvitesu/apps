import 'package:flutter_test/flutter_test.dart';
import 'package:muggu_studio/features/home/application/daily_design.dart';

void main() {
  test(
    'daily design index is stable throughout a day and advances by date',
    () {
      final morning = DateTime(2026, 11, 21, 8);
      final evening = DateTime(2026, 11, 21, 20);
      final nextDay = DateTime(2026, 11, 22);

      expect(dailyDesignIndex(morning, 10), dailyDesignIndex(evening, 10));
      expect(
        dailyDesignIndex(nextDay, 10),
        isNot(dailyDesignIndex(morning, 10)),
      );
    },
  );

  test('daily design index handles empty catalogues', () {
    expect(dailyDesignIndex(DateTime(2026), 0), isNull);
  });
}

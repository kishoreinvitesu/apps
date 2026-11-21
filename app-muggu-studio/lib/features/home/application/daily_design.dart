int? dailyDesignIndex(DateTime date, int designCount) {
  if (designCount <= 0) {
    return null;
  }

  final dayNumber = DateTime.utc(
    date.year,
    date.month,
    date.day,
  ).difference(DateTime.utc(1970)).inDays;
  return dayNumber % designCount;
}

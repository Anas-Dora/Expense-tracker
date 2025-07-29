class DateRangeHelper {
  static (DateTime, DateTime) calculateCurrentRange() {
    final now = DateTime.now();

    DateTime start;
    DateTime end;

    if (now.day < 27) {
      start = DateTime(now.year, now.month - 1, 27);
      end = DateTime(now.year, now.month, 27);
    } else {
      start = DateTime(now.year, now.month, 27);
      end = DateTime(now.year, now.month + 1, 27);
    }
    return (start, end);
  }
}

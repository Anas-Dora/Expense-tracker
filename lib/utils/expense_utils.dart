import '../data/ausgabe.dart';

class ExpenseGrouper {
  static Map<DateTime, List<Ausgabe>> groupByDate(List<Ausgabe> ausgaben) {
    final Map<DateTime, List<Ausgabe>> grouped = {};
    for (var ausgabe in ausgaben) {
      final date = DateTime(
        ausgabe.datum.year,
        ausgabe.datum.month,
        ausgabe.datum.day,
      );
      grouped.putIfAbsent(date, () => []).add(ausgabe);
    }
    return grouped;
  }
}

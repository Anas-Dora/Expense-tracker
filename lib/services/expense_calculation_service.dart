import 'package:expenditure/data/ausgabe.dart';
import 'package:intl/intl.dart';

/// Gibt die gruppierten Ausgaben zurück nach Tag/Woche/Monat und Kategorie
Map<String, Map<String, double>> berechneSummen(
  List<Ausgabe> ausgaben,
  String zeitraum,
  String filterKategorie,
  List<String> ausgewaehlteKategorien,
) {
  final heute = DateTime.now();
  final summen = <String, Map<String, double>>{};

  // Kategorie-Filter
  final gefilterteAusgaben =
      ausgaben.where((a) {
        return filterKategorie == 'Alle' ||
            ausgewaehlteKategorien.contains(a.kategorie);
      }).toList();

  // Zeitraum-Auswahl
  switch (zeitraum) {
    case 'Heute':
      final start = DateTime(heute.year, heute.month, heute.day);
      final ende = start.add(const Duration(days: 1));
      final heuteAusgaben = _filterAusgaben(gefilterteAusgaben, start, ende);
      summen['Heute'] = _summiereNachKategorie(heuteAusgaben);
      break;

    case 'Woche':
      final start = heute.subtract(Duration(days: heute.weekday - 1));
      final ende = start.add(const Duration(days: 7));
      final wocheAusgaben = _filterAusgaben(gefilterteAusgaben, start, ende);
      for (var a in wocheAusgaben) {
        final label = DateFormat('dd.MM.').format(a.datum);
        _addToSumme(summen, label, a.kategorie, a.betrag);
      }
      break;

    case 'Monat':
      final zeitraum = _berechneMonatsZeitraum(heute);
      final monatAusgaben = _filterAusgaben(
        gefilterteAusgaben,
        zeitraum.start,
        zeitraum.ende,
      );
      for (var a in monatAusgaben) {
        final woche = _berechneWocheImMonat(zeitraum.start, a.datum);
        final label = 'Woche $woche';
        _addToSumme(summen, label, a.kategorie, a.betrag);
      }
      break;
  }

  return summen;
}

List<Ausgabe> _filterAusgaben(
  List<Ausgabe> ausgaben,
  DateTime start,
  DateTime ende,
) {
  return ausgaben
      .where(
        (a) =>
            a.datum.isAfter(start.subtract(const Duration(seconds: 1))) &&
            a.datum.isBefore(ende),
      )
      .toList();
}

Map<String, double> _summiereNachKategorie(List<Ausgabe> ausgaben) {
  final result = <String, double>{};
  for (var a in ausgaben) {
    result[a.kategorie] = (result[a.kategorie] ?? 0) + a.betrag;
  }
  return result;
}

void _addToSumme(
  Map<String, Map<String, double>> summen,
  String label,
  String kategorie,
  double betrag,
) {
  summen.putIfAbsent(label, () => {});
  summen[label]![kategorie] = (summen[label]![kategorie] ?? 0) + betrag;
}

class Zeitraum {
  final DateTime start;
  final DateTime ende;
  Zeitraum(this.start, this.ende);
}

Zeitraum _berechneMonatsZeitraum(DateTime heute) {
  DateTime start, ende;
  if (heute.day < 27) {
    start =
        heute.month == 1
            ? DateTime(heute.year - 1, 12, 27)
            : DateTime(heute.year, heute.month - 1, 27);
    ende = DateTime(heute.year, heute.month, 27);
  } else {
    start = DateTime(heute.year, heute.month, 27);
    ende =
        heute.month == 12
            ? DateTime(heute.year + 1, 1, 27)
            : DateTime(heute.year, heute.month + 1, 27);
  }
  return Zeitraum(start, ende);
}

int _berechneWocheImMonat(DateTime startDatum, DateTime datum) {
  final ersterMontag = startDatum.add(
    Duration(days: 8 - startDatum.weekday % 7),
  );
  if (datum.isBefore(ersterMontag)) return 1;
  final tageSeitErstemMontag = datum.difference(ersterMontag).inDays;
  return (tageSeitErstemMontag / 7).floor() + 2;
}

double berechneGesamtausgaben(
  Map<String, Map<String, double>> daten,
  String zeitraum,
) {
  double gesamt = 0;
  for (var eintrag in daten.values) {
    gesamt += eintrag.values.fold(0.0, (sum, betrag) => sum + betrag);
  }
  return gesamt;
}

/// Hilfsfunktion: prüft, ob das Datum von heute ist
bool istHeute(DateTime datum) {
  final jetzt = DateTime.now();
  return datum.year == jetzt.year &&
      datum.month == jetzt.month &&
      datum.day == jetzt.day;
}

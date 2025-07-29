import 'package:hive/hive.dart';
import '../data/ausgabe.dart';
import '../data/betrag.dart';

class ExpensesRepository {
  final _ausgabenBox = Hive.box<Ausgabe>('ausgaben');
  final _betragBox = Hive.box<Betrag>('betraege');

  List<Ausgabe> fetchAusgaben() => _ausgabenBox.values.toList();

  double getStartingAmount() {
    if (_betragBox.isNotEmpty) {
      return _betragBox.values.last.geldMenge ?? 0.0;
    }
    return 0.0;
  }

  void clearAll() {
    _ausgabenBox.clear();
    _betragBox.clear();
  }

  void deleteAusgabe(Ausgabe ausgabe) {
    ausgabe.delete();
  }
}

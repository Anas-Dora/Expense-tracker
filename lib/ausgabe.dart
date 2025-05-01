import 'package:hive/hive.dart';

part 'ausgabe.g.dart'; // 👉 wird generiert

@HiveType(typeId: 1)
class Ausgabe extends HiveObject {
  @HiveField(0)
  final double betrag;

  @HiveField(1)
  final String beschreibung;

  @HiveField(2)
  final String kategorie;

  @HiveField(3)
  final DateTime datum;

  Ausgabe(this.betrag, this.beschreibung, this.kategorie, this.datum);
}

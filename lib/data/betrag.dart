import 'package:hive/hive.dart';

part 'betrag.g.dart';

@HiveType(typeId: 0)
class Betrag extends HiveObject {
  Betrag(this.geldMenge);

  @HiveField(0)
  final double? geldMenge;
}

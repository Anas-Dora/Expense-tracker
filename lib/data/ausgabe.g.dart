// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ausgabe.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AusgabeAdapter extends TypeAdapter<Ausgabe> {
  @override
  final int typeId = 1;

  @override
  Ausgabe read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Ausgabe(
      fields[0] as double,
      fields[1] as String,
      fields[2] as String,
      fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Ausgabe obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.betrag)
      ..writeByte(1)
      ..write(obj.beschreibung)
      ..writeByte(2)
      ..write(obj.kategorie)
      ..writeByte(3)
      ..write(obj.datum);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AusgabeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

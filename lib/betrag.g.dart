// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'betrag.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BetragAdapter extends TypeAdapter<Betrag> {
  @override
  final int typeId = 0;

  @override
  Betrag read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Betrag(
      fields[0] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, Betrag obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.geldMenge);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BetragAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

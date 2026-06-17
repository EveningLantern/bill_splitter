// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bill_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BillEntryAdapter extends TypeAdapter<BillEntry> {
  @override
  final int typeId = 5;

  @override
  BillEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BillEntry(
      id: fields[0] as String?,
      type: fields[1] as BillEntryType,
      amount: fields[2] as double,
      name: fields[3] as String,
      dateTime: fields[4] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, BillEntry obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.name)
      ..writeByte(4)
      ..write(obj.dateTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BillEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BillEntryTypeAdapter extends TypeAdapter<BillEntryType> {
  @override
  final int typeId = 4;

  @override
  BillEntryType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return BillEntryType.expense;
      case 1:
        return BillEntryType.income;
      default:
        return BillEntryType.expense;
    }
  }

  @override
  void write(BinaryWriter writer, BillEntryType obj) {
    switch (obj) {
      case BillEntryType.expense:
        writer.writeByte(0);
        break;
      case BillEntryType.income:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BillEntryTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

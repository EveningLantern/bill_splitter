// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history_batch.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HistoryBatchAdapter extends TypeAdapter<HistoryBatch> {
  @override
  final int typeId = 6;

  @override
  HistoryBatch read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HistoryBatch(
      id: fields[0] as String?,
      type: fields[1] as BillEntryType,
      entries: (fields[2] as List).cast<BillEntry>(),
      resetAt: fields[3] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, HistoryBatch obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.entries)
      ..writeByte(3)
      ..write(obj.resetAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HistoryBatchAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

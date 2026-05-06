// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'split_session.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SplitSessionAdapter extends TypeAdapter<SplitSession> {
  @override
  final int typeId = 2;

  @override
  SplitSession read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SplitSession(
      id: fields[0] as String?,
      title: fields[1] as String,
      participants: (fields[2] as List).cast<Person>(),
      expenses: (fields[3] as List).cast<Expense>(),
      createdAt: fields[4] as DateTime?,
      isSettled: fields[5] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, SplitSession obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.participants)
      ..writeByte(3)
      ..write(obj.expenses)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.isSettled);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SplitSessionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

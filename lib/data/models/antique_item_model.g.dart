// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'antique_item_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AntiqueItemModelAdapter extends TypeAdapter<AntiqueItemModel> {
  @override
  final int typeId = 0;

  @override
  AntiqueItemModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AntiqueItemModel(
      id: fields[0] as String,
      name: fields[1] as String,
      category: fields[2] as String,
      description: fields[3] as String,
      estimatedValue: fields[4] as double,
      currency: fields[5] as String,
      acquisitionDate: fields[6] as DateTime,
      origin: fields[7] as String,
      period: fields[8] as String,
      condition: fields[9] as String,
      imageUrls: (fields[10] as List).cast<String>(),
      provenance: fields[11] as String,
      historicalData: (fields[12] as Map).cast<dynamic, dynamic>(),
      createdAt: fields[13] as DateTime,
      updatedAt: fields[14] as DateTime,
      userId: fields[15] as String,
    );
  }

  @override
  void write(BinaryWriter writer, AntiqueItemModel obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.category)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.estimatedValue)
      ..writeByte(5)
      ..write(obj.currency)
      ..writeByte(6)
      ..write(obj.acquisitionDate)
      ..writeByte(7)
      ..write(obj.origin)
      ..writeByte(8)
      ..write(obj.period)
      ..writeByte(9)
      ..write(obj.condition)
      ..writeByte(10)
      ..write(obj.imageUrls)
      ..writeByte(11)
      ..write(obj.provenance)
      ..writeByte(12)
      ..write(obj.historicalData)
      ..writeByte(13)
      ..write(obj.createdAt)
      ..writeByte(14)
      ..write(obj.updatedAt)
      ..writeByte(15)
      ..write(obj.userId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AntiqueItemModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

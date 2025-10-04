// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BudgetAdapter extends TypeAdapter<Budget> {
  @override
  final int typeId = 3;

  @override
  Budget read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Budget(
      id: fields[0] as String,
      name: fields[1] as String,
      targetAmount: fields[2] as double,
      currentAmount: fields[3] as double,
      category: fields[4] as String,
      period: fields[5] as BudgetPeriod,
      startDate: fields[6] as DateTime,
      endDate: fields[7] as DateTime,
      isActive: fields[8] as bool,
      alertThreshold: fields[9] as double,
      notificationsEnabled: fields[10] as bool,
      description: fields[11] as String?,
      icon: fields[12] as String?,
      createdAt: fields[13] as DateTime?,
      updatedAt: fields[14] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Budget obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.targetAmount)
      ..writeByte(3)
      ..write(obj.currentAmount)
      ..writeByte(4)
      ..write(obj.category)
      ..writeByte(5)
      ..write(obj.period)
      ..writeByte(6)
      ..write(obj.startDate)
      ..writeByte(7)
      ..write(obj.endDate)
      ..writeByte(8)
      ..write(obj.isActive)
      ..writeByte(9)
      ..write(obj.alertThreshold)
      ..writeByte(10)
      ..write(obj.notificationsEnabled)
      ..writeByte(11)
      ..write(obj.description)
      ..writeByte(12)
      ..write(obj.icon)
      ..writeByte(13)
      ..write(obj.createdAt)
      ..writeByte(14)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BudgetAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BudgetPeriodAdapter extends TypeAdapter<BudgetPeriod> {
  @override
  final int typeId = 2;

  @override
  BudgetPeriod read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return BudgetPeriod.daily;
      case 1:
        return BudgetPeriod.weekly;
      case 2:
        return BudgetPeriod.monthly;
      case 3:
        return BudgetPeriod.yearly;
      default:
        return BudgetPeriod.daily;
    }
  }

  @override
  void write(BinaryWriter writer, BudgetPeriod obj) {
    switch (obj) {
      case BudgetPeriod.daily:
        writer.writeByte(0);
        break;
      case BudgetPeriod.weekly:
        writer.writeByte(1);
        break;
      case BudgetPeriod.monthly:
        writer.writeByte(2);
        break;
      case BudgetPeriod.yearly:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BudgetPeriodAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

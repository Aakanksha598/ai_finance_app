// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goal.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MicroActionAdapter extends TypeAdapter<MicroAction> {
  @override
  final int typeId = 5;

  @override
  MicroAction read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MicroAction(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      amount: fields[3] as double,
      isCompleted: fields[4] as bool,
      completedAt: fields[5] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, MicroAction obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.amount)
      ..writeByte(4)
      ..write(obj.isCompleted)
      ..writeByte(5)
      ..write(obj.completedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MicroActionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class GoalAdapter extends TypeAdapter<Goal> {
  @override
  final int typeId = 6;

  @override
  Goal read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Goal(
      id: fields[0] as String,
      name: fields[1] as String,
      targetAmount: fields[2] as double,
      currentAmount: fields[3] as double,
      type: fields[4] as GoalType,
      targetDate: fields[5] as DateTime,
      isActive: fields[6] as bool,
      description: fields[7] as String?,
      icon: fields[8] as String?,
      microActions: (fields[9] as List).cast<MicroAction>(),
      monthlyContribution: fields[10] as double,
      autoContribution: fields[11] as bool,
      category: fields[12] as String?,
      createdAt: fields[13] as DateTime?,
      updatedAt: fields[14] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Goal obj) {
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
      ..write(obj.type)
      ..writeByte(5)
      ..write(obj.targetDate)
      ..writeByte(6)
      ..write(obj.isActive)
      ..writeByte(7)
      ..write(obj.description)
      ..writeByte(8)
      ..write(obj.icon)
      ..writeByte(9)
      ..write(obj.microActions)
      ..writeByte(10)
      ..write(obj.monthlyContribution)
      ..writeByte(11)
      ..write(obj.autoContribution)
      ..writeByte(12)
      ..write(obj.category)
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
      other is GoalAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class GoalTypeAdapter extends TypeAdapter<GoalType> {
  @override
  final int typeId = 4;

  @override
  GoalType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return GoalType.savings;
      case 1:
        return GoalType.debt;
      case 2:
        return GoalType.investment;
      case 3:
        return GoalType.emergency;
      case 4:
        return GoalType.custom;
      default:
        return GoalType.savings;
    }
  }

  @override
  void write(BinaryWriter writer, GoalType obj) {
    switch (obj) {
      case GoalType.savings:
        writer.writeByte(0);
        break;
      case GoalType.debt:
        writer.writeByte(1);
        break;
      case GoalType.investment:
        writer.writeByte(2);
        break;
      case GoalType.emergency:
        writer.writeByte(3);
        break;
      case GoalType.custom:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GoalTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CatalogAdapter extends TypeAdapter<Catalog> {
  @override
  final int typeId = 2;

  @override
  Catalog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Catalog(
      fields[0] as String,
      fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Catalog obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.icon);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CatalogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AccountAdapter extends TypeAdapter<Account> {
  @override
  final int typeId = 1;

  @override
  Account read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Account(
      fields[0] as String,
      fields[1] as String,
      fields[2] as int,
      fields[3] as EVisibility,
    );
  }

  @override
  void write(BinaryWriter writer, Account obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.icon)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.overBalance)
      ..writeByte(3)
      ..write(obj.visibility);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccountAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TransactionItemAdapter extends TypeAdapter<TransactionItem> {
  @override
  final int typeId = 0;

  @override
  TransactionItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TransactionItem(
      fields[0] as TransactionType,
      fields[1] as Catalog,
      fields[4] as int,
      fields[5] as String,
      fields[6] as String,
      fromAccount: fields[2] as Account?,
      toAccount: fields[3] as Account?,
      image: fields[7] as String?,
      key: fields[8] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, TransactionItem obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.type)
      ..writeByte(1)
      ..write(obj.catalog)
      ..writeByte(2)
      ..write(obj.fromAccount)
      ..writeByte(3)
      ..write(obj.toAccount)
      ..writeByte(4)
      ..write(obj.amount)
      ..writeByte(5)
      ..write(obj.note)
      ..writeByte(6)
      ..write(obj.date)
      ..writeByte(7)
      ..write(obj.image)
      ..writeByte(8)
      ..write(obj.key);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class EVisibilityAdapter extends TypeAdapter<EVisibility> {
  @override
  final int typeId = 4;

  @override
  EVisibility read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return EVisibility.visible;
      case 1:
        return EVisibility.hidden;
      default:
        return EVisibility.visible;
    }
  }

  @override
  void write(BinaryWriter writer, EVisibility obj) {
    switch (obj) {
      case EVisibility.visible:
        writer.writeByte(0);
        break;
      case EVisibility.hidden:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EVisibilityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TransactionTypeAdapter extends TypeAdapter<TransactionType> {
  @override
  final int typeId = 3;

  @override
  TransactionType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TransactionType.all;
      case 1:
        return TransactionType.expense;
      case 2:
        return TransactionType.income;
      case 3:
        return TransactionType.transfer;
      default:
        return TransactionType.all;
    }
  }

  @override
  void write(BinaryWriter writer, TransactionType obj) {
    switch (obj) {
      case TransactionType.all:
        writer.writeByte(0);
        break;
      case TransactionType.expense:
        writer.writeByte(1);
        break;
      case TransactionType.income:
        writer.writeByte(2);
        break;
      case TransactionType.transfer:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

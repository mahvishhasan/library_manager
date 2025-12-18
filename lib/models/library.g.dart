// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'library.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LibraryAdapter extends TypeAdapter<Library> {
  @override
  final int typeId = 1;

  @override
  Library read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Library(
      name: fields[0] as String,
      books: (fields[1] as List).cast<Book>(),
      backgroundImagePath: fields[2] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Library obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.books)
      ..writeByte(2)
      ..write(obj.backgroundImagePath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LibraryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'word_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WordModelAdapter extends TypeAdapter<WordModel> {
  @override
  final int typeId = 0;

  @override
  WordModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WordModel(
      id: fields[0] as String,
      word: fields[1] as String,
      meaning: fields[2] as String,
      pronunciation: fields[3] as String?,
      example: fields[4] as String?,
      level: fields[5] as String,
      type: fields[6] as String,
      category: fields[12] as String?,
      learningLanguage: fields[7] as String,
      nativeLanguage: fields[8] as String,
      createdAt: fields[9] as DateTime,
      isInVocabulary: fields[10] as bool,
      groupIds: (fields[11] as List?)?.cast<String>(),
      synonyms: (fields[13] as List?)?.cast<String>(),
      antonyms: (fields[14] as List?)?.cast<String>(),
      verbConjugations: (fields[15] as Map?)?.cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, WordModel obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.word)
      ..writeByte(2)
      ..write(obj.meaning)
      ..writeByte(3)
      ..write(obj.pronunciation)
      ..writeByte(4)
      ..write(obj.example)
      ..writeByte(5)
      ..write(obj.level)
      ..writeByte(6)
      ..write(obj.type)
      ..writeByte(12)
      ..write(obj.category)
      ..writeByte(7)
      ..write(obj.learningLanguage)
      ..writeByte(8)
      ..write(obj.nativeLanguage)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(10)
      ..write(obj.isInVocabulary)
      ..writeByte(11)
      ..write(obj.groupIds)
      ..writeByte(13)
      ..write(obj.synonyms)
      ..writeByte(14)
      ..write(obj.antonyms)
      ..writeByte(15)
      ..write(obj.verbConjugations);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WordModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

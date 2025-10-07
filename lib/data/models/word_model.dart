import 'package:hive/hive.dart';

part 'word_model.g.dart';

@HiveType(typeId: 0)
class WordModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String word;

  @HiveField(2)
  final String meaning;

  @HiveField(3)
  final String? pronunciation;

  @HiveField(4)
  final String? example;

  @HiveField(5)
  final String level; // 'beginner', 'intermediate', 'advanced'

  @HiveField(6)
  final String type; // 'word' or 'expression'

  @HiveField(12)
  final String? category; // 'business', 'travel', 'daily', 'academic', 'casual'

  @HiveField(7)
  final String learningLanguage; // 'en' or 'ko'

  @HiveField(8)
  final String nativeLanguage; // 'en' or 'ko'

  @HiveField(9)
  final DateTime createdAt;

  @HiveField(10)
  bool isInVocabulary;

  @HiveField(11)
  List<String>? groupIds;

  @HiveField(13)
  List<String>? synonyms;

  @HiveField(14)
  List<String>? antonyms;

  @HiveField(15)
  Map<String, dynamic>? verbConjugations; // 동사 변화형 정보

  WordModel({
    required this.id,
    required this.word,
    required this.meaning,
    this.pronunciation,
    this.example,
    required this.level,
    required this.type,
    this.category,
    required this.learningLanguage,
    required this.nativeLanguage,
    required this.createdAt,
    this.isInVocabulary = false,
    this.groupIds,
    this.synonyms,
    this.antonyms,
    this.verbConjugations,
  });

  WordModel copyWith({
    String? id,
    String? word,
    String? meaning,
    String? pronunciation,
    String? example,
    String? level,
    String? type,
    String? category,
    String? learningLanguage,
    String? nativeLanguage,
    DateTime? createdAt,
    bool? isInVocabulary,
    List<String>? groupIds,
    List<String>? synonyms,
    List<String>? antonyms,
    Map<String, dynamic>? verbConjugations,
  }) {
    return WordModel(
      id: id ?? this.id,
      word: word ?? this.word,
      meaning: meaning ?? this.meaning,
      pronunciation: pronunciation ?? this.pronunciation,
      example: example ?? this.example,
      level: level ?? this.level,
      type: type ?? this.type,
      category: category ?? this.category,
      learningLanguage: learningLanguage ?? this.learningLanguage,
      nativeLanguage: nativeLanguage ?? this.nativeLanguage,
      createdAt: createdAt ?? this.createdAt,
      isInVocabulary: isInVocabulary ?? this.isInVocabulary,
      groupIds: groupIds ?? this.groupIds,
      synonyms: synonyms ?? this.synonyms,
      antonyms: antonyms ?? this.antonyms,
      verbConjugations: verbConjugations ?? this.verbConjugations,
    );
  }
}

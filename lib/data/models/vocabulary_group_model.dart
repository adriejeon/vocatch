import 'package:hive/hive.dart';

part 'vocabulary_group_model.g.dart';

@HiveType(typeId: 1)
class VocabularyGroupModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  final DateTime createdAt;

  @HiveField(3)
  DateTime updatedAt;

  @HiveField(4)
  List<String> wordIds;

  VocabularyGroupModel({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    this.wordIds = const [],
  });

  VocabularyGroupModel copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? wordIds,
  }) {
    return VocabularyGroupModel(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      wordIds: wordIds ?? this.wordIds,
    );
  }
}

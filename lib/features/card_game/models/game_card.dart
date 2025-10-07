import '../../../data/models/word_model.dart';

/// 게임에서 사용되는 카드 모델
class GameCard {
  final String id;
  final String content;
  final String matchingContent;
  final bool isWord; // true: 단어, false: 뜻
  final WordModel? wordModel;
  bool isFlipped;
  bool isMatched;

  GameCard({
    required this.id,
    required this.content,
    required this.matchingContent,
    required this.isWord,
    this.wordModel,
    this.isFlipped = false,
    this.isMatched = false,
  });

  GameCard copyWith({
    String? id,
    String? content,
    String? matchingContent,
    bool? isWord,
    WordModel? wordModel,
    bool? isFlipped,
    bool? isMatched,
  }) {
    return GameCard(
      id: id ?? this.id,
      content: content ?? this.content,
      matchingContent: matchingContent ?? this.matchingContent,
      isWord: isWord ?? this.isWord,
      wordModel: wordModel ?? this.wordModel,
      isFlipped: isFlipped ?? this.isFlipped,
      isMatched: isMatched ?? this.isMatched,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GameCard && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

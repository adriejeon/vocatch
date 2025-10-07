import 'game_card.dart';

/// 게임 상태 모델
class GameState {
  final List<GameCard> cards;
  final List<GameCard> flippedCards;
  final int moves;
  final int matches;
  final bool isGameComplete;
  final bool isGameStarted;
  final DateTime? startTime;
  final DateTime? endTime;
  final int score;
  final bool isShowingInitialCards; // 초기 카드 노출 중 여부

  GameState({
    required this.cards,
    this.flippedCards = const [],
    this.moves = 0,
    this.matches = 0,
    this.isGameComplete = false,
    this.isGameStarted = false,
    this.startTime,
    this.endTime,
    this.score = 0,
    this.isShowingInitialCards = false,
  });

  GameState copyWith({
    List<GameCard>? cards,
    List<GameCard>? flippedCards,
    int? moves,
    int? matches,
    bool? isGameComplete,
    bool? isGameStarted,
    DateTime? startTime,
    DateTime? endTime,
    int? score,
    bool? isShowingInitialCards,
  }) {
    return GameState(
      cards: cards ?? this.cards,
      flippedCards: flippedCards ?? this.flippedCards,
      moves: moves ?? this.moves,
      matches: matches ?? this.matches,
      isGameComplete: isGameComplete ?? this.isGameComplete,
      isGameStarted: isGameStarted ?? this.isGameStarted,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      score: score ?? this.score,
      isShowingInitialCards:
          isShowingInitialCards ?? this.isShowingInitialCards,
    );
  }

  /// 게임 시간 계산 (초)
  int get gameTimeInSeconds {
    if (startTime == null) return 0;
    final end = endTime ?? DateTime.now();
    return end.difference(startTime!).inSeconds;
  }

  /// 정확도 계산 (퍼센트)
  double get accuracy {
    if (moves == 0) return 0.0;
    return (matches / moves) * 100;
  }
}

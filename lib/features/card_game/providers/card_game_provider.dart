import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/word_model.dart';
import '../../../data/local/hive_service.dart';
import '../models/game_card.dart';
import '../models/game_state.dart';

/// 카드 매칭 게임 Provider
class CardGameNotifier extends StateNotifier<GameState> {
  CardGameNotifier() : super(GameState(cards: []));

  String? _currentGroupId;
  int? _currentCardCount;

  /// 게임 초기화
  Future<void> initializeGame({required String groupId, int? cardCount}) async {
    try {
      // 그룹의 단어들 가져오기
      final words = await _getWordsFromGroup(groupId);

      // 카드 개수 결정: 지정되지 않았으면 그룹의 모든 단어 사용, 최대 20개
      final actualCardCount = cardCount ?? (words.length * 2).clamp(8, 40);

      if (words.length < actualCardCount ~/ 2) {
        throw Exception(
          '그룹에 충분한 단어가 없습니다. 최소 ${actualCardCount ~/ 2}개의 단어가 필요합니다.',
        );
      }

      // 게임용 카드 생성
      final cards = _createGameCards(words, actualCardCount);

      // 카드 섞기
      cards.shuffle();

      // 초기에 모든 카드를 뒤집은 상태로 시작
      final initialCards = cards
          .map((card) => card.copyWith(isFlipped: true))
          .toList();

      // 현재 그룹 ID와 카드 개수 저장
      _currentGroupId = groupId;
      _currentCardCount = actualCardCount;

      state = GameState(
        cards: initialCards,
        isGameStarted: true,
        startTime: DateTime.now(),
        isShowingInitialCards: true,
      );

      // 2초 후 카드를 다시 뒤집음
      Future.delayed(const Duration(seconds: 2), () {
        if (state.isShowingInitialCards) {
          final hiddenCards = state.cards
              .map((card) => card.copyWith(isFlipped: false))
              .toList();
          state = state.copyWith(
            cards: hiddenCards,
            isShowingInitialCards: false,
          );
        }
      });
    } catch (e) {
      print('Initialize game error: $e');
      rethrow;
    }
  }

  /// 그룹에서 단어들 가져오기
  Future<List<WordModel>> _getWordsFromGroup(String groupId) async {
    // 그룹 정보 가져오기
    final groupBox = HiveService.getGroupsBox();
    final group = groupBox.get(groupId);

    if (group == null || group.wordIds.isEmpty) {
      throw Exception('그룹에 단어가 없습니다.');
    }

    // 단어 박스에서 그룹의 단어들 가져오기
    final wordBox = HiveService.getWordsBox();
    final words = <WordModel>[];

    for (final wordId in group.wordIds) {
      final word = wordBox.get(wordId);
      if (word != null) {
        words.add(word);
      }
    }

    return words;
  }

  /// 게임용 카드 생성
  List<GameCard> _createGameCards(List<WordModel> words, int cardCount) {
    final cards = <GameCard>[];
    final wordCount = cardCount ~/ 2;
    // 단어를 섞어서 랜덤하게 선택
    final shuffledWords = List<WordModel>.from(words)..shuffle();
    final selectedWords = shuffledWords.take(wordCount).toList();

    for (final word in selectedWords) {
      // 단어 카드
      cards.add(
        GameCard(
          id: '${word.id}_word',
          content: word.word,
          matchingContent: word.meaning,
          isWord: true,
          wordModel: word,
        ),
      );

      // 뜻 카드
      cards.add(
        GameCard(
          id: '${word.id}_meaning',
          content: word.meaning,
          matchingContent: word.word,
          isWord: false,
          wordModel: word,
        ),
      );
    }

    return cards;
  }

  /// 카드 클릭 처리
  void flipCard(String cardId) {
    if (state.isGameComplete || state.isShowingInitialCards) return;

    final cardIndex = state.cards.indexWhere((card) => card.id == cardId);
    if (cardIndex == -1) return;

    final card = state.cards[cardIndex];
    if (card.isFlipped || card.isMatched) return;

    // 이미 2장이 뒤집혀 있으면 첫 번째 카드 뒤집기
    if (state.flippedCards.length >= 2) {
      _resetFlippedCards();
    }

    // 카드 뒤집기
    final updatedCards = List<GameCard>.from(state.cards);
    updatedCards[cardIndex] = card.copyWith(isFlipped: true);

    final flippedCards = [
      ...state.flippedCards,
      card.copyWith(isFlipped: true),
    ];

    state = state.copyWith(
      cards: updatedCards,
      flippedCards: flippedCards,
      moves: state.moves + 1,
    );

    // 2장이 뒤집혔으면 매칭 확인
    if (flippedCards.length == 2) {
      _checkMatch(flippedCards);
    }
  }

  /// 뒤집힌 카드들 리셋
  void _resetFlippedCards() {
    final updatedCards = state.cards.map((card) {
      if (state.flippedCards.any((flipped) => flipped.id == card.id)) {
        return card.copyWith(isFlipped: false);
      }
      return card;
    }).toList();

    state = state.copyWith(cards: updatedCards, flippedCards: []);
  }

  /// 매칭 확인
  void _checkMatch(List<GameCard> flippedCards) {
    if (flippedCards.length != 2) return;

    final card1 = flippedCards[0];
    final card2 = flippedCards[1];

    // 매칭 확인 (단어와 뜻이 매칭되는지)
    final isMatch =
        (card1.isWord &&
            !card2.isWord &&
            card1.matchingContent == card2.content) ||
        (!card1.isWord &&
            card2.isWord &&
            card1.content == card2.matchingContent);

    if (isMatch) {
      // 매칭된 카드들 처리
      final updatedCards = state.cards.map((card) {
        if (flippedCards.any((flipped) => flipped.id == card.id)) {
          return card.copyWith(isMatched: true, isFlipped: true);
        }
        return card;
      }).toList();

      final newMatches = state.matches + 1;
      final isGameComplete = newMatches == state.cards.length ~/ 2;

      state = state.copyWith(
        cards: updatedCards,
        flippedCards: [],
        matches: newMatches,
        isGameComplete: isGameComplete,
        endTime: isGameComplete ? DateTime.now() : null,
        score: _calculateScore(),
      );
    } else {
      // 매칭되지 않으면 잠시 후 카드들 뒤집기
      Future.delayed(const Duration(milliseconds: 1000), () {
        _resetFlippedCards();
      });
    }
  }

  /// 점수 계산
  int _calculateScore() {
    if (state.moves == 0) return 0;

    final timeBonus = max(0, 300 - state.gameTimeInSeconds); // 시간 보너스
    final accuracyBonus = (state.accuracy / 100 * 100).round(); // 정확도 보너스
    final matchBonus = state.matches * 50; // 매칭 보너스

    return timeBonus + accuracyBonus + matchBonus;
  }

  /// 게임 리셋
  void resetGame() {
    _currentGroupId = null;
    _currentCardCount = null;
    state = GameState(cards: []);
  }

  /// 게임 재시작
  Future<void> restartGame() async {
    if (_currentGroupId == null) return;

    // 현재 그룹으로 게임 재초기화
    await initializeGame(
      groupId: _currentGroupId!,
      cardCount: _currentCardCount,
    );
  }
}

/// 카드 게임 Provider
final cardGameProvider = StateNotifierProvider<CardGameNotifier, GameState>((
  ref,
) {
  return CardGameNotifier();
});

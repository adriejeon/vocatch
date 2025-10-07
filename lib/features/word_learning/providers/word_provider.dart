import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/local/hive_service.dart';
import '../../../data/models/word_model.dart';

/// 단어 상태를 관리하는 Provider
class WordNotifier extends StateNotifier<List<WordModel>> {
  WordNotifier() : super([]) {
    _loadWords();
  }

  void _loadWords() {
    final box = HiveService.getWordsBox();
    state = box.values.toList();
  }

  /// 단어 추가
  Future<void> addWord(WordModel word) async {
    final box = HiveService.getWordsBox();
    await box.put(word.id, word);
    _loadWords();
  }

  /// 단어 업데이트
  Future<void> updateWord(WordModel word) async {
    final box = HiveService.getWordsBox();
    await box.put(word.id, word);
    _loadWords();
  }

  /// 단어 삭제
  Future<void> deleteWord(String wordId) async {
    final box = HiveService.getWordsBox();
    await box.delete(wordId);
    _loadWords();
  }

  /// 단어장에 추가/제거
  Future<void> toggleVocabulary(String wordId) async {
    final box = HiveService.getWordsBox();
    final word = box.get(wordId);
    if (word != null) {
      final updatedWord = word.copyWith(isInVocabulary: !word.isInVocabulary);
      await box.put(wordId, updatedWord);
      _loadWords();
    }
  }

  /// 그룹에 단어 추가
  Future<void> addWordToGroup(String wordId, String groupId) async {
    final box = HiveService.getWordsBox();
    final word = box.get(wordId);
    if (word != null) {
      final groupIds = word.groupIds ?? [];
      if (!groupIds.contains(groupId)) {
        groupIds.add(groupId);
        final updatedWord = word.copyWith(groupIds: groupIds);
        await box.put(wordId, updatedWord);
        _loadWords();
      }
    }
  }

  /// 그룹에서 단어 제거
  Future<void> removeWordFromGroup(String wordId, String groupId) async {
    final box = HiveService.getWordsBox();
    final word = box.get(wordId);
    if (word != null) {
      final groupIds = word.groupIds ?? [];
      groupIds.remove(groupId);
      final updatedWord = word.copyWith(groupIds: groupIds);
      await box.put(wordId, updatedWord);
      _loadWords();
    }
  }

  /// 레벨별 단어 가져오기
  List<WordModel> getWordsByLevel(String level, String learningLanguage) {
    return state
        .where(
          (word) =>
              word.level == level && word.learningLanguage == learningLanguage,
        )
        .toList();
  }

  /// 단어장에 있는 단어만 가져오기
  List<WordModel> getVocabularyWords() {
    return state.where((word) => word.isInVocabulary).toList();
  }

  /// 특정 그룹의 단어 가져오기
  List<WordModel> getWordsByGroup(String groupId) {
    return state
        .where((word) => word.groupIds?.contains(groupId) ?? false)
        .toList();
  }

  /// 데이터베이스에서 단어 목록 새로고침 (다른 Provider의 변경사항 반영)
  Future<void> refreshWords() async {
    _loadWords();
  }
}

/// 단어 Provider
final wordProvider = StateNotifierProvider<WordNotifier, List<WordModel>>((
  ref,
) {
  return WordNotifier();
});

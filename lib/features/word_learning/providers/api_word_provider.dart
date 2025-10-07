import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/services/dictionary_api_service.dart';
import '../../../data/models/word_model.dart';
import '../../../data/local/hive_service.dart';

/// API를 통해 동적으로 단어를 가져오는 Provider
class ApiWordNotifier extends StateNotifier<List<WordModel>> {
  ApiWordNotifier() : super([]);

  /// 일일 단어를 API에서 가져와서 데이터베이스에 저장
  Future<void> loadDailyWords({
    required String level,
    required String learningLanguage,
    required String nativeLanguage,
    int count = 5,
  }) async {
    try {
      state = []; // 로딩 상태
      
      // API에서 단어 생성
      final words = await DictionaryApiService.generateDailyWords(
        level: level,
        learningLanguage: learningLanguage,
        nativeLanguage: nativeLanguage,
        count: count,
      );

      // 데이터베이스에 저장
      final box = HiveService.getWordsBox();
      for (var word in words) {
        await box.put(word.id, word);
      }

      state = words;
    } catch (e) {
      print('Load daily words error: $e');
      state = [];
    }
  }

  /// 특정 단어를 API에서 검색하여 추가
  Future<WordModel?> searchAndAddWord({
    required String word,
    required String level,
    required String learningLanguage,
    required String nativeLanguage,
  }) async {
    try {
      final wordModel = await DictionaryApiService.createWordFromApi(
        word: word,
        level: level,
        learningLanguage: learningLanguage,
        nativeLanguage: nativeLanguage,
      );

      if (wordModel != null) {
        // 데이터베이스에 저장
        final box = HiveService.getWordsBox();
        await box.put(wordModel.id, wordModel);
        
        // 상태 업데이트
        state = [...state, wordModel];
      }

      return wordModel;
    } catch (e) {
      print('Search and add word error: $e');
      return null;
    }
  }

  /// 기존 단어 목록 로드
  Future<void> loadExistingWords({
    required String level,
    required String learningLanguage,
  }) async {
    try {
      final box = HiveService.getWordsBox();
      final allWords = box.values.toList();
      
      final filteredWords = allWords
          .where((word) =>
              word.level == level && 
              word.learningLanguage == learningLanguage)
          .toList();

      state = filteredWords;
    } catch (e) {
      print('Load existing words error: $e');
      state = [];
    }
  }

  /// 단어를 단어장에 추가/제거
  Future<void> toggleVocabulary(String wordId) async {
    try {
      final box = HiveService.getWordsBox();
      final word = box.get(wordId);
      
      if (word != null) {
        final updatedWord = word.copyWith(
          isInVocabulary: !word.isInVocabulary,
        );
        await box.put(wordId, updatedWord);
        
        // 상태 업데이트
        final index = state.indexWhere((w) => w.id == wordId);
        if (index != -1) {
          state = [
            ...state.sublist(0, index),
            updatedWord,
            ...state.sublist(index + 1),
          ];
        }
      }
    } catch (e) {
      print('Toggle vocabulary error: $e');
    }
  }

  /// 단어 삭제
  Future<void> deleteWord(String wordId) async {
    try {
      final box = HiveService.getWordsBox();
      await box.delete(wordId);
      
      // 상태에서 제거
      state = state.where((word) => word.id != wordId).toList();
    } catch (e) {
      print('Delete word error: $e');
    }
  }
}

/// API 단어 Provider
final apiWordProvider = StateNotifierProvider<ApiWordNotifier, List<WordModel>>((ref) {
  return ApiWordNotifier();
});

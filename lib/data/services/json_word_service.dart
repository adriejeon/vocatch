import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/word_model.dart';
import 'dictionary_api_service.dart';

/// JSON 파일 기반 단어 서비스
class JsonWordService {
  static const String _learnedWordsKey = 'learned_words_json';
  static const String _lastLoadDateKey = 'last_json_word_load_date';

  // 캐시된 데이터
  static Map<String, List<Map<String, dynamic>>>? _cachedData;

  /// JSON 파일에서 단어 데이터 로드
  static Future<Map<String, List<Map<String, dynamic>>>> _loadJsonData(
    String language,
    String level,
    String category,
  ) async {
    final cacheKey = '${language}_${level}_${category}';

    if (_cachedData != null && _cachedData!.containsKey(cacheKey)) {
      return {cacheKey: _cachedData![cacheKey]!};
    }

    try {
      // 파일명 생성
      final fileName = '${language}_${level}_${category}.json';
      final jsonContent = await rootBundle.loadString('assets/data/$fileName');
      final List<dynamic> jsonData = json.decode(jsonContent);

      final words = jsonData
          .map((item) => Map<String, dynamic>.from(item))
          .toList();

      if (_cachedData == null) {
        _cachedData = {};
      }
      _cachedData![cacheKey] = words;

      print('Loaded ${words.length} words from $fileName');
      return {cacheKey: words};
    } catch (e) {
      print('Error loading JSON data: $e');
      return {cacheKey: []};
    }
  }

  /// 학습 완료 단어 Set 로드
  static Future<Set<String>> _loadLearnedWords() async {
    final prefs = await SharedPreferences.getInstance();
    final learnedList = prefs.getStringList(_learnedWordsKey) ?? [];
    return Set<String>.from(learnedList);
  }

  /// 학습 완료 단어 Set 저장
  static Future<void> _saveLearnedWords(Set<String> learnedWords) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_learnedWordsKey, learnedWords.toList());
  }

  /// 오늘의 단어 가져오기
  static Future<List<WordModel>> getTodayWords({
    required String language,
    required String level,
    required String category,
    required String learningLanguage,
    required String nativeLanguage,
    int count = 5,
  }) async {
    try {
      // 1. 학습 완료 단어 목록 로드
      final learnedWords = await _loadLearnedWords();

      // 2. JSON 데이터 로드
      final data = await _loadJsonData(language, level, category);
      final cacheKey = '${language}_${level}_${category}';
      final allWords = data[cacheKey] ?? [];

      if (allWords.isEmpty) {
        print('No words found in JSON file');
        return [];
      }

      // 3. 아직 학습하지 않은 단어 필터링
      final availableWords = allWords.where((wordData) {
        final word = _getWordFromData(wordData, language);
        return !learnedWords.contains(word);
      }).toList();

      // 4. 단어가 부족하면 전체에서 랜덤 선택
      final wordsToUse = availableWords.isEmpty ? allWords : availableWords;

      // 5. 랜덤으로 섞어서 필요한 개수만큼 선택
      final shuffled = List<Map<String, dynamic>>.from(wordsToUse);
      shuffled.shuffle(Random());
      final selectedWords = shuffled.take(count).toList();

      // 6. WordModel로 변환
      final List<WordModel> wordModels = [];
      for (int i = 0; i < selectedWords.length; i++) {
        final wordData = selectedWords[i];
        final wordModel = await _convertToWordModel(
          wordData,
          language,
          level,
          category,
          learningLanguage,
          nativeLanguage,
          i,
        );

        if (wordModel != null) {
          wordModels.add(wordModel);
        }
      }

      // 7. 학습 완료 목록에 추가
      final newWords = wordModels.map((w) => w.word).toList();
      learnedWords.addAll(newWords);
      await _saveLearnedWords(learnedWords);

      // 8. 로드 날짜 저장
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now().toIso8601String().split('T')[0];
      await prefs.setString(_lastLoadDateKey, today);

      print(
        'Generated ${wordModels.length} words for $language $level $category',
      );
      return wordModels;
    } catch (e) {
      print('Error getting today words: $e');
      return [];
    }
  }

  /// JSON 데이터에서 단어 추출
  static String _getWordFromData(
    Map<String, dynamic> wordData,
    String language,
  ) {
    if (language == 'EN') {
      return wordData['word']?.toString() ?? '';
    } else {
      return wordData['word_ko']?.toString() ?? '';
    }
  }

  /// JSON 데이터를 WordModel로 변환
  static Future<WordModel?> _convertToWordModel(
    Map<String, dynamic> wordData,
    String language,
    String level,
    String category,
    String learningLanguage,
    String nativeLanguage,
    int index,
  ) async {
    try {
      final word = _getWordFromData(wordData, language);
      final example = wordData['example']?.toString() ?? '';

      if (word.isEmpty) return null;

      // Dictionary API에서 발음 정보 가져오기
      String? pronunciation;
      try {
        final apiWordModel = await DictionaryApiService.createWordFromApi(
          word: word,
          level: _convertLevelToApi(level),
          learningLanguage: learningLanguage,
          nativeLanguage: nativeLanguage,
          category: _convertCategoryToApi(category),
        );
        pronunciation = apiWordModel?.pronunciation;
      } catch (e) {
        print('Dictionary API error for $word: $e');
      }

      // 의미 추출
      String meaning;
      if (language == 'EN') {
        meaning = wordData['meaning_ko']?.toString() ?? '';
      } else {
        meaning = wordData['meaning_en']?.toString() ?? '';
      }

      // 품사 정보 추출
      final pos = wordData['pos']?.toString() ?? '';

      return WordModel(
        id: 'json_${DateTime.now().millisecondsSinceEpoch}_$index',
        word: word,
        meaning: meaning,
        pronunciation: pronunciation,
        example: example,
        level: _convertLevelToApi(level),
        type: 'word',
        category: _convertCategoryToApi(category),
        learningLanguage: learningLanguage,
        nativeLanguage: nativeLanguage,
        createdAt: DateTime.now(),
        isInVocabulary: false,
        // 품사 정보를 synonyms 필드에 임시 저장 (WordModel에 pos 필드가 없으므로)
        synonyms: pos.isNotEmpty ? [pos] : null,
      );
    } catch (e) {
      print('Error converting to WordModel: $e');
      return null;
    }
  }

  /// 레벨 변환 (한국어 -> API 형식)
  static String _convertLevelToApi(String level) {
    switch (level) {
      case '기초다지기':
        return 'beginner';
      case '표현력확장':
        return 'intermediate';
      case '원어민수준':
        return 'advanced';
      default:
        return 'beginner';
    }
  }

  /// 카테고리 변환 (한국어 -> API 형식)
  static String _convertCategoryToApi(String category) {
    switch (category) {
      case '일상회화':
        return 'conversation';
      case '여행':
        return 'travel';
      case '비즈니스':
        return 'business';
      case '뉴스-시사':
        return 'news';
      default:
        return 'conversation';
    }
  }

  /// 오늘 단어가 이미 로드되었는지 확인
  static Future<bool> hasLoadedToday() async {
    final prefs = await SharedPreferences.getInstance();
    final lastLoadDate = prefs.getString(_lastLoadDateKey);
    final today = DateTime.now().toIso8601String().split('T')[0];
    return lastLoadDate == today;
  }

  /// 학습 완료 단어 초기화 (테스트용)
  static Future<void> resetLearnedWords() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_learnedWordsKey);
    await prefs.remove(_lastLoadDateKey);
  }

  /// 학습 통계 정보 가져오기
  static Future<Map<String, dynamic>> getLearnedWordsStats() async {
    final learnedWords = await _loadLearnedWords();
    return {'total': learnedWords.length, 'words': learnedWords.toList()};
  }
}

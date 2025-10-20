import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/word_model.dart';
import 'dictionary_api_service.dart';
import 'words_api_service.dart';
import 'vocab_svg_parser.dart';
import 'json_word_service.dart';

/// 오늘의 단어 생성 서비스 (학습 진행 추적 포함)
class DailyWordService {
  // SharedPreferences keys
  static const String _lastUpdateDateKey = 'daily_words_last_update_date';
  static const String _dailyWordsKey = 'daily_words_cache';
  static const String _learnedWordsKey = 'learned_words_set';

  // 데이터 캐시
  static Map<String, dynamic>? _coreWordsData;
  static Map<String, dynamic>? _wordFrequencyData;

  /// 데이터 파일 로드 (최초 1회만)
  static Future<void> _loadDataFiles() async {
    if (_coreWordsData == null) {
      final coreWordsJson = await rootBundle.loadString(
        'assets/data/core_words.json',
      );
      _coreWordsData = json.decode(coreWordsJson);
    }

    if (_wordFrequencyData == null) {
      final frequencyJson = await rootBundle.loadString(
        'assets/data/word_frequency.json',
      );
      _wordFrequencyData = json.decode(frequencyJson);
    }
  }

  /// 현재 날짜를 문자열로 반환 (YYYY-MM-DD)
  static String _getCurrentDate() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
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

  /// 캐시된 오늘의 단어 로드 (언어 정보 포함)
  static Future<List<String>?> _loadCachedDailyWords(
    String category,
    String level,
    String learningLanguage,
    String nativeLanguage,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey =
        '${_dailyWordsKey}_${category}_${level}_${learningLanguage}_$nativeLanguage';
    final cachedWordsJson = prefs.getString(cacheKey);

    if (cachedWordsJson != null) {
      final List<dynamic> decoded = json.decode(cachedWordsJson);
      return decoded.map((e) => e.toString()).toList();
    }

    return null;
  }

  /// 오늘의 단어 캐시 저장 (언어 정보 포함)
  static Future<void> _saveDailyWordsCache(
    String category,
    String level,
    String learningLanguage,
    String nativeLanguage,
    List<String> words,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final today = _getCurrentDate();
    final cacheKey =
        '${_dailyWordsKey}_${category}_${level}_${learningLanguage}_$nativeLanguage';

    await prefs.setString(_lastUpdateDateKey, today);
    await prefs.setString(cacheKey, json.encode(words));
  }

  /// ========== 메인 함수: 오늘의 단어 가져오기 ==========
  static Future<List<WordModel>> getDailyWords({
    required String category,
    required String level,
    required String learningLanguage,
    required String nativeLanguage,
    int coreCount = 3,
    int expansionCount = 2,
  }) async {
    try {
      // 1. JSON 서비스 사용 (새로운 시스템)
      final jsonLanguage = learningLanguage == 'English' ? 'EN' : 'KO';
      final jsonLevel = _convertLevelToJson(level);
      final jsonCategory = _convertCategoryToJson(category);

      // JSON 서비스로 오늘의 단어 가져오기
      final jsonWords = await JsonWordService.getTodayWords(
        language: jsonLanguage,
        level: jsonLevel,
        category: jsonCategory,
        learningLanguage: learningLanguage,
        nativeLanguage: nativeLanguage,
        count: 5,
      );

      if (jsonWords.isNotEmpty) {
        print('JSON words loaded: ${jsonWords.length} words');
        return jsonWords;
      }

      // 2. JSON 서비스 실패 시 기존 시스템 사용
      print('JSON service failed, falling back to legacy system');

      // 기존 데이터 파일 로드
      await _loadDataFiles();

      final today = _getCurrentDate();
      final prefs = await SharedPreferences.getInstance();
      final lastUpdatedDate = prefs.getString(_lastUpdateDateKey);

      // 3. 날짜가 같으면 캐시된 단어 반환 (한국어의 경우 캐시 무시)
      if (lastUpdatedDate == today && learningLanguage != 'Korean') {
        final cachedWords = await _loadCachedDailyWords(
          category,
          level,
          learningLanguage,
          nativeLanguage,
        );
        if (cachedWords != null && cachedWords.isNotEmpty) {
          // 캐시된 단어들을 WordModel로 변환 (원래 언어 설정 유지)
          return await _convertToWordModels(
            cachedWords,
            level,
            learningLanguage,
            nativeLanguage,
            category,
          );
        }
      }

      // 4. 학습 완료 단어 목록 로드
      Set<String> learnedWords = await _loadLearnedWords();

      // 5. 오늘의 단어 목록 생성
      List<String> newDailyWords = [];

      // 일상회화 카테고리이고 기초다지기 레벨인 경우 SVG 파서 사용
      if (category == 'conversation' &&
          level == 'beginner' &&
          learningLanguage == 'English') {
        final svgWords = await VocabSvgParser.getRandomConversationWords(
          count: 5,
        );
        newDailyWords = svgWords
            .map((w) => w['word'] ?? '')
            .where((w) => w.isNotEmpty)
            .toList();
        print(
          'SVG conversation words: $newDailyWords (count: ${newDailyWords.length})',
        );
      } else {
        // 6. 코어 단어 가져오기
        final coreWords = await _getCoreWords(
          category,
          level,
          learnedWords,
          coreCount,
          learningLanguage,
        );
        print('Korean core words: $coreWords (count: ${coreWords.length})');
        newDailyWords.addAll(coreWords);
      }

      // 6. 확장 단어 가져오기
      if (learnedWords.isNotEmpty) {
        final expansionWords = await _getExpansionWords(
          level,
          learnedWords,
          expansionCount,
          learningLanguage,
        );
        newDailyWords.addAll(expansionWords);
      }

      // 한국어의 경우 항상 추가 코어 단어 생성 (5개 보장)
      if (learningLanguage == 'Korean' && newDailyWords.length < 5) {
        final neededCount = 5 - newDailyWords.length;
        print(
          'Korean needs $neededCount more words. Current: ${newDailyWords.length}',
        );
        final additionalCoreWords = await _getCoreWords(
          category,
          level,
          learnedWords,
          neededCount,
          learningLanguage,
        );
        print(
          'Korean additional words: $additionalCoreWords (count: ${additionalCoreWords.length})',
        );
        newDailyWords.addAll(additionalCoreWords);
      } else if (learningLanguage != 'Korean' && learnedWords.isEmpty) {
        // 영어의 경우 학습한 단어가 없으면 코어 단어를 더 많이 생성
        final additionalCoreWords = await _getCoreWords(
          category,
          level,
          learnedWords,
          expansionCount,
          learningLanguage,
        );
        newDailyWords.addAll(additionalCoreWords);
      }

      // 7. 총 5개로 제한
      print(
        'Final Korean words: $newDailyWords (count: ${newDailyWords.length})',
      );
      if (newDailyWords.length > 5) {
        newDailyWords = newDailyWords.take(5).toList();
      }

      // 7. 학습 완료 목록에 추가
      learnedWords.addAll(newDailyWords);
      await _saveLearnedWords(learnedWords);

      // 8. 캐시 저장
      await _saveDailyWordsCache(
        category,
        level,
        learningLanguage,
        nativeLanguage,
        newDailyWords,
      );

      // 9. WordModel로 변환하여 반환
      return await _convertToWordModels(
        newDailyWords,
        level,
        learningLanguage,
        nativeLanguage,
        category,
      );
    } catch (e) {
      print('getDailyWords error: $e');
      return [];
    }
  }

  /// 코어 단어 가져오기
  static Future<List<String>> _getCoreWords(
    String category,
    String level,
    Set<String> learnedWords,
    int count,
    String learningLanguage,
  ) async {
    try {
      if (_coreWordsData == null) return [];

      // 학습언어에 따라 데이터 경로 결정
      Map<String, dynamic> categoryData;
      if (learningLanguage == 'Korean') {
        // 한국어의 경우: korean -> category -> level
        final koreanData = _coreWordsData!['korean'];
        if (koreanData == null) return [];
        categoryData = koreanData[category];
      } else {
        // 영어의 경우: category -> level
        categoryData = _coreWordsData![category];
      }

      final List<dynamic> wordList = categoryData[level] ?? [];

      // 단어 목록에서 중복 제거
      final uniqueWordList = <String>[];
      for (dynamic word in wordList) {
        final wordStr = word.toString();
        if (!uniqueWordList.contains(wordStr)) {
          uniqueWordList.add(wordStr);
        }
      }

      // 아직 학습하지 않은 단어만 필터링
      final availableWords = uniqueWordList
          .where((word) => !learnedWords.contains(word))
          .toList();

      // 단어가 부족하면 가능한 만큼만 반환
      if (availableWords.isEmpty) {
        // 학습한 단어가 많아서 새 단어가 없는 경우, 전체 목록에서 랜덤 선택
        final allWords = uniqueWordList.toList();
        allWords.shuffle();

        // 중복 제거
        final uniqueAllWords = <String>[];
        for (String word in allWords) {
          if (!uniqueAllWords.contains(word)) {
            uniqueAllWords.add(word);
          }
        }

        return uniqueAllWords.take(count).toList();
      }

      // 랜덤으로 섞어서 필요한 개수만큼 반환 (정확히 count개)
      availableWords.shuffle();
      final selectedWords = availableWords.take(count).toList();

      // 중복 제거
      final uniqueSelectedWords = <String>[];
      for (String word in selectedWords) {
        if (!uniqueSelectedWords.contains(word)) {
          uniqueSelectedWords.add(word);
        }
      }

      // 부족한 경우 전체 목록에서 추가 선택
      if (uniqueSelectedWords.length < count && uniqueWordList.isNotEmpty) {
        final remainingNeeded = count - uniqueSelectedWords.length;
        final additionalWords = uniqueWordList
            .where((word) => !uniqueSelectedWords.contains(word))
            .take(remainingNeeded)
            .toList();
        uniqueSelectedWords.addAll(additionalWords);
      }

      // 한국어의 경우 여전히 부족하면 다른 카테고리에서 단어 가져오기
      if (learningLanguage == 'Korean' && uniqueSelectedWords.length < count) {
        final remainingNeeded = count - uniqueSelectedWords.length;
        final additionalWords = await _getKoreanWordsFromOtherCategories(
          category,
          level,
          learnedWords,
          remainingNeeded,
        );
        uniqueSelectedWords.addAll(additionalWords);
      }

      return uniqueSelectedWords;
    } catch (e) {
      print('_getCoreWords error: $e');
      return [];
    }
  }

  /// 한국어 단어를 다른 카테고리에서 가져오기
  static Future<List<String>> _getKoreanWordsFromOtherCategories(
    String currentCategory,
    String level,
    Set<String> learnedWords,
    int count,
  ) async {
    try {
      if (_coreWordsData == null) return [];

      final koreanData = _coreWordsData!['korean'];
      if (koreanData == null) return [];

      final allKoreanWords = <String>[];

      // 모든 카테고리에서 단어 수집 (현재 카테고리 제외)
      for (final category in koreanData.keys) {
        if (category != currentCategory) {
          final categoryData = koreanData[category];
          if (categoryData is Map && categoryData.containsKey(level)) {
            final levelData = categoryData[level];
            if (levelData is List) {
              allKoreanWords.addAll(levelData.map((e) => e.toString()));
            }
          }
        }
      }

      // 이미 학습한 단어 제거
      final availableWords = allKoreanWords
          .where((word) => !learnedWords.contains(word))
          .toList();

      // 랜덤으로 섞어서 필요한 개수만큼 반환
      availableWords.shuffle();
      return availableWords.take(count).toList();
    } catch (e) {
      print('_getKoreanWordsFromOtherCategories error: $e');
      return [];
    }
  }

  /// 한국어 관련 단어 가져오기 (코어 데이터에서)
  static List<String> _getKoreanRelatedWords(
    String seedWord,
    Set<String> learnedWords,
    int count,
  ) {
    try {
      if (_coreWordsData == null) return [];

      // 모든 한국어 카테고리에서 관련 단어 찾기
      final koreanData = _coreWordsData!['korean'];
      if (koreanData == null) return [];

      final allKoreanWords = <String>[];

      // 모든 카테고리와 레벨에서 단어 수집
      for (final category in koreanData.keys) {
        final categoryData = koreanData[category];
        if (categoryData is Map) {
          for (final level in categoryData.keys) {
            final levelData = categoryData[level];
            if (levelData is List) {
              allKoreanWords.addAll(levelData.map((e) => e.toString()));
            }
          }
        }
      }

      // 이미 학습한 단어 제거
      final availableWords = allKoreanWords
          .where((word) => !learnedWords.contains(word))
          .toList();

      // 랜덤으로 섞어서 필요한 개수만큼 반환
      availableWords.shuffle();
      return availableWords.take(count).toList();
    } catch (e) {
      print('_getKoreanRelatedWords error: $e');
      return [];
    }
  }

  /// 확장 단어 가져오기 (WordsAPI 사용)
  static Future<List<String>> _getExpansionWords(
    String level,
    Set<String> learnedWords,
    int count,
    String learningLanguage,
  ) async {
    try {
      // 학습한 단어가 없으면 빈 배열 반환
      if (learnedWords.isEmpty) {
        return [];
      }

      // 학습한 단어 중에서 랜덤으로 씨앗 단어 선택
      final learnedList = learnedWords.toList();
      final random = Random();
      final seedWord = learnedList[random.nextInt(learnedList.length)];

      // 한국어의 경우 관련 단어는 코어 데이터에서 가져오기
      if (learningLanguage == 'Korean') {
        return _getKoreanRelatedWords(seedWord, learnedWords, count);
      }

      // 영어의 경우 WordsAPI로 관련 단어 가져오기
      final relatedWords = await WordsApiService.getRelatedWords(seedWord);

      if (relatedWords.isEmpty) {
        return [];
      }

      // 이미 학습한 단어 제거
      final newWords = relatedWords
          .where((word) => !learnedWords.contains(word))
          .toList();

      if (newWords.isEmpty) {
        return [];
      }

      // 난이도 필터링
      final filteredWords = _filterWordsByLevel(newWords, level);

      if (filteredWords.isEmpty) {
        // 필터링 결과가 없으면 원본에서 선택
        newWords.shuffle();
        return newWords.take(count).toList();
      }

      // 랜덤으로 필요한 개수만큼 반환 (정확히 count개)
      filteredWords.shuffle();
      final selectedWords = filteredWords.take(count).toList();

      // 부족한 경우 원본에서 추가 선택
      if (selectedWords.length < count && newWords.isNotEmpty) {
        final remainingNeeded = count - selectedWords.length;
        final additionalWords = newWords
            .where((word) => !selectedWords.contains(word))
            .take(remainingNeeded)
            .toList();
        selectedWords.addAll(additionalWords);
      }

      return selectedWords;
    } catch (e) {
      print('_getExpansionWords error: $e');
      return [];
    }
  }

  /// 레벨에 따라 단어 필터링 (word_frequency.json 사용)
  static List<String> _filterWordsByLevel(List<String> words, String level) {
    if (_wordFrequencyData == null) return words;

    return words.where((word) {
      final frequency = _wordFrequencyData![word.toLowerCase()];

      // 빈도 데이터가 없는 단어는 제외
      if (frequency == null) return false;

      final rank = frequency as int;

      switch (level) {
        case 'beginner':
          // 기초다지기: 1~3000위 단어
          return rank >= 1 && rank <= 3000;
        case 'intermediate':
          // 표현력확장: 3001~10000위 단어
          return rank > 3000 && rank <= 10000;
        case 'advanced':
          // 원어민수준: 10001~30000위 단어
          return rank > 10000 && rank <= 30000;
        default:
          return true;
      }
    }).toList();
  }

  /// 단어 문자열 목록을 WordModel로 변환
  static Future<List<WordModel>> _convertToWordModels(
    List<String> words,
    String level,
    String learningLanguage,
    String nativeLanguage,
    String category,
  ) async {
    final List<WordModel> wordModels = [];

    // 일상회화 카테고리이고 기초다지기 레벨인 경우 SVG 파서 사용
    if (category == 'conversation' &&
        level == 'beginner' &&
        learningLanguage == 'English') {
      return await VocabSvgParser.convertToWordModels(
        level: level,
        learningLanguage: learningLanguage,
        nativeLanguage: nativeLanguage,
        category: category,
        count: words.length,
      );
    }

    for (String word in words) {
      final wordModel = await DictionaryApiService.createWordFromApi(
        word: word,
        level: level,
        learningLanguage: learningLanguage,
        nativeLanguage: nativeLanguage,
        category: category,
      );

      if (wordModel != null) {
        wordModels.add(wordModel);
      }
    }

    return wordModels;
  }

  /// 강제로 새로운 단어 생성 (캐시 무시)
  static Future<List<WordModel>> forceGenerateNewWords({
    required String category,
    required String level,
    required String learningLanguage,
    required String nativeLanguage,
    int coreCount = 3,
    int expansionCount = 2,
  }) async {
    try {
      // 캐시 삭제 (언어 정보 포함)
      final prefs = await SharedPreferences.getInstance();
      final cacheKey =
          '${_dailyWordsKey}_${category}_${level}_${learningLanguage}_$nativeLanguage';
      await prefs.remove(cacheKey);
      await prefs.remove(_lastUpdateDateKey);

      // 새로운 단어 생성
      return await getDailyWords(
        category: category,
        level: level,
        learningLanguage: learningLanguage,
        nativeLanguage: nativeLanguage,
        coreCount: coreCount,
        expansionCount: expansionCount,
      );
    } catch (e) {
      print('forceGenerateNewWords error: $e');
      return [];
    }
  }

  /// 학습 완료 단어 초기화 (테스트용)
  static Future<void> resetLearnedWords() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_learnedWordsKey);
  }

  /// 학습 통계 정보 가져오기
  static Future<Map<String, dynamic>> getLearnedWordsStats() async {
    final learnedWords = await _loadLearnedWords();

    return {'total': learnedWords.length, 'words': learnedWords.toList()};
  }

  /// 레벨을 JSON 형식으로 변환
  static String _convertLevelToJson(String level) {
    switch (level) {
      case 'beginner':
        return '기초다지기';
      case 'intermediate':
        return '표현력확장';
      case 'advanced':
        return '원어민수준';
      default:
        return '기초다지기';
    }
  }

  /// 카테고리를 JSON 형식으로 변환
  static String _convertCategoryToJson(String category) {
    switch (category) {
      case 'conversation':
        return '일상회화';
      case 'travel':
        return '여행';
      case 'business':
        return '비즈니스';
      case 'news':
        return '뉴스-시사';
      default:
        return '일상회화';
    }
  }
}

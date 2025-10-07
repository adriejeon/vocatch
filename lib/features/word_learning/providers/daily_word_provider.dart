import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/services/daily_word_service.dart';
import '../../../data/models/word_model.dart';
import '../../../data/local/hive_service.dart';

/// 일일 단어 상태 모델 (학습언어별, 난이도별, 카테고리별 독립 관리)
class DailyWordState {
  final Map<String, Map<String, Map<String, List<WordModel>>>>
  languageLevelCategoryWords; // language -> level -> category -> words
  final Map<String, Map<String, Map<String, bool>>>
  languageLevelCategoryLoaded; // language -> level -> category -> loaded
  final bool isLoading;
  final String? currentCategory;
  final String? currentLevel;
  final String? currentLanguage;

  DailyWordState({
    required this.languageLevelCategoryWords,
    required this.languageLevelCategoryLoaded,
    required this.isLoading,
    this.currentCategory,
    this.currentLevel,
    this.currentLanguage,
  });

  DailyWordState copyWith({
    Map<String, Map<String, Map<String, List<WordModel>>>>?
    languageLevelCategoryWords,
    Map<String, Map<String, Map<String, bool>>>? languageLevelCategoryLoaded,
    bool? isLoading,
    String? currentCategory,
    String? currentLevel,
    String? currentLanguage,
  }) {
    return DailyWordState(
      languageLevelCategoryWords:
          languageLevelCategoryWords ?? this.languageLevelCategoryWords,
      languageLevelCategoryLoaded:
          languageLevelCategoryLoaded ?? this.languageLevelCategoryLoaded,
      isLoading: isLoading ?? this.isLoading,
      currentCategory: currentCategory ?? this.currentCategory,
      currentLevel: currentLevel ?? this.currentLevel,
      currentLanguage: currentLanguage ?? this.currentLanguage,
    );
  }

  // 현재 학습언어, 난이도, 카테고리의 단어 목록 가져오기
  List<WordModel> get words {
    if (currentLanguage == null ||
        currentLevel == null ||
        currentCategory == null ||
        languageLevelCategoryWords.isEmpty) {
      return [];
    }
    try {
      return languageLevelCategoryWords[currentLanguage!]?[currentLevel!]?[currentCategory!] ??
          [];
    } catch (e) {
      print('Error accessing words: $e');
      return [];
    }
  }

  // 현재 학습언어, 난이도, 카테고리의 로드 상태 가져오기
  bool get hasLoadedToday {
    if (currentLanguage == null ||
        currentLevel == null ||
        currentCategory == null ||
        languageLevelCategoryLoaded.isEmpty) {
      return false;
    }
    try {
      return languageLevelCategoryLoaded[currentLanguage!]?[currentLevel!]?[currentCategory!] ??
          false;
    } catch (e) {
      print('Error accessing hasLoadedToday: $e');
      return false;
    }
  }
}

/// 일일 단어 관리 Provider
class DailyWordNotifier extends StateNotifier<DailyWordState> {
  DailyWordNotifier()
    : super(
        DailyWordState(
          languageLevelCategoryWords:
              <String, Map<String, Map<String, List<WordModel>>>>{},
          languageLevelCategoryLoaded:
              <String, Map<String, Map<String, bool>>>{},
          isLoading: false,
        ),
      ) {
    // 초기화 시 기존 데이터 자동 복원
    _autoRestoreFromCache();
  }

  static const String _lastLoadDateKey = 'last_daily_word_load_date';
  static const String _dailyWordsKey = 'daily_words';
  static const String _lastCategoryKey = 'last_daily_word_category';
  static const String _lastLevelKey = 'last_daily_word_level';
  static const String _lastLearningLangKey = 'last_daily_word_learning_lang';
  static const String _lastLanguageKey = 'last_daily_word_language';

  /// 앱 시작 시 캐시된 오늘의 단어 자동 복원 (카테고리별)
  Future<void> _autoRestoreFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastLoadDate = prefs.getString(_lastLoadDateKey);
      final today = DateTime.now().toIso8601String().split('T')[0];

      if (lastLoadDate == today) {
        // 모든 학습언어, 난이도, 카테고리에 대해 캐시된 데이터 확인
        final languages = ['en', 'ko']; // 영어, 한국어
        final levels = ['beginner', 'intermediate', 'advanced'];
        final categories = ['conversation', 'travel', 'business', 'news'];
        final Map<String, Map<String, Map<String, List<WordModel>>>>
        languageLevelCategoryWords =
            <String, Map<String, Map<String, List<WordModel>>>>{};
        final Map<String, Map<String, Map<String, bool>>>
        languageLevelCategoryLoaded =
            <String, Map<String, Map<String, bool>>>{};

        for (String language in languages) {
          languageLevelCategoryWords[language] =
              <String, Map<String, List<WordModel>>>{};
          languageLevelCategoryLoaded[language] = <String, Map<String, bool>>{};

          for (String level in levels) {
            languageLevelCategoryWords[language]![level] =
                <String, List<WordModel>>{};
            languageLevelCategoryLoaded[language]![level] = <String, bool>{};

            for (String category in categories) {
              final cachedWords =
                  await _loadExistingTodayWordsForLanguageLevelCategory(
                    language,
                    level,
                    category,
                  );
              if (cachedWords.isNotEmpty) {
                languageLevelCategoryWords[language]![level]![category] =
                    cachedWords;
                languageLevelCategoryLoaded[language]![level]![category] = true;
              } else {
                languageLevelCategoryLoaded[language]![level]![category] =
                    false;
              }
            }
          }
        }

        // null 체크 후 상태 업데이트
        if (languageLevelCategoryWords.isNotEmpty &&
            languageLevelCategoryLoaded.isNotEmpty) {
          state = state.copyWith(
            languageLevelCategoryWords: languageLevelCategoryWords,
            languageLevelCategoryLoaded: languageLevelCategoryLoaded,
          );
        }
      } else {
        // 날짜가 다르면 모든 학습언어, 난이도, 카테고리 초기화
        state = state.copyWith(
          languageLevelCategoryWords:
              <String, Map<String, Map<String, List<WordModel>>>>{},
          languageLevelCategoryLoaded:
              <String, Map<String, Map<String, bool>>>{},
        );
      }
    } catch (e) {
      print('Auto restore error: $e');
      // 에러 발생 시 빈 상태로 초기화
      state = state.copyWith(
        languageLevelCategoryWords:
            <String, Map<String, Map<String, List<WordModel>>>>{},
        languageLevelCategoryLoaded: <String, Map<String, Map<String, bool>>>{},
      );
    }
  }

  /// 특정 학습언어, 난이도, 카테고리의 기존 오늘의 단어 로드
  Future<List<WordModel>> _loadExistingTodayWordsForLanguageLevelCategory(
    String language,
    String level,
    String category,
  ) async {
    try {
      final box = HiveService.getWordsBox();
      final allWords = box.values.toList();

      // 오늘의 단어 필터링 (학습언어별, 난이도별, 카테고리별)
      final todayWords = allWords
          .where(
            (word) =>
                word.learningLanguage == language &&
                word.level == level &&
                (word.category ?? 'daily') == category &&
                _isTodayWord(word),
          )
          .toList();

      return todayWords;
    } catch (e) {
      print('Load existing today words for language level category error: $e');
      return [];
    }
  }

  /// 특정 학습언어, 난이도, 카테고리의 오늘 단어 로드 여부 확인
  Future<bool> _isTodayWordsLoadedForLanguageLevelCategory(
    String language,
    String level,
    String category,
  ) async {
    try {
      final box = HiveService.getWordsBox();
      final allWords = box.values.toList();

      // 오늘의 단어 필터링 (학습언어별, 난이도별, 카테고리별)
      final todayWords = allWords
          .where(
            (word) =>
                word.learningLanguage == language &&
                word.level == level &&
                (word.category ?? 'daily') == category &&
                _isTodayWord(word),
          )
          .toList();

      return todayWords.isNotEmpty;
    } catch (e) {
      print('Check today words loaded for language level category error: $e');
      return false;
    }
  }

  /// 오늘의 단어 로드 날짜, 카테고리, 레벨, 언어 저장
  Future<void> _saveLoadDate(
    String language,
    String category,
    String level,
    String learningLanguage,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    await prefs.setString(_lastLoadDateKey, today);
    await prefs.setString(_lastCategoryKey, category);
    await prefs.setString(_lastLevelKey, level);
    await prefs.setString(_lastLearningLangKey, learningLanguage);
    await prefs.setString(_lastLanguageKey, language);
  }

  /// 오늘의 단어를 로드 (학습언어별, 난이도별, 카테고리별, 하루에 한번만)
  Future<void> loadTodayWordsForLanguage({
    required String language,
    required String level,
    required String learningLanguage,
    required String nativeLanguage,
    String category = 'daily',
    int count = 20,
  }) async {
    try {
      // 이미 오늘 단어가 로드되었는지 확인 (학습언어별, 난이도별, 카테고리별)
      if (await _isTodayWordsLoadedForLanguageLevelCategory(
        language,
        level,
        category,
      )) {
        // 이미 로드된 경우 현재 학습언어, 난이도, 카테고리만 설정
        state = state.copyWith(
          currentLanguage: language,
          currentCategory: category,
          currentLevel: level,
        );
        return;
      }

      // 로딩 상태 시작
      state = state.copyWith(isLoading: true);

      // DailyWordService를 사용하여 오늘의 단어 생성 (학습 진행 추적 포함)
      // learningLanguage를 DailyWordService가 기대하는 형식으로 변환
      final serviceLearningLanguage = language == 'en' ? 'English' : 'Korean';
      final words = await DailyWordService.getDailyWords(
        category: category,
        level: level,
        learningLanguage: serviceLearningLanguage,
        nativeLanguage: nativeLanguage,
        coreCount: 3,
        expansionCount: 2,
      );

      // 데이터베이스에 저장
      final box = HiveService.getWordsBox();
      for (var word in words) {
        await box.put(word.id, word);
      }

      // 오늘의 단어로 마킹
      await _markAsTodayWords(words);

      // 로드 날짜, 카테고리, 레벨, 언어 저장
      await _saveLoadDate(language, category, level, learningLanguage);

      // 학습언어별, 난이도별, 카테고리별 상태 업데이트
      final updatedLanguageLevelCategoryWords =
          Map<String, Map<String, Map<String, List<WordModel>>>>.from(
            state.languageLevelCategoryWords,
          );
      if (!updatedLanguageLevelCategoryWords.containsKey(language)) {
        updatedLanguageLevelCategoryWords[language] =
            <String, Map<String, List<WordModel>>>{};
      }
      if (!updatedLanguageLevelCategoryWords[language]!.containsKey(level)) {
        updatedLanguageLevelCategoryWords[language]![level] =
            <String, List<WordModel>>{};
      }
      updatedLanguageLevelCategoryWords[language]![level]![category] = words;

      final updatedLanguageLevelCategoryLoaded =
          Map<String, Map<String, Map<String, bool>>>.from(
            state.languageLevelCategoryLoaded,
          );
      if (!updatedLanguageLevelCategoryLoaded.containsKey(language)) {
        updatedLanguageLevelCategoryLoaded[language] =
            <String, Map<String, bool>>{};
      }
      if (!updatedLanguageLevelCategoryLoaded[language]!.containsKey(level)) {
        updatedLanguageLevelCategoryLoaded[language]![level] = <String, bool>{};
      }
      updatedLanguageLevelCategoryLoaded[language]![level]![category] = true;

      state = state.copyWith(
        languageLevelCategoryWords: updatedLanguageLevelCategoryWords,
        languageLevelCategoryLoaded: updatedLanguageLevelCategoryLoaded,
        currentLanguage: language,
        currentCategory: category,
        currentLevel: level,
        isLoading: false,
      );
    } catch (e) {
      print('Load today words error: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  /// 오늘의 단어를 로드 (레거시 - 학습언어별 지원)
  Future<void> loadTodayWords({
    required String level,
    required String learningLanguage,
    required String nativeLanguage,
    String category = 'daily',
    int count = 20,
  }) async {
    // 학습언어를 'en' 또는 'ko'로 변환
    final language = learningLanguage == 'English' ? 'en' : 'ko';

    // 새로운 메서드 호출
    await loadTodayWordsForLanguage(
      language: language,
      level: level,
      learningLanguage: learningLanguage,
      nativeLanguage: nativeLanguage,
      category: category,
      count: count,
    );
  }

  /// 단어가 오늘의 단어인지 확인
  bool _isTodayWord(WordModel word) {
    final today = DateTime.now();
    final wordDate = word.createdAt;

    return wordDate.year == today.year &&
        wordDate.month == today.month &&
        wordDate.day == today.day;
  }

  /// 단어들을 오늘의 단어로 마킹
  Future<void> _markAsTodayWords(List<WordModel> words) async {
    final prefs = await SharedPreferences.getInstance();
    final wordIds = words.map((word) => word.id).toList();
    await prefs.setStringList(_dailyWordsKey, wordIds);
  }

  /// 강제로 새로운 단어 로드 (레거시 - 학습언어별 지원)
  Future<void> forceLoadNewWords({
    required String level,
    required String learningLanguage,
    required String nativeLanguage,
    String category = 'daily',
    int count = 20,
  }) async {
    // 학습언어를 'en' 또는 'ko'로 변환
    final language = learningLanguage == 'English' ? 'en' : 'ko';

    // 새로운 메서드 호출 (강제 생성)
    await forceLoadNewWordsForLanguage(
      language: language,
      level: level,
      learningLanguage: learningLanguage,
      nativeLanguage: nativeLanguage,
      category: category,
      count: count,
    );
  }

  /// 강제로 새로운 단어 로드 (학습언어별, 난이도별, 카테고리별)
  Future<void> forceLoadNewWordsForLanguage({
    required String language,
    required String level,
    required String learningLanguage,
    required String nativeLanguage,
    String category = 'daily',
    int count = 20,
  }) async {
    try {
      // 로딩 상태 시작
      state = state.copyWith(isLoading: true);

      // 기존 오늘의 단어 삭제 (해당 학습언어, 난이도, 카테고리만)
      await _clearTodayWordsForLanguageLevelCategory(language, level, category);

      // DailyWordService를 사용하여 새로운 단어 강제 생성
      // learningLanguage를 DailyWordService가 기대하는 형식으로 변환
      final serviceLearningLanguage = language == 'en' ? 'English' : 'Korean';
      final words = await DailyWordService.forceGenerateNewWords(
        category: category,
        level: level,
        learningLanguage: serviceLearningLanguage,
        nativeLanguage: nativeLanguage,
        coreCount: 3,
        expansionCount: 2,
      );

      // 데이터베이스에 저장
      final box = HiveService.getWordsBox();
      for (var word in words) {
        await box.put(word.id, word);
      }

      // 오늘의 단어로 마킹
      await _markAsTodayWords(words);

      // 로드 날짜, 카테고리, 레벨, 언어 저장
      await _saveLoadDate(language, category, level, learningLanguage);

      // 학습언어별, 난이도별, 카테고리별 상태 업데이트
      final updatedLanguageLevelCategoryWords =
          Map<String, Map<String, Map<String, List<WordModel>>>>.from(
            state.languageLevelCategoryWords,
          );
      final updatedLanguageLevelCategoryLoaded =
          Map<String, Map<String, Map<String, bool>>>.from(
            state.languageLevelCategoryLoaded,
          );

      // 학습언어별 맵이 없으면 생성
      if (!updatedLanguageLevelCategoryWords.containsKey(language)) {
        updatedLanguageLevelCategoryWords[language] =
            <String, Map<String, List<WordModel>>>{};
      }
      if (!updatedLanguageLevelCategoryWords[language]!.containsKey(level)) {
        updatedLanguageLevelCategoryWords[language]![level] =
            <String, List<WordModel>>{};
      }
      if (!updatedLanguageLevelCategoryLoaded.containsKey(language)) {
        updatedLanguageLevelCategoryLoaded[language] =
            <String, Map<String, bool>>{};
      }
      if (!updatedLanguageLevelCategoryLoaded[language]!.containsKey(level)) {
        updatedLanguageLevelCategoryLoaded[language]![level] = <String, bool>{};
      }

      updatedLanguageLevelCategoryWords[language]![level]![category] = words;
      updatedLanguageLevelCategoryLoaded[language]![level]![category] = true;

      state = state.copyWith(
        languageLevelCategoryWords: updatedLanguageLevelCategoryWords,
        languageLevelCategoryLoaded: updatedLanguageLevelCategoryLoaded,
        currentLanguage: language,
        currentCategory: category,
        currentLevel: level,
        isLoading: false,
      );
    } catch (e) {
      print('Force load new words error: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  /// 특정 학습언어, 난이도, 카테고리의 오늘의 단어 삭제
  Future<void> _clearTodayWordsForLanguageLevelCategory(
    String language,
    String level,
    String category,
  ) async {
    try {
      final box = HiveService.getWordsBox();
      final allWords = box.values.toList();

      // 해당 학습언어, 난이도, 카테고리의 오늘의 단어 삭제
      for (var word in allWords) {
        if (word.learningLanguage == language &&
            word.level == level &&
            (word.category ?? 'daily') == category &&
            _isTodayWord(word)) {
          await box.delete(word.id);
        }
      }
    } catch (e) {
      print('Clear today words for language level category error: $e');
    }
  }

  /// 단어를 단어장에 추가/제거 (카테고리별)
  Future<void> toggleVocabulary(String wordId) async {
    try {
      final box = HiveService.getWordsBox();
      final word = box.get(wordId);

      if (word != null) {
        final updatedWord = word.copyWith(isInVocabulary: !word.isInVocabulary);
        await box.put(wordId, updatedWord);

        // 현재 학습언어, 난이도, 카테고리의 단어 목록 업데이트
        if (state.currentLanguage != null &&
            state.currentCategory != null &&
            state.currentLevel != null) {
          final updatedLanguageLevelCategoryWords =
              Map<String, Map<String, Map<String, List<WordModel>>>>.from(
                state.languageLevelCategoryWords,
              );
          final currentWords =
              updatedLanguageLevelCategoryWords[state.currentLanguage!]?[state
                  .currentLevel!]?[state.currentCategory!] ??
              [];
          final index = currentWords.indexWhere((w) => w.id == wordId);

          if (index != -1) {
            final updatedWords = [
              ...currentWords.sublist(0, index),
              updatedWord,
              ...currentWords.sublist(index + 1),
            ];
            updatedLanguageLevelCategoryWords[state.currentLanguage!]![state
                    .currentLevel!]![state.currentCategory!] =
                updatedWords;
            state = state.copyWith(
              languageLevelCategoryWords: updatedLanguageLevelCategoryWords,
            );
          }
        }
      }
    } catch (e) {
      print('Toggle vocabulary error: $e');
    }
  }

  /// 자정에 자동으로 리셋되는지 확인
  Future<bool> shouldReset() async {
    final prefs = await SharedPreferences.getInstance();
    final lastLoadDate = prefs.getString(_lastLoadDateKey);

    if (lastLoadDate == null) return true;

    final today = DateTime.now().toIso8601String().split('T')[0];
    return lastLoadDate != today;
  }

  /// 날짜가 변경되었는지 확인하고 필요시 리셋
  Future<void> checkAndResetIfNeeded() async {
    if (await shouldReset()) {
      // 날짜가 변경되었으면 모든 학습언어, 난이도, 카테고리 상태 초기화
      state = state.copyWith(
        languageLevelCategoryWords:
            <String, Map<String, Map<String, List<WordModel>>>>{},
        languageLevelCategoryLoaded: <String, Map<String, Map<String, bool>>>{},
        currentLanguage: null,
        currentCategory: null,
        currentLevel: null,
      );
    }
  }

  /// 현재 카테고리 설정
  void setCurrentCategory(String category) {
    state = state.copyWith(currentCategory: category);
  }

  /// 현재 카테고리와 레벨 설정
  void setCurrentCategoryAndLevel(String category, String level) {
    state = state.copyWith(currentCategory: category, currentLevel: level);
  }

  /// 현재 학습언어, 카테고리, 레벨 설정
  void setCurrentLanguageCategoryAndLevel(
    String language,
    String category,
    String level,
  ) {
    state = state.copyWith(
      currentLanguage: language,
      currentCategory: category,
      currentLevel: level,
    );
  }

  /// 레벨 변경 시 해당 카테고리 상태 리셋 (사용하지 않음 - 각 난이도별로 독립 유지)
  void resetCategoryForLevelChange(String category) {
    // 더 이상 상태를 리셋하지 않음 - 각 난이도별로 독립적으로 유지
    // 이 메서드는 호출되지 않음
  }
}

/// 일일 단어 Provider
final dailyWordStateProvider =
    StateNotifierProvider<DailyWordNotifier, DailyWordState>((ref) {
      return DailyWordNotifier();
    });

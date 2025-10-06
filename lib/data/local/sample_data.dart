import '../models/word_model.dart';

/// 샘플 데이터를 생성합니다.
class SampleData {
  /// 영어 학습용 초급 단어 (한국어로 의미)
  static List<WordModel> get englishBeginnerWords => [
        WordModel(
          id: 'en_beginner_1',
          word: 'Hello',
          meaning: '안녕하세요',
          pronunciation: 'həˈloʊ',
          example: 'Hello, how are you?',
          level: 'beginner',
          type: 'word',
          learningLanguage: 'en',
          nativeLanguage: 'ko',
          createdAt: DateTime.now(),
        ),
        WordModel(
          id: 'en_beginner_2',
          word: 'Thank you',
          meaning: '감사합니다',
          pronunciation: 'θæŋk juː',
          example: 'Thank you for your help.',
          level: 'beginner',
          type: 'expression',
          learningLanguage: 'en',
          nativeLanguage: 'ko',
          createdAt: DateTime.now(),
        ),
        WordModel(
          id: 'en_beginner_3',
          word: 'Apple',
          meaning: '사과',
          pronunciation: 'ˈæp.əl',
          example: 'I like to eat an apple.',
          level: 'beginner',
          type: 'word',
          learningLanguage: 'en',
          nativeLanguage: 'ko',
          createdAt: DateTime.now(),
        ),
        WordModel(
          id: 'en_beginner_4',
          word: 'Good morning',
          meaning: '좋은 아침',
          pronunciation: 'ɡʊd ˈmɔːr.nɪŋ',
          example: 'Good morning! Did you sleep well?',
          level: 'beginner',
          type: 'expression',
          learningLanguage: 'en',
          nativeLanguage: 'ko',
          createdAt: DateTime.now(),
        ),
        WordModel(
          id: 'en_beginner_5',
          word: 'Water',
          meaning: '물',
          pronunciation: 'ˈwɔː.tər',
          example: 'I drink water every day.',
          level: 'beginner',
          type: 'word',
          learningLanguage: 'en',
          nativeLanguage: 'ko',
          createdAt: DateTime.now(),
        ),
      ];

  /// 영어 학습용 중급 단어
  static List<WordModel> get englishIntermediateWords => [
        WordModel(
          id: 'en_intermediate_1',
          word: 'Accomplish',
          meaning: '성취하다',
          pronunciation: 'əˈkʌm.plɪʃ',
          example: 'She accomplished her goal.',
          level: 'intermediate',
          type: 'word',
          learningLanguage: 'en',
          nativeLanguage: 'ko',
          createdAt: DateTime.now(),
        ),
        WordModel(
          id: 'en_intermediate_2',
          word: 'Break the ice',
          meaning: '어색한 분위기를 깨다',
          pronunciation: 'breɪk ðiː aɪs',
          example: 'He told a joke to break the ice.',
          level: 'intermediate',
          type: 'expression',
          learningLanguage: 'en',
          nativeLanguage: 'ko',
          createdAt: DateTime.now(),
        ),
        WordModel(
          id: 'en_intermediate_3',
          word: 'Determine',
          meaning: '결정하다',
          pronunciation: 'dɪˈtɜː.mɪn',
          example: 'We need to determine the best solution.',
          level: 'intermediate',
          type: 'word',
          learningLanguage: 'en',
          nativeLanguage: 'ko',
          createdAt: DateTime.now(),
        ),
      ];

  /// 영어 학습용 고급 단어
  static List<WordModel> get englishAdvancedWords => [
        WordModel(
          id: 'en_advanced_1',
          word: 'Ubiquitous',
          meaning: '어디에나 있는',
          pronunciation: 'juːˈbɪk.wɪ.təs',
          example: 'Smartphones are ubiquitous in modern society.',
          level: 'advanced',
          type: 'word',
          learningLanguage: 'en',
          nativeLanguage: 'ko',
          createdAt: DateTime.now(),
        ),
        WordModel(
          id: 'en_advanced_2',
          word: 'Cut corners',
          meaning: '지름길을 택하다, 편법을 쓰다',
          pronunciation: 'kʌt ˈkɔː.nərz',
          example: 'Don\'t cut corners when it comes to safety.',
          level: 'advanced',
          type: 'expression',
          learningLanguage: 'en',
          nativeLanguage: 'ko',
          createdAt: DateTime.now(),
        ),
      ];

  /// 한국어 학습용 초급 단어 (영어로 의미)
  static List<WordModel> get koreanBeginnerWords => [
        WordModel(
          id: 'ko_beginner_1',
          word: '안녕하세요',
          meaning: 'Hello',
          pronunciation: 'an-nyeong-ha-se-yo',
          example: '안녕하세요, 만나서 반갑습니다.',
          level: 'beginner',
          type: 'expression',
          learningLanguage: 'ko',
          nativeLanguage: 'en',
          createdAt: DateTime.now(),
        ),
        WordModel(
          id: 'ko_beginner_2',
          word: '감사합니다',
          meaning: 'Thank you',
          pronunciation: 'gam-sa-ham-ni-da',
          example: '도와주셔서 감사합니다.',
          level: 'beginner',
          type: 'expression',
          learningLanguage: 'ko',
          nativeLanguage: 'en',
          createdAt: DateTime.now(),
        ),
        WordModel(
          id: 'ko_beginner_3',
          word: '사과',
          meaning: 'Apple',
          pronunciation: 'sa-gwa',
          example: '나는 사과를 좋아해요.',
          level: 'beginner',
          type: 'word',
          learningLanguage: 'ko',
          nativeLanguage: 'en',
          createdAt: DateTime.now(),
        ),
        WordModel(
          id: 'ko_beginner_4',
          word: '물',
          meaning: 'Water',
          pronunciation: 'mul',
          example: '물 한 잔 주세요.',
          level: 'beginner',
          type: 'word',
          learningLanguage: 'ko',
          nativeLanguage: 'en',
          createdAt: DateTime.now(),
        ),
        WordModel(
          id: 'ko_beginner_5',
          word: '좋은 아침',
          meaning: 'Good morning',
          pronunciation: 'jo-eun a-chim',
          example: '좋은 아침입니다!',
          level: 'beginner',
          type: 'expression',
          learningLanguage: 'ko',
          nativeLanguage: 'en',
          createdAt: DateTime.now(),
        ),
      ];

  /// 한국어 학습용 중급 단어
  static List<WordModel> get koreanIntermediateWords => [
        WordModel(
          id: 'ko_intermediate_1',
          word: '성취하다',
          meaning: 'To accomplish',
          pronunciation: 'seong-chwi-ha-da',
          example: '그녀는 목표를 성취했습니다.',
          level: 'intermediate',
          type: 'word',
          learningLanguage: 'ko',
          nativeLanguage: 'en',
          createdAt: DateTime.now(),
        ),
        WordModel(
          id: 'ko_intermediate_2',
          word: '분위기를 깨다',
          meaning: 'Break the ice',
          pronunciation: 'bun-wi-gi-reul kkae-da',
          example: '그는 농담으로 분위기를 깼습니다.',
          level: 'intermediate',
          type: 'expression',
          learningLanguage: 'ko',
          nativeLanguage: 'en',
          createdAt: DateTime.now(),
        ),
      ];

  /// 한국어 학습용 고급 단어
  static List<WordModel> get koreanAdvancedWords => [
        WordModel(
          id: 'ko_advanced_1',
          word: '편법',
          meaning: 'Shortcut, workaround',
          pronunciation: 'pyeon-beop',
          example: '편법을 쓰지 마세요.',
          level: 'advanced',
          type: 'word',
          learningLanguage: 'ko',
          nativeLanguage: 'en',
          createdAt: DateTime.now(),
        ),
      ];

  /// 모든 샘플 단어 가져오기
  static List<WordModel> getAllSampleWords() {
    return [
      ...englishBeginnerWords,
      ...englishIntermediateWords,
      ...englishAdvancedWords,
      ...koreanBeginnerWords,
      ...koreanIntermediateWords,
      ...koreanAdvancedWords,
    ];
  }

  /// 특정 학습 언어와 레벨의 단어 가져오기
  static List<WordModel> getWordsByLanguageAndLevel(
    String learningLanguage,
    String level,
  ) {
    return getAllSampleWords()
        .where((word) =>
            word.learningLanguage == learningLanguage && word.level == level)
        .toList();
  }
}

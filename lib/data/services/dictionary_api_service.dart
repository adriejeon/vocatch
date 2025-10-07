import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../models/word_model.dart';

/// 개선된 Dictionary API 서비스 (캐싱 및 최적화 포함)
class DictionaryApiService {
  static const String _baseUrl =
      'https://api.dictionaryapi.dev/api/v2/entries/en';

  // 캐싱을 위한 메모리 캐시
  static final Map<String, Map<String, dynamic>> _definitionCache = {};
  static final Map<String, bool> _verbCache = {};
  static final Map<String, Map<String, dynamic>> _conjugationCache = {};

  // 캐시 만료 시간 (1시간)
  static const Duration _cacheExpiry = Duration(hours: 1);
  static final Map<String, DateTime> _cacheTimestamps = {};

  // Free Dictionary API는 이미 _baseUrl에 설정됨

  /// DeepL API를 사용한 번역 기능
  static Future<String> _translateWithDeepL(
    String text,
    String targetLang,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('https://api-free.deepl.com/v2/translate'),
        headers: {
          'Authorization':
              'DeepL-Auth-Key c86d475c-f0f5-4959-960e-6ca3f3bbe24c:fx',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {'text': text, 'target_lang': targetLang},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['translations'] != null && data['translations'].isNotEmpty) {
          return data['translations'][0]['text'] ?? text;
        }
      }
      print('DeepL API error: ${response.statusCode}');
    } catch (e) {
      print('DeepL translation error: $e');
    }
    return text;
  }

  /// 한국어 단어 정의 가져오기 (국립국어원 API 연동)
  static Future<Map<String, dynamic>?> getKoreanWordDefinition(
    String word,
  ) async {
    try {
      // 캐시 확인
      final cacheKey = 'korean_$word';
      if (_definitionCache.containsKey(cacheKey)) {
        final cached = _definitionCache[cacheKey];
        final timestamp = _cacheTimestamps[cacheKey];
        if (timestamp != null &&
            DateTime.now().difference(timestamp) < _cacheExpiry) {
          return cached;
        }
      }

      // 국립국어원 API 호출
      final response = await http.get(
        Uri.parse(
          'https://krdict.korean.go.kr/api/search?key=E80B216E56DD8C874CE0B038FEC234D3&q=$word&type=word&translated=y',
        ),
      );

      String definition = '';
      String romanization = _convertKoreanToRomanization(word);

      if (response.statusCode == 200) {
        // XML 응답 파싱
        final xmlResponse = response.body;
        print(
          'Korean API response for $word: ${xmlResponse.substring(0, xmlResponse.length > 200 ? 200 : xmlResponse.length)}...',
        );
        definition = _parseKoreanDefinitionFromXml(xmlResponse, word);
        print('Parsed definition for $word: $definition');
      } else {
        print('Korean API error: ${response.statusCode}');
      }

      // API에서 정의를 가져오지 못한 경우 DeepL 번역 사용
      if (definition.isEmpty) {
        print('Using DeepL translation for $word');
        definition = await _translateWithDeepL(word, 'EN');
      }

      final result = {
        'word': word,
        'definition': definition,
        'pronunciation': romanization,
        'language': 'ko',
      };

      // 캐시에 저장
      _definitionCache[cacheKey] = result;
      _cacheTimestamps[cacheKey] = DateTime.now();

      return result;
    } catch (e) {
      print('Korean word definition error: $e');
      // 에러 발생 시 DeepL 번역 사용
      String definition = await _translateWithDeepL(word, 'EN');
      String romanization = _convertKoreanToRomanization(word);

      return {
        'word': word,
        'definition': definition,
        'pronunciation': romanization,
        'language': 'ko',
      };
    }
  }

  /// XML에서 한국어 정의 추출 (개선된 버전)
  static String _parseKoreanDefinitionFromXml(String xmlResponse, String word) {
    try {
      print('Parsing XML for word: $word');

      // XML에서 정의 추출 (개선된 파싱)
      final lines = xmlResponse.split('\n');

      for (String line in lines) {
        line = line.trim();

        // <definition> 태그에서 정의 추출
        if (line.contains('<definition>') && line.contains('</definition>')) {
          final start = line.indexOf('<definition>') + 12;
          final end = line.indexOf('</definition>');
          if (start < end) {
            final definition = line.substring(start, end).trim();
            if (definition.isNotEmpty) {
              print('Found definition: $definition');
              return definition;
            }
          }
        }

        // <sense> 태그에서 정의 추출
        if (line.contains('<sense>') && line.contains('</sense>')) {
          final start = line.indexOf('<sense>') + 7;
          final end = line.indexOf('</sense>');
          if (start < end) {
            final sense = line.substring(start, end).trim();
            if (sense.isNotEmpty && !sense.startsWith('<')) {
              print('Found sense: $sense');
              return sense;
            }
          }
        }

        // <translation> 태그에서 정의 추출 (영어 번역이 있는 경우)
        if (line.contains('<translation>') && line.contains('</translation>')) {
          final start = line.indexOf('<translation>') + 13;
          final end = line.indexOf('</translation>');
          if (start < end) {
            final translation = line.substring(start, end).trim();
            if (translation.isNotEmpty) {
              print('Found translation: $translation');
              return translation;
            }
          }
        }

        // <def> 태그에서 정의 추출
        if (line.contains('<def>') && line.contains('</def>')) {
          final start = line.indexOf('<def>') + 5;
          final end = line.indexOf('</def>');
          if (start < end) {
            final def = line.substring(start, end).trim();
            if (def.isNotEmpty) {
              print('Found def: $def');
              return def;
            }
          }
        }

        // <word_info> 태그 내부의 정의 추출
        if (line.contains('<word_info>')) {
          // 다음 줄들을 확인하여 정의 찾기
          final currentIndex = lines.indexOf(line);
          for (
            int i = currentIndex + 1;
            i < lines.length && i < currentIndex + 10;
            i++
          ) {
            final nextLine = lines[i].trim();
            if (nextLine.contains('</word_info>')) break;

            if (nextLine.contains('<definition>') &&
                nextLine.contains('</definition>')) {
              final start = nextLine.indexOf('<definition>') + 12;
              final end = nextLine.indexOf('</definition>');
              if (start < end) {
                final definition = nextLine.substring(start, end).trim();
                if (definition.isNotEmpty) {
                  print('Found definition in word_info: $definition');
                  return definition;
                }
              }
            }
          }
        }
      }

      // XML 구조를 더 자세히 분석
      print('XML structure analysis:');
      for (String line in lines) {
        if (line.trim().startsWith('<') && line.trim().contains('>')) {
          print('XML line: ${line.trim()}');
        }
      }
    } catch (e) {
      print('XML parsing error: $e');
    }

    return '';
  }

  /// 한국어를 로마자로 변환
  static String _convertKoreanToRomanization(String koreanText) {
    // 한글 자모 분해 및 로마자 변환 테이블
    final Map<String, String> initialConsonants = {
      'ㄱ': 'g',
      'ㄲ': 'kk',
      'ㄴ': 'n',
      'ㄷ': 'd',
      'ㄸ': 'tt',
      'ㄹ': 'r',
      'ㅁ': 'm',
      'ㅂ': 'b',
      'ㅃ': 'pp',
      'ㅅ': 's',
      'ㅆ': 'ss',
      'ㅇ': '',
      'ㅈ': 'j',
      'ㅉ': 'jj',
      'ㅊ': 'ch',
      'ㅋ': 'k',
      'ㅌ': 't',
      'ㅍ': 'p',
      'ㅎ': 'h',
    };

    final Map<String, String> vowels = {
      'ㅏ': 'a',
      'ㅐ': 'ae',
      'ㅑ': 'ya',
      'ㅒ': 'yae',
      'ㅓ': 'eo',
      'ㅔ': 'e',
      'ㅕ': 'yeo',
      'ㅖ': 'ye',
      'ㅗ': 'o',
      'ㅘ': 'wa',
      'ㅙ': 'wae',
      'ㅚ': 'oe',
      'ㅛ': 'yo',
      'ㅜ': 'u',
      'ㅝ': 'wo',
      'ㅞ': 'we',
      'ㅟ': 'wi',
      'ㅠ': 'yu',
      'ㅡ': 'eu',
      'ㅢ': 'ui',
      'ㅣ': 'i',
    };

    final Map<String, String> finalConsonants = {
      '': '',
      'ㄱ': 'k',
      'ㄲ': 'k',
      'ㄳ': 'k',
      'ㄴ': 'n',
      'ㄵ': 'n',
      'ㄶ': 'n',
      'ㄷ': 't',
      'ㄹ': 'l',
      'ㄺ': 'k',
      'ㄻ': 'm',
      'ㄼ': 'p',
      'ㄽ': 'l',
      'ㄾ': 'l',
      'ㄿ': 'p',
      'ㅀ': 'l',
      'ㅁ': 'm',
      'ㅂ': 'p',
      'ㅄ': 'p',
      'ㅅ': 't',
      'ㅆ': 't',
      'ㅇ': 'ng',
      'ㅈ': 't',
      'ㅊ': 't',
      'ㅋ': 'k',
      'ㅌ': 't',
      'ㅍ': 'p',
      'ㅎ': 't',
    };

    String result = '';

    for (int i = 0; i < koreanText.length; i++) {
      final char = koreanText[i];
      final code = char.codeUnitAt(0);

      // 한글 유니코드 범위: AC00(가) ~ D7A3(힣)
      if (code >= 0xAC00 && code <= 0xD7A3) {
        final syllableIndex = code - 0xAC00;
        final initialIndex = syllableIndex ~/ (21 * 28);
        final vowelIndex = (syllableIndex % (21 * 28)) ~/ 28;
        final finalIndex = syllableIndex % 28;

        final initialKeys = initialConsonants.keys.toList();
        final vowelKeys = vowels.keys.toList();
        final finalKeys = ['', ...finalConsonants.keys.toList().skip(1)];

        if (initialIndex < initialKeys.length &&
            vowelIndex < vowelKeys.length &&
            finalIndex < finalKeys.length) {
          result += initialConsonants[initialKeys[initialIndex]]!;
          result += vowels[vowelKeys[vowelIndex]]!;
          if (finalIndex > 0) {
            result += finalConsonants[finalKeys[finalIndex]]!;
          }
        }
      } else {
        // 한글이 아닌 문자는 그대로 유지
        result += char;
      }
    }

    return result.isNotEmpty ? result : koreanText;
  }

  /// Free Dictionary API로 영어 단어의 상세 정보를 가져옵니다 (캐싱 포함)
  static Future<Map<String, dynamic>?> getWordDefinition(String word) async {
    final cacheKey = word.toLowerCase();

    // 캐시 확인
    if (_definitionCache.containsKey(cacheKey) &&
        _cacheTimestamps.containsKey(cacheKey)) {
      final cacheTime = _cacheTimestamps[cacheKey]!;
      if (DateTime.now().difference(cacheTime) < _cacheExpiry) {
        return _definitionCache[cacheKey];
      } else {
        // 캐시 만료된 경우 제거
        _definitionCache.remove(cacheKey);
        _cacheTimestamps.remove(cacheKey);
      }
    }

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/$word'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          final wordData = data[0];

          // 캐시에 저장
          _definitionCache[cacheKey] = wordData;
          _cacheTimestamps[cacheKey] = DateTime.now();

          return wordData;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// API에서 가져온 데이터를 WordModel로 변환합니다 (개선된 버전)
  static Future<WordModel?> createWordFromApi({
    required String word,
    required String level,
    required String learningLanguage,
    required String nativeLanguage,
    required String category,
  }) async {
    try {
      String meaning = '';
      String? pronunciation;
      String? example;

      if (learningLanguage == 'English') {
        // 영어 학습자: DeepL API로 영어 단어를 한국어로 번역
        print('Translating English word to Korean: $word');
        meaning = await _translateWithDeepL(word, 'KO');
        print('Translated meaning: $meaning');

        // 발음 정보는 영어 그대로 유지
        pronunciation = word;

        // 예문은 제거 (간략한 의미만 제공)
        example = null;
      } else if (learningLanguage == 'Korean') {
        // 한국어 학습자: DeepL API로 한국어 단어를 영어로 번역
        print('Translating Korean word to English: $word');
        meaning = await _translateWithDeepL(word, 'EN');
        print('Translated meaning: $meaning');

        // 발음 정보는 로마자 표기 사용
        pronunciation = _convertKoreanToRomanization(word);

        // 예문은 제거 (간략한 의미만 제공)
        example = null;
      }

      return WordModel(
        id: 'api_${DateTime.now().millisecondsSinceEpoch}_${word.hashCode}',
        word: word,
        meaning: meaning,
        pronunciation: pronunciation,
        example: example,
        level: level,
        type: 'word',
        category: category,
        learningLanguage: learningLanguage,
        nativeLanguage: nativeLanguage,
        createdAt: DateTime.now(),
        isInVocabulary: false,
        synonyms: null, // 동의어 제거
        antonyms: null, // 반대어 제거
        verbConjugations: null, // 동사 변화형 제거
      );
    } catch (e) {
      return null;
    }
  }

  /// 일일 단어 목록을 생성합니다 (개선된 버전 - 하드코딩 제거)
  static Future<List<WordModel>> generateDailyWords({
    required String level,
    required String learningLanguage,
    required String nativeLanguage,
    String category = 'conversation',
    int count = 20,
  }) async {
    final List<WordModel> words = [];

    // 하드코딩된 단어 목록 대신 동적으로 단어 생성
    final wordList = await _generateDynamicWordList(
      level: level,
      learningLanguage: learningLanguage,
      category: category,
      count: count,
    );

    for (String word in wordList) {
      final wordModel = await createWordFromApi(
        word: word,
        level: level,
        learningLanguage: learningLanguage,
        nativeLanguage: nativeLanguage,
        category: category,
      );

      if (wordModel != null) {
        words.add(wordModel);
      }
    }

    return words;
  }

  /// 동적으로 단어 목록을 생성합니다 (Datamuse API 사용)
  static Future<List<String>> _generateDynamicWordList({
    required String level,
    required String learningLanguage,
    required String category,
    required int count,
  }) async {
    final List<String> selectedWords = [];

    // 날짜 기반 시드로 매일 다른 단어 조합 생성
    final today = DateTime.now();
    final dateSeed = today.year * 10000 + today.month * 100 + today.day;

    // Datamuse API로 카테고리 관련 단어 가져오기
    final relatedWords = await _fetchWordsFromDatamuseAPI(
      category: category,
      maxResults: count * 3, // 필터링을 고려해 더 많이 가져오기
    );

    if (relatedWords.isEmpty) {
      // API 실패 시 기본 단어 반환
      return _getFallbackWords(category, level, count);
    }

    // 레벨별 필터링
    final filteredWords = _filterWordsByLevel(relatedWords, level);

    // 날짜 시드 기반으로 셔플 (매일 같은 순서, 하루가 지나면 바뀜)
    final random = Random(dateSeed);
    filteredWords.shuffle(random);

    // 필요한 개수만큼 선택
    for (String word in filteredWords) {
      if (selectedWords.length >= count) break;

      // 중복 체크 및 추가
      if (!selectedWords.contains(word)) {
        selectedWords.add(word);
      }
    }

    // 부족한 경우 추가 단어 가져오기
    if (selectedWords.length < count) {
      final additionalWords = await _fetchAdditionalWords(
        category: category,
        level: level,
        needed: count - selectedWords.length,
        exclude: selectedWords,
      );
      selectedWords.addAll(additionalWords);
    }

    return selectedWords.take(count).toList();
  }

  /// Datamuse API에서 카테고리 관련 단어를 가져옵니다 (무료 API)
  static Future<List<String>> _fetchWordsFromDatamuseAPI({
    required String category,
    required int maxResults,
  }) async {
    try {
      // 카테고리별 토픽 키워드
      final topicKeywords = {
        'conversation': 'communication',
        'business': 'business',
        'travel': 'travel',
        'news': 'news',
      };

      final topic = topicKeywords[category] ?? 'general';

      // Datamuse API: topics 파라미터 사용
      final response = await http.get(
        Uri.parse(
          'https://api.datamuse.com/words?topics=$topic&max=$maxResults',
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final words = data
            .map((item) => item['word'] as String)
            .where(
              (word) =>
                  word.length >= 3 &&
                  word.length <= 15 &&
                  !word.contains(' ') &&
                  !word.contains('-') &&
                  RegExp(r'^[a-zA-Z]+$').hasMatch(word),
            )
            .toList();

        return words;
      }

      // topics가 작동하지 않으면 related words 시도
      return await _fetchRelatedWords(topic, maxResults);
    } catch (e) {
      return [];
    }
  }

  /// 관련 단어를 가져옵니다 (Datamuse API)
  static Future<List<String>> _fetchRelatedWords(
    String keyword,
    int maxResults,
  ) async {
    try {
      // 'means like' 및 'related to' 조합
      final response = await http.get(
        Uri.parse('https://api.datamuse.com/words?ml=$keyword&max=$maxResults'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final words = data
            .map((item) => item['word'] as String)
            .where(
              (word) =>
                  word.length >= 3 &&
                  word.length <= 15 &&
                  !word.contains(' ') &&
                  !word.contains('-') &&
                  RegExp(r'^[a-zA-Z]+$').hasMatch(word),
            )
            .toList();

        return words;
      }

      return [];
    } catch (e) {
      return [];
    }
  }

  /// 레벨에 따라 단어 필터링 (개선된 알고리즘)
  static List<String> _filterWordsByLevel(List<String> words, String level) {
    return words.where((word) {
      final complexity = _calculateWordComplexity(word);

      switch (level) {
        case 'beginner':
          // 초급: 매우 간단한 단어 (3-5글자, 1-2음절, 복잡도 3.0 이하)
          return word.length >= 3 &&
              word.length <= 6 &&
              complexity >= 1.0 &&
              complexity <= 3.0;
        case 'intermediate':
          // 중급: 중간 난이도 (5-9글자, 2-3음절, 복잡도 2.5-5.0)
          return word.length >= 5 &&
              word.length <= 10 &&
              complexity > 2.5 &&
              complexity <= 5.0;
        case 'advanced':
          // 고급: 복잡한 단어 (8글자 이상, 3음절 이상, 복잡도 4.5+)
          return word.length >= 7 && complexity > 4.0;
        default:
          return true;
      }
    }).toList();
  }

  /// 단어의 복잡도를 계산합니다 (0-10 스케일, 개선된 알고리즘)
  static double _calculateWordComplexity(String word) {
    // 1. 길이 점수 (0-5) - 비선형 스케일
    double lengthScore;
    if (word.length <= 4) {
      lengthScore = 1.0;
    } else if (word.length <= 6) {
      lengthScore = 2.0;
    } else if (word.length <= 8) {
      lengthScore = 3.5;
    } else if (word.length <= 10) {
      lengthScore = 4.5;
    } else {
      lengthScore = 5.0;
    }

    // 2. 음절 추정 (0-5) - 더 정확한 가중치
    final syllableCount = _estimateSyllables(word);
    double syllableScore;
    if (syllableCount == 1) {
      syllableScore = 1.0;
    } else if (syllableCount == 2) {
      syllableScore = 2.5;
    } else if (syllableCount == 3) {
      syllableScore = 4.0;
    } else {
      syllableScore = 5.0;
    }

    // 3. 연속 자음 패턴 (0-2) - 발음 난이도
    final consonantScore = _calculateConsonantComplexity(word);

    // 가중 평균 (길이 30%, 음절 50%, 자음 패턴 20%)
    return (lengthScore * 0.3) + (syllableScore * 0.5) + (consonantScore * 0.2);
  }

  /// 연속 자음 패턴으로 발음 난이도 계산
  static double _calculateConsonantComplexity(String word) {
    word = word.toLowerCase();
    int maxConsonantStreak = 0;
    int currentStreak = 0;

    for (int i = 0; i < word.length; i++) {
      if (!'aeiouy'.contains(word[i])) {
        currentStreak++;
        if (currentStreak > maxConsonantStreak) {
          maxConsonantStreak = currentStreak;
        }
      } else {
        currentStreak = 0;
      }
    }

    // 연속 자음이 많을수록 복잡함
    if (maxConsonantStreak <= 1) {
      return 0.5;
    } else if (maxConsonantStreak == 2) {
      return 1.5;
    } else if (maxConsonantStreak == 3) {
      return 3.0;
    } else {
      return 5.0;
    }
  }

  /// 단어의 음절 수를 추정합니다
  static int _estimateSyllables(String word) {
    word = word.toLowerCase();
    int count = 0;
    bool previousWasVowel = false;

    for (int i = 0; i < word.length; i++) {
      final char = word[i];
      final isVowel = 'aeiouy'.contains(char);

      if (isVowel && !previousWasVowel) {
        count++;
      }

      previousWasVowel = isVowel;
    }

    // 'e'로 끝나는 경우 조정
    if (word.endsWith('e') && count > 1) {
      count--;
    }

    // 최소 1음절
    return count < 1 ? 1 : count;
  }

  /// 추가 단어를 가져옵니다
  static Future<List<String>> _fetchAdditionalWords({
    required String category,
    required String level,
    required int needed,
    required List<String> exclude,
  }) async {
    try {
      final List<String> additionalWords = [];

      // 여러 관련 키워드로 시도
      final categoryKeywords = {
        'conversation': ['talk', 'speak', 'communicate', 'conversation'],
        'business': ['work', 'company', 'office', 'business'],
        'travel': ['trip', 'journey', 'vacation', 'travel'],
        'news': ['information', 'report', 'news', 'media'],
      };

      final keywords = categoryKeywords[category] ?? ['general'];

      for (String keyword in keywords) {
        if (additionalWords.length >= needed) break;

        final words = await _fetchRelatedWords(keyword, 50);
        final filtered = _filterWordsByLevel(words, level);

        for (String word in filtered) {
          if (additionalWords.length >= needed) break;
          if (!exclude.contains(word) && !additionalWords.contains(word)) {
            additionalWords.add(word);
          }
        }
      }

      return additionalWords;
    } catch (e) {
      return [];
    }
  }

  /// API 실패 시 최소한의 기본 단어 반환
  static List<String> _getFallbackWords(
    String category,
    String level,
    int count,
  ) {
    // 매우 기본적인 단어만 fallback으로 사용
    final basicWords = {
      'conversation': ['talk', 'speak', 'listen', 'say', 'tell'],
      'business': ['work', 'job', 'office', 'money', 'team'],
      'travel': ['go', 'trip', 'hotel', 'food', 'place'],
      'news': ['news', 'today', 'time', 'people', 'event'],
    };

    final words = basicWords[category] ?? ['word', 'learn', 'study'];
    return words.take(count).toList();
  }

  // 기존 하드코딩된 단어 목록 제거됨 - 동적 생성으로 대체

  // 동의어/반대어 검증 메서드 제거 (사용하지 않음)

  // 사용하지 않는 단어 검증 메서드 제거

  // 사용하지 않는 메서드들 제거 (동의어/반대어 기능 제거로 인해 불필요)

  /// 캐시 정리 메서드
  static void clearCache() {
    _definitionCache.clear();
    _verbCache.clear();
    _conjugationCache.clear();
    _cacheTimestamps.clear();
  }

  /// 만료된 캐시만 정리
  static void clearExpiredCache() {
    final now = DateTime.now();
    final expiredKeys = <String>[];

    for (final entry in _cacheTimestamps.entries) {
      if (now.difference(entry.value) >= _cacheExpiry) {
        expiredKeys.add(entry.key);
      }
    }

    for (final key in expiredKeys) {
      _definitionCache.remove(key);
      _verbCache.remove(key);
      _conjugationCache.remove(key);
      _cacheTimestamps.remove(key);
    }
  }

  /// 캐시 통계 정보
  static Map<String, int> getCacheStats() {
    return {
      'definitions': _definitionCache.length,
      'verbs': _verbCache.length,
      'conjugations': _conjugationCache.length,
      'total': _cacheTimestamps.length,
    };
  }
}

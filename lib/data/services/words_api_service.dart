import 'dart:convert';
import 'package:http/http.dart' as http;

/// WordsAPI를 사용하여 동사 변화형 정보를 가져오는 서비스
class WordsApiService {
  static const String _baseUrl = 'https://wordsapiv1.p.rapidapi.com/words';
  static const String _apiKey = 'YOUR_RAPIDAPI_KEY'; // 실제 키로 교체 필요

  /// 단어가 동사인지 확인하고 동사 변화형 정보를 가져옵니다
  static Future<Map<String, dynamic>?> getVerbConjugations(String word) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/$word'),
        headers: {
          'X-RapidAPI-Key': _apiKey,
          'X-RapidAPI-Host': 'wordsapiv1.p.rapidapi.com',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // 동사인지 확인
        if (data['results'] != null) {
          final results = data['results'] as List;
          final verbResult = results.firstWhere(
            (result) => result['partOfSpeech'] == 'verb',
            orElse: () => null,
          );

          if (verbResult != null) {
            return _extractVerbConjugations(data);
          }
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 동사 변화형 정보를 추출합니다
  static Map<String, dynamic> _extractVerbConjugations(
    Map<String, dynamic> data,
  ) {
    final conjugations = <String, dynamic>{};

    // 기본 형태들
    if (data['word'] != null) {
      conjugations['base'] = data['word'];
    }

    // results에서 동사 관련 정보 추출
    if (data['results'] != null) {
      final results = data['results'] as List;
      for (var result in results) {
        if (result['partOfSpeech'] == 'verb') {
          // 동사 정의
          if (result['definition'] != null) {
            conjugations['definition'] = result['definition'];
          }

          // 동사 예문
          if (result['examples'] != null && result['examples'].isNotEmpty) {
            conjugations['examples'] = result['examples'];
          }
        }
      }
    }

    // 동사 변화형 생성 (일반적인 규칙 기반)
    final baseWord = data['word'] as String?;
    if (baseWord != null) {
      conjugations['conjugations'] = _generateVerbConjugations(baseWord);
    }

    return conjugations;
  }

  /// 기본적인 동사 변화형을 생성합니다 (규칙 기반)
  static Map<String, String> _generateVerbConjugations(String baseWord) {
    final conjugations = <String, String>{};

    // 현재형
    conjugations['present'] = baseWord;

    // 3인칭 단수 현재형
    if (baseWord.endsWith('s') ||
        baseWord.endsWith('sh') ||
        baseWord.endsWith('ch') ||
        baseWord.endsWith('x') ||
        baseWord.endsWith('z')) {
      conjugations['present_3rd'] = '${baseWord}es';
    } else if (baseWord.endsWith('y') &&
        !_isVowel(baseWord[baseWord.length - 2])) {
      conjugations['present_3rd'] =
          '${baseWord.substring(0, baseWord.length - 1)}ies';
    } else {
      conjugations['present_3rd'] = '${baseWord}s';
    }

    // 과거형 (기본 규칙)
    if (baseWord.endsWith('e')) {
      conjugations['past'] = '${baseWord}d';
    } else if (baseWord.endsWith('y') &&
        !_isVowel(baseWord[baseWord.length - 2])) {
      conjugations['past'] = '${baseWord.substring(0, baseWord.length - 1)}ied';
    } else if (_isConsonant(baseWord[baseWord.length - 1]) &&
        _isVowel(baseWord[baseWord.length - 2]) &&
        _isConsonant(baseWord[baseWord.length - 3])) {
      // 단모음 + 단자음으로 끝나는 경우 (doubling rule)
      conjugations['past'] = '${baseWord}${baseWord[baseWord.length - 1]}ed';
    } else {
      conjugations['past'] = '${baseWord}ed';
    }

    // 과거분사형 (과거형과 동일한 규칙 적용)
    conjugations['past_participle'] = conjugations['past']!;

    // 현재분사형
    if (baseWord.endsWith('e')) {
      conjugations['present_participle'] =
          '${baseWord.substring(0, baseWord.length - 1)}ing';
    } else if (baseWord.endsWith('ie')) {
      conjugations['present_participle'] =
          '${baseWord.substring(0, baseWord.length - 2)}ying';
    } else if (_isConsonant(baseWord[baseWord.length - 1]) &&
        _isVowel(baseWord[baseWord.length - 2]) &&
        _isConsonant(baseWord[baseWord.length - 3])) {
      // 단모음 + 단자음으로 끝나는 경우
      conjugations['present_participle'] =
          '${baseWord}${baseWord[baseWord.length - 1]}ing';
    } else {
      conjugations['present_participle'] = '${baseWord}ing';
    }

    return conjugations;
  }

  /// 모음인지 확인
  static bool _isVowel(String char) {
    return 'aeiou'.contains(char.toLowerCase());
  }

  /// 자음인지 확인
  static bool _isConsonant(String char) {
    return !_isVowel(char);
  }

  /// 단어가 동사인지 빠르게 확인합니다 (Dictionary API 사용)
  static Future<bool> isVerb(String word) async {
    try {
      final response = await http.get(
        Uri.parse('https://api.dictionaryapi.dev/api/v2/entries/en/$word'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          final wordData = data[0];
          if (wordData['meanings'] != null) {
            final meanings = wordData['meanings'] as List;
            for (var meaning in meanings) {
              if (meaning['partOfSpeech'] == 'verb') {
                return true;
              }
            }
          }
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// 관련 단어를 가져옵니다 (Datamuse API 사용 - 무료)
  static Future<List<String>> getRelatedWords(String word) async {
    try {
      final relatedWords = <String>{};

      // 1. 유의어 가져오기 (means like)
      final synonymsResponse = await http.get(
        Uri.parse('https://api.datamuse.com/words?ml=$word&max=20'),
      );

      if (synonymsResponse.statusCode == 200) {
        final List<dynamic> synonymsData = json.decode(synonymsResponse.body);
        for (var item in synonymsData) {
          if (item['word'] != null) {
            relatedWords.add(item['word'] as String);
          }
        }
      }

      // 2. 관련 단어 가져오기 (related words)
      final relatedResponse = await http.get(
        Uri.parse('https://api.datamuse.com/words?rel_trg=$word&max=20'),
      );

      if (relatedResponse.statusCode == 200) {
        final List<dynamic> relatedData = json.decode(relatedResponse.body);
        for (var item in relatedData) {
          if (item['word'] != null) {
            relatedWords.add(item['word'] as String);
          }
        }
      }

      // 3. 형용사-명사 연관 단어 (adjective -> noun or vice versa)
      final associationResponse = await http.get(
        Uri.parse('https://api.datamuse.com/words?rel_jjb=$word&max=10'),
      );

      if (associationResponse.statusCode == 200) {
        final List<dynamic> associationData = json.decode(
          associationResponse.body,
        );
        for (var item in associationData) {
          if (item['word'] != null) {
            relatedWords.add(item['word'] as String);
          }
        }
      }

      // 필터링: 공백이나 특수문자 포함 단어 제거
      final filteredWords = relatedWords
          .where(
            (w) =>
                w.isNotEmpty &&
                !w.contains(' ') &&
                !w.contains('-') &&
                RegExp(r'^[a-zA-Z]+$').hasMatch(w),
          )
          .toList();

      return filteredWords;
    } catch (e) {
      print('getRelatedWords error: $e');
      return [];
    }
  }
}

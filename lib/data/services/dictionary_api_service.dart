import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/word_model.dart';

/// 무료 Dictionary API를 사용하여 단어 데이터를 가져오는 서비스
class DictionaryApiService {
  static const String _baseUrl = 'https://api.dictionaryapi.dev/api/v2/entries/en';
  static const String _translationUrl = 'https://api.mymemory.translated.net/get';

  /// 영어 단어의 정의, 발음, 예문을 가져옵니다
  static Future<Map<String, dynamic>?> getWordDefinition(String word) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/$word'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          return data[0];
        }
      }
      return null;
    } catch (e) {
      print('Dictionary API Error: $e');
      return null;
    }
  }

  /// 한국어로 번역합니다
  static Future<String?> translateToKorean(String text) async {
    try {
      final response = await http.get(
        Uri.parse('$_translationUrl?q=${Uri.encodeComponent(text)}&langpair=en|ko'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['responseStatus'] == 200) {
          return data['responseData']?['translatedText'];
        }
      }
      return null;
    } catch (e) {
      print('Translation API Error: $e');
      return null;
    }
  }

  /// 영어로 번역합니다
  static Future<String?> translateToEnglish(String text) async {
    try {
      final response = await http.get(
        Uri.parse('$_translationUrl?q=${Uri.encodeComponent(text)}&langpair=ko|en'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['responseStatus'] == 200) {
          return data['responseData']?['translatedText'];
        }
      }
      return null;
    } catch (e) {
      print('Translation API Error: $e');
      return null;
    }
  }

  /// API에서 가져온 데이터를 WordModel로 변환합니다
  static Future<WordModel?> createWordFromApi({
    required String word,
    required String level,
    required String learningLanguage,
    required String nativeLanguage,
  }) async {
    try {
      // 영어 단어 정의 가져오기
      final definitionData = await getWordDefinition(word);
      if (definitionData == null) return null;

      // 의미 추출
      String meaning = '';
      String? pronunciation;
      String? example;

      // 의미 추출 (첫 번째 의미 사용)
      if (definitionData['meanings'] != null &&
          definitionData['meanings'].isNotEmpty) {
        final meanings = definitionData['meanings'][0];
        if (meanings['definitions'] != null &&
            meanings['definitions'].isNotEmpty) {
          meaning = meanings['definitions'][0]['definition'] ?? '';
          example = meanings['definitions'][0]['example'];
        }
      }

      // 발음 추출
      if (definitionData['phonetics'] != null &&
          definitionData['phonetics'].isNotEmpty) {
        pronunciation = definitionData['phonetics'][0]['text'];
      }

      // 한국어 번역 (영어 학습인 경우)
      if (learningLanguage == 'en' && nativeLanguage == 'ko') {
        final koreanTranslation = await translateToKorean(meaning);
        if (koreanTranslation != null) {
          meaning = koreanTranslation;
        }
      }

      // 영어 번역 (한국어 학습인 경우)
      if (learningLanguage == 'ko' && nativeLanguage == 'en') {
        final englishTranslation = await translateToEnglish(meaning);
        if (englishTranslation != null) {
          meaning = englishTranslation;
        }
      }

      return WordModel(
        id: 'api_${DateTime.now().millisecondsSinceEpoch}',
        word: word,
        meaning: meaning,
        pronunciation: pronunciation,
        example: example,
        level: level,
        type: 'word',
        learningLanguage: learningLanguage,
        nativeLanguage: nativeLanguage,
        createdAt: DateTime.now(),
        isInVocabulary: false,
      );
    } catch (e) {
      print('Create word from API error: $e');
      return null;
    }
  }

  /// 일일 단어 목록을 생성합니다
  static Future<List<WordModel>> generateDailyWords({
    required String level,
    required String learningLanguage,
    required String nativeLanguage,
    int count = 5,
  }) async {
    final List<WordModel> words = [];
    
    // 레벨별 단어 목록
    final List<String> wordLists = {
      'beginner': [
        'hello', 'world', 'love', 'happy', 'good', 'time', 'day', 'night',
        'water', 'food', 'home', 'family', 'friend', 'book', 'music'
      ],
      'intermediate': [
        'accomplish', 'determine', 'establish', 'maintain', 'achieve',
        'develop', 'improve', 'create', 'discover', 'explore'
      ],
      'advanced': [
        'ubiquitous', 'sophisticated', 'comprehensive', 'extraordinary',
        'phenomenal', 'magnificent', 'tremendous', 'outstanding'
      ]
    }[level] ?? [];

    // 랜덤하게 단어 선택
    wordLists.shuffle();
    final selectedWords = wordLists.take(count).toList();

    for (String word in selectedWords) {
      final wordModel = await createWordFromApi(
        word: word,
        level: level,
        learningLanguage: learningLanguage,
        nativeLanguage: nativeLanguage,
      );
      
      if (wordModel != null) {
        words.add(wordModel);
      }
    }

    return words;
  }
}

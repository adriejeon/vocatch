import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;
import '../models/word_model.dart';
import 'dictionary_api_service.dart';

/// SVG 파일에서 일상회화 단어 데이터를 파싱하는 서비스
class VocabSvgParser {
  static Map<String, List<Map<String, String>>>? _cachedData;

  /// SVG 파일에서 단어 데이터 로드
  static Future<Map<String, List<Map<String, String>>>> _loadSvgData() async {
    if (_cachedData != null) return _cachedData!;

    try {
      final svgContent = await rootBundle.loadString(
        'assets/data/vocab_everyday-conversation_beginner.svg',
      );

      final words = <Map<String, String>>[];

      // SVG에서 텍스트 라인들을 파싱
      final lines = svgContent.split('\n');

      for (final line in lines) {
        // "숫자) 단어 — 예문" 형태의 라인을 찾기
        final regex = RegExp(r'(\d+)\)\s+([^—]+)\s*—\s*(.+)');
        final match = regex.firstMatch(line);

        if (match != null) {
          final word = match.group(2)?.trim() ?? '';
          final example = match.group(3)?.trim() ?? '';

          if (word.isNotEmpty && example.isNotEmpty) {
            words.add({'word': word, 'example': example});
          }
        }
      }

      print('Parsed ${words.length} words from SVG');

      _cachedData = {'conversation': words};

      return _cachedData!;
    } catch (e) {
      print('SVG parsing error: $e');
      return {'conversation': []};
    }
  }

  /// 일상회화 기초다지기 단어에서 랜덤으로 5개 선택
  static Future<List<Map<String, String>>> getRandomConversationWords({
    int count = 5,
  }) async {
    try {
      final data = await _loadSvgData();
      final conversationWords = data['conversation'] ?? [];

      if (conversationWords.isEmpty) {
        return [];
      }

      // 랜덤으로 섞기
      final shuffled = List<Map<String, String>>.from(conversationWords);
      shuffled.shuffle(Random());

      // 요청된 개수만큼 반환
      return shuffled.take(count).toList();
    } catch (e) {
      print('Get random conversation words error: $e');
      return [];
    }
  }

  /// 일상회화 단어를 WordModel로 변환
  static Future<List<WordModel>> convertToWordModels({
    required String level,
    required String learningLanguage,
    required String nativeLanguage,
    required String category,
    int count = 5,
  }) async {
    try {
      final wordsData = await getRandomConversationWords(count: count);
      final List<WordModel> wordModels = [];

      for (int i = 0; i < wordsData.length; i++) {
        final wordData = wordsData[i];
        final word = wordData['word'] ?? '';
        final example = wordData['example'] ?? '';

        if (word.isNotEmpty) {
          // Dictionary API를 사용하여 정확한 번역 가져오기
          final apiWordModel = await DictionaryApiService.createWordFromApi(
            word: word,
            level: level,
            learningLanguage: learningLanguage,
            nativeLanguage: nativeLanguage,
            category: category,
          );

          if (apiWordModel != null) {
            // API에서 가져온 모델에 예문 추가
            final wordModel = apiWordModel.copyWith(example: example);
            wordModels.add(wordModel);
          } else {
            // API 실패 시 기본 모델 생성
            final wordModel = WordModel(
              id: 'conversation_${DateTime.now().millisecondsSinceEpoch}_$i',
              word: word,
              meaning: _getKoreanMeaning(word),
              example: example,
              level: level,
              type: 'word',
              category: category,
              learningLanguage: learningLanguage,
              nativeLanguage: nativeLanguage,
              createdAt: DateTime.now(),
              isInVocabulary: false,
            );
            wordModels.add(wordModel);
          }
        }
      }

      return wordModels;
    } catch (e) {
      print('Convert to word models error: $e');
      return [];
    }
  }

  /// 간단한 한국어 의미 제공 (실제로는 API나 사전 데이터를 사용해야 함)
  static String _getKoreanMeaning(String word) {
    // 간단한 매핑 (실제로는 더 정교한 번역이 필요)
    final meanings = {
      'hello': '안녕하세요',
      'thanks': '감사합니다',
      'sorry': '죄송합니다',
      'busy': '바쁜',
      'hungry': '배고픈',
      'tired': '피곤한',
      'favorite': '좋아하는',
      'usually': '보통',
      'together': '함께',
      'expensive': '비싼',
      'idea': '아이디어',
      'schedule': '일정',
      'break': '휴식',
      'delicious': '맛있는',
      'need': '필요한',
      'good': '좋은',
      'bad': '나쁜',
      'help': '도움',
      'talk': '말하다',
      'speak': '말하다',
      'listen': '듣다',
      'ask': '물어보다',
      'answer': '대답하다',
      'tell': '말하다',
      'say': '말하다',
      'name': '이름',
      'meet': '만나다',
      'friend': '친구',
      'family': '가족',
      'happy': '행복한',
      'sad': '슬픈',
      'like': '좋아하다',
      'want': '원하다',
      'have': '가지다',
      'get': '얻다',
      'give': '주다',
      'know': '알다',
      'think': '생각하다',
      'feel': '느끼다',
      'see': '보다',
      'hear': '듣다',
      'come': '오다',
      'go': '가다',
      'eat': '먹다',
      'drink': '마시다',
      'sleep': '자다',
      'morning': '아침',
      'afternoon': '오후',
      'evening': '저녁',
      'night': '밤',
      'today': '오늘',
      'tomorrow': '내일',
      'yesterday': '어제',
      'time': '시간',
      'day': '날',
      'week': '주',
    };

    return meanings[word.toLowerCase()] ?? word;
  }
}

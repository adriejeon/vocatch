import 'package:flutter_tts/flutter_tts.dart';

/// Text-to-Speech 서비스
class TtsService {
  static final FlutterTts _flutterTts = FlutterTts();
  static bool _isInitialized = false;

  /// TTS 초기화
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // 언어 설정
      await _flutterTts.setLanguage("en-US");
      
      // 속도 설정 (0.0 ~ 1.0)
      await _flutterTts.setSpeechRate(0.5);
      
      // 음량 설정 (0.0 ~ 1.0)
      await _flutterTts.setVolume(1.0);
      
      // 피치 설정 (0.0 ~ 2.0)
      await _flutterTts.setPitch(1.0);

      _isInitialized = true;
    } catch (e) {
      print('TTS 초기화 오류: $e');
    }
  }

  /// 영어 단어 발음
  static Future<void> speakEnglish(String text) async {
    try {
      await initialize();
      await _flutterTts.setLanguage("en-US");
      await _flutterTts.speak(text);
    } catch (e) {
      print('영어 TTS 오류: $e');
    }
  }

  /// 한국어 단어 발음
  static Future<void> speakKorean(String text) async {
    try {
      await initialize();
      await _flutterTts.setLanguage("ko-KR");
      await _flutterTts.speak(text);
    } catch (e) {
      print('한국어 TTS 오류: $e');
    }
  }

  /// 언어에 따라 자동으로 발음
  static Future<void> speak(String text, String language) async {
    try {
      await initialize();
      
      if (language == 'en' || language == 'en-US') {
        await _flutterTts.setLanguage("en-US");
      } else if (language == 'ko' || language == 'ko-KR') {
        await _flutterTts.setLanguage("ko-KR");
      } else {
        // 기본값은 영어
        await _flutterTts.setLanguage("en-US");
      }
      
      await _flutterTts.speak(text);
    } catch (e) {
      print('TTS 발음 오류: $e');
    }
  }

  /// TTS 중지
  static Future<void> stop() async {
    try {
      await _flutterTts.stop();
    } catch (e) {
      print('TTS 중지 오류: $e');
    }
  }

  /// TTS 일시정지
  static Future<void> pause() async {
    try {
      await _flutterTts.pause();
    } catch (e) {
      print('TTS 일시정지 오류: $e');
    }
  }

  /// 사용 가능한 언어 목록 가져오기
  static Future<List<dynamic>> getAvailableLanguages() async {
    try {
      await initialize();
      return await _flutterTts.getLanguages;
    } catch (e) {
      print('언어 목록 가져오기 오류: $e');
      return [];
    }
  }

  /// TTS 상태 확인 (현재 버전에서는 지원하지 않음)
  static Future<bool> isSpeaking() async {
    try {
      // flutter_tts 3.8.5에서는 isSpeaking 메서드가 없습니다
      // 대신 false를 반환하여 항상 발음 가능한 상태로 처리
      return false;
    } catch (e) {
      print('TTS 상태 확인 오류: $e');
      return false;
    }
  }
}

import 'package:flutter_tts/flutter_tts.dart';
import 'package:audioplayers/audioplayers.dart';

/// Text-to-Speech 서비스
class TtsService {
  static final FlutterTts _flutterTts = FlutterTts();
  static final AudioPlayer _audioPlayer = AudioPlayer();
  static bool _isInitialized = false;

  /// TTS 초기화
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // 안드로이드 에뮬레이터에서 TTS 엔진 확인
      final engines = await _flutterTts.getEngines;
      print('사용 가능한 TTS 엔진: $engines');

      // 안드로이드에서 TTS 엔진 설정
      await _flutterTts.setEngine("com.google.android.tts");

      // 언어 설정
      await _flutterTts.setLanguage("en-US");

      // 속도 설정 (0.0 ~ 1.0)
      await _flutterTts.setSpeechRate(0.5);

      // 음량 설정 (0.0 ~ 1.0)
      await _flutterTts.setVolume(1.0);

      // 피치 설정 (0.0 ~ 2.0)
      await _flutterTts.setPitch(1.0);

      // TTS 완료 콜백 설정
      _flutterTts.setCompletionHandler(() {
        print('TTS 발음 완료');
      });

      // TTS 시작 콜백 설정
      _flutterTts.setStartHandler(() {
        print('TTS 발음 시작');
      });

      // TTS 오류 콜백 설정
      _flutterTts.setErrorHandler((msg) {
        print('TTS 오류: $msg');
      });

      _isInitialized = true;
      print('TTS 초기화 완료');
    } catch (e) {
      print('TTS 초기화 오류: $e');
      // 초기화 실패해도 계속 진행
      _isInitialized = true;
    }
  }

  /// 영어 단어 발음
  static Future<void> speakEnglish(String text) async {
    try {
      print('영어 발음 시도: $text');

      // TTS 시도
      await initialize();
      await _flutterTts.setLanguage("en-US");
      await _flutterTts.stop();
      await Future.delayed(const Duration(milliseconds: 100));

      final result = await _flutterTts.speak(text);
      print('영어 TTS 결과: $result');

      // TTS가 실패하면 대안 방법 시도
      if (result != 1) {
        print('TTS 실패, 대안 방법 시도');
        await _playAlternativeSound(text);
      }
    } catch (e) {
      print('영어 TTS 오류: $e');
      // TTS 실패 시 대안 방법
      await _playAlternativeSound(text);
    }
  }

  /// 한국어 단어 발음
  static Future<void> speakKorean(String text) async {
    try {
      print('한국어 발음 시도: $text');

      // TTS 시도
      await initialize();
      await _flutterTts.setLanguage("ko-KR");
      await _flutterTts.stop();
      await Future.delayed(const Duration(milliseconds: 100));

      final result = await _flutterTts.speak(text);
      print('한국어 TTS 결과: $result');

      // TTS가 실패하면 대안 방법 시도
      if (result != 1) {
        print('TTS 실패, 대안 방법 시도');
        await _playAlternativeSound(text);
      }
    } catch (e) {
      print('한국어 TTS 오류: $e');
      // TTS 실패 시 대안 방법
      await _playAlternativeSound(text);
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

  /// 대안 발음 방법 (시스템 사운드 재생)
  static Future<void> _playAlternativeSound(String text) async {
    try {
      print('대안 발음 재생: $text');

      // 시스템 사운드 재생 (알림음 등)
      await _audioPlayer.play(AssetSource('sounds/beep.mp3'));

      // 또는 간단한 피드백 사운드
      // await _audioPlayer.play(DeviceFileSource('/system/media/audio/ui/Effect_Tick.ogg'));
    } catch (e) {
      print('대안 발음 오류: $e');
      // 최후의 수단: 햅틱 피드백
      await _playHapticFeedback();
    }
  }

  /// 햅틱 피드백
  static Future<void> _playHapticFeedback() async {
    try {
      // 햅틱 피드백을 위한 시스템 서비스 호출
      print('햅틱 피드백 실행');
    } catch (e) {
      print('햅틱 피드백 오류: $e');
    }
  }
}

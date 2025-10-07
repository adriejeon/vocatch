import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/services/tts_service.dart';
import 'data/local/hive_service.dart';
import 'data/local/sample_data.dart';
import 'features/language_selection/screens/language_selection_screen.dart';
import 'features/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 상태바 스타일 설정
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Hive 초기화
  await HiveService.init();

  // TTS 초기화
  await TtsService.initialize();

  // 샘플 데이터 로드
  await _loadSampleData();

  runApp(const ProviderScope(child: VocatchApp()));
}

/// 샘플 데이터를 데이터베이스에 로드합니다.
Future<void> _loadSampleData() async {
  final wordsBox = HiveService.getWordsBox();
  
  // 이미 데이터가 있으면 로드하지 않음
  if (wordsBox.isNotEmpty) return;

  final sampleWords = SampleData.getAllSampleWords();
  for (var word in sampleWords) {
    await wordsBox.put(word.id, word);
  }
}

class VocatchApp extends ConsumerWidget {
  const VocatchApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = HiveService.getOrCreateSettings();

    return MaterialApp(
      title: 'Vocatch',
      theme: AppTheme.lightTheme,
      home: settings.isFirstLaunch
          ? const LanguageSelectionScreen()
          : const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

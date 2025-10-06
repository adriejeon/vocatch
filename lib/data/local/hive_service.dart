import 'package:hive_flutter/hive_flutter.dart';
import '../models/word_model.dart';
import '../models/vocabulary_group_model.dart';
import '../models/app_settings_model.dart';

/// Hive 데이터베이스 초기화 및 관리 서비스
class HiveService {
  // Box names
  static const String wordsBoxName = 'words';
  static const String groupsBoxName = 'vocabulary_groups';
  static const String settingsBoxName = 'app_settings';

  /// Hive 초기화
  static Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters
    Hive.registerAdapter(WordModelAdapter());
    Hive.registerAdapter(VocabularyGroupModelAdapter());
    Hive.registerAdapter(AppSettingsModelAdapter());

    // Open boxes
    await Hive.openBox<WordModel>(wordsBoxName);
    await Hive.openBox<VocabularyGroupModel>(groupsBoxName);
    await Hive.openBox<AppSettingsModel>(settingsBoxName);
  }

  /// 단어 Box 가져오기
  static Box<WordModel> getWordsBox() {
    return Hive.box<WordModel>(wordsBoxName);
  }

  /// 그룹 Box 가져오기
  static Box<VocabularyGroupModel> getGroupsBox() {
    return Hive.box<VocabularyGroupModel>(groupsBoxName);
  }

  /// 설정 Box 가져오기
  static Box<AppSettingsModel> getSettingsBox() {
    return Hive.box<AppSettingsModel>(settingsBoxName);
  }

  /// 앱 설정 가져오기 또는 생성
  static AppSettingsModel getOrCreateSettings() {
    final box = getSettingsBox();
    if (box.isEmpty) {
      final settings = AppSettingsModel();
      box.add(settings);
      return settings;
    }
    return box.getAt(0)!;
  }

  /// 앱 설정 업데이트
  static Future<void> updateSettings(AppSettingsModel settings) async {
    final box = getSettingsBox();
    if (box.isEmpty) {
      await box.add(settings);
    } else {
      await box.putAt(0, settings);
    }
  }

  /// 모든 데이터 삭제
  static Future<void> clearAll() async {
    await getWordsBox().clear();
    await getGroupsBox().clear();
    await getSettingsBox().clear();
  }
}

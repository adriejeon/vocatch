import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/local/hive_service.dart';
import '../../data/models/app_settings_model.dart';

/// 언어 설정 상태를 관리하는 Provider
class LanguageNotifier extends StateNotifier<AppSettingsModel> {
  LanguageNotifier() : super(HiveService.getOrCreateSettings());

  /// UI 언어 변경
  Future<void> changeUiLanguage(String languageCode) async {
    final newSettings = state.copyWith(uiLanguage: languageCode);
    await HiveService.updateSettings(newSettings);
    state = newSettings;
  }

  /// 학습 언어 변경
  Future<void> changeLearningLanguage(String languageCode) async {
    final newSettings = state.copyWith(learningLanguage: languageCode);
    await HiveService.updateSettings(newSettings);
    state = newSettings;
  }

  /// 사용자 수준 변경
  Future<void> changeUserLevel(String level) async {
    final newSettings = state.copyWith(userLevel: level);
    await HiveService.updateSettings(newSettings);
    state = newSettings;
  }

  /// 초기 설정 완료
  Future<void> completeInitialSetup({
    required String uiLanguage,
    required String learningLanguage,
    String? userLevel,
  }) async {
    final newSettings = AppSettingsModel(
      uiLanguage: uiLanguage,
      learningLanguage: learningLanguage,
      isFirstLaunch: false,
      userLevel: userLevel ?? 'foundation',
    );
    await HiveService.updateSettings(newSettings);
    state = newSettings;
  }

  /// 설정 초기화
  Future<void> reset() async {
    final newSettings = AppSettingsModel();
    await HiveService.updateSettings(newSettings);
    state = newSettings;
  }
}

/// 언어 설정 Provider
final languageProvider =
    StateNotifierProvider<LanguageNotifier, AppSettingsModel>((ref) {
      return LanguageNotifier();
    });

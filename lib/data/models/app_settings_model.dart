import 'package:hive/hive.dart';

part 'app_settings_model.g.dart';

@HiveType(typeId: 2)
class AppSettingsModel extends HiveObject {
  @HiveField(0)
  String uiLanguage; // 'ko' or 'en'

  @HiveField(1)
  String learningLanguage; // 'ko' or 'en'

  @HiveField(2)
  bool isFirstLaunch;

  @HiveField(3)
  String userLevel; // 'foundation', 'expression', 'native'

  AppSettingsModel({
    this.uiLanguage = 'ko',
    this.learningLanguage = 'en',
    this.isFirstLaunch = true,
    this.userLevel = 'foundation',
  });

  AppSettingsModel copyWith({
    String? uiLanguage,
    String? learningLanguage,
    bool? isFirstLaunch,
    String? userLevel,
  }) {
    return AppSettingsModel(
      uiLanguage: uiLanguage ?? this.uiLanguage,
      learningLanguage: learningLanguage ?? this.learningLanguage,
      isFirstLaunch: isFirstLaunch ?? this.isFirstLaunch,
      userLevel: userLevel ?? this.userLevel,
    );
  }
}

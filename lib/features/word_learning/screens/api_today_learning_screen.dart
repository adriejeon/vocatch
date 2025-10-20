import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/providers/language_provider.dart';
import '../providers/daily_word_provider.dart';
import '../widgets/word_card.dart';

class ApiTodayLearningScreen extends ConsumerStatefulWidget {
  const ApiTodayLearningScreen({super.key});

  @override
  ConsumerState<ApiTodayLearningScreen> createState() =>
      _ApiTodayLearningScreenState();
}

class _ApiTodayLearningScreenState
    extends ConsumerState<ApiTodayLearningScreen> {
  String selectedCategory = 'conversation';

  @override
  void initState() {
    super.initState();
    // 날짜 체크 및 필요시 리셋
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dailyWordStateProvider.notifier).checkAndResetIfNeeded();
      // 초기 카테고리와 레벨 설정
      final settings = ref.read(languageProvider);
      final level = _convertLevelToApi(settings.userLevel);
      ref
          .read(dailyWordStateProvider.notifier)
          .setCurrentLanguageCategoryAndLevel(
            settings.learningLanguage,
            selectedCategory,
            level,
          );
    });
  }

  // 새로운 레벨 체계를 API 레벨로 변환
  String _convertLevelToApi(String userLevel) {
    switch (userLevel) {
      case 'foundation':
        return 'beginner';
      case 'expression':
        return 'intermediate';
      case 'native':
        return 'advanced';
      default:
        return 'beginner';
    }
  }

  Future<void> _loadNewWords() async {
    try {
      final settings = ref.read(languageProvider);
      final level = _convertLevelToApi(settings.userLevel);
      final language = settings.learningLanguage; // 'en' 또는 'ko'

      await ref
          .read(dailyWordStateProvider.notifier)
          .loadTodayWordsForLanguage(
            language: language,
            level: level,
            learningLanguage: settings.learningLanguage,
            nativeLanguage: settings.uiLanguage,
            category: selectedCategory,
            count: 5,
          );
    } catch (e) {
      print('Load new words error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(languageProvider);
    final uiLang = settings.uiLanguage;
    final dailyWordState = ref.watch(dailyWordStateProvider);
    final dailyWordNotifier = ref.read(dailyWordStateProvider.notifier);

    // 학습언어 변경 시 상태 업데이트
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final level = _convertLevelToApi(settings.userLevel);
      final currentLanguage = settings.learningLanguage;

      // 현재 상태의 언어와 다르면 업데이트
      if (dailyWordState.currentLanguage != currentLanguage) {
        dailyWordNotifier.setCurrentLanguageCategoryAndLevel(
          currentLanguage,
          selectedCategory,
          level,
        );
      }
    });

    // Provider 상태에서 값 가져오기
    final words = dailyWordState.words;
    final isLoading = dailyWordState.isLoading;
    final hasLoadedToday = dailyWordState.hasLoadedToday;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppStrings.get('today_learning_title', uiLang)),
        leading: IconButton(
          icon: const Icon(Icons.tune),
          onPressed: () => _showLevelDialog(context),
          tooltip: AppStrings.get('level_setting', uiLang),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () => _showLanguageDialog(context),
            tooltip: '언어 설정',
          ),
        ],
      ),
      body: Column(
        children: [
          // Category Selection Tabs (반응형)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12, // 좌우 12px 패딩으로 조정
              vertical: AppSpacing.paddingSmall,
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // 카테고리 개수
                const int categoryCount = 4;
                // 각 탭의 최소 너비 (패딩 포함)
                const double minTabWidth = 80.0; // 최소 너비 줄임
                // 전체 최소 너비
                final double totalMinWidth = categoryCount * minTabWidth;

                // 화면 너비가 충분하면 전체 너비 사용, 아니면 스크롤
                if (constraints.maxWidth >= totalMinWidth) {
                  return Row(
                    children: [
                      Expanded(
                        child: _buildCategoryButton('conversation', uiLang),
                      ),
                      const SizedBox(width: 4), // 간격 줄임
                      Expanded(child: _buildCategoryButton('travel', uiLang)),
                      const SizedBox(width: 4),
                      Expanded(child: _buildCategoryButton('business', uiLang)),
                      const SizedBox(width: 4),
                      Expanded(child: _buildCategoryButton('news', uiLang)),
                    ],
                  );
                } else {
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildCategoryButton('conversation', uiLang),
                        const SizedBox(width: 4),
                        _buildCategoryButton('travel', uiLang),
                        const SizedBox(width: 4),
                        _buildCategoryButton('business', uiLang),
                        const SizedBox(width: 4),
                        _buildCategoryButton('news', uiLang),
                      ],
                    ),
                  );
                }
              },
            ),
          ),

          // Loading Indicator
          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(AppSpacing.paddingMedium),
              child: CircularProgressIndicator(),
            ),

          // Word List
          Expanded(
            child: !hasLoadedToday && !isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.school, size: 64, color: AppColors.grey40),
                        const SizedBox(height: AppSpacing.paddingMedium),
                        Text(
                          AppStrings.get('get_words_today', uiLang),
                          style: AppTextStyles.headline4.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.paddingLarge),
                        ElevatedButton.icon(
                          onPressed: _loadNewWords,
                          icon: const Icon(Icons.school),
                          label: Text(
                            AppStrings.get('get_words_button', uiLang),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.grey00,
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.paddingLarge,
                              vertical: AppSpacing.paddingMedium,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.paddingMedium),
                    itemCount: words.length,
                    itemBuilder: (context, index) {
                      final word = words[index];
                      return WordCard(
                        word: word,
                        onToggleVocabulary: () {
                          dailyWordNotifier.toggleVocabulary(word.id);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryButton(String category, String uiLang) {
    final isSelected = selectedCategory == category;
    String categoryKey = 'category_$category';

    return ElevatedButton(
      onPressed: () {
        setState(() {
          selectedCategory = category;
        });
        // 카테고리 변경 시 현재 카테고리와 레벨 설정
        final settings = ref.read(languageProvider);
        final level = _convertLevelToApi(settings.userLevel);
        ref
            .read(dailyWordStateProvider.notifier)
            .setCurrentLanguageCategoryAndLevel(
              settings.learningLanguage,
              category,
              level,
            );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? AppColors.primary : AppColors.grey20,
        foregroundColor: isSelected ? AppColors.grey00 : AppColors.textPrimary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.paddingSmall,
          horizontal: AppSpacing.paddingMedium,
        ),
        minimumSize: const Size(80, 40), // 최소 크기 설정
      ),
      child: Text(
        AppStrings.get(categoryKey, uiLang),
        style: AppTextStyles.labelSmall.copyWith(
          color: isSelected ? AppColors.grey00 : AppColors.textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildLanguageButton(
    String languageCode,
    String label,
    String flag,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? AppColors.grey80 : AppColors.grey20,
        foregroundColor: isSelected ? AppColors.grey00 : AppColors.textPrimary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.paddingMedium),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(flag, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: AppSpacing.paddingSmall),
          Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              color: isSelected ? AppColors.grey00 : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    final settings = ref.read(languageProvider);
    final currentUiLang = settings.uiLanguage;
    final currentLearningLang = settings.learningLanguage;

    // 임시 선택 상태를 위한 변수들
    String tempUiLang = currentUiLang;
    String tempLearningLang = currentLearningLang;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('언어 설정', style: AppTextStyles.headline4),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 앱 언어 설정
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '앱 언어',
                  style: AppTextStyles.labelLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildLanguageButton(
                      'ko',
                      '한국어',
                      '🇰🇷',
                      tempUiLang == 'ko',
                      () {
                        setState(() {
                          tempUiLang = 'ko';
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.paddingSmall),
                  Expanded(
                    child: _buildLanguageButton(
                      'en',
                      'English',
                      '🇺🇸',
                      tempUiLang == 'en',
                      () {
                        setState(() {
                          tempUiLang = 'en';
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // 학습 언어 설정
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '학습할 언어',
                  style: AppTextStyles.labelLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildLanguageButton(
                      'ko',
                      '한국어',
                      '🇰🇷',
                      tempLearningLang == 'ko',
                      () {
                        setState(() {
                          tempLearningLang = 'ko';
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.paddingSmall),
                  Expanded(
                    child: _buildLanguageButton(
                      'en',
                      'English',
                      '🇺🇸',
                      tempLearningLang == 'en',
                      () {
                        setState(() {
                          tempLearningLang = 'en';
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                '취소',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                // 앱 언어 변경
                if (tempUiLang != currentUiLang) {
                  await ref
                      .read(languageProvider.notifier)
                      .changeUiLanguage(tempUiLang);
                }

                // 학습 언어 변경
                if (tempLearningLang != currentLearningLang) {
                  await ref
                      .read(languageProvider.notifier)
                      .changeLearningLanguage(tempLearningLang);
                  // 학습 언어 변경 시 상태는 Provider가 자동으로 관리
                }

                if (mounted) {
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.grey00,
              ),
              child: Text(
                '적용',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.grey00,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLevelDialog(BuildContext context) {
    final settings = ref.read(languageProvider);
    final currentLevel = settings.userLevel;
    final uiLang = settings.uiLanguage;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          AppStrings.get('level_setting', uiLang),
          style: AppTextStyles.headline4,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLevelOption(
              'foundation',
              uiLang,
              currentLevel == 'foundation',
              () async {
                await ref
                    .read(languageProvider.notifier)
                    .changeUserLevel('foundation');
                // 레벨 변경 시 현재 레벨 설정
                final level = _convertLevelToApi('foundation');
                ref
                    .read(dailyWordStateProvider.notifier)
                    .setCurrentLanguageCategoryAndLevel(
                      settings.learningLanguage,
                      selectedCategory,
                      level,
                    );
                if (mounted && Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
              },
            ),
            const SizedBox(height: AppSpacing.paddingSmall),
            _buildLevelOption(
              'expression',
              uiLang,
              currentLevel == 'expression',
              () async {
                await ref
                    .read(languageProvider.notifier)
                    .changeUserLevel('expression');
                // 레벨 변경 시 현재 레벨 설정
                final level = _convertLevelToApi('expression');
                ref
                    .read(dailyWordStateProvider.notifier)
                    .setCurrentLanguageCategoryAndLevel(
                      settings.learningLanguage,
                      selectedCategory,
                      level,
                    );
                if (mounted && Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
              },
            ),
            const SizedBox(height: AppSpacing.paddingSmall),
            _buildLevelOption(
              'native',
              uiLang,
              currentLevel == 'native',
              () async {
                await ref
                    .read(languageProvider.notifier)
                    .changeUserLevel('native');
                // 레벨 변경 시 현재 레벨 설정
                final level = _convertLevelToApi('native');
                ref
                    .read(dailyWordStateProvider.notifier)
                    .setCurrentLanguageCategoryAndLevel(
                      settings.learningLanguage,
                      selectedCategory,
                      level,
                    );
                if (mounted && Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelOption(
    String level,
    String uiLang,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.paddingMedium),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : AppColors.surface,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                AppStrings.get('level_$level', uiLang),
                style: AppTextStyles.labelLarge.copyWith(
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}

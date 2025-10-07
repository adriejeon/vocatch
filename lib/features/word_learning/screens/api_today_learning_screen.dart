import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/providers/language_provider.dart';
import '../providers/api_word_provider.dart';
import '../widgets/word_card.dart';

class ApiTodayLearningScreen extends ConsumerStatefulWidget {
  const ApiTodayLearningScreen({super.key});

  @override
  ConsumerState<ApiTodayLearningScreen> createState() =>
      _ApiTodayLearningScreenState();
}

class _ApiTodayLearningScreenState extends ConsumerState<ApiTodayLearningScreen> {
  String selectedLevel = 'beginner';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadWords();
  }

  Future<void> _loadWords() async {
    final settings = ref.read(languageProvider);
    await ref.read(apiWordProvider.notifier).loadExistingWords(
      level: selectedLevel,
      learningLanguage: settings.learningLanguage,
    );
  }

  Future<void> _loadNewWords() async {
    setState(() {
      isLoading = true;
    });

    try {
      final settings = ref.read(languageProvider);
      await ref.read(apiWordProvider.notifier).loadDailyWords(
        level: selectedLevel,
        learningLanguage: settings.learningLanguage,
        nativeLanguage: settings.uiLanguage,
        count: 5,
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(languageProvider);
    final uiLang = settings.uiLanguage;
    final words = ref.watch(apiWordProvider);
    final apiWordNotifier = ref.read(apiWordProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppStrings.get('today_learning_title', uiLang)),
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () => _showLanguageDialog(context),
            tooltip: 'Change UI Language',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: isLoading ? null : _loadNewWords,
            tooltip: 'Load New Words',
          ),
        ],
      ),
      body: Column(
        children: [
          // Level Selection Buttons
          Container(
            padding: const EdgeInsets.all(AppSpacing.paddingMedium),
            child: Row(
              children: [
                _buildLevelButton('beginner', uiLang),
                const SizedBox(width: AppSpacing.paddingSmall),
                _buildLevelButton('intermediate', uiLang),
                const SizedBox(width: AppSpacing.paddingSmall),
                _buildLevelButton('advanced', uiLang),
              ],
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
            child: words.isEmpty && !isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.cloud_download,
                          size: 64,
                          color: AppColors.grey40,
                        ),
                        const SizedBox(height: AppSpacing.paddingMedium),
                        Text(
                          AppStrings.get('no_words_today', uiLang),
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.paddingSmall),
                        ElevatedButton.icon(
                          onPressed: _loadNewWords,
                          icon: const Icon(Icons.cloud_download),
                          label: Text('새로운 단어 가져오기'),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.paddingMedium),
                    itemCount: words.length,
                    itemBuilder: (context, index) {
                      return WordCard(
                        word: words[index],
                        onToggleVocabulary: () {
                          apiWordNotifier.toggleVocabulary(words[index].id);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelButton(String level, String uiLang) {
    final isSelected = selectedLevel == level;
    String levelKey = 'level_$level';

    return Expanded(
      child: ElevatedButton(
        onPressed: () async {
          setState(() {
            selectedLevel = level;
          });
          await _loadWords();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? AppColors.primary : AppColors.grey20,
          foregroundColor: isSelected ? AppColors.grey00 : AppColors.textPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.paddingMedium),
        ),
        child: Text(
          AppStrings.get(levelKey, uiLang),
          style: AppTextStyles.labelMedium.copyWith(
            color: isSelected ? AppColors.grey00 : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    final settings = ref.read(languageProvider);
    final currentUiLang = settings.uiLanguage;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          AppStrings.get('select_ui_language', currentUiLang),
          style: AppTextStyles.headline4,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('한국어'),
              leading: const Text('🇰🇷', style: TextStyle(fontSize: 24)),
              onTap: () {
                ref.read(languageProvider.notifier).changeUiLanguage('ko');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('English'),
              leading: const Text('🇺🇸', style: TextStyle(fontSize: 24)),
              onTap: () {
                ref.read(languageProvider.notifier).changeUiLanguage('en');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

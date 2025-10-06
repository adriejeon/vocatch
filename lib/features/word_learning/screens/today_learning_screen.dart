import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/providers/language_provider.dart';
import '../providers/word_provider.dart';
import '../widgets/word_card.dart';

class TodayLearningScreen extends ConsumerStatefulWidget {
  const TodayLearningScreen({super.key});

  @override
  ConsumerState<TodayLearningScreen> createState() =>
      _TodayLearningScreenState();
}

class _TodayLearningScreenState extends ConsumerState<TodayLearningScreen> {
  String selectedLevel = 'beginner';

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(languageProvider);
    final uiLang = settings.uiLanguage;
    final learningLang = settings.learningLanguage;
    ref.watch(wordProvider); // Watch for changes
    final wordNotifier = ref.read(wordProvider.notifier);

    final filteredWords = wordNotifier.getWordsByLevel(
      selectedLevel,
      learningLang,
    );

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

          // Word List
          Expanded(
            child: filteredWords.isEmpty
                ? Center(
                    child: Text(
                      AppStrings.get('no_words_today', uiLang),
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.paddingMedium),
                    itemCount: filteredWords.length,
                    itemBuilder: (context, index) {
                      return WordCard(
                        word: filteredWords[index],
                        onToggleVocabulary: () {
                          wordNotifier.toggleVocabulary(filteredWords[index].id);
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
        onPressed: () {
          setState(() {
            selectedLevel = level;
          });
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

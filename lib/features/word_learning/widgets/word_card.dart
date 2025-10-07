import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/providers/language_provider.dart';
import '../../../core/services/tts_service.dart';
import '../../../data/models/word_model.dart';

class WordCard extends ConsumerWidget {
  final WordModel word;
  final VoidCallback onToggleVocabulary;

  const WordCard({
    super.key,
    required this.word,
    required this.onToggleVocabulary,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(languageProvider);
    final uiLang = settings.uiLanguage;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.paddingMedium),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Word and Type
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              word.word,
                              style: AppTextStyles.headline4,
                            ),
                          ),
                          // 발음 듣기 버튼
                          IconButton(
                            onPressed: () => _speakWord(word, uiLang),
                            icon: const Icon(
                              Icons.volume_up,
                              color: AppColors.primary,
                            ),
                            tooltip: '발음 듣기',
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                          ),
                        ],
                      ),
                      if (word.pronunciation != null)
                        Text(
                          word.pronunciation!,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.paddingSmall,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: word.type == 'word'
                        ? AppColors.primary.withOpacity(0.1)
                        : AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                  ),
                  child: Text(
                    AppStrings.get(word.type, uiLang),
                    style: AppTextStyles.labelSmall.copyWith(
                      color: word.type == 'word'
                          ? AppColors.primary
                          : AppColors.success,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.paddingSmall),

            // Meaning
            Text(
              '${AppStrings.get('meaning', uiLang)}: ${word.meaning}',
              style: AppTextStyles.bodyMedium,
            ),

            // Example
            if (word.example != null) ...[
              const SizedBox(height: AppSpacing.paddingSmall),
              Container(
                padding: const EdgeInsets.all(AppSpacing.paddingSmall),
                decoration: BoxDecoration(
                  color: AppColors.grey10,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                ),
                child: Text(
                  '${AppStrings.get('example', uiLang)}: ${word.example}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],

            const SizedBox(height: AppSpacing.paddingSmall),

            // Action Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onToggleVocabulary,
                icon: Icon(
                  word.isInVocabulary
                      ? Icons.bookmark
                      : Icons.bookmark_border,
                ),
                label: Text(
                  word.isInVocabulary
                      ? AppStrings.get('remove_from_vocabulary', uiLang)
                      : AppStrings.get('add_to_vocabulary', uiLang),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: word.isInVocabulary
                      ? AppColors.grey40
                      : AppColors.primary,
                  foregroundColor: AppColors.grey00,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 단어 발음 듣기
  void _speakWord(WordModel word, String uiLang) async {
    try {
      // 학습 언어에 따라 발음
      if (word.learningLanguage == 'en') {
        // 영어 단어 발음
        await TtsService.speakEnglish(word.word);
      } else if (word.learningLanguage == 'ko') {
        // 한국어 단어 발음
        await TtsService.speakKorean(word.word);
      }
    } catch (e) {
      print('발음 재생 오류: $e');
    }
  }
}

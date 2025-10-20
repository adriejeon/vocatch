import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/providers/language_provider.dart';
import '../../../core/services/tts_service.dart';
import '../../../data/models/word_model.dart';
import '../../word_learning/providers/daily_word_provider.dart';

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

    // Provider에서 최신 단어 정보 가져오기
    final dailyWordState = ref.watch(dailyWordStateProvider);
    final currentWord = dailyWordState.words.firstWhere(
      (w) => w.id == word.id,
      orElse: () => word,
    );

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
                              currentWord.word,
                              style: AppTextStyles.headline4,
                            ),
                          ),
                          // 품사 칩
                          if (currentWord.synonyms != null &&
                              currentWord.synonyms!.isNotEmpty)
                            Container(
                              margin: const EdgeInsets.only(
                                right: AppSpacing.paddingSmall,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.paddingSmall,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(
                                  AppSpacing.radiusSmall,
                                ),
                                border: Border.all(
                                  color: AppColors.primary.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                _getPosLabel(
                                  currentWord.synonyms!.first,
                                  uiLang,
                                ),
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11,
                                ),
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
                      if (currentWord.pronunciation != null)
                        Text(
                          currentWord.pronunciation!,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.paddingSmall),

            // Meaning
            Text(currentWord.meaning, style: AppTextStyles.bodyMedium),

            // Example
            if (currentWord.example != null) ...[
              const SizedBox(height: AppSpacing.paddingSmall),
              SizedBox(
                width: double.infinity,
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.paddingSmall),
                  decoration: BoxDecoration(
                    color: AppColors.grey10,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                  ),
                  child: Text(
                    '${AppStrings.get('example', uiLang)}: ${currentWord.example}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ],

            // 동사 변화형 정보
            if (currentWord.verbConjugations != null) ...[
              const SizedBox(height: AppSpacing.paddingSmall),
              _buildVerbConjugations(currentWord.verbConjugations!, uiLang),
            ],

            // 동의어/반대어 제거 (사용자 요청에 따라)
            const SizedBox(height: AppSpacing.paddingSmall),

            // Action Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onToggleVocabulary,
                icon: Icon(
                  currentWord.isInVocabulary
                      ? Icons.bookmark
                      : Icons.bookmark_border,
                ),
                label: Text(
                  currentWord.isInVocabulary
                      ? AppStrings.get('remove_from_vocabulary', uiLang)
                      : AppStrings.get('add_to_vocabulary', uiLang),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: currentWord.isInVocabulary
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

  // 동의어/반대어 관련 메서드 제거 (사용자 요청에 따라)

  /// 동사 변화형 표시 위젯
  Widget _buildVerbConjugations(
    Map<String, dynamic> conjugations,
    String uiLang,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.paddingSmall),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
        border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.auto_awesome,
                size: 16,
                color: AppColors.primary,
              ),
              const SizedBox(width: AppSpacing.paddingSmall),
              Text(
                AppStrings.get('verb_conjugations', uiLang),
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.paddingSmall),
          if (conjugations['conjugations'] != null) ...[
            _buildConjugationGrid(
              conjugations['conjugations'] as Map<String, String>,
            ),
          ],
          if (conjugations['examples'] != null) ...[
            const SizedBox(height: AppSpacing.paddingSmall),
            _buildConjugationExamples(conjugations['examples'] as List<String>),
          ],
        ],
      ),
    );
  }

  /// 동사 변화형 그리드
  Widget _buildConjugationGrid(Map<String, String> conjugations) {
    final List<MapEntry<String, String>> entries = conjugations.entries
        .toList();

    return Wrap(
      spacing: AppSpacing.paddingSmall,
      runSpacing: AppSpacing.paddingSmall,
      children: entries.map((entry) {
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.paddingSmall,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.2),
            borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.4),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getConjugationLabel(entry.key),
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                entry.value,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  /// 동사 변화형 라벨 변환
  String _getConjugationLabel(String key) {
    switch (key) {
      case 'present':
        return '현재형';
      case 'present_3rd':
        return '3인칭 단수';
      case 'past':
        return '과거형';
      case 'past_participle':
        return '과거분사';
      case 'present_participle':
        return '현재분사';
      default:
        return key;
    }
  }

  /// 동사 변화형 예문
  Widget _buildConjugationExamples(List<String> examples) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '예문:',
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.paddingSmall),
        ...examples
            .take(2)
            .map(
              (example) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '• $example',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
      ],
    );
  }

  /// 단어 발음 듣기
  void _speakWord(WordModel word, String uiLang) async {
    try {
      print('발음 버튼 클릭됨: ${word.word}');

      // 시각적 피드백 먼저 표시
      _showPronunciationFeedback(word.word);

      // 학습 언어에 따라 발음
      if (word.learningLanguage == 'en' || word.learningLanguage == 'English') {
        // 영어 단어 발음
        print('영어 TTS 호출 시작');
        await TtsService.speakEnglish(word.word);
        print('영어 TTS 호출 완료');
      } else if (word.learningLanguage == 'ko' ||
          word.learningLanguage == 'Korean') {
        // 한국어 단어 발음
        print('한국어 TTS 호출 시작');
        await TtsService.speakKorean(word.word);
        print('한국어 TTS 호출 완료');
      } else {
        print('알 수 없는 학습 언어: ${word.learningLanguage}');
        // 기본적으로 영어로 시도
        print('기본값으로 영어 TTS 시도');
        await TtsService.speakEnglish(word.word);
      }
    } catch (e) {
      print('발음 재생 오류: $e');
      _showPronunciationFeedback(word.word);
    }
  }

  /// 발음 피드백 표시
  void _showPronunciationFeedback(String word) {
    // 콘솔에 발음 피드백 표시
    print('🔊 "$word" 발음 재생 중...');
  }

  /// 품사 라벨 변환 (다국어 지원)
  String _getPosLabel(String pos, String uiLang) {
    final posKey = 'pos_${pos.toLowerCase()}';
    final translatedPos = AppStrings.get(posKey, uiLang);

    // 번역이 있으면 사용, 없으면 원본 반환
    if (translatedPos != posKey) {
      return translatedPos;
    }

    // 기본값으로 원본을 대문자로 반환
    return pos.toUpperCase();
  }
}

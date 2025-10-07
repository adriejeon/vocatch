import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/providers/language_provider.dart';
import '../../main_screen.dart';

/// 언어 수준 테스트 화면
class LevelTestScreen extends ConsumerStatefulWidget {
  final String uiLanguage;
  final String learningLanguage;

  const LevelTestScreen({
    super.key,
    required this.uiLanguage,
    required this.learningLanguage,
  });

  @override
  ConsumerState<LevelTestScreen> createState() => _LevelTestScreenState();
}

class _LevelTestScreenState extends ConsumerState<LevelTestScreen> {
  int currentQuestionIndex = 0;
  int foundationScore = 0;
  int expressionScore = 0;
  int nativeScore = 0;
  bool isTestComplete = false;
  String? determinedLevel;

  // 테스트 단어들 (각 수준별 5개씩)
  List<Map<String, String>> get testWords {
    if (widget.learningLanguage == 'ko') {
      // 한국어 학습용 테스트 단어들
      return [
        // 기초 다지기 (foundation)
        {'word': '안녕하세요', 'meaning': 'Hello', 'level': 'foundation'},
        {'word': '감사합니다', 'meaning': 'Thank you', 'level': 'foundation'},
        {'word': '좋은', 'meaning': 'Good', 'level': 'foundation'},
        {'word': '물', 'meaning': 'Water', 'level': 'foundation'},
        {'word': '음식', 'meaning': 'Food', 'level': 'foundation'},
        // 표현력 확장 (expression)
        {'word': '감사하다', 'meaning': 'Appreciate', 'level': 'expression'},
        {'word': '고려하다', 'meaning': 'Consider', 'level': 'expression'},
        {'word': '기회', 'meaning': 'Opportunity', 'level': 'expression'},
        {'word': '필요한', 'meaning': 'Necessary', 'level': 'expression'},
        {'word': '이용 가능한', 'meaning': 'Available', 'level': 'expression'},
        // 원어민 수준 (native)
        {'word': '비록 ~일지라도', 'meaning': 'Albeit', 'level': 'native'},
        {'word': '세심한', 'meaning': 'Meticulous', 'level': 'native'},
        {'word': '모호한', 'meaning': 'Ambiguous', 'level': 'native'},
        {'word': '웅변의', 'meaning': 'Eloquent', 'level': 'native'},
        {'word': '실용적인', 'meaning': 'Pragmatic', 'level': 'native'},
      ];
    } else {
      // 영어 학습용 테스트 단어들
      return [
        // 기초 다지기 (foundation)
        {'word': 'hello', 'meaning': '안녕하세요', 'level': 'foundation'},
        {'word': 'thank you', 'meaning': '감사합니다', 'level': 'foundation'},
        {'word': 'good', 'meaning': '좋은', 'level': 'foundation'},
        {'word': 'water', 'meaning': '물', 'level': 'foundation'},
        {'word': 'food', 'meaning': '음식', 'level': 'foundation'},
        // 표현력 확장 (expression)
        {'word': 'appreciate', 'meaning': '감사하다', 'level': 'expression'},
        {'word': 'consider', 'meaning': '고려하다', 'level': 'expression'},
        {'word': 'opportunity', 'meaning': '기회', 'level': 'expression'},
        {'word': 'necessary', 'meaning': '필요한', 'level': 'expression'},
        {'word': 'available', 'meaning': '이용 가능한', 'level': 'expression'},
        // 원어민 수준 (native)
        {'word': 'albeit', 'meaning': '비록 ~일지라도', 'level': 'native'},
        {'word': 'meticulous', 'meaning': '세심한', 'level': 'native'},
        {'word': 'ambiguous', 'meaning': '모호한', 'level': 'native'},
        {'word': 'eloquent', 'meaning': '웅변의', 'level': 'native'},
        {'word': 'pragmatic', 'meaning': '실용적인', 'level': 'native'},
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isTestComplete) {
      return _buildTestCompleteScreen();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.paddingLarge),
          child: Column(
            children: [
              // Progress Indicator
              Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: (currentQuestionIndex + 1) / testWords.length,
                      backgroundColor: AppColors.grey20,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.paddingMedium),
                  Text(
                    '${currentQuestionIndex + 1}/${testWords.length}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.paddingXLarge),

              // Title
              Text(
                AppStrings.get('level_test_title', widget.uiLanguage),
                style: AppTextStyles.headline3,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.paddingSmall),
              Text(
                AppStrings.get('level_test_question', widget.uiLanguage),
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.paddingXLarge),

              // Word Card
              Expanded(
                child: Center(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.paddingXLarge * 2),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(
                        AppSpacing.radiusLarge,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          testWords[currentQuestionIndex]['word']!,
                          style: AppTextStyles.headline1.copyWith(
                            fontSize: 48,
                            color: AppColors.primary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.paddingMedium),
                        Text(
                          testWords[currentQuestionIndex]['meaning']!,
                          style: AppTextStyles.headline4.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.paddingXLarge),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _handleAnswer(false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.grey20,
                        foregroundColor: AppColors.grey80,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.paddingLarge,
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        AppStrings.get('i_dont_know', widget.uiLanguage),
                        style: AppTextStyles.buttonLarge.copyWith(
                          color: AppColors.grey80,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.paddingMedium),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _handleAnswer(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.paddingLarge,
                        ),
                      ),
                      child: Text(
                        AppStrings.get('i_know', widget.uiLanguage),
                        style: AppTextStyles.buttonLarge,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.paddingMedium),

              // Skip Button
              TextButton(
                onPressed: _skipTest,
                child: Text(
                  AppStrings.get('skip_test', widget.uiLanguage),
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTestCompleteScreen() {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.paddingLarge),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.celebration, size: 80, color: AppColors.primary),
              const SizedBox(height: AppSpacing.paddingXLarge),
              Text(
                AppStrings.get('test_complete', widget.uiLanguage),
                style: AppTextStyles.headline2,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.paddingMedium),
              Text(
                AppStrings.get('your_level_is', widget.uiLanguage),
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.paddingLarge),
              Container(
                padding: const EdgeInsets.all(AppSpacing.paddingXLarge),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                  border: Border.all(color: AppColors.primary, width: 2),
                ),
                child: Text(
                  AppStrings.get('level_$determinedLevel', widget.uiLanguage),
                  style: AppTextStyles.headline3.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.paddingXLarge * 2),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _completeSetup,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.paddingMedium,
                    ),
                  ),
                  child: Text(
                    AppStrings.get('start', widget.uiLanguage),
                    style: AppTextStyles.buttonLarge,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleAnswer(bool knows) {
    final currentLevel = testWords[currentQuestionIndex]['level']!;

    if (knows) {
      // 알고 있다고 답한 경우, 해당 레벨에 점수 추가
      switch (currentLevel) {
        case 'foundation':
          foundationScore++;
          break;
        case 'expression':
          expressionScore++;
          break;
        case 'native':
          nativeScore++;
          break;
      }
    }

    // 다음 질문으로 이동
    if (currentQuestionIndex < testWords.length - 1) {
      setState(() {
        currentQuestionIndex++;
      });
    } else {
      _completeTest();
    }
  }

  void _completeTest() {
    // 점수를 기반으로 수준 결정
    // foundation 5개 중 4개 이상 -> 최소 expression
    // expression 5개 중 4개 이상 -> 최소 native
    String level = 'foundation';

    if (foundationScore >= 4 && expressionScore >= 4) {
      level = 'native';
    } else if (foundationScore >= 4) {
      level = 'expression';
    }

    setState(() {
      determinedLevel = level;
      isTestComplete = true;
    });
  }

  void _skipTest() {
    // 테스트를 건너뛰고 기본 수준(foundation)으로 설정
    setState(() {
      determinedLevel = 'foundation';
      isTestComplete = true;
    });
  }

  Future<void> _completeSetup() async {
    await ref
        .read(languageProvider.notifier)
        .completeInitialSetup(
          uiLanguage: widget.uiLanguage,
          learningLanguage: widget.learningLanguage,
          userLevel: determinedLevel,
        );

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    }
  }
}

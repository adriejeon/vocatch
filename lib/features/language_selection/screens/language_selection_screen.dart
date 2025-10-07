import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/providers/language_provider.dart';
import 'level_test_screen.dart';

class LanguageSelectionScreen extends ConsumerStatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  ConsumerState<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState
    extends ConsumerState<LanguageSelectionScreen> {
  String? selectedLearningLanguage;
  String? selectedUiLanguage;
  int currentStep = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.paddingLarge),
          child: Column(
            children: [
              // Progress Indicator
              LinearProgressIndicator(
                value: (currentStep + 1) / 3,
                backgroundColor: AppColors.grey20,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.paddingXLarge),

              // Content
              Expanded(
                child: currentStep == 0
                    ? _buildLearningLanguageSelection()
                    : _buildUiLanguageSelection(),
              ),

              // Next Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _canProceed() ? _handleNext : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.paddingMedium,
                    ),
                  ),
                  child: Text(
                    currentStep == 0 ? '다음' : '시작하기',
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

  Widget _buildLearningLanguageSelection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          '학습할 언어를 선택하세요',
          style: AppTextStyles.headline3,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.paddingXLarge),
        _buildLanguageCard(
          language: 'en',
          label: 'English',
          subtitle: '영어',
          isSelected: selectedLearningLanguage == 'en',
          onTap: () {
            setState(() {
              selectedLearningLanguage = 'en';
            });
          },
        ),
        const SizedBox(height: AppSpacing.paddingMedium),
        _buildLanguageCard(
          language: 'ko',
          label: '한국어',
          subtitle: 'Korean',
          isSelected: selectedLearningLanguage == 'ko',
          onTap: () {
            setState(() {
              selectedLearningLanguage = 'ko';
            });
          },
        ),
      ],
    );
  }

  Widget _buildUiLanguageSelection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          '앱 언어를 선택하세요',
          style: AppTextStyles.headline3,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.paddingXLarge),
        _buildLanguageCard(
          language: 'ko',
          label: '한국어',
          subtitle: 'Korean',
          isSelected: selectedUiLanguage == 'ko',
          onTap: () {
            setState(() {
              selectedUiLanguage = 'ko';
            });
          },
        ),
        const SizedBox(height: AppSpacing.paddingMedium),
        _buildLanguageCard(
          language: 'en',
          label: 'English',
          subtitle: '영어',
          isSelected: selectedUiLanguage == 'en',
          onTap: () {
            setState(() {
              selectedUiLanguage = 'en';
            });
          },
        ),
      ],
    );
  }

  Widget _buildLanguageCard({
    required String language,
    required String label,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.paddingLarge),
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
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.grey20,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  language == 'en' ? '🇺🇸' : '🇰🇷',
                  style: const TextStyle(fontSize: 32),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.paddingMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.labelLarge.copyWith(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 28,
              ),
          ],
        ),
      ),
    );
  }

  bool _canProceed() {
    if (currentStep == 0) {
      return selectedLearningLanguage != null;
    } else {
      return selectedUiLanguage != null;
    }
  }

  void _handleNext() {
    if (currentStep == 0) {
      setState(() {
        currentStep = 1;
      });
    } else {
      _completeSetup();
    }
  }

  void _completeSetup() {
    if (selectedUiLanguage != null && selectedLearningLanguage != null) {
      // 언어 수준 테스트 화면으로 이동
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => LevelTestScreen(
            uiLanguage: selectedUiLanguage!,
            learningLanguage: selectedLearningLanguage!,
          ),
        ),
      );
    }
  }
}

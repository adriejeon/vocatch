import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/providers/language_provider.dart';
import '../models/game_state.dart';

class GameResultDialog extends ConsumerWidget {
  final GameState gameState;
  final VoidCallback onRestart;
  final VoidCallback onHome;

  const GameResultDialog({
    super.key,
    required this.gameState,
    required this.onRestart,
    required this.onHome,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(languageProvider);
    final uiLang = settings.uiLanguage;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.paddingLarge),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 완료 아이콘
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle,
              color: AppColors.success,
              size: 48,
            ),
          ),

          const SizedBox(height: AppSpacing.paddingLarge),

          // 완료 메시지
          Text(
            AppStrings.get('game_complete', uiLang),
            style: AppTextStyles.headline4.copyWith(
              color: AppColors.success,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: AppSpacing.paddingMedium),

          // 결과 통계
          Container(
            padding: const EdgeInsets.all(AppSpacing.paddingMedium),
            decoration: BoxDecoration(
              color: AppColors.grey10,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildStatRow(
                  AppStrings.get('total_moves', uiLang),
                  '${gameState.moves}',
                ),
                _buildStatRow(
                  AppStrings.get('completion_time', uiLang),
                  _formatTime(gameState.gameTimeInSeconds),
                ),
                _buildStatRow(
                  AppStrings.get('accuracy', uiLang),
                  '${gameState.accuracy.toStringAsFixed(1)}%',
                ),
                _buildStatRow(
                  AppStrings.get('final_score', uiLang),
                  '${gameState.score}',
                  isScore: true,
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.paddingLarge),

          // 버튼들
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onRestart,
                  icon: const Icon(Icons.refresh),
                  label: Text(AppStrings.get('retry', uiLang)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.grey00,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.paddingMedium,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.paddingMedium),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onHome,
                  icon: const Icon(Icons.home),
                  label: Text(AppStrings.get('go_home', uiLang)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.paddingMedium,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, {bool isScore = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isScore ? AppColors.primary : AppColors.textPrimary,
              fontWeight: isScore ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}

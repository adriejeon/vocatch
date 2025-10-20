import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/providers/language_provider.dart';
import '../../vocabulary/providers/group_provider.dart';
import '../providers/card_game_provider.dart';
import '../widgets/game_card_widget.dart';
import '../widgets/game_result_dialog.dart';

class CardMatchingScreen extends ConsumerWidget {
  const CardMatchingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(languageProvider);
    final uiLang = settings.uiLanguage;
    final groups = ref.watch(groupProvider);
    final gameState = ref.watch(cardGameProvider);
    final gameNotifier = ref.read(cardGameProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppStrings.get('card_matching_title', uiLang)),
        actions: [
          if (gameState.isGameStarted) ...[
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => gameNotifier.restartGame(),
              tooltip: AppStrings.get('game_restart', uiLang),
            ),
            IconButton(
              icon: const Icon(Icons.home),
              onPressed: () => gameNotifier.resetGame(),
              tooltip: AppStrings.get('go_home', uiLang),
            ),
          ],
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () => _showLanguageDialog(context, ref),
            tooltip: '언어 설정',
          ),
        ],
      ),
      body: gameState.isGameStarted
          ? _buildGameBoard(context, gameState, gameNotifier, uiLang)
          : groups.isEmpty
          ? _buildNoGroupsMessage(uiLang)
          : _buildGroupSelection(context, groups, uiLang, gameNotifier, ref),
    );
  }

  Widget _buildNoGroupsMessage(String uiLang) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.games_outlined, size: 64, color: AppColors.grey40),
          const SizedBox(height: AppSpacing.paddingMedium),
          Text(
            AppStrings.get('no_groups', uiLang),
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.paddingSmall),
          Text(
            AppStrings.get('create_group_first', uiLang),
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupSelection(
    BuildContext context,
    List groups,
    String uiLang,
    gameNotifier,
    WidgetRef ref,
  ) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacing.paddingMedium,
        top: AppSpacing.paddingMedium,
        bottom: AppSpacing.paddingMedium,
      ),
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: groups.length,
              itemBuilder: (context, index) {
                final group = groups[index];
                return Container(
                  margin: const EdgeInsets.only(
                    bottom: AppSpacing.paddingMedium,
                  ),
                  child: ListTile(
                    title: Text(group.name, style: AppTextStyles.labelLarge),
                    subtitle: Text(
                      '${group.wordIds.length} ${AppStrings.get('word', uiLang)}',
                      style: AppTextStyles.bodySmall,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 게임 시작 버튼 (너비 줄임)
                        SizedBox(
                          width: 100, // 고정 너비 설정
                          child: ElevatedButton(
                            onPressed: group.wordIds.length >= 4
                                ? () => _startGame(
                                    context,
                                    group.id,
                                    gameNotifier,
                                    ref,
                                  )
                                : null,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.paddingSmall,
                                vertical: AppSpacing.paddingSmall,
                              ),
                            ),
                            child: Text(
                              AppStrings.get('start_game', uiLang),
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.grey00,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // 삭제 버튼 (오른쪽에 위치)
                        IconButton(
                          onPressed: () => _showDeleteGroupDialog(
                            context,
                            group,
                            ref,
                            uiLang,
                          ),
                          icon: const Icon(
                            Icons.delete_outline,
                            color: AppColors.error,
                            size: 20,
                          ),
                          tooltip: AppStrings.get('delete_group', uiLang),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 8,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 20,
                            minHeight: 20,
                          ),
                          splashRadius: 20,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameBoard(
    BuildContext context,
    gameState,
    gameNotifier,
    String uiLang,
  ) {
    return Column(
      children: [
        // 게임 정보
        Container(
          padding: const EdgeInsets.all(AppSpacing.paddingMedium),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildGameInfo(
                AppStrings.get('moves', uiLang),
                '${gameState.moves}',
              ),
              _buildGameInfo(
                AppStrings.get('matches', uiLang),
                '${gameState.matches}/${gameState.cards.length ~/ 2}',
              ),
              _buildGameInfo(
                AppStrings.get('time', uiLang),
                _formatTime(gameState.gameTimeInSeconds),
              ),
              _buildGameInfo(
                AppStrings.get('score', uiLang),
                '${gameState.score}',
              ),
            ],
          ),
        ),

        // 게임 완료 시 결과 다이얼로그
        if (gameState.isGameComplete)
          Expanded(
            child: GameResultDialog(
              gameState: gameState,
              onRestart: () => gameNotifier.restartGame(),
              onHome: () => gameNotifier.resetGame(),
            ),
          )
        else
          // 카드 그리드
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.paddingMedium),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 0.8,
                ),
                itemCount: gameState.cards.length,
                itemBuilder: (context, index) {
                  final card = gameState.cards[index];
                  return GameCardWidget(
                    card: card,
                    onTap: () => gameNotifier.flipCard(card.id),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildGameInfo(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.labelLarge.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _startGame(
    BuildContext context,
    String groupId,
    gameNotifier,
    WidgetRef ref,
  ) async {
    try {
      // 그룹의 단어 개수에 따라 카드 개수 결정 (최대 20개, 최소 4개)
      final groups = ref.read(groupProvider);
      final group = groups.firstWhere((g) => g.id == groupId);
      final wordCount = group.wordIds.length;
      final cardCount = (wordCount * 2).clamp(8, 40);

      await gameNotifier.initializeGame(groupId: groupId, cardCount: cardCount);
    } catch (e) {
      if (context.mounted) {
        final settings = ref.read(languageProvider);
        final uiLang = settings.uiLanguage;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppStrings.get('game_start_failed', uiLang)}: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// 그룹 삭제 확인 다이얼로그 표시
  void _showDeleteGroupDialog(
    BuildContext context,
    dynamic group,
    WidgetRef ref,
    String uiLang,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          AppStrings.get('delete_group', uiLang),
          style: AppTextStyles.headline4,
        ),
        content: Text(
          '${AppStrings.get('delete_group_confirm', uiLang)} "${group.name}"?',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppStrings.get('cancel', uiLang),
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteGroup(context, group.id, ref, uiLang);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.grey00,
            ),
            child: Text(
              AppStrings.get('delete', uiLang),
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.grey00,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 그룹 삭제 실행
  Future<void> _deleteGroup(
    BuildContext context,
    String groupId,
    WidgetRef ref,
    String uiLang,
  ) async {
    try {
      await ref.read(groupProvider.notifier).deleteGroup(groupId);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.get('group_deleted', uiLang)),
            backgroundColor: AppColors.grey80,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppStrings.get('delete_failed', uiLang)}: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showLanguageDialog(BuildContext context, WidgetRef ref) {
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
                }

                if (context.mounted) {
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
}

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
        actions: gameState.isGameStarted
            ? [
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
              ]
            : null,
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
      padding: const EdgeInsets.all(AppSpacing.paddingMedium),
      child: Column(
        children: [
          Text(
            AppStrings.get('select_group', uiLang),
            style: AppTextStyles.headline4,
          ),
          const SizedBox(height: AppSpacing.paddingMedium),
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
                      '${group.wordIds.length} ${AppStrings.get('word', uiLang)}${group.wordIds.length > 1 ? 's' : ''}',
                      style: AppTextStyles.bodySmall,
                    ),
                    trailing: ElevatedButton(
                      onPressed: group.wordIds.length >= 4
                          ? () =>
                                _startGame(context, group.id, gameNotifier, ref)
                          : null,
                      child: Text(AppStrings.get('start_game', uiLang)),
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
}

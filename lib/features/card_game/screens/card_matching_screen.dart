import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/providers/language_provider.dart';
import '../../vocabulary/providers/group_provider.dart';

class CardMatchingScreen extends ConsumerWidget {
  const CardMatchingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(languageProvider);
    final uiLang = settings.uiLanguage;
    final groups = ref.watch(groupProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppStrings.get('card_matching_title', uiLang)),
      ),
      body: groups.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.games_outlined,
                    size: 64,
                    color: AppColors.grey40,
                  ),
                  const SizedBox(height: AppSpacing.paddingMedium),
                  Text(
                    AppStrings.get('no_groups', uiLang),
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.paddingSmall),
                  Text(
                    '단어장에서 그룹을 먼저 만들어주세요',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(AppSpacing.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                        return Card(
                          margin: const EdgeInsets.only(
                            bottom: AppSpacing.paddingMedium,
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: AppColors.primary,
                              child: Text(
                                group.name[0].toUpperCase(),
                                style: AppTextStyles.labelLarge.copyWith(
                                  color: AppColors.grey00,
                                ),
                              ),
                            ),
                            title: Text(
                              group.name,
                              style: AppTextStyles.labelLarge,
                            ),
                            subtitle: Text(
                              '${group.wordIds.length} ${AppStrings.get('word', uiLang)}${group.wordIds.length > 1 ? 's' : ''}',
                              style: AppTextStyles.bodySmall,
                            ),
                            trailing: ElevatedButton(
                              onPressed: group.wordIds.length >= 4
                                  ? () {
                                      // TODO: Start game
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            '게임 기능은 곧 추가될 예정입니다!',
                                          ),
                                          backgroundColor: AppColors.info,
                                        ),
                                      );
                                    }
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
            ),
    );
  }
}

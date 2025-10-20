import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/providers/language_provider.dart';
import '../../../data/models/word_model.dart';
import '../../word_learning/providers/word_provider.dart';
import '../providers/group_provider.dart';
import '../widgets/add_word_dialog.dart';

class VocabularyScreen extends ConsumerStatefulWidget {
  const VocabularyScreen({super.key});

  @override
  ConsumerState<VocabularyScreen> createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends ConsumerState<VocabularyScreen> {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    // 화면이 포커스될 때마다 단어 목록 새로고침
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(wordProvider);
    });

    // 2초마다 자동 새로고침
    _refreshTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (mounted) {
        ref.invalidate(wordProvider);
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(languageProvider);
    final uiLang = settings.uiLanguage;
    final allWords = ref.watch(wordProvider);
    final vocabularyWords = allWords
        .where((word) => word.isInVocabulary)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppStrings.get('vocabulary_title', uiLang)),
        leading: IconButton(
          icon: const Icon(Icons.create_new_folder_outlined),
          onPressed: () => _showCreateGroupDialog(context, ref),
          tooltip: AppStrings.get('create_group', uiLang),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(wordProvider);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(AppStrings.get('refreshed', uiLang)),
                  backgroundColor: AppColors.grey80,
                ),
              );
            },
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () => _showLanguageDialog(context),
            tooltip: '언어 설정',
          ),
        ],
      ),
      body: vocabularyWords.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.folder_open, size: 64, color: AppColors.grey40),
                  const SizedBox(height: AppSpacing.paddingMedium),
                  Text(
                    AppStrings.get('no_vocabulary', uiLang),
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.paddingMedium),
              itemCount: vocabularyWords.length,
              itemBuilder: (context, index) {
                final word = vocabularyWords[index];
                return Card(
                  margin: const EdgeInsets.only(
                    bottom: AppSpacing.paddingMedium,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      child: Text(
                        word.word[0].toUpperCase(),
                        style: AppTextStyles.labelLarge.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    title: Text(word.word, style: AppTextStyles.labelLarge),
                    subtitle: Text(
                      word.meaning,
                      style: AppTextStyles.bodySmall,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.create_new_folder_outlined),
                          onPressed: () =>
                              _showAddToGroupDialog(context, ref, word),
                          color: AppColors.primary,
                          tooltip: AppStrings.get('add_to_group', uiLang),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () async {
                            await ref
                                .read(wordProvider.notifier)
                                .toggleVocabulary(word.id);
                            // 단어장 화면 새로고침
                            ref.invalidate(wordProvider);
                          },
                          color: AppColors.error,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddWordDialog(context),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.grey00,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  void _showAddWordDialog(BuildContext context) {
    showDialog(context: context, builder: (context) => const AddWordDialog());
  }

  void _showCreateGroupDialog(BuildContext context, WidgetRef ref) {
    final settings = ref.read(languageProvider);
    final uiLang = settings.uiLanguage;
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          AppStrings.get('create_group', uiLang),
          style: AppTextStyles.headline4,
        ),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: AppStrings.get('group_name', uiLang),
            border: const OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppStrings.get('cancel', uiLang)),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                ref.read(groupProvider.notifier).createGroup(controller.text);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppStrings.get('success', uiLang)),
                    backgroundColor: AppColors.grey80,
                  ),
                );
              }
            },
            child: Text(AppStrings.get('create', uiLang)),
          ),
        ],
      ),
    );
  }

  void _showAddToGroupDialog(
    BuildContext context,
    WidgetRef ref,
    WordModel word,
  ) {
    final settings = ref.read(languageProvider);
    final uiLang = settings.uiLanguage;
    final groups = ref.read(groupProvider);

    if (groups.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.get('no_groups', uiLang)),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          AppStrings.get('select_group_to_add', uiLang),
          style: AppTextStyles.headline4,
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: groups.map((group) {
              return ListTile(
                title: Text(group.name, style: AppTextStyles.labelLarge),
                subtitle: Text(
                  '${group.wordIds.length} ${AppStrings.get('word', uiLang)}',
                  style: AppTextStyles.bodySmall,
                ),
                onTap: () {
                  ref
                      .read(groupProvider.notifier)
                      .addWordToGroup(group.id, word.id);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppStrings.get('added_to_group', uiLang)),
                      backgroundColor: AppColors.grey80,
                    ),
                  );
                },
              );
            }).toList(),
          ),
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
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
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

                if (mounted) {
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

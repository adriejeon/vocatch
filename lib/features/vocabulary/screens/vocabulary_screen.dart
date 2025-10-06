import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/providers/language_provider.dart';
import '../../word_learning/providers/word_provider.dart';
import '../providers/group_provider.dart';

class VocabularyScreen extends ConsumerWidget {
  const VocabularyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(languageProvider);
    final uiLang = settings.uiLanguage;
    final wordNotifier = ref.read(wordProvider.notifier);
    final vocabularyWords = wordNotifier.getVocabularyWords();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppStrings.get('vocabulary_title', uiLang)),
        actions: [
          IconButton(
            icon: const Icon(Icons.create_new_folder_outlined),
            onPressed: () => _showCreateGroupDialog(context, ref),
            tooltip: AppStrings.get('create_group', uiLang),
          ),
        ],
      ),
      body: vocabularyWords.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.folder_open,
                    size: 64,
                    color: AppColors.grey40,
                  ),
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
                  margin: const EdgeInsets.only(bottom: AppSpacing.paddingMedium),
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
                    title: Text(
                      word.word,
                      style: AppTextStyles.labelLarge,
                    ),
                    subtitle: Text(
                      word.meaning,
                      style: AppTextStyles.bodySmall,
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () {
                        ref.read(wordProvider.notifier).toggleVocabulary(word.id);
                      },
                      color: AppColors.error,
                    ),
                  ),
                );
              },
            ),
    );
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
                    backgroundColor: AppColors.success,
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
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/providers/language_provider.dart';
import '../../../data/models/word_model.dart';
import '../../word_learning/providers/word_provider.dart';

class AddWordDialog extends ConsumerStatefulWidget {
  const AddWordDialog({super.key});

  @override
  ConsumerState<AddWordDialog> createState() => _AddWordDialogState();
}

class _AddWordDialogState extends ConsumerState<AddWordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _wordController = TextEditingController();
  final _meaningController = TextEditingController();
  final _pronunciationController = TextEditingController();
  final _exampleController = TextEditingController();

  String _selectedType = 'word';

  @override
  void dispose() {
    _wordController.dispose();
    _meaningController.dispose();
    _pronunciationController.dispose();
    _exampleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(languageProvider);
    final uiLang = settings.uiLanguage;
    final learningLang = settings.learningLanguage;
    // nativeLanguage는 learningLanguage의 반대
    final nativeLang = learningLang == 'en' ? 'ko' : 'en';

    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.paddingLarge),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 제목
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.paddingSmall),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusSmall,
                        ),
                      ),
                      child: const Icon(
                        Icons.add_circle_outline,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.paddingMedium),
                    Expanded(
                      child: Text(
                        AppStrings.get('add_new_word', uiLang),
                        style: AppTextStyles.headline4,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.paddingLarge),

                // 단어 입력
                TextFormField(
                  controller: _wordController,
                  decoration: InputDecoration(
                    labelText: AppStrings.get('word_text', uiLang),
                    hintText: AppStrings.get('word_hint', uiLang),
                    prefixIcon: const Icon(Icons.text_fields),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return AppStrings.get('please_enter_word', uiLang);
                    }
                    return null;
                  },
                  autofocus: true,
                ),
                const SizedBox(height: AppSpacing.paddingMedium),

                // 의미 입력
                TextFormField(
                  controller: _meaningController,
                  decoration: InputDecoration(
                    labelText: AppStrings.get('meaning', uiLang),
                    hintText: AppStrings.get('meaning_hint', uiLang),
                    prefixIcon: const Icon(Icons.translate),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return AppStrings.get('please_enter_meaning', uiLang);
                    }
                    return null;
                  },
                  maxLines: 2,
                ),
                const SizedBox(height: AppSpacing.paddingMedium),

                // 발음 입력 (선택)
                TextFormField(
                  controller: _pronunciationController,
                  decoration: InputDecoration(
                    labelText: AppStrings.get('pronunciation', uiLang),
                    hintText: AppStrings.get('pronunciation_hint', uiLang),
                    prefixIcon: const Icon(Icons.record_voice_over),
                  ),
                ),
                const SizedBox(height: AppSpacing.paddingMedium),

                // 예문 입력 (선택)
                TextFormField(
                  controller: _exampleController,
                  decoration: InputDecoration(
                    labelText: AppStrings.get('example', uiLang),
                    hintText: AppStrings.get('example_hint', uiLang),
                    prefixIcon: const Icon(Icons.format_quote),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: AppSpacing.paddingMedium),

                // 타입 선택
                _buildTypeSelector(uiLang),
                const SizedBox(height: AppSpacing.paddingLarge),

                // 버튼
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(AppStrings.get('cancel', uiLang)),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.paddingMedium),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _saveWord(
                          context,
                          ref,
                          learningLang,
                          nativeLang,
                          uiLang,
                        ),
                        child: Text(AppStrings.get('save', uiLang)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeSelector(String uiLang) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.paddingMedium),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedType,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, color: AppColors.primary),
          style: AppTextStyles.bodyMedium,
          dropdownColor: AppColors.surface,
          items: [
            DropdownMenuItem(
              value: 'word',
              child: Text(AppStrings.get('type_word', uiLang)),
            ),
            DropdownMenuItem(
              value: 'expression',
              child: Text(AppStrings.get('type_expression', uiLang)),
            ),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedType = value;
              });
            }
          },
        ),
      ),
    );
  }

  Future<void> _saveWord(
    BuildContext context,
    WidgetRef ref,
    String learningLang,
    String nativeLang,
    String uiLang,
  ) async {
    if (_formKey.currentState!.validate()) {
      final uuid = const Uuid();
      final newWord = WordModel(
        id: uuid.v4(),
        word: _wordController.text.trim(),
        meaning: _meaningController.text.trim(),
        pronunciation: _pronunciationController.text.trim().isNotEmpty
            ? _pronunciationController.text.trim()
            : null,
        example: _exampleController.text.trim().isNotEmpty
            ? _exampleController.text.trim()
            : null,
        level: 'beginner', // 기본값으로 기초다지기 설정
        type: _selectedType,
        learningLanguage: learningLang,
        nativeLanguage: nativeLang,
        createdAt: DateTime.now(),
        isInVocabulary: true, // 직접 추가한 단어는 자동으로 단어장에 추가
      );

      await ref.read(wordProvider.notifier).addWord(newWord);

      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.get('word_added', uiLang)),
            backgroundColor: AppColors.grey80,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
            ),
          ),
        );
      }
    }
  }
}

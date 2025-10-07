import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../models/game_card.dart';

class GameCardWidget extends StatelessWidget {
  final GameCard card;
  final VoidCallback onTap;

  const GameCardWidget({super.key, required this.card, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: _getCardColor(),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _buildCardContent(),
          ),
        ),
      ),
    );
  }

  Color _getCardColor() {
    if (card.isMatched) {
      return AppColors.success.withOpacity(0.3);
    } else if (card.isFlipped) {
      return AppColors.primary.withOpacity(0.1);
    } else {
      return AppColors.grey20;
    }
  }

  Widget _buildCardContent() {
    if (card.isFlipped || card.isMatched) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.paddingSmall),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              card.isWord ? Icons.text_fields : Icons.translate,
              color: card.isMatched ? AppColors.success : AppColors.primary,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              card.content,
              key: ValueKey('content_${card.id}'),
              style: AppTextStyles.bodySmall.copyWith(
                color: card.isMatched
                    ? AppColors.success
                    : AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      );
    } else {
      return Icon(
        Icons.help_outline,
        key: ValueKey('question_${card.id}'),
        color: AppColors.grey40,
        size: 32,
      );
    }
  }
}

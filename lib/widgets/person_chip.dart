import 'package:flutter/material.dart';
import 'avatar_bubble.dart';
import '../theme/app_theme.dart';

class PersonChip extends StatelessWidget {
  final String name;
  final String? avatarEmoji;
  final bool isSelected;
  final String? amountBadge;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const PersonChip({
    super.key,
    required this.name,
    this.avatarEmoji,
    this.isSelected = false,
    this.amountBadge,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.accentWarm.withValues(alpha: 0.2)
              : AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.chipRadius),
          border: Border.all(
            color: isSelected ? AppTheme.accentWarm : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AvatarBubble(
              name: name,
              avatarEmoji: avatarEmoji,
              avatarSize: AvatarSize.small,
            ),
            const SizedBox(width: 8),
            Text(
              name,
              style: TextStyle(
                color: isSelected ? AppTheme.accentWarm : AppTheme.textPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            if (amountBadge != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.accentWarm.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  amountBadge!,
                  style: const TextStyle(
                    color: AppTheme.accentWarm,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
            if (onDelete != null) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onDelete,
                child: const Icon(
                  Icons.close,
                  size: 16,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

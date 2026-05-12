import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'avatar_bubble.dart';

/// A rounded chip showing a small avatar + person name + optional amount badge.
/// Selected state switches to a warm peach background.
class PersonChip extends StatelessWidget {
  final String name;
  final String? avatarEmoji;
  final bool isSelected;
  final String? amountLabel;  // e.g. "₹350"
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const PersonChip({
    super.key,
    required this.name,
    this.avatarEmoji,
    this.isSelected = false,
    this.amountLabel,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isSelected
        ? AppTheme.accentWarm.withValues(alpha: 0.18)
        : AppTheme.surface;
    final border = isSelected ? AppTheme.accentWarm : Colors.transparent;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppTheme.chipRadius),
          border: Border.all(color: border, width: 1.4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AvatarBubble(
              name: name,
              avatarEmoji: avatarEmoji,
              sizeVariant: AvatarSize.small,
            ),
            const SizedBox(width: 8),
            Text(
              name,
              style: TextStyle(
                color: isSelected ? AppTheme.accentWarm : AppTheme.textPrimary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
            ),
            if (amountLabel != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.accentWarm.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  amountLabel!,
                  style: const TextStyle(
                    color: AppTheme.accentWarm,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
            if (onDelete != null) ...[
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onDelete,
                child: Icon(
                  Icons.close_rounded,
                  size: 14,
                  color: isSelected ? AppTheme.accentWarm : AppTheme.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

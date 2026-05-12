import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum AvatarSize { small, medium, large }

class AvatarBubble extends StatelessWidget {
  final String name;
  final String? avatarEmoji;
  final AvatarSize avatarSize;
  final double? customSize;

  const AvatarBubble({
    super.key,
    required this.name,
    this.avatarEmoji,
    this.avatarSize = AvatarSize.medium,
    this.customSize,
  });

  double get size {
    if (customSize != null) return customSize!;
    switch (avatarSize) {
      case AvatarSize.small:
        return 32;
      case AvatarSize.medium:
        return 44;
      case AvatarSize.large:
        return 60;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = [
      const Color(0xFF6366F1), // Indigo
      const Color(0xFF8B5CF6), // Violet
      const Color(0xFFEC4899), // Pink
      const Color(0xFFF59E0B), // Amber
      const Color(0xFF10B981), // Emerald
      const Color(0xFF3B82F6), // Blue
      const Color(0xFFEF4444), // Red
      const Color(0xFF8B5A2B), // Brown
    ];

    final color = colors[name.length % colors.length];

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.3), color.withValues(alpha: 0.1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: color, width: size > 40 ? 2.5 : 2),
      ),
      child: Center(
        child: Text(
          avatarEmoji ?? (name.isNotEmpty ? name[0].toUpperCase() : '?'),
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: size * 0.4,
          ),
        ),
      ),
    );
  }
}

class AvatarStack extends StatelessWidget {
  final List<String> names;
  final List<String?> emojis;
  final AvatarSize size;
  final int maxVisible;
  final double overlapOffset;

  const AvatarStack({
    super.key,
    required this.names,
    this.emojis = const [],
    this.size = AvatarSize.medium,
    this.maxVisible = 4,
    this.overlapOffset = 12,
  });

  @override
  Widget build(BuildContext context) {
    final visibleNames = names.take(maxVisible).toList();
    final remainingCount = names.length - maxVisible;
    final avatarSize = _getAvatarSize();

    return SizedBox(
      height: avatarSize,
      width:
          (visibleNames.length * (avatarSize - overlapOffset)) +
          overlapOffset +
          (remainingCount > 0 ? avatarSize : 0),
      child: Stack(
        children: [
          // Visible avatars
          ...visibleNames.asMap().entries.map((entry) {
            final index = entry.key;
            final name = entry.value;
            final emoji = emojis.length > index ? emojis[index] : null;

            return Positioned(
              left: index * (avatarSize - overlapOffset),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.primaryBg, width: 2),
                ),
                child: AvatarBubble(
                  name: name,
                  avatarEmoji: emoji,
                  avatarSize: size,
                ),
              ),
            );
          }),

          // Overflow indicator
          if (remainingCount > 0)
            Positioned(
              left: visibleNames.length * (avatarSize - overlapOffset),
              child: Container(
                width: avatarSize,
                height: avatarSize,
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.textSecondary, width: 2),
                ),
                child: Center(
                  child: Text(
                    '+$remainingCount',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: avatarSize * 0.25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  double _getAvatarSize() {
    switch (size) {
      case AvatarSize.small:
        return 32;
      case AvatarSize.medium:
        return 44;
      case AvatarSize.large:
        return 60;
    }
  }
}

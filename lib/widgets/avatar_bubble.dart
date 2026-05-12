import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// ── Size variants ─────────────────────────────────────────────────────────────
enum AvatarSize { small, medium, large }

extension AvatarSizeExt on AvatarSize {
  double get px {
    switch (this) {
      case AvatarSize.small:  return 32;
      case AvatarSize.medium: return 44;
      case AvatarSize.large:  return 60;
    }
  }
}

// ── Gradient ring colours per person (cycling) ────────────────────────────────
final _gradients = [
  [const Color(0xFF00D2FF), const Color(0xFF7B2FBE)],
  [const Color(0xFFFF6B9D), const Color(0xFFC44BFF)],
  [const Color(0xFFFFB347), const Color(0xFFFF5733)],
  [const Color(0xFF43E97B), const Color(0xFF38F9D7)],
  [const Color(0xFFF5C98A), const Color(0xFF9B59B6)],
];

List<Color> _gradientFor(String name) =>
    _gradients[name.length % _gradients.length];

// ─────────────────────────────────────────────────────────────────────────────
// AvatarBubble
// ─────────────────────────────────────────────────────────────────────────────

/// A circular avatar with a gradient border ring.
/// Shows [avatarEmoji] if set, otherwise the first letter of [name].
class AvatarBubble extends StatelessWidget {
  final String name;
  final String? avatarEmoji;
  final AvatarSize sizeVariant;
  /// Override pixel size directly (ignores [sizeVariant] when set).
  final double? sizePx;
  final String? heroTag;

  const AvatarBubble({
    super.key,
    required this.name,
    this.avatarEmoji,
    this.sizeVariant = AvatarSize.medium,
    this.sizePx,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    final double size = sizePx ?? sizeVariant.px;
    final gradient = _gradientFor(name);
    final label = avatarEmoji ?? (name.isNotEmpty ? name[0].toUpperCase() : '?');
    const ringWidth = 2.5;

    Widget circle = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(ringWidth),
        child: Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF3D3A7A), // AppTheme.surface
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: size * 0.38,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );

    if (heroTag != null) {
      circle = Hero(tag: heroTag!, child: circle);
    }
    return circle;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AvatarStack
// ─────────────────────────────────────────────────────────────────────────────

/// Overlapping row of [AvatarBubble]s, max [maxVisible] shown, then "+N" chip.
class AvatarStack extends StatelessWidget {
  final List<String> names;
  final List<String?> emojis;
  final AvatarSize sizeVariant;
  final int maxVisible;
  /// How much each avatar overlaps the previous one (px).
  final double overlap;

  const AvatarStack({
    super.key,
    required this.names,
    this.emojis = const [],
    this.sizeVariant = AvatarSize.small,
    this.maxVisible = 4,
    this.overlap = 12,
  });

  @override
  Widget build(BuildContext context) {
    final size = sizeVariant.px;
    final shown = names.take(maxVisible).toList();
    final extra = names.length - shown.length;
    final totalWidth = shown.length * (size - overlap) + overlap +
        (extra > 0 ? size - overlap + 4 : 0);

    return SizedBox(
      height: size,
      width: totalWidth,
      child: Stack(
        children: [
          ...List.generate(shown.length, (i) => Positioned(
                left: i * (size - overlap),
                child: AvatarBubble(
                  name: shown[i],
                  avatarEmoji: i < emojis.length ? emojis[i] : null,
                  sizeVariant: sizeVariant,
                ),
              )),
          if (extra > 0)
            Positioned(
              left: shown.length * (size - overlap),
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.accentButton.withValues(alpha: 0.5),
                  border: Border.all(color: AppTheme.surface, width: 1.5),
                ),
                child: Center(
                  child: Text(
                    '+$extra',
                    style: TextStyle(
                      fontSize: size * 0.3,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

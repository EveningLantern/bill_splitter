import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A display-only (or interactive) slider with a colored track per person
/// and a floating label above the thumb showing the live ₹ amount.
class AmountSlider extends StatelessWidget {
  final String label;
  final double value;
  final double max;
  final Color color;
  /// Set to null or provide a no-op to make it display-only.
  final ValueChanged<double>? onChanged;

  const AmountSlider({
    super.key,
    required this.label,
    required this.value,
    required this.max,
    required this.color,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final fraction = max > 0 ? (value / max).clamp(0.0, 1.0) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Name row ─────────────────────────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
            Text(
              '₹${value.toStringAsFixed(2)}',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),

        // ── Track + thumb ─────────────────────────────────────────────────────
        SizedBox(
          height: 28,
          child: LayoutBuilder(builder: (ctx, box) {
            // Position the floating amount label above the thumb
            final thumbX = fraction * box.maxWidth;
            return Stack(
              clipBehavior: Clip.none,
              children: [
                // Colored filled bar
                Positioned.fill(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: fraction,
                          minHeight: 6,
                          backgroundColor: AppTheme.primaryBg,
                          valueColor: AlwaysStoppedAnimation(color),
                        ),
                      ),
                    ],
                  ),
                ),

                // Thumb circle
                Positioned(
                  left: thumbX - 9,
                  top: 5,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color,
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.45),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),

                // Transparent gesture overlay for interactive mode
                if (onChanged != null)
                  Positioned.fill(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: Colors.transparent,
                        inactiveTrackColor: Colors.transparent,
                        thumbColor: Colors.transparent,
                        overlayColor: color.withValues(alpha: 0.1),
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                        trackHeight: 6,
                      ),
                      child: Slider(
                        value: value,
                        max: max == 0 ? 1 : max,
                        onChanged: onChanged,
                      ),
                    ),
                  ),
              ],
            );
          }),
        ),
      ],
    );
  }
}

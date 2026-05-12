import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AmountSlider extends StatefulWidget {
  final double value;
  final double max;
  final ValueChanged<double> onChanged;
  final String personName;
  final Color? trackColor;
  final bool showLabel;

  const AmountSlider({
    super.key,
    required this.value,
    required this.max,
    required this.onChanged,
    required this.personName,
    this.trackColor,
    this.showLabel = true,
  });

  @override
  State<AmountSlider> createState() => _AmountSliderState();
}

class _AmountSliderState extends State<AmountSlider> {
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = widget.trackColor ?? AppTheme.accentWarm;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showLabel) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.personName,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: _isDragging ? effectiveColor : AppTheme.textPrimary,
                  fontWeight: _isDragging ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style:
                    Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: effectiveColor,
                      fontWeight: FontWeight.bold,
                    ) ??
                    const TextStyle(),
                child: Text('₹${widget.value.toStringAsFixed(0)}'),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],

        // Custom slider with live amount label above thumb
        Stack(
          clipBehavior: Clip.none,
          children: [
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 6.0,
                activeTrackColor: effectiveColor,
                inactiveTrackColor: AppTheme.surface,
                thumbColor: effectiveColor,
                overlayColor: effectiveColor.withValues(alpha: 0.2),
                thumbShape: const RoundSliderThumbShape(
                  enabledThumbRadius: 12.0,
                ),
                overlayShape: const RoundSliderOverlayShape(
                  overlayRadius: 20.0,
                ),
                trackShape: const RoundedRectSliderTrackShape(),
              ),
              child: Slider(
                value: widget.value,
                max: widget.max,
                onChanged: widget.onChanged,
                onChangeStart: (_) => setState(() => _isDragging = true),
                onChangeEnd: (_) => setState(() => _isDragging = false),
              ),
            ),

            // Live amount label above thumb
            if (_isDragging)
              Positioned(
                left: _getThumbPosition() - 30,
                top: -45,
                child: AnimatedOpacity(
                  opacity: _isDragging ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: effectiveColor,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      '₹${widget.value.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: AppTheme.primaryBg,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  double _getThumbPosition() {
    // Calculate thumb position based on slider value
    const sliderPadding = 24.0; // Default slider padding
    final sliderWidth = MediaQuery.of(context).size.width - (sliderPadding * 2);
    final thumbPosition =
        (widget.value / widget.max) * sliderWidth + sliderPadding;
    return thumbPosition.clamp(sliderPadding, sliderWidth + sliderPadding);
  }
}

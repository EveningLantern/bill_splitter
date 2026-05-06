import 'package:flutter/material.dart';

class AmountSlider extends StatelessWidget {
  final double value;
  final double max;
  final ValueChanged<double> onChanged;
  final String label;
  final Color? color;

  const AmountSlider({
    super.key,
    required this.value,
    required this.max,
    required this.onChanged,
    required this.label,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: Theme.of(context).textTheme.titleMedium),
            Text(
              '₹${value.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: color ?? Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: color,
            thumbColor: color,
            overlayColor: color?.withOpacity(0.2),
          ),
          child: Slider(
            value: value,
            max: max,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

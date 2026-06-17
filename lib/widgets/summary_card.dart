import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Reusable card for displaying a running total (Total Expenses or Total Income).
///
/// Uses [AppTheme.surface] background and [AppTheme.cardRadius] shape.
/// Formats [amount] as `₹X.XX` using [double.toStringAsFixed].
class SummaryCard extends StatelessWidget {
  /// Short label displayed above the amount, e.g. "Total Expenses".
  final String label;

  /// Numeric total to display.
  final double amount;

  /// Accent color applied to the leading [icon], e.g. [Colors.redAccent] for
  /// expenses or [AppTheme.accentWarm] for income.
  final Color accentColor;

  /// Icon shown next to the label row, e.g. [Icons.arrow_downward_rounded].
  final IconData icon;

  const SummaryCard({
    required this.label,
    required this.amount,
    required this.accentColor,
    required this.icon,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: accentColor, size: 18),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '₹${amount.toStringAsFixed(2)}',
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'avatar_bubble.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Torn-paper edge painter
// ─────────────────────────────────────────────────────────────────────────────

class _TornEdgePainter extends CustomPainter {
  final Color color;
  final bool isTop;
  final int teeth = 18;

  const _TornEdgePainter({
    required this.color,
    this.isTop = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path();
    final toothW = size.width / teeth;
    final toothH = isTop ? 8.0 : -8.0;

    if (isTop) {
      path.moveTo(0, size.height);
      for (int i = 0; i < teeth; i++) {
        final x = i * toothW;
        path.lineTo(x + toothW / 2, size.height - toothH);
        path.lineTo(x + toothW, size.height);
      }
      path.lineTo(size.width, 0);
      path.lineTo(0, 0);
    } else {
      path.moveTo(0, 0);
      for (int i = 0; i < teeth; i++) {
        final x = i * toothW;
        path.lineTo(x + toothW / 2, -toothH);
        path.lineTo(x + toothW, 0);
      }
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_TornEdgePainter old) => old.color != color;
}

// ─────────────────────────────────────────────────────────────────────────────
// Dashed divider painter
// ─────────────────────────────────────────────────────────────────────────────

class _DashedLinePainter extends CustomPainter {
  final Color color;
  const _DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    const dashW = 8.0;
    const gapW = 5.0;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(min(x + dashW, size.width), 0), paint);
      x += dashW + gapW;
    }
  }

  @override
  bool shouldRepaint(_DashedLinePainter old) => old.color != color;
}

// ─────────────────────────────────────────────────────────────────────────────
// ReceiptCard
// ─────────────────────────────────────────────────────────────────────────────

/// A receipt-style card with a torn-paper zigzag top edge, dashed mid-divider,
/// session [title] + [total], and a row of participant [names] / [emojis].
class ReceiptCard extends StatelessWidget {
  final String title;
  final double total;
  final List<String> names;
  final List<String?> emojis;
  final int expenseCount;

  const ReceiptCard({
    super.key,
    required this.title,
    required this.total,
    required this.names,
    this.emojis = const [],
    this.expenseCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Torn top edge ────────────────────────────────────────────────────
        CustomPaint(
          size: const Size(double.infinity, 16),
          painter: _TornEdgePainter(color: AppTheme.accentWarm),
        ),

        // ── Receipt body ─────────────────────────────────────────────────────
        Container(
          width: double.infinity,
          color: AppTheme.accentWarm,
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Receipt',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppTheme.primaryBg.withValues(alpha: 0.55),
                      letterSpacing: 2,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppTheme.primaryBg,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),

              // Dashed divider
              CustomPaint(
                size: const Size(double.infinity, 1),
                painter: _DashedLinePainter(
                    color: AppTheme.primaryBg.withValues(alpha: 0.3)),
              ),
              const SizedBox(height: 12),

              // Totals row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$expenseCount expense${expenseCount == 1 ? '' : 's'}',
                    style: TextStyle(
                        color: AppTheme.primaryBg.withValues(alpha: 0.65),
                        fontSize: 13),
                  ),
                  Text(
                    '₹${total.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppTheme.primaryBg,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Participant avatars
              if (names.isNotEmpty)
                AvatarStack(
                  names: names,
                  emojis: emojis,
                  sizeVariant: AvatarSize.small,
                  maxVisible: 5,
                ),
              const SizedBox(height: 16),
            ],
          ),
        ),

        // ── Torn bottom edge ─────────────────────────────────────────────────
        CustomPaint(
          size: const Size(double.infinity, 16),
          painter: _TornEdgePainter(color: AppTheme.accentWarm, isTop: false),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'avatar_bubble.dart';
import '../theme/app_theme.dart';

class ReceiptCard extends StatelessWidget {
  final String title;
  final double totalAmount;
  final List<String> participantNames;
  final List<String?> participantEmojis;
  final VoidCallback? onTap;
  final Widget? trailing;

  const ReceiptCard({
    super.key,
    required this.title,
    required this.totalAmount,
    required this.participantNames,
    this.participantEmojis = const [],
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: CustomPaint(
          painter: _ReceiptPainter(),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and total
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (trailing != null) trailing!,
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '₹${totalAmount.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppTheme.accentWarm,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                // Dashed divider
                const SizedBox(height: 16),
                CustomPaint(
                  painter: _DashedLinePainter(),
                  size: const Size(double.infinity, 1),
                ),
                const SizedBox(height: 16),

                // Participant avatars
                Row(
                  children: [
                    AvatarStack(
                      names: participantNames,
                      emojis: participantEmojis,
                      size: AvatarSize.small,
                      maxVisible: 4,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${participantNames.length} participant${participantNames.length == 1 ? '' : 's'}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ReceiptPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.surface
      ..style = PaintingStyle.fill;

    final path = Path();

    // Create torn paper effect at top
    const tearHeight = 8.0;
    const tearWidth = 12.0;

    // Start from top-left with torn edge
    path.moveTo(0, tearHeight);

    // Create zigzag pattern across the top
    for (double x = 0; x < size.width; x += tearWidth) {
      final nextX = (x + tearWidth).clamp(0.0, size.width);
      if (x % (tearWidth * 2) == 0) {
        path.lineTo(nextX, 0);
      } else {
        path.lineTo(nextX, tearHeight);
      }
    }

    // Complete the rectangle
    path.lineTo(size.width, size.height - AppTheme.cardRadius);
    path.quadraticBezierTo(
      size.width,
      size.height,
      size.width - AppTheme.cardRadius,
      size.height,
    );
    path.lineTo(AppTheme.cardRadius, size.height);
    path.quadraticBezierTo(
      0,
      size.height,
      0,
      size.height - AppTheme.cardRadius,
    );
    path.close();

    canvas.drawPath(path, paint);

    // Add subtle shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.1)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    canvas.drawPath(path, shadowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.textSecondary.withValues(alpha: 0.3)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const dashWidth = 8.0;
    const dashSpace = 4.0;

    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset((startX + dashWidth).clamp(0, size.width), 0),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

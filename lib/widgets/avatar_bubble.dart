import 'package:flutter/material.dart';

class AvatarBubble extends StatelessWidget {
  final String name;
  final String? avatarEmoji;
  final double size;

  const AvatarBubble({
    super.key,
    required this.name,
    this.avatarEmoji,
    this.size = 100,
  });

  @override
  Widget build(BuildContext context) {
    final color = Colors.primaries[name.length % Colors.primaries.length];
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2),
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

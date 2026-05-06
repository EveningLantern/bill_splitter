import 'package:flutter/material.dart';
import 'avatar_bubble.dart';

class PersonChip extends StatelessWidget {
  final String name;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const PersonChip({
    super.key,
    required this.name,
    this.isSelected = false,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Chip(
        avatar: AvatarBubble(name: name, size: 24),
        label: Text(name),
        onDeleted: onDelete,
        backgroundColor: isSelected ? Theme.of(context).colorScheme.primaryContainer : null,
        side: isSelected ? BorderSide(color: Theme.of(context).colorScheme.primary) : null,
      ),
    );
  }
}

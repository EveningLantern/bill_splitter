import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/session_provider.dart';
import '../../theme/app_theme.dart';

/// Step 1 — Session title + participant management.
class Step1Setup extends ConsumerStatefulWidget {
  const Step1Setup({super.key});

  @override
  ConsumerState<Step1Setup> createState() => _Step1SetupState();
}

class _Step1SetupState extends ConsumerState<Step1Setup> {
  final _titleCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final session = ref.read(splitSessionNotifierProvider);
    _titleCtrl.text = session.title == 'New Trip' ? '' : session.title;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  void _addPerson() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    ref
        .read(splitSessionNotifierProvider.notifier)
        .addParticipantWithEmoji(name, null);
    _nameCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(splitSessionNotifierProvider);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Name this split',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 6),
        Text(
          'e.g. Team Dinner, Goa Trip',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _titleCtrl,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Session Title',
            prefixIcon: Icon(Icons.label_outline),
          ),
          onChanged: (v) {
            if (v.trim().isNotEmpty) {
              ref
                  .read(splitSessionNotifierProvider.notifier)
                  .setTitle(v.trim());
            }
          },
        ),
        const SizedBox(height: 32),
        Text(
          'Add Participants',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 6),
        Text(
          'Who\'s splitting this bill?',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _nameCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  hintText: 'Enter name',
                  prefixIcon: Icon(Icons.person_add_outlined),
                ),
                onSubmitted: (_) => _addPerson(),
              ),
            ),
            const SizedBox(width: 10),
            FilledButton(
              onPressed: _addPerson,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
              ),
              child: const Icon(Icons.add),
            ),
          ],
        ),
        const SizedBox(height: 20),
        if (session.participants.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(AppTheme.cardRadius),
            ),
            child: Center(
              child: Text(
                'No participants yet — add at least 2',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: session.participants.map((p) {
              final colors = [
                Colors.pinkAccent,
                Colors.cyanAccent,
                Colors.deepPurpleAccent,
                Colors.orangeAccent,
              ];
              final color = colors[p.name.length % colors.length];
              return Chip(
                avatar: CircleAvatar(
                  backgroundColor: color.withValues(alpha: 0.25),
                  child: Text(
                    p.avatarEmoji ?? p.name[0].toUpperCase(),
                    style: TextStyle(fontSize: 12, color: color),
                  ),
                ),
                label: Text(p.name),
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () => ref
                    .read(splitSessionNotifierProvider.notifier)
                    .removeParticipant(p.id),
              );
            }).toList(),
          ),
      ],
    );
  }
}

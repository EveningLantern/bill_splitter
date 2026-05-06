import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/history_provider.dart';
import '../providers/profile_provider.dart';
import '../theme/app_theme.dart';

/// Bottom sheet shown when the user taps their avatar in the top bar.
class ProfileSheet extends ConsumerStatefulWidget {
  const ProfileSheet({super.key});

  @override
  ConsumerState<ProfileSheet> createState() => _ProfileSheetState();
}

class _ProfileSheetState extends ConsumerState<ProfileSheet> {
  bool _editing = false;
  late TextEditingController _nameCtrl;
  late TextEditingController _emojiCtrl;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(profileProvider);
    _nameCtrl = TextEditingController(text: profile.name);
    _emojiCtrl = TextEditingController(text: profile.emoji);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emojiCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider);
    final history = ref.watch(historyProvider);

    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.textSecondary.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Avatar + Name
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
            child: Row(
              children: [
                _AvatarCircle(emoji: profile.emoji, size: 60),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.accentWarm.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${history.length} split${history.length == 1 ? '' : 's'}',
                          style: const TextStyle(
                            color: AppTheme.accentWarm,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(
              color: Color(0x22FFFFFF), indent: 24, endIndent: 24),

          // Edit Profile (inline)
          if (_editing) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Edit Profile',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(color: AppTheme.textSecondary)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _nameCtrl,
                    decoration:
                        const InputDecoration(labelText: 'Your name'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _emojiCtrl,
                    decoration:
                        const InputDecoration(labelText: 'Avatar emoji'),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => setState(() => _editing = false),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: () {
                            ref
                                .read(profileProvider.notifier)
                                .updateName(_nameCtrl.text.trim());
                            ref
                                .read(profileProvider.notifier)
                                .updateEmoji(_emojiCtrl.text.trim());
                            setState(() => _editing = false);
                          },
                          child: const Text('Save'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ] else ...[
            ListTile(
              leading: const Icon(Icons.history_rounded,
                  color: AppTheme.accentWarm),
              title: const Text('Split History'),
              trailing: const Icon(Icons.chevron_right,
                  color: AppTheme.textSecondary),
              onTap: () {
                Navigator.pop(context);
                context.push('/history');
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit_rounded,
                  color: AppTheme.accentWarm),
              title: const Text('Edit Profile'),
              trailing: const Icon(Icons.chevron_right,
                  color: AppTheme.textSecondary),
              onTap: () => setState(() => _editing = true),
            ),
          ],

          // Safe area padding
          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    );
  }
}

/// Small coloured circle used in the profile sheet header.
class _AvatarCircle extends StatelessWidget {
  final String emoji;
  final double size;
  const _AvatarCircle({required this.emoji, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppTheme.accentButton.withValues(alpha: 0.3),
        shape: BoxShape.circle,
        border: Border.all(color: AppTheme.accentWarm, width: 2),
      ),
      child: Center(
        child: Text(emoji, style: TextStyle(fontSize: size * 0.45)),
      ),
    );
  }
}

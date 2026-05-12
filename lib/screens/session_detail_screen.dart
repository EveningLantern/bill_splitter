import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/person.dart';
import '../providers/history_provider.dart';
import '../providers/settlement_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/avatar_bubble.dart';

/// Full-page session detail. Navigated to via `/history/:id`.
class SessionDetailScreen extends ConsumerWidget {
  final String sessionId;
  const SessionDetailScreen({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(historyProvider);
    final session = history.firstWhere(
      (s) => s.id == sessionId,
      orElse: () => throw StateError('Session $sessionId not found'),
    );

    // Settlements — computed reactively via settlementProvider family.
    List settlements = [];
    try {
      settlements = ref.watch(settlementsProvider(sessionId));
    } catch (_) {
      settlements = [];
    }

    Person personById(String id) =>
        session.participants.firstWhere((p) => p.id == id,
            orElse: () => Person(name: '?'));

    String shareText() {
      final buf = StringBuffer()
        ..writeln('💸 ${session.title} — Split Summary')
        ..writeln('Total: ₹${session.totalAmount.toStringAsFixed(2)}')
        ..writeln();
      if (settlements.isEmpty) {
        buf.writeln('Everyone is settled ✓');
      } else {
        buf.writeln('Settlements:');
        for (final s in settlements) {
          final from = personById(s.fromPersonId);
          final to = personById(s.toPersonId);
          buf.writeln('  ${from.name} → ${to.name}: ₹${s.amount.toStringAsFixed(2)}');
        }
      }
      return buf.toString();
    }

    return Scaffold(
      backgroundColor: AppTheme.primaryBg,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryBg,
        title: Text(session.title),
        leading: const BackButton(),
        actions: [
          // Share / copy button
          IconButton(
            icon: const Icon(Icons.copy_rounded),
            tooltip: 'Copy settlement',
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: shareText()));
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Settlement text copied!'),
                  behavior: SnackBarBehavior.floating,
                ));
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Header ──────────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.accentWarm,
              borderRadius: BorderRadius.circular(AppTheme.cardRadius),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppTheme.primaryBg,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${session.expenses.length} expenses  •  '
                  '${session.participants.length} people',
                  style: TextStyle(
                      color: AppTheme.primaryBg.withValues(alpha: 0.65),
                      fontSize: 13),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AvatarStack(
                      names: session.participants.map((p) => p.name).toList(),
                      emojis: session.participants
                          .map((p) => p.avatarEmoji)
                          .toList(),
                      sizeVariant: AvatarSize.small,
                      maxVisible: 5,
                    ),
                    Text(
                      '₹${session.totalAmount.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: AppTheme.primaryBg,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Expenses ─────────────────────────────────────────────────────────
          Text('Expenses', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          if (session.expenses.isEmpty)
            _emptyCard(context, 'No expenses recorded.')
          else
            ...session.expenses.map((e) {
              final payer = personById(e.paidById);
              final splitNames =
                  e.splitAmongIds.map((id) => personById(id).name).join(', ');
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.receipt_outlined,
                        color: AppTheme.accentWarm, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(e.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 2),
                          Text(
                            'Paid by ${payer.name}',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: AppTheme.textSecondary),
                          ),
                          Text(
                            'Split among $splitNames',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: AppTheme.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '₹${e.amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: AppTheme.accentWarm,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            }),
          const SizedBox(height: 20),

          // ── Settlements ──────────────────────────────────────────────────────
          Text('Who Pays Whom',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          if (settlements.isEmpty)
            _emptyCard(context, 'Everyone is even ✓')
          else
            ...settlements.map((s) {
              final from = personById(s.fromPersonId);
              final to = personById(s.toPersonId);
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    AvatarBubble(
                        name: from.name,
                        avatarEmoji: from.avatarEmoji,
                        sizeVariant: AvatarSize.small),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_rounded,
                        color: AppTheme.accentWarm, size: 18),
                    const SizedBox(width: 8),
                    AvatarBubble(
                        name: to.name,
                        avatarEmoji: to.avatarEmoji,
                        sizeVariant: AvatarSize.small),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text('${from.name} pays ${to.name}',
                          style: Theme.of(context).textTheme.bodyMedium),
                    ),
                    Text(
                      '₹${s.amount.toStringAsFixed(2)}',
                      style: const TextStyle(
                          color: AppTheme.accentWarm,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            }),
          const SizedBox(height: 20),

          // ── Mark settled toggle ──────────────────────────────────────────────
          OutlinedButton.icon(
            onPressed: () => ref
                .read(historyProvider.notifier)
                .markSettled(session.id, settled: !session.isSettled),
            icon: Icon(session.isSettled
                ? Icons.undo_rounded
                : Icons.check_circle_outline),
            label: Text(session.isSettled ? 'Mark Active' : 'Mark Settled'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              foregroundColor:
                  session.isSettled ? Colors.amber : Colors.greenAccent,
              side: BorderSide(
                color: session.isSettled ? Colors.amber : Colors.greenAccent,
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _emptyCard(BuildContext context, String msg) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.greenAccent),
            const SizedBox(width: 10),
            Text(msg, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      );
}

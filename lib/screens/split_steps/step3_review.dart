import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/person.dart';
import '../../providers/active_session_provider.dart';
import '../../providers/history_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/settlement_calculator.dart';

const _personColors = [Colors.cyan, Colors.pinkAccent, Colors.deepPurpleAccent, Colors.orangeAccent, Colors.greenAccent];

/// Step 3 — Receipt summary, per-person breakdown, and settlement instructions.
class Step3Review extends ConsumerWidget {
  const Step3Review({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(activeSessionProvider);
    final participantIds = session.participants.map((p) => p.id).toList();
    final settlements = SettlementCalculator.calculate(participantIds, session.expenses);

    // Build per-person spent map
    final Map<String, double> spent = {for (final p in session.participants) p.id: 0.0};
    for (final e in session.expenses) {
      final share = e.amount / e.splitAmongIds.length;
      for (final id in e.splitAmongIds) {
        spent[id] = (spent[id] ?? 0) + share;
      }
    }

    // Net balance: positive = owed to, negative = owes
    final Map<String, double> netBalance = {for (final p in session.participants) p.id: 0.0};
    for (final e in session.expenses) {
      netBalance[e.paidById] = (netBalance[e.paidById] ?? 0) + e.amount;
      final share = e.amount / e.splitAmongIds.length;
      for (final id in e.splitAmongIds) {
        netBalance[id] = (netBalance[id] ?? 0) - share;
      }
    }

    final total = session.totalAmount;

    Person personById(String id) =>
        session.participants.firstWhere((p) => p.id == id, orElse: () => Person(name: '?'));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ── Receipt card ──────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.accentWarm,
            borderRadius: BorderRadius.circular(AppTheme.cardRadius),
          ),
          child: Column(
            children: [
              Text('Receipt', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppTheme.primaryBg.withValues(alpha: 0.6))),
              const SizedBox(height: 4),
              Text(session.title,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppTheme.primaryBg, fontWeight: FontWeight.bold)),
              const Divider(color: Colors.black26, height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${session.expenses.length} expenses', style: TextStyle(color: AppTheme.primaryBg.withValues(alpha: 0.7))),
                  Text('₹${total.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppTheme.primaryBg, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 12),
              // Stacked avatars
              SizedBox(
                height: 40,
                child: Stack(
                  children: List.generate(session.participants.length.clamp(0, 5), (i) {
                    final p = session.participants[i];
                    return Positioned(
                      left: i * 26.0,
                      child: Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: _personColors[i % _personColors.length].withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.accentWarm, width: 2),
                        ),
                        child: Center(child: Text(p.avatarEmoji ?? p.name[0].toUpperCase(), style: const TextStyle(fontSize: 14))),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // ── Per-person breakdown ──────────────────────────────────────
        Text('Breakdown', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        ...session.participants.asMap().entries.map((entry) {
          final i = entry.key;
          final p = entry.value;
          final personSpent = spent[p.id] ?? 0;
          final net = netBalance[p.id] ?? 0;
          final color = _personColors[i % _personColors.length];
          final barFraction = total > 0 ? (personSpent / total).clamp(0.0, 1.0) : 0.0;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Center(child: Text(p.avatarEmoji ?? p.name[0].toUpperCase(), style: const TextStyle(fontSize: 16))),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Text(p.name, style: Theme.of(context).textTheme.titleMedium)),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('₹${personSpent.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(color: color, fontWeight: FontWeight.bold)),
                        Text(
                          net > 0.01 ? 'gets back ₹${net.toStringAsFixed(0)}' : net < -0.01 ? 'owes ₹${(-net).toStringAsFixed(0)}' : 'settled ✓',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: net > 0.01 ? Colors.greenAccent : net < -0.01 ? Colors.redAccent : AppTheme.textSecondary,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Display-only colored bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: barFraction,
                    minHeight: 6,
                    backgroundColor: AppTheme.primaryBg,
                    valueColor: AlwaysStoppedAnimation(color),
                  ),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 8),

        // ── Settlements ───────────────────────────────────────────────
        Text('Settlement Instructions', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        if (settlements.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(16)),
            child: const Row(
              children: [
                Icon(Icons.check_circle_outline, color: Colors.greenAccent),
                SizedBox(width: 10),
                Text('Everyone is perfectly settled! 🎉'),
              ],
            ),
          )
        else
          ...settlements.map((s) {
            final from = personById(s.fromPersonId);
            final to = personById(s.toPersonId);
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(16)),
              child: Row(
                children: [
                  const Icon(Icons.arrow_forward_rounded, color: AppTheme.accentWarm, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: Theme.of(context).textTheme.bodyLarge,
                        children: [
                          TextSpan(text: from.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          const TextSpan(text: ' pays '),
                          TextSpan(text: to.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                  Text(
                    '₹${s.amount.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppTheme.accentWarm, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          }),
        const SizedBox(height: 24),

        // ── Action buttons ────────────────────────────────────────────
        FilledButton.icon(
          onPressed: () {
            ref.read(historyProvider.notifier).addSession(session);
            ref.read(activeSessionProvider.notifier).reset();
            context.go('/');
          },
          icon: const Icon(Icons.check_rounded),
          label: const Text('Confirm Split'),
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            backgroundColor: Colors.greenAccent.shade700,
            foregroundColor: Colors.white,
          ),
        ),
        const SizedBox(height: 10),
        OutlinedButton(
          onPressed: () {
            ref.read(activeSessionProvider.notifier).reset();
            context.go('/');
          },
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            side: const BorderSide(color: Colors.redAccent),
            foregroundColor: Colors.redAccent,
          ),
          child: const Text('Discard Session'),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

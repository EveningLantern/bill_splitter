import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/person.dart';
import '../models/split_session.dart';
import '../providers/history_provider.dart';
import '../theme/app_theme.dart';
import '../utils/settlement_calculator.dart';

const _personColors = [
  Colors.cyan,
  Colors.pinkAccent,
  Colors.deepPurpleAccent,
  Colors.orangeAccent,
  Colors.greenAccent,
];

// ─────────────────────────────────────────────────────────────────────────────
// HISTORY SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

enum _Filter { all, active, settled }

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  _Filter _filter = _Filter.all;

  @override
  Widget build(BuildContext context) {
    final history = ref.watch(historyProvider);

    final filtered = history.where((s) {
      if (_filter == _Filter.active) return !s.isSettled;
      if (_filter == _Filter.settled) return s.isSettled;
      return true;
    }).toList();

    // ── Stats ───────────────────────────────────────────────────────────────
    final totalAmount = history.fold(0.0, (sum, s) => sum + s.totalAmount);

    // Most frequent co-splitter across all sessions
    final nameCount = <String, int>{};
    for (final s in history) {
      for (final p in s.participants) {
        nameCount[p.name] = (nameCount[p.name] ?? 0) + 1;
      }
    }
    String? topName;
    if (nameCount.isNotEmpty) {
      topName = nameCount.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
    }

    return Scaffold(
      backgroundColor: AppTheme.primaryBg,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryBg,
        title: const Text('Split History'),
        leading: const BackButton(),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            color: AppTheme.surface,
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'clear_settled', child: Text('Delete settled')),
            ],
            onSelected: (v) async {
              if (v == 'clear_settled') {
                for (final s in history.where((s) => s.isSettled)) {
                  await ref.read(historyProvider.notifier).deleteSession(s.id);
                }
              }
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Stats row ──────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: Row(
              children: [
                _StatBubble(label: 'Sessions', value: '${history.length}'),
                const SizedBox(width: 10),
                _StatBubble(label: 'Total split', value: '₹${totalAmount.toStringAsFixed(0)}'),
                const SizedBox(width: 10),
                _StatBubble(label: 'Top buddy', value: topName ?? '–'),
              ],
            ),
          ),

          // ── Segmented filter ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: SegmentedButton<_Filter>(
              segments: const [
                ButtonSegment(value: _Filter.all, label: Text('All')),
                ButtonSegment(value: _Filter.active, label: Text('Active')),
                ButtonSegment(value: _Filter.settled, label: Text('Settled')),
              ],
              selected: {_filter},
              onSelectionChanged: (s) => setState(() => _filter = s.first),
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.resolveWith(
                  (states) => states.contains(WidgetState.selected)
                      ? AppTheme.accentButton
                      : AppTheme.surface,
                ),
              ),
            ),
          ),

          // ── List ───────────────────────────────────────────────────────────
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.history_toggle_off,
                            size: 60,
                            color: AppTheme.textSecondary.withValues(alpha: 0.4)),
                        const SizedBox(height: 12),
                        Text('No sessions here yet',
                            style: Theme.of(context).textTheme.titleMedium),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: filtered.length,
                    itemBuilder: (context, i) => _SessionCard(
                      session: filtered[i],
                      key: ValueKey(filtered[i].id),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

// ── Stat bubble ───────────────────────────────────────────────────────────────

class _StatBubble extends StatelessWidget {
  final String label;
  final String value;
  const _StatBubble({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: AppTheme.accentWarm, fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text(label,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppTheme.textSecondary),
                maxLines: 1),
          ],
        ),
      ),
    );
  }
}

// ── Session card (expandable) ─────────────────────────────────────────────────

class _SessionCard extends ConsumerStatefulWidget {
  final SplitSession session;
  const _SessionCard({required this.session, super.key});

  @override
  ConsumerState<_SessionCard> createState() => _SessionCardState();
}

class _SessionCardState extends ConsumerState<_SessionCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final s = widget.session;
    final date = '${s.createdAt.day}/${s.createdAt.month}/${s.createdAt.year}';

    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.cardRadius),
          border: Border.all(
            color: s.isSettled
                ? Colors.greenAccent.withValues(alpha: 0.4)
                : AppTheme.accentWarm.withValues(alpha: 0.25),
            width: 1.2,
          ),
        ),
        child: Column(
          children: [
            // ── Card header ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(s.title,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 2),
                            Text(date,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: AppTheme.textSecondary)),
                          ],
                        ),
                      ),
                      // Status chip
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: s.isSettled
                              ? Colors.greenAccent.withValues(alpha: 0.15)
                              : Colors.amber.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          s.isSettled ? '✓ Settled' : '⏳ Active',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: s.isSettled ? Colors.greenAccent : Colors.amber,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Stacked avatars
                      _StackedAvatars(participants: s.participants),
                      // Total
                      Text(
                        '₹${s.totalAmount.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppTheme.accentWarm,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Inline expansion: full detail ──────────────────────────────
            if (_expanded) _SessionDetail(session: s),

            // Expand chevron
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Icon(
                _expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                color: AppTheme.textSecondary,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Stacked Avatars ───────────────────────────────────────────────────────────

class _StackedAvatars extends StatelessWidget {
  final List<Person> participants;
  const _StackedAvatars({required this.participants});

  @override
  Widget build(BuildContext context) {
    const size = 30.0;
    const overlap = 10.0;
    final shown = participants.take(5).toList();
    final extra = participants.length - shown.length;

    return SizedBox(
      height: size,
      width: shown.length * (size - overlap) + overlap + (extra > 0 ? 30 : 0),
      child: Stack(
        children: [
          ...List.generate(shown.length, (i) {
            final p = shown[i];
            return Positioned(
              left: i * (size - overlap),
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: _personColors[i % _personColors.length].withValues(alpha: 0.25),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.surface, width: 1.5),
                ),
                child: Center(
                  child: Text(
                    p.avatarEmoji ?? p.name[0].toUpperCase(),
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
            );
          }),
          if (extra > 0)
            Positioned(
              left: shown.length * (size - overlap),
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: AppTheme.accentButton.withValues(alpha: 0.4),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.surface, width: 1.5),
                ),
                child: Center(
                  child: Text('+$extra',
                      style: const TextStyle(fontSize: 9, color: AppTheme.textPrimary)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SESSION DETAIL (inline expansion)
// ─────────────────────────────────────────────────────────────────────────────

class _SessionDetail extends ConsumerWidget {
  final SplitSession session;
  const _SessionDetail({required this.session});

  String _buildShareText(SplitSession s, List settlements) {
    final buf = StringBuffer();
    buf.writeln('💸 ${s.title} — Split Summary');
    buf.writeln('Total: ₹${s.totalAmount.toStringAsFixed(2)}');
    buf.writeln();
    buf.writeln('Settlements:');
    for (final st in settlements) {
      final from = s.participants.firstWhere((p) => p.id == st.fromPersonId);
      final to = s.participants.firstWhere((p) => p.id == st.toPersonId);
      buf.writeln('  ${from.name} → ${to.name}: ₹${st.amount.toStringAsFixed(2)}');
    }
    return buf.toString();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = session;
    final participantIds = s.participants.map((p) => p.id).toList();
    final settlements = SettlementCalculator.calculate(participantIds, s.expenses);
    final shareText = _buildShareText(s, settlements);

    Person personById(String id) =>
        s.participants.firstWhere((p) => p.id == id, orElse: () => Person(name: '?'));

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.primaryBg.withValues(alpha: 0.6),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(AppTheme.cardRadius),
          bottomRight: Radius.circular(AppTheme.cardRadius),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(color: Color(0x22FFFFFF)),

          // ── Expenses ────────────────────────────────────────────────────
          Text('Expenses',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(color: AppTheme.textSecondary)),
          const SizedBox(height: 8),
          ...s.expenses.map((e) {
            final payer = personById(e.paidById);
            final splitNames = e.splitAmongIds
                .map((id) => personById(id).name)
                .join(', ');
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.receipt_outlined,
                      size: 16, color: AppTheme.accentWarm),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(e.title,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppTheme.textPrimary,
                                  fontWeight: FontWeight.w600)),
                        Text('Paid by ${payer.name}  •  split among $splitNames',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: AppTheme.textSecondary)),
                      ],
                    ),
                  ),
                  Text('₹${e.amount.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.accentWarm,
                            fontWeight: FontWeight.bold)),
                ],
              ),
            );
          }),

          const Divider(color: Color(0x22FFFFFF)),

          // ── Settlements ─────────────────────────────────────────────────
          Text('Who pays whom',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(color: AppTheme.textSecondary)),
          const SizedBox(height: 8),
          if (settlements.isEmpty)
            const Text('Everyone is even ✓',
                style: TextStyle(color: Colors.greenAccent))
          else
            ...settlements.map((st) {
              final from = personById(st.fromPersonId);
              final to = personById(st.toPersonId);
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    const Icon(Icons.arrow_forward_rounded,
                        size: 14, color: AppTheme.accentWarm),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text('${from.name} pays ${to.name}',
                          style: Theme.of(context).textTheme.bodyMedium),
                    ),
                    Text('₹${st.amount.toStringAsFixed(2)}',
                        style: const TextStyle(
                            color: AppTheme.accentWarm, fontWeight: FontWeight.bold)),
                  ],
                ),
              );
            }),

          const SizedBox(height: 12),

          // ── Action row: Mark settled + Share ────────────────────────────
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => ref
                      .read(historyProvider.notifier)
                      .markSettled(s.id, settled: !s.isSettled),
                  icon: Icon(
                    s.isSettled ? Icons.undo_rounded : Icons.check_circle_outline,
                    size: 16,
                  ),
                  label: Text(s.isSettled ? 'Mark Active' : 'Mark Settled'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor:
                        s.isSettled ? Colors.amber : Colors.greenAccent,
                    side: BorderSide(
                      color: s.isSettled ? Colors.amber : Colors.greenAccent,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: shareText));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Settlement text copied!'),
                        behavior: SnackBarBehavior.floating,
                      ));
                    }
                  },
                  icon: const Icon(Icons.copy_rounded, size: 16),
                  label: const Text('Copy'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.textSecondary,
                    side: const BorderSide(color: AppTheme.textSecondary),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

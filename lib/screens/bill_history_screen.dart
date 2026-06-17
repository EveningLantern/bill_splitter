import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/bill_entry.dart';
import '../models/history_batch.dart';
import '../providers/bill_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/fade_slide.dart';

// ─────────────────────────────────────────────────────────────────────────────
// BILL HISTORY SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class BillHistoryScreen extends ConsumerWidget {
  const BillHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(billProvider);

    return Scaffold(
      backgroundColor: AppTheme.primaryBg,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryBg,
        title: const Text('Bill History'),
        leading: const BackButton(),
      ),
      body: asyncState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Unable to load history')),
        data: (state) {
          final history =
              state.history; // already sorted newest-first by provider
          if (history.isEmpty) {
            return const Center(child: Text('No history yet'));
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            itemCount: history.length,
            itemBuilder: (context, i) => FadeSlide(
              delay: Duration(milliseconds: i * 60),
              child: _BatchCard(batch: history[i]),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BATCH CARD
// ─────────────────────────────────────────────────────────────────────────────

class _BatchCard extends StatelessWidget {
  final HistoryBatch batch;

  const _BatchCard({required this.batch});

  @override
  Widget build(BuildContext context) {
    final isExpense = batch.type == BillEntryType.expense;
    final chipColor = isExpense ? Colors.redAccent : AppTheme.accentWarm;
    final chipBg = isExpense
        ? Colors.redAccent.withValues(alpha: 0.15)
        : AppTheme.accentWarm.withValues(alpha: 0.15);
    final typeLabel = isExpense ? 'Expense' : 'Income';
    final resetLocal = batch.resetAt.toLocal();
    final formattedDate = _formatDate(resetLocal);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top row: type chip + total amount ─────────────────────────────
          Row(
            children: [
              // Type chip
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: chipBg,
                  borderRadius: BorderRadius.circular(AppTheme.chipRadius),
                ),
                child: Text(
                  typeLabel,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: chipColor,
                  ),
                ),
              ),
              const Spacer(),
              // Total
              Text(
                '₹${batch.totalAmount.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: chipColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // ── Reset date ────────────────────────────────────────────────────
          Row(
            children: [
              const Icon(
                Icons.access_time_rounded,
                size: 14,
                color: AppTheme.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                formattedDate,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // ── Entry count ───────────────────────────────────────────────────
          Text(
            '${batch.entryCount} ${batch.entryCount == 1 ? 'entry' : 'entries'}',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DATE FORMATTING  (dd MMM yyyy, HH:mm)  — no intl dependency
// ─────────────────────────────────────────────────────────────────────────────

const _monthNames = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

String _formatDate(DateTime dt) {
  final day = dt.day.toString().padLeft(2, '0');
  final month = _monthNames[dt.month - 1];
  final year = dt.year;
  final hour = dt.hour.toString().padLeft(2, '0');
  final minute = dt.minute.toString().padLeft(2, '0');
  return '$day $month $year, $hour:$minute';
}

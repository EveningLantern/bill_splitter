import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/bill_entry.dart';
import '../providers/bill_provider.dart';
import '../theme/app_theme.dart';
import 'entry_form_sheet.dart';
import 'fade_slide.dart';
import 'summary_card.dart';

// ─────────────────────────────────────────────────────────────────────────────
// BillTrackerSection — root ConsumerWidget for the Bill tab
// ─────────────────────────────────────────────────────────────────────────────

/// Root widget rendered under the "Bill" tab in HomeScreen.
/// Watches [billProvider] and delegates to [_BillContent] on data,
/// or shows a loading/error state.
/// Requirements: 2.1–2.9, 5.1–5.7, 6.1–6.7, 7.7, 10.1, 10.3, 10.4, 10.6, 10.7
class BillTrackerSection extends ConsumerWidget {
  const BillTrackerSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(billProvider);

    return asyncState.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => _ErrorPlaceholder(message: err.toString()),
      data: (state) => _BillContent(state: state),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _BillContent — the full data-state layout
// ─────────────────────────────────────────────────────────────────────────────

class _BillContent extends ConsumerWidget {
  final BillState state;

  const _BillContent({required this.state});

  void _handleError(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Show error snackbar if errorMessage is set
    if (state.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          _handleError(context, state.errorMessage!);
        }
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Summary cards row ─────────────────────────────────────────────
        Row(
          children: [
            Expanded(
              child: SummaryCard(
                label: 'Total Expenses',
                amount: state.totalExpense,
                accentColor: Colors.redAccent,
                icon: Icons.arrow_downward_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SummaryCard(
                label: 'Total Income',
                amount: state.totalIncome,
                accentColor: AppTheme.accentWarm,
                icon: Icons.arrow_upward_rounded,
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // ── Expenses section ──────────────────────────────────────────────
        _SectionHeader(
          title: 'Expenses',
          onAdd: () => EntryFormSheet.show(context, EntryFormMode.expense),
          onReset: state.expenses.isNotEmpty
              ? () => _confirmReset(
                  context: context,
                  ref: ref,
                  type: BillEntryType.expense,
                )
              : null,
        ),
        const SizedBox(height: 8),
        state.expenses.isEmpty
            ? const _EmptyPlaceholder(text: 'No expenses yet')
            : _EntryList(entries: state.expenses, type: BillEntryType.expense),

        const SizedBox(height: 20),

        // ── Income section ────────────────────────────────────────────────
        _SectionHeader(
          title: 'Income',
          onAdd: () => EntryFormSheet.show(context, EntryFormMode.income),
          onReset: state.incomes.isNotEmpty
              ? () => _confirmReset(
                  context: context,
                  ref: ref,
                  type: BillEntryType.income,
                )
              : null,
        ),
        const SizedBox(height: 8),
        state.incomes.isEmpty
            ? const _EmptyPlaceholder(text: 'No income yet')
            : _EntryList(entries: state.incomes, type: BillEntryType.income),

        const SizedBox(height: 20),

        // ── History button ────────────────────────────────────────────────
        _HistoryButton(),

        const SizedBox(height: 8),
      ],
    );
  }

  /// Shows a confirmation dialog before resetting a category.
  /// On confirm, calls the appropriate notifier method and shows a SnackBar on error.
  Future<void> _confirmReset({
    required BuildContext context,
    required WidgetRef ref,
    required BillEntryType type,
  }) async {
    final isExpense = type == BillEntryType.expense;
    final label = isExpense ? 'expenses' : 'income';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: Text('Reset ${isExpense ? 'Expenses' : 'Income'}'),
        content: Text(
          'All $label entries will be moved to history. This cannot be undone.',
          style: Theme.of(ctx).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!context.mounted) return;

    try {
      if (isExpense) {
        await ref.read(billProvider.notifier).resetExpenses();
      } else {
        await ref.read(billProvider.notifier).resetIncomes();
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to reset $label. Please try again.')),
        );
      }
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _SectionHeader — title + Add button + Reset button
// ─────────────────────────────────────────────────────────────────────────────

/// Renders a row with the section [title], an always-enabled Add icon button,
/// and a "Reset" text button that is disabled (null onPressed) when [onReset] is null.
class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onAdd;

  /// Null when the entry list is empty — disables the Reset button.
  final VoidCallback? onReset;

  const _SectionHeader({
    required this.title,
    required this.onAdd,
    this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleMedium),
        ),
        // Add icon button — always enabled
        IconButton(
          onPressed: onAdd,
          icon: const Icon(Icons.add_rounded),
          color: AppTheme.accentWarm,
          tooltip: 'Add ${title.toLowerCase()}',
          constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
          padding: EdgeInsets.zero,
        ),
        // Reset text button — disabled when onReset is null
        TextButton(
          onPressed: onReset,
          style: TextButton.styleFrom(
            foregroundColor: onReset != null
                ? AppTheme.textSecondary
                : AppTheme.textSecondary.withValues(alpha: 0.35),
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
          child: const Text('Reset'),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _EntryList — Column of FadeSlide-wrapped _EntryTile items
// ─────────────────────────────────────────────────────────────────────────────

/// Renders a [Column] of [_EntryTile] widgets, each wrapped in [FadeSlide]
/// for staggered entrance animation.
/// Does NOT use a ListView so it can be embedded in the parent scroll view.
class _EntryList extends StatelessWidget {
  final List<BillEntry> entries;
  final BillEntryType type;

  const _EntryList({required this.entries, required this.type});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(entries.length, (i) {
        return FadeSlide(
          delay: Duration(milliseconds: i * 50),
          child: _EntryTile(entry: entries[i]),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _EntryTile — a single expense or income row
// ─────────────────────────────────────────────────────────────────────────────

/// Displays a single [BillEntry] with:
/// - Leading icon (red downward for expense, accentWarm upward for income)
/// - Entry name
/// - ₹X.XX amount
/// - Formatted date-time (e.g. "15 Jun 2025  •  14:30")
class _EntryTile extends StatelessWidget {
  final BillEntry entry;

  const _EntryTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    final isExpense = entry.type == BillEntryType.expense;
    final accentColor = isExpense ? Colors.redAccent : AppTheme.accentWarm;
    final icon = isExpense
        ? Icons.arrow_downward_rounded
        : Icons.arrow_upward_rounded;

    final dt = entry.dateTime;
    final monthNames = [
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
    final day = dt.day.toString().padLeft(2, '0');
    final month = monthNames[dt.month - 1];
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    final formattedDate = '$day $month ${dt.year}  •  $hour:$minute';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
      ),
      child: Row(
        children: [
          // ── Leading icon ──────────────────────────────────────────────
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: accentColor, size: 18),
          ),
          const SizedBox(width: 12),

          // ── Name + date ───────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.name,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  formattedDate,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // ── Amount ────────────────────────────────────────────────────
          Text(
            '₹${entry.amount.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: accentColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _EmptyPlaceholder — shown when a list is empty
// ─────────────────────────────────────────────────────────────────────────────

/// Simple centered text rendered in place of an empty entry list.
class _EmptyPlaceholder extends StatelessWidget {
  final String text;

  const _EmptyPlaceholder({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppTheme.textSecondary.withValues(alpha: 0.6),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _HistoryButton — navigates to /bill-history
// ─────────────────────────────────────────────────────────────────────────────

/// Full-width outlined button that pushes the `/bill-history` route.
class _HistoryButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => context.push('/bill-history'),
      icon: const Icon(Icons.history_rounded, size: 18),
      label: const Text('View Bill History'),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppTheme.textSecondary,
        side: const BorderSide(color: AppTheme.textSecondary),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ErrorPlaceholder — shown when the provider emits an error state
// ─────────────────────────────────────────────────────────────────────────────

class _ErrorPlaceholder extends StatelessWidget {
  final String message;

  const _ErrorPlaceholder({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 40,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 12),
            Text(
              'Unable to load bill data',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

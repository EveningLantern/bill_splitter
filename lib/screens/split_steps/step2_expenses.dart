import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/active_session_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/add_expense_sheet.dart';

/// Step 2 — Add & manage expenses.
class Step2Expenses extends ConsumerWidget {
  const Step2Expenses({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(activeSessionProvider);
    final total = session.totalAmount;

    return Stack(
      children: [
        Column(
          children: [
            // Running total banner
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(AppTheme.cardRadius),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Running Total', style: Theme.of(context).textTheme.titleMedium),
                  Text(
                    '₹${total.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppTheme.accentWarm,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),

            // Expense list
            Expanded(
              child: session.expenses.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.receipt_long_outlined,
                              size: 56, color: AppTheme.textSecondary.withValues(alpha: 0.5)),
                          const SizedBox(height: 12),
                          Text('No expenses yet', style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 4),
                          Text('Tap + to add one', style: Theme.of(context).textTheme.bodyMedium),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                      itemCount: session.expenses.length,
                      itemBuilder: (context, i) {
                        final expense = session.expenses[i];
                        final paidBy = session.participants
                            .firstWhere((p) => p.id == expense.paidById, orElse: () => session.participants.first);
                        return Dismissible(
                          key: Key(expense.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: Colors.redAccent.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                            ),
                            child: const Icon(Icons.delete_outline, color: Colors.white),
                          ),
                          onDismissed: (_) =>
                              ref.read(activeSessionProvider.notifier).removeExpense(expense.id),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTheme.surface,
                              borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: AppTheme.accentButton.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.receipt_outlined, color: AppTheme.accentWarm),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(expense.title, style: Theme.of(context).textTheme.titleMedium),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Paid by ${paidBy.name}  •  split among ${expense.splitAmongIds.length}',
                                        style: Theme.of(context).textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '₹${expense.amount.toStringAsFixed(2)}',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        color: AppTheme.accentWarm,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),

        // FAB
        Positioned(
          bottom: 0,
          right: 0,
          left: 0,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: FilledButton.icon(
              onPressed: session.participants.isEmpty
                  ? null
                  : () => showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: AppTheme.surface,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                        ),
                        builder: (_) => AddExpenseSheet(participants: session.participants),
                      ),
              icon: const Icon(Icons.add),
              label: const Text('Add Expense'),
            ),
          ),
        ),
      ],
    );
  }
}

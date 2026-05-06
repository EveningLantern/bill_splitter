import '../models/expense.dart';
import '../models/settlement.dart';

/// Computes the minimal set of debt-settlement transactions for a group of
/// expenses using the Greedy Debt-Simplification algorithm.
///
/// ### How it works
/// 1. **Balance map** — For every expense:
///    - Add the full [Expense.amount] to the payer's balance (they are owed).
///    - Subtract each participant's equal share from their balance (they owe).
///    Net result: positive balance = person is owed money, negative = owes money.
///
/// 2. **Greedy matching** — Repeatedly:
///    - Pick the maximum creditor (highest positive balance).
///    - Pick the maximum debtor (most negative balance, stored as positive).
///    - The transaction amount = min(creditor balance, debtor balance).
///    - Record Settlement(fromPersonId: debtor, toPersonId: creditor, amount).
///    - Reduce both balances by [amount].
///    - Remove either/both if their balance reaches zero.
///    Continue until no non-zero balances remain.
///
/// This guarantees the minimum number of transactions needed to settle the
/// group — at most N-1 for N people.
class SettlementCalculator {
  /// Returns the minimal list of [Settlement] transactions.
  ///
  /// [personIds]  — the full set of participant IDs in the session.
  /// [expenses]   — all expenses to settle.
  ///
  /// Participants not involved in any expense remain at zero and are ignored.
  static List<Settlement> calculate(
    List<String> personIds,
    List<Expense> expenses,
  ) {
    if (personIds.isEmpty || expenses.isEmpty) return [];

    // ── Step 1: Build net balance map ──────────────────────────────────────
    final Map<String, double> balances = {
      for (final id in personIds) id: 0.0,
    };

    for (final expense in expenses) {
      // Payer is credited the full amount they fronted.
      balances[expense.paidById] =
          (balances[expense.paidById] ?? 0.0) + expense.amount;

      // Each participant (including payer) is debited their equal share.
      final int splitCount = expense.splitAmongIds.length;
      if (splitCount == 0) continue;
      final double share = expense.amount / splitCount;
      for (final id in expense.splitAmongIds) {
        balances[id] = (balances[id] ?? 0.0) - share;
      }
    }

    // ── Step 2: Separate into creditors / debtors ──────────────────────────
    // Use mutable lists; we sort and pop from the front each iteration.
    const double epsilon = 0.005; // ignore sub-half-paisa rounding dust

    // creditors: (id, +amount they are owed)
    final List<_Balance> creditors = [];
    // debtors:   (id, +amount they owe, stored as positive)
    final List<_Balance> debtors = [];

    balances.forEach((id, balance) {
      if (balance > epsilon) {
        creditors.add(_Balance(id, balance));
      } else if (balance < -epsilon) {
        debtors.add(_Balance(id, -balance)); // store as positive
      }
    });

    // ── Step 3: Greedy matching ────────────────────────────────────────────
    final List<Settlement> settlements = [];

    while (creditors.isNotEmpty && debtors.isNotEmpty) {
      // Always match the largest creditor with the largest debtor.
      creditors.sort((a, b) => b.amount.compareTo(a.amount));
      debtors.sort((a, b) => b.amount.compareTo(a.amount));

      final _Balance creditor = creditors.first;
      final _Balance debtor = debtors.first;

      final double amount =
          creditor.amount < debtor.amount ? creditor.amount : debtor.amount;

      // Round to 2 decimal places to avoid floating-point display noise.
      final double roundedAmount =
          (amount * 100).round() / 100;

      settlements.add(Settlement(
        fromPersonId: debtor.id,
        toPersonId: creditor.id,
        amount: roundedAmount,
      ));

      creditor.amount -= amount;
      debtor.amount -= amount;

      if (creditor.amount < epsilon) creditors.removeAt(0);
      if (debtor.amount < epsilon) debtors.removeAt(0);
    }

    return settlements;
  }
}

/// Internal mutable balance holder used during the greedy matching pass.
class _Balance {
  final String id;
  double amount;
  _Balance(this.id, this.amount);
}

import '../models/split_session.dart';
import '../models/person.dart';
import '../models/expense.dart';
import '../providers/settlement_provider.dart';

/// Utility class for computing optimal settlements for a split session
class SettlementCalculator {
  /// Legacy method for backward compatibility with tests
  /// Takes separate lists of participants and expenses
  static List<Settlement> calculate(
    List<String> participantIds,
    List<Expense> expenses,
  ) {
    // Convert to SplitSession format
    final participants = participantIds
        .map((id) => Person(id: id, name: id, avatarEmoji: null))
        .toList();

    final session = SplitSession(
      title: 'Test Session',
      participants: participants,
      expenses: expenses,
    );

    return compute(session);
  }

  /// Computes the minimal set of settlements needed to settle all debts
  /// Uses a greedy algorithm to minimize the number of transactions
  static List<Settlement> compute(SplitSession session) {
    if (session.expenses.isEmpty || session.participants.isEmpty) {
      return [];
    }

    // Calculate net balance for each participant
    final balances = <String, double>{};
    final participantNames = <String, String>{};

    // Initialize balances and name mapping
    for (final participant in session.participants) {
      balances[participant.id] = 0.0;
      participantNames[participant.id] = participant.name;
    }

    // Process each expense
    for (final expense in session.expenses) {
      final splitAmount = _roundToTwoDecimals(
        expense.amount / expense.splitAmongIds.length,
      );

      // The payer gets credited with the full amount
      balances[expense.paidById] = _roundToTwoDecimals(
        (balances[expense.paidById] ?? 0) + expense.amount,
      );

      // Each person in the split gets debited their share
      for (final participantId in expense.splitAmongIds) {
        balances[participantId] = _roundToTwoDecimals(
          (balances[participantId] ?? 0) - splitAmount,
        );
      }
    }

    // Separate debtors and creditors
    final debtors = <MapEntry<String, double>>[];
    final creditors = <MapEntry<String, double>>[];

    for (final entry in balances.entries) {
      if (entry.value < -0.01) {
        // Owes money (with small tolerance for floating point)
        debtors.add(MapEntry(entry.key, -entry.value)); // Make positive
      } else if (entry.value > 0.01) {
        // Is owed money
        creditors.add(MapEntry(entry.key, entry.value));
      }
    }

    // Sort by amount (largest first) for better optimization
    debtors.sort((a, b) => b.value.compareTo(a.value));
    creditors.sort((a, b) => b.value.compareTo(a.value));

    // Generate settlements using greedy algorithm
    final settlements = <Settlement>[];
    final debtorBalances = Map<String, double>.fromEntries(debtors);
    final creditorBalances = Map<String, double>.fromEntries(creditors);

    while (debtorBalances.isNotEmpty && creditorBalances.isNotEmpty) {
      // Get the largest debtor and creditor
      final debtorEntry = debtorBalances.entries.first;
      final creditorEntry = creditorBalances.entries.first;

      final debtorId = debtorEntry.key;
      final creditorId = creditorEntry.key;
      final debtAmount = debtorEntry.value;
      final creditAmount = creditorEntry.value;

      // Calculate settlement amount (minimum of debt and credit)
      final settlementAmount = debtAmount < creditAmount
          ? debtAmount
          : creditAmount;

      // Create settlement
      settlements.add(
        Settlement(
          fromPersonId: debtorId,
          toPersonId: creditorId,
          fromPersonName: participantNames[debtorId]!,
          toPersonName: participantNames[creditorId]!,
          amount: _roundToTwoDecimals(settlementAmount),
        ),
      );

      // Update balances
      final newDebtAmount = debtAmount - settlementAmount;
      final newCreditAmount = creditAmount - settlementAmount;

      // Remove or update debtor
      if (newDebtAmount <= 0.01) {
        debtorBalances.remove(debtorId);
      } else {
        debtorBalances[debtorId] = newDebtAmount;
      }

      // Remove or update creditor
      if (newCreditAmount <= 0.01) {
        creditorBalances.remove(creditorId);
      } else {
        creditorBalances[creditorId] = newCreditAmount;
      }
    }

    return settlements;
  }

  /// Validates that the settlements balance out correctly
  static bool validateSettlements(
    SplitSession session,
    List<Settlement> settlements,
  ) {
    final netAmounts = <String, double>{};

    // Initialize with original balances
    for (final participant in session.participants) {
      netAmounts[participant.id] = 0.0;
    }

    // Calculate original balances from expenses
    for (final expense in session.expenses) {
      final splitAmount = expense.amount / expense.splitAmongIds.length;
      netAmounts[expense.paidById] =
          (netAmounts[expense.paidById] ?? 0) + expense.amount;

      for (final participantId in expense.splitAmongIds) {
        netAmounts[participantId] =
            (netAmounts[participantId] ?? 0) - splitAmount;
      }
    }

    // Apply settlements
    for (final settlement in settlements) {
      netAmounts[settlement.fromPersonId] =
          (netAmounts[settlement.fromPersonId] ?? 0) + settlement.amount;
      netAmounts[settlement.toPersonId] =
          (netAmounts[settlement.toPersonId] ?? 0) - settlement.amount;
    }

    // Check if all balances are close to zero
    return netAmounts.values.every((balance) => balance.abs() < 0.01);
  }

  /// Calculates the total amount that needs to be settled
  static double getTotalSettlementAmount(List<Settlement> settlements) {
    return settlements.fold(0.0, (sum, settlement) => sum + settlement.amount);
  }

  /// Groups settlements by person (who owes what)
  static Map<String, List<Settlement>> groupSettlementsByDebtor(
    List<Settlement> settlements,
  ) {
    final grouped = <String, List<Settlement>>{};

    for (final settlement in settlements) {
      grouped.putIfAbsent(settlement.fromPersonName, () => []).add(settlement);
    }

    return grouped;
  }

  /// Groups settlements by person (who receives what)
  static Map<String, List<Settlement>> groupSettlementsByCreditor(
    List<Settlement> settlements,
  ) {
    final grouped = <String, List<Settlement>>{};

    for (final settlement in settlements) {
      grouped.putIfAbsent(settlement.toPersonName, () => []).add(settlement);
    }

    return grouped;
  }

  /// Helper method to round amounts to 2 decimal places to avoid floating point precision issues
  static double _roundToTwoDecimals(double value) {
    return (value * 100).round() / 100;
  }
}

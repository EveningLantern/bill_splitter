import 'package:flutter_test/flutter_test.dart';
import 'package:bill_splitter/models/expense.dart';
import 'package:bill_splitter/models/settlement.dart';
import 'package:bill_splitter/utils/settlement_calculator.dart';

// ── Helpers ──────────────────────────────────────────────────────────────────

/// Fake expense factory — ids are simple strings for readability.
Expense expense(
  String title,
  double amount,
  String paidById,
  List<String> splitAmongIds,
) =>
    Expense(
      title: title,
      amount: amount,
      paidById: paidById,
      splitAmongIds: splitAmongIds,
    );

/// Verifies that applying the settlement transactions zeroes every participant's
/// net balance (i.e., the settlements fully resolve all debts).
void expectBalanced(
  List<String> personIds,
  List<Expense> expenses,
  List<Settlement> settlements,
) {
  // Build the expected net-balance map from expenses.
  final Map<String, double> balances = {for (final id in personIds) id: 0.0};
  for (final e in expenses) {
    balances[e.paidById] = (balances[e.paidById] ?? 0) + e.amount;
    final share = e.amount / e.splitAmongIds.length;
    for (final id in e.splitAmongIds) {
      balances[id] = (balances[id] ?? 0) - share;
    }
  }

  // Apply settlements on top of the balance map.
  // A settlement (from → to, amount) means:
  //   "from" pays out → their balance increases (less in the red / more settled)
  //   "to" receives   → their balance decreases (less in the green / received)
  for (final s in settlements) {
    balances[s.fromPersonId] = (balances[s.fromPersonId] ?? 0) + s.amount;
    balances[s.toPersonId]   = (balances[s.toPersonId]   ?? 0) - s.amount;
  }

  // After settlements every balance should be ~zero.
  for (final id in personIds) {
    final residual = balances[id] ?? 0;
    expect(
      residual.abs(),
      lessThan(0.02),
      reason: 'Person $id still has unresolved balance: $residual',
    );
  }
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  // Person IDs used across tests.
  const alice = 'alice';
  const bob = 'bob';
  const charlie = 'charlie';
  const diana = 'diana';
  const eve = 'eve';

  group('SettlementCalculator — edge cases', () {
    test('empty expenses → no settlements', () {
      final result = SettlementCalculator.calculate([alice, bob], []);
      expect(result, isEmpty);
    });

    test('empty participants → no settlements', () {
      final result = SettlementCalculator.calculate(
        [],
        [expense('Lunch', 300, alice, [alice, bob])],
      );
      expect(result, isEmpty);
    });

    test('single person pays for themselves → no settlements', () {
      final result = SettlementCalculator.calculate(
        [alice],
        [expense('Coffee', 100, alice, [alice])],
      );
      expect(result, isEmpty);
    });

    test('two people — one pays for both → single settlement', () {
      // Alice pays ₹200 split equally → Bob owes Alice ₹100.
      final expenses = [expense('Dinner', 200, alice, [alice, bob])];
      final result =
          SettlementCalculator.calculate([alice, bob], expenses);

      expect(result, hasLength(1));
      expect(result.first.fromPersonId, bob);
      expect(result.first.toPersonId, alice);
      expect(result.first.amount, closeTo(100.0, 0.01));

      expectBalanced([alice, bob], expenses, result);
    });

    test('perfectly balanced — everyone pays equal share → no settlements', () {
      // Alice pays ₹100, Bob pays ₹100, each split among both.
      final expenses = [
        expense('Drink A', 100, alice, [alice, bob]),
        expense('Drink B', 100, bob, [alice, bob]),
      ];
      final result =
          SettlementCalculator.calculate([alice, bob], expenses);
      expect(result, isEmpty);
      expectBalanced([alice, bob], expenses, result);
    });
  });

  group('SettlementCalculator — example scenario (5 friends, day out)', () {
    // Alice paid ₹1200 for drinks (split among all 5)        → share = 240 each
    // Bob paid ₹2500 for movie tickets (split among all 5)   → share = 500 each
    // Charlie paid ₹800 for Uber ride (split among 3 people) → share = 266.67 each
    //
    // Net balances (pay - owe):
    //   Alice:   +1200 − 240 − 500 − 0      = +460   (shared in Uber? no — 3 people)
    //   Bob:     +2500 − 240 − 500 − 0      = +1760   (not in Uber)
    //   Charlie: +800  − 240 − 500 − 266.67 = −206.67
    //   Diana:   0     − 240 − 500 − 266.67 = −1006.67
    //   Eve:     0     − 240 − 500 − 0      = −740
    //
    // Assumption: Uber split among Alice, Charlie, Diana.

    final people = [alice, bob, charlie, diana, eve];
    final expenses = [
      expense('Drinks', 1200, alice, [alice, bob, charlie, diana, eve]),
      expense('Movie Tickets', 2500, bob, [alice, bob, charlie, diana, eve]),
      expense('Uber Ride', 800, charlie, [alice, charlie, diana]),
    ];

    late List<Settlement> settlements;

    setUp(() {
      settlements = SettlementCalculator.calculate(people, expenses);
    });

    test('books balance to zero for every participant', () {
      expectBalanced(people, expenses, settlements);
    });

    test('number of transactions ≤ N-1 (greedy minimisation)', () {
      // For 5 people, max transactions needed is 4.
      expect(settlements.length, lessThanOrEqualTo(people.length - 1));
    });

    test('all settlement amounts are positive', () {
      for (final s in settlements) {
        expect(s.amount, greaterThan(0));
      }
    });

    test('no self-payments (from ≠ to)', () {
      for (final s in settlements) {
        expect(s.fromPersonId, isNot(equals(s.toPersonId)));
      }
    });

    test('creditors are not paying anyone', () {
      // Net creditors (positive balance) should only appear as toPersonId.
      final creditorIds = {alice, bob}; // Computed manually above.
      for (final s in settlements) {
        expect(creditorIds, isNot(contains(s.fromPersonId)));
      }
    });

    test('debtors are not receiving from anyone', () {
      // Net debtors should only appear as fromPersonId.
      final debtorIds = {charlie, diana, eve};
      for (final s in settlements) {
        expect(debtorIds, isNot(contains(s.toPersonId)));
      }
    });
  });

  group('SettlementCalculator — three people, asymmetric split', () {
    // Alice pays ₹600 split between Alice & Bob (Charlie excluded).
    // Charlie pays ₹900 split among all three.
    //
    // Balances:
    //   Alice:   +600 − 300 − 300 = 0
    //   Bob:     0   − 300 − 300  = −600
    //   Charlie: +900 − 0   − 300 = +600
    // → Bob pays Charlie ₹600.

    final people = [alice, bob, charlie];
    final expenses = [
      expense('Pizza', 600, alice, [alice, bob]),
      expense('Hotel', 900, charlie, [alice, bob, charlie]),
    ];

    test('single settlement: Bob → Charlie ₹600', () {
      final result =
          SettlementCalculator.calculate(people, expenses);

      expect(result, hasLength(1));
      expect(result.first.fromPersonId, bob);
      expect(result.first.toPersonId, charlie);
      expect(result.first.amount, closeTo(600.0, 0.01));

      expectBalanced(people, expenses, result);
    });
  });

  group('SettlementCalculator — four people, multiple creditors & debtors', () {
    // Alice   pays ₹1000 split among all 4  → share 250
    // Bob     pays ₹0                       → owes 250
    // Charlie pays ₹600 split among all 4   → share 150
    // Diana   pays ₹0                       → owes 400
    //
    // Balances:
    //   Alice:   +1000 − 250 − 150 = +600
    //   Bob:     0     − 250 − 150 = −400
    //   Charlie: +600  − 250 − 150 = +200
    //   Diana:   0     − 250 − 150 = −400

    final people = [alice, bob, charlie, diana];
    final expenses = [
      expense('Dinner', 1000, alice, [alice, bob, charlie, diana]),
      expense('Dessert', 600, charlie, [alice, bob, charlie, diana]),
    ];

    test('books balance to zero', () {
      final result = SettlementCalculator.calculate(people, expenses);
      expectBalanced(people, expenses, result);
    });

    test('transactions ≤ 3 (N-1 for 4 people)', () {
      final result = SettlementCalculator.calculate(people, expenses);
      expect(result.length, lessThanOrEqualTo(3));
    });

    test('total money transferred equals total debt', () {
      final result = SettlementCalculator.calculate(people, expenses);
      final totalTransferred =
          result.fold<double>(0.0, (sum, s) => sum + s.amount);
      // Total debt = 400 + 400 = 800
      expect(totalTransferred, closeTo(800.0, 0.05));
    });
  });

  group('SettlementCalculator — floating point robustness', () {
    test('₹10 split 3 ways does not leave ghost balance', () {
      // ₹10 / 3 = 3.333… — classic source of fp drift.
      final people = [alice, bob, charlie];
      final expenses = [
        expense('Coffee', 10, alice, [alice, bob, charlie]),
      ];
      final result = SettlementCalculator.calculate(people, expenses);
      expectBalanced(people, expenses, result);
    });

    test('large amounts with many participants', () {
      final ids = List.generate(10, (i) => 'p$i');
      final expenses = [
        expense('Party', 9999, ids[0], ids),
        expense('Transport', 4321, ids[1], ids.sublist(0, 5)),
        expense('Food', 2718, ids[2], ids.sublist(3)),
      ];
      final result = SettlementCalculator.calculate(ids, expenses);
      expectBalanced(ids, expenses, result);
      expect(result.length, lessThanOrEqualTo(ids.length - 1));
    });
  });
}

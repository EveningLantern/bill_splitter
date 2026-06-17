import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/bill_entry.dart';
import '../models/history_batch.dart';

part 'bill_provider.g.dart';

/// Immutable snapshot of all Bill Tracker state.
/// Exposed to the UI via ref.watch(billProvider).
@immutable
class BillState {
  final List<BillEntry> expenses; // active expense entries, newest-first
  final List<BillEntry> incomes; // active income entries, newest-first
  final List<HistoryBatch> history; // all history batches, newest-first
  final double totalExpense; // sum of expenses[*].amount
  final double totalIncome; // sum of incomes[*].amount
  final String? errorMessage; // non-null when a Hive operation failed

  const BillState({
    this.expenses = const [],
    this.incomes = const [],
    this.history = const [],
    this.totalExpense = 0.0,
    this.totalIncome = 0.0,
    this.errorMessage,
  });

  BillState copyWith({
    List<BillEntry>? expenses,
    List<BillEntry>? incomes,
    List<HistoryBatch>? history,
    double? totalExpense,
    double? totalIncome,
    String? errorMessage,
  }) => BillState(
    expenses: expenses ?? this.expenses,
    incomes: incomes ?? this.incomes,
    history: history ?? this.history,
    totalExpense: totalExpense ?? this.totalExpense,
    totalIncome: totalIncome ?? this.totalIncome,
    errorMessage: errorMessage, // null clears the error
  );
}

@riverpod
class Bill extends _$Bill {
  late Box<BillEntry> _entriesBox;
  late Box<HistoryBatch> _historyBox;

  /// Opens Hive boxes, runs auto-purge, loads initial state.
  /// Subscribes to box watch events for reactive updates.
  @override
  Future<BillState> build() async {
    _entriesBox = Hive.box<BillEntry>('bill_entries');
    _historyBox = Hive.box<HistoryBatch>('bill_history');

    await _purgeOldBatches();

    // Subscribe to external changes (e.g. from other isolates, though unlikely).
    final sub = _entriesBox.watch().listen((_) => _refresh());
    ref.onDispose(sub.cancel);

    return _buildState();
  }

  /// Add an expense or income entry.
  /// On success: emits new BillState with updated list + recalculated total.
  /// On failure: state unchanged; errorMessage set; throws so caller can show snackbar.
  Future<void> addEntry(BillEntry entry) async {
    try {
      await _entriesBox.put(entry.id, entry);
      _refresh();
    } catch (e) {
      _setError('Failed to save entry: $e');
      rethrow;
    }
  }

  /// Move all active expense entries to a HistoryBatch, then clear them.
  /// No-op if expense list is empty.
  /// Atomic: if either Hive write fails, state is left unchanged.
  Future<void> resetExpenses() async {
    final current = state.valueOrNull;
    if (current == null || current.expenses.isEmpty) return;

    final batch = HistoryBatch(
      type: BillEntryType.expense,
      entries: List.unmodifiable(current.expenses),
      resetAt: DateTime.now().toUtc(),
    );

    try {
      await _historyBox.put(batch.id, batch);
      try {
        for (final e in current.expenses) {
          await _entriesBox.delete(e.id);
        }
      } catch (e) {
        // Rollback history write if entry deletes fail.
        await _historyBox.delete(batch.id);
        rethrow;
      }
      _refresh();
    } catch (e) {
      _setError('Failed to reset expenses: $e');
      rethrow;
    }
  }

  /// Move all active income entries to a HistoryBatch, then clear them.
  /// No-op if income list is empty.
  /// Atomic: if either Hive write fails, state is left unchanged.
  Future<void> resetIncomes() async {
    final current = state.valueOrNull;
    if (current == null || current.incomes.isEmpty) return;

    final batch = HistoryBatch(
      type: BillEntryType.income,
      entries: List.unmodifiable(current.incomes),
      resetAt: DateTime.now().toUtc(),
    );

    try {
      await _historyBox.put(batch.id, batch);
      try {
        for (final e in current.incomes) {
          await _entriesBox.delete(e.id);
        }
      } catch (e) {
        await _historyBox.delete(batch.id);
        rethrow;
      }
      _refresh();
    } catch (e) {
      _setError('Failed to reset income: $e');
      rethrow;
    }
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  /// Delete history batches whose resetAt (date-only) is >20 calendar days ago.
  /// Errors per-batch are logged and skipped; other batches continue to be evaluated.
  Future<void> _purgeOldBatches() async {
    final today = _dateOnly(DateTime.now());
    for (final batch in List.of(_historyBox.values)) {
      final resetDay = _dateOnly(batch.resetAt.toLocal());
      final diff = today.difference(resetDay).inDays;
      if (diff > 20) {
        try {
          await _historyBox.delete(batch.id);
        } catch (e) {
          // Log and continue — do not abort remaining purge or block startup.
          debugPrint('BillProvider: purge failed for batch ${batch.id}: $e');
        }
      }
    }
  }

  /// Reconstruct BillState from current box contents.
  BillState _buildState() {
    final allEntries = _entriesBox.values.toList()
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));

    final expenses = allEntries
        .where((e) => e.type == BillEntryType.expense)
        .toList();
    final incomes = allEntries
        .where((e) => e.type == BillEntryType.income)
        .toList();

    final history = _historyBox.values.toList()
      ..sort((a, b) => b.resetAt.compareTo(a.resetAt));

    return BillState(
      expenses: expenses,
      incomes: incomes,
      history: history,
      totalExpense: _total(expenses),
      totalIncome: _total(incomes),
    );
  }

  void _refresh() => state = AsyncData(_buildState());

  void _setError(String msg) {
    final current = state.valueOrNull ?? const BillState();
    state = AsyncData(current.copyWith(errorMessage: msg));
  }

  double _total(List<BillEntry> entries) =>
      entries.fold(0.0, (sum, e) => sum + e.amount);

  /// Returns a DateTime with only year/month/day (no time component).
  DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);
}

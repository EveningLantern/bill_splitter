import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/expense.dart';
import '../models/person.dart';
import '../models/split_session.dart';
import 'history_provider.dart';

part 'session_provider.g.dart';

/// Holds the in-progress [SplitSession] being built across the 3-step wizard.
/// On [confirmSession] the session is persisted via [HistoryNotifier] and
/// the local state is reset.
@riverpod
class SplitSessionNotifier extends _$SplitSessionNotifier {
  @override
  SplitSession build() => SplitSession(
        title: '',
        participants: [],
        expenses: [],
      );

  // ── Title ─────────────────────────────────────────────────────────────────

  void setTitle(String title) => state = _copy(title: title);

  // ── Participants ──────────────────────────────────────────────────────────

  /// Add a participant by name, with an optional emoji avatar.
  void addParticipant(String name, {String? emoji}) {
    final person = Person(name: name.trim(), avatarEmoji: emoji);
    state = _copy(participants: [...state.participants, person]);
  }

  /// Remove participant by id; also cleans up their expenses.
  void removeParticipant(String id) {
    state = _copy(
      participants: state.participants.where((p) => p.id != id).toList(),
      // Drop expenses where only this person is the sole split-member or payer.
      expenses: state.expenses
          .where((e) => e.paidById != id && !e.splitAmongIds.contains(id))
          .toList(),
    );
  }

  // ── Expenses ──────────────────────────────────────────────────────────────

  void addExpense(Expense expense) =>
      state = _copy(expenses: [...state.expenses, expense]);

  void removeExpense(String id) =>
      state = _copy(expenses: state.expenses.where((e) => e.id != id).toList());

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  /// Save the current session to Hive via [HistoryNotifier] and reset.
  /// Returns the saved [SplitSession] so callers can navigate to it.
  Future<SplitSession> confirmSession() async {
    final session = _copy(isSettled: false);
    await ref.read(historyProvider.notifier).saveSession(session);
    reset();
    return session;
  }

  /// Discard the in-progress session without saving.
  void reset() => state = SplitSession(title: '', participants: [], expenses: []);

  // ── Helpers ───────────────────────────────────────────────────────────────

  SplitSession _copy({
    String? title,
    List<Person>? participants,
    List<Expense>? expenses,
    bool? isSettled,
  }) =>
      SplitSession(
        id: state.id,
        title: title ?? state.title,
        participants: participants ?? state.participants,
        expenses: expenses ?? state.expenses,
        createdAt: state.createdAt,
        isSettled: isSettled ?? state.isSettled,
      );
}

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/person.dart';
import '../models/expense.dart';
import '../models/split_session.dart';

part 'session_provider.g.dart';

@riverpod
class SplitSessionNotifier extends _$SplitSessionNotifier {
  @override
  SplitSession build() {
    return SplitSession(title: 'New Trip', participants: [], expenses: []);
  }

  /// Set the title of the current session
  void setTitle(String title) {
    state = _copyWith(title: title);
  }

  /// Add a participant to the session
  void addParticipant(Person participant) {
    state = _copyWith(participants: [...state.participants, participant]);
  }

  /// Add a participant with name and optional emoji
  void addParticipantWithEmoji(String name, String? emoji) {
    final participant = Person(name: name, avatarEmoji: emoji);
    addParticipant(participant);
  }

  /// Remove a participant from the session
  void removeParticipant(String participantId) {
    state = _copyWith(
      participants: state.participants
          .where((p) => p.id != participantId)
          .toList(),
      expenses: state.expenses
          .where(
            (e) =>
                e.paidById != participantId &&
                !e.splitAmongIds.contains(participantId),
          )
          .toList(),
    );
  }

  /// Add an expense to the session
  void addExpense(Expense expense) {
    state = _copyWith(expenses: [...state.expenses, expense]);
  }

  /// Remove an expense from the session
  void removeExpense(String expenseId) {
    state = _copyWith(
      expenses: state.expenses.where((e) => e.id != expenseId).toList(),
    );
  }

  /// Update an existing expense
  void updateExpense(Expense updatedExpense) {
    final expenses = state.expenses.map((e) {
      return e.id == updatedExpense.id ? updatedExpense : e;
    }).toList();
    state = _copyWith(expenses: expenses);
  }

  /// Confirm the session (mark as ready to save)
  SplitSession confirmSession() {
    return SplitSession(
      id: state.id,
      title: state.title,
      participants: state.participants,
      expenses: state.expenses,
      createdAt: DateTime.now(),
      isSettled: false,
    );
  }

  /// Reset the session to initial state
  void reset() {
    state = SplitSession(title: 'New Trip', participants: [], expenses: []);
  }

  /// Mark the current session as settled
  void markSettled() {
    state = _copyWith(isSettled: true);
  }

  /// Update participant emoji
  void updateParticipantEmoji(String participantId, String emoji) {
    final participants = state.participants.map((p) {
      if (p.id == participantId) {
        return Person(id: p.id, name: p.name, avatarEmoji: emoji);
      }
      return p;
    }).toList();
    state = _copyWith(participants: participants);
  }

  /// Load an existing session for editing
  void loadSession(SplitSession session) {
    state = session;
  }

  // ── Private helpers ─────────────────────────────────────────────────────
  SplitSession _copyWith({
    String? title,
    List<Person>? participants,
    List<Expense>? expenses,
    bool? isSettled,
  }) {
    return SplitSession(
      id: state.id,
      title: title ?? state.title,
      participants: participants ?? state.participants,
      expenses: expenses ?? state.expenses,
      createdAt: state.createdAt,
      isSettled: isSettled ?? state.isSettled,
    );
  }
}

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/person.dart';
import '../models/expense.dart';
import '../models/split_session.dart';

part 'active_session_provider.g.dart';

@riverpod
class ActiveSession extends _$ActiveSession {
  @override
  SplitSession build() {
    return SplitSession(
      title: 'New Trip',
      participants: [],
      expenses: [],
    );
  }

  void setTitle(String title) => state = _copy(title: title);

  void addPerson(String name) {
    state = _copy(participants: [...state.participants, Person(name: name)]);
  }

  void removePerson(String id) {
    state = _copy(
      participants: state.participants.where((p) => p.id != id).toList(),
      expenses: state.expenses
          .where((e) => e.paidById != id && !e.splitAmongIds.contains(id))
          .toList(),
    );
  }

  void addExpense(Expense expense) {
    state = _copy(expenses: [...state.expenses, expense]);
  }

  void removeExpense(String id) {
    state = _copy(expenses: state.expenses.where((e) => e.id != id).toList());
  }

  void addPersonWithEmoji(String name, String? emoji) {
    final person = Person(name: name, avatarEmoji: emoji);
    state = _copy(participants: [...state.participants, person]);
  }

  void markSettled() {
    state = SplitSession(
      id: state.id,
      title: state.title,
      participants: state.participants,
      expenses: state.expenses,
      createdAt: state.createdAt,
      isSettled: true,
    );
  }

  void reset() {
    state = SplitSession(title: 'New Trip', participants: [], expenses: []);
  }

  // ── Private helpers ─────────────────────────────────────────────────────
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

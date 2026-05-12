import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/split_session.dart';

part 'history_provider.g.dart';

@riverpod
class HistoryNotifier extends _$HistoryNotifier {
  late Box<SplitSession> _box;

  @override
  List<SplitSession> build() {
    _box = Hive.box<SplitSession>('sessions');
    return _box.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Save a new session to Hive and update the state
  Future<void> saveSession(SplitSession session) async {
    await _box.put(session.id, session);
    state = _box.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Delete a session from Hive and update the state
  Future<void> deleteSession(String id) async {
    await _box.delete(id);
    state = _box.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Mark a session as settled or unsettled
  Future<void> markSettled(String sessionId, bool isSettled) async {
    final session = _box.get(sessionId);
    if (session != null) {
      final updatedSession = SplitSession(
        id: session.id,
        title: session.title,
        participants: session.participants,
        expenses: session.expenses,
        createdAt: session.createdAt,
        isSettled: isSettled,
      );
      await saveSession(updatedSession);
    }
  }

  /// Toggle the settled status of a session
  Future<void> toggleSettled(String sessionId) async {
    final session = _box.get(sessionId);
    if (session != null) {
      await markSettled(sessionId, !session.isSettled);
    }
  }

  /// Update an existing session
  Future<void> updateSession(SplitSession session) async {
    await saveSession(session);
  }

  /// Add a session (alias for saveSession for backward compatibility)
  Future<void> addSession(SplitSession session) async {
    await saveSession(session);
  }
}

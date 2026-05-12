import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/split_session.dart';

part 'history_provider.g.dart';

/// Reads/writes [SplitSession] objects from the Hive box `'sessions'`.
/// Exposes a [List<SplitSession>] sorted newest-first.
/// Subscribes to box changes via [Box.watch] for reactive updates.
@riverpod
class History extends _$History {
  late Box<SplitSession> _box;

  @override
  List<SplitSession> build() {
    _box = Hive.box<SplitSession>('sessions');

    // React to any box write/delete without manual state pushes.
    final sub = _box.watch().listen((_) => state = _sorted());
    ref.onDispose(sub.cancel);

    return _sorted();
  }

  // ── Public API ────────────────────────────────────────────────────────────

  /// Alias for [addSession] — used by [SplitSessionNotifier.confirmSession].
  Future<void> saveSession(SplitSession session) async {
    await _box.put(session.id, session);
    state = _sorted();
  }

  /// Legacy alias kept for compatibility.
  Future<void> addSession(SplitSession session) => saveSession(session);

  Future<void> deleteSession(String id) async {
    await _box.delete(id);
    state = _sorted();
  }

  /// Toggle the settled flag for an existing session.
  Future<void> markSettled(String id, {bool settled = true}) async {
    final session = _box.get(id);
    if (session == null) return;
    final updated = SplitSession(
      id: session.id,
      title: session.title,
      participants: session.participants,
      expenses: session.expenses,
      createdAt: session.createdAt,
      isSettled: settled,
    );
    await _box.put(id, updated);
    state = _sorted();
  }

  // ── Private ───────────────────────────────────────────────────────────────

  List<SplitSession> _sorted() =>
      _box.values.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
}

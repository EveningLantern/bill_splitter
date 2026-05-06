import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/split_session.dart';

part 'history_provider.g.dart';

@riverpod
class History extends _$History {
  late Box<SplitSession> _box;

  @override
  List<SplitSession> build() {
    _box = Hive.box<SplitSession>('sessions');
    return _box.values.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> addSession(SplitSession session) async {
    await _box.put(session.id, session);
    state = _box.values.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> deleteSession(String id) async {
    await _box.delete(id);
    state = _box.values.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }
}

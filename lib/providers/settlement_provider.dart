import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/settlement.dart';
import '../utils/settlement_calculator.dart';
import 'history_provider.dart';

part 'settlement_provider.g.dart';

/// Watches [HistoryNotifier] and computes the minimal settlement list for
/// the session identified by [sessionId].
///
/// Returns an empty list when the session cannot be found.
///
/// This is a *family* provider — create it with:
///   ```dart
///   ref.watch(settlementsProvider(sessionId))
///   ```
@riverpod
List<Settlement> settlements(Ref ref, String sessionId) {
  final history = ref.watch(historyProvider);

  final session = history.firstWhere(
    (s) => s.id == sessionId,
    orElse: () => throw StateError('Session $sessionId not found'),
  );

  final participantIds = session.participants.map((p) => p.id).toList();
  return SettlementCalculator.calculate(participantIds, session.expenses);
}

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../utils/settlement_calculator.dart';
import 'history_provider.dart';

part 'settlement_provider.g.dart';

/// Settlement data structure
class Settlement {
  final String fromPersonId;
  final String toPersonId;
  final String fromPersonName;
  final String toPersonName;
  final double amount;

  const Settlement({
    required this.fromPersonId,
    required this.toPersonId,
    required this.fromPersonName,
    required this.toPersonName,
    required this.amount,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Settlement &&
          runtimeType == other.runtimeType &&
          fromPersonId == other.fromPersonId &&
          toPersonId == other.toPersonId &&
          amount == other.amount;

  @override
  int get hashCode =>
      fromPersonId.hashCode ^ toPersonId.hashCode ^ amount.hashCode;

  @override
  String toString() {
    return 'Settlement(from: $fromPersonName, to: $toPersonName, amount: ₹${amount.toStringAsFixed(2)})';
  }
}

/// Computes settlements for a specific session
@riverpod
List<Settlement> settlements(SettlementsRef ref, String sessionId) {
  final history = ref.watch(historyNotifierProvider);

  // Find the session by ID
  final session = history.firstWhere(
    (s) => s.id == sessionId,
    orElse: () => throw ArgumentError('Session with ID $sessionId not found'),
  );

  // Use the settlement calculator to compute optimal settlements
  return SettlementCalculator.compute(session);
}

/// Computes settlements for all active (unsettled) sessions
@riverpod
Map<String, List<Settlement>> allActiveSettlements(
  AllActiveSettlementsRef ref,
) {
  final history = ref.watch(historyNotifierProvider);
  final activeSessions = history.where((s) => !s.isSettled);

  final settlements = <String, List<Settlement>>{};
  for (final session in activeSessions) {
    settlements[session.id] = SettlementCalculator.compute(session);
  }

  return settlements;
}

/// Computes total amount owed by a person across all active sessions
@riverpod
double totalOwedByPerson(TotalOwedByPersonRef ref, String personName) {
  final allSettlements = ref.watch(allActiveSettlementsProvider);

  double totalOwed = 0.0;
  for (final sessionSettlements in allSettlements.values) {
    for (final settlement in sessionSettlements) {
      if (settlement.fromPersonName == personName) {
        totalOwed += settlement.amount;
      }
    }
  }

  return totalOwed;
}

/// Computes total amount to be received by a person across all active sessions
@riverpod
double totalToReceiveByPerson(
  TotalToReceiveByPersonRef ref,
  String personName,
) {
  final allSettlements = ref.watch(allActiveSettlementsProvider);

  double totalToReceive = 0.0;
  for (final sessionSettlements in allSettlements.values) {
    for (final settlement in sessionSettlements) {
      if (settlement.toPersonName == personName) {
        totalToReceive += settlement.amount;
      }
    }
  }

  return totalToReceive;
}

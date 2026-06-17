import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'bill_entry.dart';

part 'history_batch.g.dart';

/// A snapshot of reset entries stored in the 'bill_history' Hive box.
/// Auto-purged when [resetAt] is >20 calendar days before the current device date.
/// typeId: 6 — registered as HistoryBatchAdapter in main.dart.
@HiveType(typeId: 6)
class HistoryBatch extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final BillEntryType type; // expense | income batch

  @HiveField(2)
  final List<BillEntry> entries; // deep snapshot of entries at reset time

  @HiveField(3)
  final DateTime resetAt; // UTC timestamp of the reset action

  HistoryBatch({
    String? id,
    required this.type,
    required this.entries,
    DateTime? resetAt,
  }) : id = id ?? const Uuid().v4(),
       resetAt = resetAt ?? DateTime.now().toUtc();

  double get totalAmount => entries.fold(0.0, (sum, e) => sum + e.amount);
  int get entryCount => entries.length;
}

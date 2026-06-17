import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'bill_entry.g.dart';

/// Discriminates between an expense entry and an income entry.
/// typeId: 4 — registered as BillEntryTypeAdapter in main.dart.
@HiveType(typeId: 4)
enum BillEntryType {
  @HiveField(0)
  expense,
  @HiveField(1)
  income,
}

/// A single personal-finance record.
/// Stored in the 'bill_entries' Hive box, keyed by [id].
/// typeId: 5 — registered as BillEntryAdapter in main.dart.
@HiveType(typeId: 5)
class BillEntry extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final BillEntryType type; // expense | income

  @HiveField(2)
  final double amount; // always positive; 0.01 – 999_999_999.99

  @HiveField(3)
  final String name; // product name (expense) or source name (income); 1–100 chars

  @HiveField(4)
  final DateTime dateTime; // user-selected date + time

  BillEntry({
    String? id,
    required this.type,
    required this.amount,
    required this.name,
    DateTime? dateTime,
  }) : id = id ?? const Uuid().v4(),
       dateTime = dateTime ?? DateTime.now();
}

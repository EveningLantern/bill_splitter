import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'expense.g.dart';

@HiveType(typeId: 1)
class Expense extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final String paidById;

  @HiveField(4)
  final List<String> splitAmongIds;

  @HiveField(5)
  final DateTime createdAt;

  Expense({
    String? id,
    required this.title,
    required this.amount,
    required this.paidById,
    required this.splitAmongIds,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();
}

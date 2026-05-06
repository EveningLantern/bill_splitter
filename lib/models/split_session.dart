import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'person.dart';
import 'expense.dart';

part 'split_session.g.dart';

@HiveType(typeId: 2)
class SplitSession extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final List<Person> participants;

  @HiveField(3)
  final List<Expense> expenses;

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  final bool isSettled;

  SplitSession({
    String? id,
    required this.title,
    required this.participants,
    required this.expenses,
    DateTime? createdAt,
    this.isSettled = false,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  double get totalAmount => expenses.fold(0.0, (sum, e) => sum + e.amount);
}

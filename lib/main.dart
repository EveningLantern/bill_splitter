import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app.dart';
import 'models/person.dart';
import 'models/expense.dart';
import 'models/split_session.dart';
import 'models/bill_entry.dart';
import 'models/history_batch.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  // Register adapters
  Hive.registerAdapter(PersonAdapter());
  Hive.registerAdapter(ExpenseAdapter());
  Hive.registerAdapter(SplitSessionAdapter());
  Hive.registerAdapter(BillEntryTypeAdapter());
  Hive.registerAdapter(BillEntryAdapter());
  Hive.registerAdapter(HistoryBatchAdapter());

  // Open boxes
  await Hive.openBox<SplitSession>('sessions');
  await Hive.openBox<BillEntry>('bill_entries');
  await Hive.openBox<HistoryBatch>('bill_history');

  runApp(ProviderScope(child: PloyApp()));
}

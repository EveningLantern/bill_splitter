import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app.dart';
import 'models/person.dart';
import 'models/expense.dart';
import 'models/split_session.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  // Register adapters
  Hive.registerAdapter(PersonAdapter());
  Hive.registerAdapter(ExpenseAdapter());
  Hive.registerAdapter(SplitSessionAdapter());

  // Open boxes
  await Hive.openBox<SplitSession>('sessions');

  runApp(ProviderScope(child: PloyApp()));
}

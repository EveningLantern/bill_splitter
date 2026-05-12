import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app.dart';
import 'models/person.dart';
import 'models/expense.dart';
import 'models/split_session.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await Hive.initFlutter();

  // Register adapters
  Hive.registerAdapter(PersonAdapter());
  Hive.registerAdapter(ExpenseAdapter());
  Hive.registerAdapter(SplitSessionAdapter());

  // Open boxes
  await Hive.openBox<SplitSession>('sessions');

  // Remove splash screen after initialization
  FlutterNativeSplash.remove();

  runApp(ProviderScope(child: PloyApp()));
}

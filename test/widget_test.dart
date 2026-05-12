import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:bill_splitter/screens/history_screen.dart';
import 'package:bill_splitter/models/person.dart';
import 'package:bill_splitter/models/expense.dart';
import 'package:bill_splitter/models/split_session.dart';

void main() {
  setUpAll(() async {
    // Initialize Hive with a temporary directory for tests
    Hive.init('./test/temp');

    // Register adapters
    Hive.registerAdapter(PersonAdapter());
    Hive.registerAdapter(ExpenseAdapter());
    Hive.registerAdapter(SplitSessionAdapter());

    // Open boxes for testing
    await Hive.openBox<SplitSession>('sessions');
  });

  tearDownAll(() async {
    await Hive.close();
  });

  testWidgets('HistoryScreen renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: HistoryScreen())),
    );

    // Should show the history screen
    expect(find.text('Split History'), findsOneWidget);
    expect(find.text('No saved sessions yet'), findsOneWidget);
  });
}

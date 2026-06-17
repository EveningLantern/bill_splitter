import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:bill_splitter/app.dart';
import 'package:bill_splitter/models/bill_entry.dart';
import 'package:bill_splitter/models/expense.dart';
import 'package:bill_splitter/models/history_batch.dart';
import 'package:bill_splitter/models/person.dart';
import 'package:bill_splitter/models/split_session.dart';

void main() {
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_test_');
    Hive.init(tempDir.path);
    Hive.registerAdapter(PersonAdapter());
    Hive.registerAdapter(ExpenseAdapter());
    Hive.registerAdapter(SplitSessionAdapter());
    Hive.registerAdapter(BillEntryTypeAdapter());
    Hive.registerAdapter(BillEntryAdapter());
    Hive.registerAdapter(HistoryBatchAdapter());
    await Hive.openBox<SplitSession>('sessions');
    await Hive.openBox<BillEntry>('bill_entries');
    await Hive.openBox<HistoryBatch>('bill_history');
  });

  tearDownAll(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  testWidgets('PloyApp smoke test — home screen renders', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(ProviderScope(child: PloyApp()));
    // Flush FadeSlide animation timers and any async provider work
    await tester.pumpAndSettle(const Duration(seconds: 2));
    // App scaffold should be present
    expect(find.byType(Scaffold), findsWidgets);
  });
}

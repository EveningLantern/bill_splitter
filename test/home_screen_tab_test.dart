// Tests for HomeScreen tab switching behavior.
// Requirements: 1.3, 1.4, 1.5
//
// Covers:
//   - Default tab is Bill (BillTrackerSection shown, Splitter content absent)
//   - Tapping "Splitter" switches to Splitter section (BillTrackerSection absent)
//   - Tapping "Bill" after switching back restores the Bill section
//   - FAB (FloatingActionButton) is present on the Splitter tab
//   - FAB is absent (null) on the Bill tab

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:bill_splitter/models/bill_entry.dart';
import 'package:bill_splitter/models/expense.dart';
import 'package:bill_splitter/models/history_batch.dart';
import 'package:bill_splitter/models/person.dart';
import 'package:bill_splitter/models/split_session.dart';
import 'package:bill_splitter/screens/home_screen.dart';
import 'package:bill_splitter/theme/app_theme.dart';
import 'package:bill_splitter/widgets/bill_tracker_section.dart';

// ── Test helpers ──────────────────────────────────────────────────────────────

/// Minimal GoRouter that serves HomeScreen at '/' and stubs out other routes.
GoRouter _buildTestRouter() => GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
    // Stub routes so any navigation from child widgets doesn't crash.
    GoRoute(path: '/split', builder: (_, __) => const _StubPage()),
    GoRoute(path: '/split-now', redirect: (_, __) => '/split'),
    GoRoute(path: '/history', builder: (_, __) => const _StubPage()),
    GoRoute(path: '/bill-history', builder: (_, __) => const _StubPage()),
    GoRoute(path: '/profile', builder: (_, __) => const _StubPage()),
  ],
);

/// Wraps the test app in a [ProviderScope] + [MaterialApp.router].
Widget _buildTestApp() => ProviderScope(
  child: MaterialApp.router(
    title: 'Test',
    theme: AppTheme.darkTheme,
    routerConfig: _buildTestRouter(),
  ),
);

// Blank page used for stub routes so navigation doesn't throw.
class _StubPage extends StatelessWidget {
  const _StubPage();
  @override
  Widget build(BuildContext context) => const Scaffold();
}

// ── Suite ─────────────────────────────────────────────────────────────────────

void main() {
  late Directory tempDir;

  // Initialise Hive once — same pattern as widget_test.dart
  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_tab_test_');
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

  // ── 1. Default tab is Bill ──────────────────────────────────────────────────

  testWidgets('default tab is Bill — BillTrackerSection is shown', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_buildTestApp());
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // BillTrackerSection should be in the widget tree on the Bill tab.
    expect(find.byType(BillTrackerSection), findsOneWidget);
  });

  testWidgets('default tab is Bill — Splitter-only widgets are absent', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_buildTestApp());
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // The Splitter tab shows a FAB. On the Bill tab it must be absent.
    expect(find.byType(FloatingActionButton), findsNothing);
  });

  // ── 2. Tapping "Splitter" switches content ──────────────────────────────────

  testWidgets('tapping Splitter tab hides BillTrackerSection', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_buildTestApp());
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Tap the "Splitter" label in the tab toggle.
    await tester.tap(find.text('Splitter'));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // BillTrackerSection should no longer be present.
    expect(find.byType(BillTrackerSection), findsNothing);
  });

  testWidgets('tapping Splitter tab shows FAB', (WidgetTester tester) async {
    await tester.pumpWidget(_buildTestApp());
    await tester.pumpAndSettle(const Duration(seconds: 2));

    await tester.tap(find.text('Splitter'));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // FAB (New Split) should appear on the Splitter tab.
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });

  // ── 3. Tapping "Bill" restores the Bill section ────────────────────────────

  testWidgets('tapping Bill after Splitter restores BillTrackerSection', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_buildTestApp());
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Switch to Splitter tab first.
    await tester.tap(find.text('Splitter'));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Now switch back to Bill.
    await tester.tap(find.text('Bill'));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // BillTrackerSection should be back in the tree.
    expect(find.byType(BillTrackerSection), findsOneWidget);
  });

  testWidgets('tapping Bill after Splitter hides FAB', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_buildTestApp());
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Switch to Splitter to get the FAB, then back to Bill.
    await tester.tap(find.text('Splitter'));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    await tester.tap(find.text('Bill'));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // FAB must be gone again on the Bill tab.
    expect(find.byType(FloatingActionButton), findsNothing);
  });

  // ── 4. FAB is present on Splitter tab ─────────────────────────────────────

  testWidgets('FAB is present when Splitter tab is active', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_buildTestApp());
    await tester.pumpAndSettle(const Duration(seconds: 2));

    await tester.tap(find.text('Splitter'));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(find.byType(FloatingActionButton), findsOneWidget);
  });

  // ── 5. FAB is absent on Bill tab ──────────────────────────────────────────

  testWidgets('FAB is absent when Bill tab is active', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_buildTestApp());
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Stay on default (Bill) tab — FAB must not exist.
    expect(find.byType(FloatingActionButton), findsNothing);
  });
}

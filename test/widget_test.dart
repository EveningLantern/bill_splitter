import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bill_splitter/app.dart';

void main() {
  testWidgets('PloyApp smoke test — home screen renders', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(child: PloyApp()),
    );
    // App scaffold should be present
    expect(find.byType(Scaffold), findsWidgets);
  });
}

// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:fitnessx/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('App shows title and navigates from box', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('FitnessX'), findsOneWidget);

    final boxFinder = find.byKey(const ValueKey('box1'));
    expect(boxFinder, findsOneWidget);

    await tester.tap(boxFinder);
    await tester.pumpAndSettle();

    expect(find.text('Exercise'), findsOneWidget);
  });
}

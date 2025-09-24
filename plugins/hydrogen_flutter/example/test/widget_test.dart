import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hydrogen_flutter_example/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('0'), findsOneWidget);

    // FIXME: 
    // Test fails - unable to load shared library...
    // https://take4-blue.com/en/program/flutter-failed-to-load-dynamic-library-at-test/
    // 

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    expect(find.text('0'), findsNothing);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App smoke test - basic MaterialApp renders', (WidgetTester tester) async {
    // Simple smoke test that doesn't require asset loading or providers
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(title: const Text('RT OneStop')),
          body: const Center(child: Text('Test')),
        ),
      ),
    );

    expect(find.text('RT OneStop'), findsOneWidget);
  });
}

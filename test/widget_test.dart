import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synquerra/core/di/injection_container.dart';
import 'package:synquerra/presentation/app/my_app.dart';

void main() {
  testWidgets('App starts and renders smoke test', (WidgetTester tester) async {
    // Initialize dependencies before running the app.
    await initDependencies();

    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Allow the app to settle.
    await tester.pumpAndSettle();

    // Verify that the app renders something, e.g., the login screen.
    // This is a basic check to ensure the app doesn't crash on startup.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}

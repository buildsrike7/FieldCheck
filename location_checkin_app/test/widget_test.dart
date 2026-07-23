import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:location_checkin_app/main.dart';

void main() {
  // Set up mock values for SharedPreferences before the tests run
  setUpAll(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('App starts on the Welcome Animation Screen and shows title', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the Welcome/Splash screen renders initially
    expect(find.text('FieldCheck'), findsOneWidget);
    expect(find.text('Your Location-Based Check-In App'), findsOneWidget);
    expect(find.byIcon(Icons.location_pin), findsOneWidget);
  });
}
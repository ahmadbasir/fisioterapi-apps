import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fisioterapi_app/main.dart';
import 'package:fisioterapi_app/core/providers/providers.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Seed blank mock values for local storage
    SharedPreferences.setMockInitialValues({});
    final sharedPrefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPrefs),
        ],
        child: const FisioActiveApp(),
      ),
    );

    // Verify splash screen elements render correctly
    expect(find.byIcon(Icons.healing_rounded), findsOneWidget);
    expect(find.text('FisioActive'), findsOneWidget);

    // Settle any pending animations and timers (like the splash screen navigation)
    await tester.pumpAndSettle();
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/theme.dart';
import 'app/router.dart';
import 'core/providers/providers.dart';

void main() async {
  // Ensure Flutter engine is initialized before shared preferences bootstrap
  WidgetsFlutterBinding.ensureInitialized();
  
  // Pre-initialize SharedPreferences for instantaneous read/writes without initial startup delays
  final sharedPrefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        // Override the placeholder provider with our active pre-initialized preferences instance
        sharedPreferencesProvider.overrideWithValue(sharedPrefs),
      ],
      child: const FisioActiveApp(),
    ),
  );
}

class FisioActiveApp extends ConsumerWidget {
  const FisioActiveApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'FisioActive - Self-Recovery Assistant',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme, // High-end dark theme system
      routerConfig: router,
    );
  }
}

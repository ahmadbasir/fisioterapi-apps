import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/providers/providers.dart';

// Import Screens (we will create these next)
import '../features/auth/presentation/splash_screen.dart';
import '../features/auth/presentation/onboarding_screen.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/profile_setup_screen.dart';
import '../features/auth/presentation/disclaimer_screen.dart';
import '../features/triage/presentation/body_map_screen.dart';
import '../features/triage/presentation/red_flags_screen.dart';
import '../features/triage/presentation/refer_doctor_screen.dart';
import '../features/dashboard/presentation/dashboard_screen.dart';
import '../features/dashboard/presentation/report_screen.dart';
import '../features/dashboard/presentation/settings_screen.dart';
import '../features/workout/presentation/workout_overview_screen.dart';
import '../features/workout/presentation/active_workout_screen.dart';
import '../features/workout/presentation/workout_summary_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  // Listen to user and injury state to trigger automatic reactive routing redirects
  final user = ref.watch(userProfileProvider);
  final injury = ref.watch(injuryProfileProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final loc = state.matchedLocation;

      // Unauthenticated state paths
      final isSplash = loc == '/';
      final isOnboarding = loc == '/onboarding';
      final isLogin = loc == '/login';

      if (user == null) {
        if (isSplash || isOnboarding || isLogin) return null;
        return '/login';
      }

      // User logged in: Profile setup completion check
      if (user.age == 0 || user.activityLevel.isEmpty) {
        if (loc == '/profile-setup') return null;
        return '/profile-setup';
      }

      // Disclaimer check
      if (!user.isDisclaimerAccepted) {
        if (loc == '/disclaimer') return null;
        return '/disclaimer';
      }

      // Injury selection assessment checks
      if (injury == null) {
        // Allow user to navigate within the triage pages
        if (loc.startsWith('/triage')) return null;
        return '/triage/body-map';
      }

      // If injury exists but pain level is critical (Red Flag screen handled inline or hard blocked),
      // we let the user access dashboard if no flag, or allow refer page
      if (loc == '/login' || loc == '/profile-setup' || loc == '/disclaimer') {
        return '/dashboard';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/profile-setup',
        builder: (context, state) => const ProfileSetupScreen(),
      ),
      GoRoute(
        path: '/disclaimer',
        builder: (context, state) => const DisclaimerScreen(),
      ),
      
      // Triage Subroutes
      GoRoute(
        path: '/triage/body-map',
        builder: (context, state) => const BodyMapSelectionScreen(),
      ),
      GoRoute(
        path: '/triage/assessment/:area',
        builder: (context, state) {
          final area = state.pathParameters['area'] ?? 'Lutut';
          return RedFlagsScreen(injuryArea: area);
        },
      ),
      GoRoute(
        path: '/triage/refer',
        builder: (context, state) => const ReferDoctorScreen(),
      ),

      // Main Dashboard Tabs & Routes
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/report',
        builder: (context, state) => const ReportScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),

      // Workout Subroutes
      GoRoute(
        path: '/workout/overview',
        builder: (context, state) => const WorkoutOverviewScreen(),
      ),
      GoRoute(
        path: '/workout/active',
        builder: (context, state) => const ActiveWorkoutScreen(),
      ),
      GoRoute(
        path: '/workout/summary',
        builder: (context, state) {
          // Allow passing completed details
          final extra = state.extra as Map<String, dynamic>?;
          return WorkoutSummaryScreen(
            painBefore: extra?['painBefore'] ?? 5,
            painAfter: extra?['painAfter'] ?? 3,
            completedCount: extra?['completedCount'] ?? 3,
            durationMinutes: extra?['durationMinutes'] ?? 10,
          );
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Halaman tidak ditemukan: ${state.error}'),
      ),
    ),
  );
});

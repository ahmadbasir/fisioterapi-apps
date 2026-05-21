import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../data/recovery_repository.dart';

// 1. SharedPreferences Provider (Pre-initialized in main)
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden in ProviderScope');
});

// 2. Repository Provider
final recoveryRepositoryProvider = Provider<RecoveryRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return RecoveryRepository(prefs);
});

// 3. UserProfile StateNotifier and Provider
class UserProfileNotifier extends StateNotifier<UserProfile?> {
  final RecoveryRepository _repository;

  UserProfileNotifier(this._repository) : super(null) {
    _loadProfile();
  }

  void _loadProfile() {
    state = _repository.getUserProfile();
  }

  Future<void> saveProfile(UserProfile profile) async {
    await _repository.saveUserProfile(profile);
    state = profile;
  }

  Future<void> acceptDisclaimer() async {
    final current = state;
    if (current != null) {
      final updated = UserProfile(
        uid: current.uid,
        email: current.email,
        age: current.age,
        weight: current.weight,
        height: current.height,
        activityLevel: current.activityLevel,
        isDisclaimerAccepted: true,
      );
      await saveProfile(updated);
    }
  }

  Future<void> logout() async {
    await _repository.clearAll();
    state = null;
  }
}

final userProfileProvider = StateNotifierProvider<UserProfileNotifier, UserProfile?>((ref) {
  final repo = ref.watch(recoveryRepositoryProvider);
  return UserProfileNotifier(repo);
});

// 4. InjuryProfile StateNotifier and Provider
class InjuryProfileNotifier extends StateNotifier<InjuryProfile?> {
  final RecoveryRepository _repository;
  final Ref _ref;

  InjuryProfileNotifier(this._repository, this._ref) : super(null) {
    _loadInjury();
  }

  void _loadInjury() {
    state = _repository.getInjuryProfile();
  }

  Future<void> setInjury(String area, int initialPainLevel) async {
    final phase = InjuryProfile.determinePhase(initialPainLevel);
    final profile = InjuryProfile(
      injuryArea: area,
      initialPainLevel: initialPainLevel,
      recoveryPhase: phase,
      startedAt: DateTime.now(),
    );
    await _repository.saveInjuryProfile(profile);
    state = profile;
  }

  Future<void> resetInjury() async {
    await _repository.resetRecoveryProfile();
    state = null;
  }

  // Reload from storage (called after workout log evaluations)
  void refresh() {
    _loadInjury();
  }
}

final injuryProfileProvider = StateNotifierProvider<InjuryProfileNotifier, InjuryProfile?>((ref) {
  final repo = ref.watch(recoveryRepositoryProvider);
  return InjuryProfileNotifier(repo, ref);
});

// 5. WorkoutLogs StateNotifier and Provider
class WorkoutLogsNotifier extends StateNotifier<List<WorkoutLog>> {
  final RecoveryRepository _repository;
  final Ref _ref;

  WorkoutLogsNotifier(this._repository, this._ref) : super([]) {
    _loadLogs();
  }

  void _loadLogs() {
    state = _repository.getWorkoutLogs();
  }

  Future<void> addLog(WorkoutLog log) async {
    await _repository.addWorkoutLog(log);
    _loadLogs();
    
    // Refresh the injury profile in case the phase shifted due to log results
    _ref.read(injuryProfileProvider.notifier).refresh();
  }
}

final workoutLogsProvider = StateNotifierProvider<WorkoutLogsNotifier, List<WorkoutLog>>((ref) {
  final repo = ref.watch(recoveryRepositoryProvider);
  return WorkoutLogsNotifier(repo, ref);
});

// 6. ActiveWorkoutSession Provider (Derived State)
final activeWorkoutSessionProvider = Provider<DailyWorkoutSession?>((ref) {
  final injury = ref.watch(injuryProfileProvider);
  if (injury == null) return null;
  
  final repo = ref.watch(recoveryRepositoryProvider);
  return repo.getWorkoutSession(injury.injuryArea, injury.recoveryPhase);
});

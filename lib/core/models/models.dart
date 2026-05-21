import 'dart:convert';

class UserProfile {
  final String uid;
  final String email;
  final int age;
  final double weight;
  final double height;
  final String activityLevel;
  final bool isDisclaimerAccepted;

  UserProfile({
    required this.uid,
    required this.email,
    required this.age,
    required this.weight,
    required this.height,
    required this.activityLevel,
    required this.isDisclaimerAccepted,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'age': age,
      'weight': weight,
      'height': height,
      'activityLevel': activityLevel,
      'isDisclaimerAccepted': isDisclaimerAccepted,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      age: map['age'] ?? 0,
      weight: (map['weight'] as num?)?.toDouble() ?? 0.0,
      height: (map['height'] as num?)?.toDouble() ?? 0.0,
      activityLevel: map['activityLevel'] ?? '',
      isDisclaimerAccepted: map['isDisclaimerAccepted'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserProfile.fromJson(String source) => UserProfile.fromMap(json.decode(source));
}

class InjuryProfile {
  final String injuryArea; // "Bahu", "Lutut", "Ankle", "Pinggang"
  final int initialPainLevel; // VAS 1-10
  final String recoveryPhase; // "Proteksi" (Phase 1), "Mobilitas" (Phase 2), "Penguatan" (Phase 3)
  final DateTime startedAt;

  InjuryProfile({
    required this.injuryArea,
    required this.initialPainLevel,
    required this.recoveryPhase,
    required this.startedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'injuryArea': injuryArea,
      'initialPainLevel': initialPainLevel,
      'recoveryPhase': recoveryPhase,
      'startedAt': startedAt.toIso8601String(),
    };
  }

  factory InjuryProfile.fromMap(Map<String, dynamic> map) {
    return InjuryProfile(
      injuryArea: map['injuryArea'] ?? '',
      initialPainLevel: map['initialPainLevel'] ?? 0,
      recoveryPhase: map['recoveryPhase'] ?? 'Proteksi',
      startedAt: DateTime.parse(map['startedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  String toJson() => json.encode(toMap());

  factory InjuryProfile.fromJson(String source) => InjuryProfile.fromMap(json.decode(source));

  // Determine recovery phase based on pain level initially
  static String determinePhase(int painLevel) {
    if (painLevel >= 7) {
      return "Proteksi"; // High pain: Protect & rest
    } else if (painLevel >= 4) {
      return "Mobilitas"; // Medium pain: Improve Range of Motion
    } else {
      return "Penguatan"; // Low pain: Strengthen muscles
    }
  }
}

class Exercise {
  final String id;
  final String name;
  final int durationSeconds;
  final int? reps;
  final int? sets;
  final String description;
  final List<String> equipment;
  final String animationType; // "lottie" or "canvas" or simple details to animate mock player

  Exercise({
    required this.id,
    required this.name,
    required this.durationSeconds,
    this.reps,
    this.sets,
    required this.description,
    required this.equipment,
    required this.animationType,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'durationSeconds': durationSeconds,
      'reps': reps,
      'sets': sets,
      'description': description,
      'equipment': equipment,
      'animationType': animationType,
    };
  }

  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      durationSeconds: map['durationSeconds'] ?? 0,
      reps: map['reps'],
      sets: map['sets'],
      description: map['description'] ?? '',
      equipment: List<String>.from(map['equipment'] ?? []),
      animationType: map['animationType'] ?? 'canvas',
    );
  }
}

class DailyWorkoutSession {
  final String id;
  final String title;
  final String phase;
  final List<Exercise> exercises;
  final int durationMinutes;

  DailyWorkoutSession({
    required this.id,
    required this.title,
    required this.phase,
    required this.exercises,
    required this.durationMinutes,
  });
}

class WorkoutLog {
  final String id;
  final DateTime date;
  final String injuryArea;
  final String phase;
  final int painBefore;
  final int painAfter;
  final int exercisesCompleted;
  final int durationMinutes;
  final bool isCompleted;

  WorkoutLog({
    required this.id,
    required this.date,
    required this.injuryArea,
    required this.phase,
    required this.painBefore,
    required this.painAfter,
    required this.exercisesCompleted,
    required this.durationMinutes,
    required this.isCompleted,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'injuryArea': injuryArea,
      'phase': phase,
      'painBefore': painBefore,
      'painAfter': painAfter,
      'exercisesCompleted': exercisesCompleted,
      'durationMinutes': durationMinutes,
      'isCompleted': isCompleted,
    };
  }

  factory WorkoutLog.fromMap(Map<String, dynamic> map) {
    return WorkoutLog(
      id: map['id'] ?? '',
      date: DateTime.parse(map['date'] ?? DateTime.now().toIso8601String()),
      injuryArea: map['injuryArea'] ?? '',
      phase: map['phase'] ?? '',
      painBefore: map['painBefore'] ?? 0,
      painAfter: map['painAfter'] ?? 0,
      exercisesCompleted: map['exercisesCompleted'] ?? 0,
      durationMinutes: map['durationMinutes'] ?? 0,
      isCompleted: map['isCompleted'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory WorkoutLog.fromJson(String source) => WorkoutLog.fromMap(json.decode(source));
}

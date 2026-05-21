import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class RecoveryRepository {
  final SharedPreferences _prefs;

  RecoveryRepository(this._prefs);

  static const String _keyUserProfile = 'user_profile';
  static const String _keyInjuryProfile = 'injury_profile';
  static const String _keyWorkoutLogs = 'workout_logs';

  // --- Profile Operations ---
  Future<bool> saveUserProfile(UserProfile profile) async {
    return await _prefs.setString(_keyUserProfile, profile.toJson());
  }

  UserProfile? getUserProfile() {
    final String? data = _prefs.getString(_keyUserProfile);
    if (data == null) return null;
    try {
      return UserProfile.fromJson(data);
    } catch (_) {
      return null;
    }
  }

  Future<bool> saveInjuryProfile(InjuryProfile profile) async {
    return await _prefs.setString(_keyInjuryProfile, profile.toJson());
  }

  InjuryProfile? getInjuryProfile() {
    final String? data = _prefs.getString(_keyInjuryProfile);
    if (data == null) return null;
    try {
      return InjuryProfile.fromJson(data);
    } catch (_) {
      return null;
    }
  }

  Future<void> resetRecoveryProfile() async {
    await _prefs.remove(_keyInjuryProfile);
    // Don't remove logs, so user can see their total history across different injuries!
  }

  Future<void> clearAll() async {
    await _prefs.remove(_keyUserProfile);
    await _prefs.remove(_keyInjuryProfile);
    await _prefs.remove(_keyWorkoutLogs);
  }

  // --- Workout Log Operations ---
  List<WorkoutLog> getWorkoutLogs() {
    final String? data = _prefs.getString(_keyWorkoutLogs);
    if (data == null) {
      // Seed mock history so the Line Chart immediately shows a stunning recovery curve!
      final seeded = _seedMockLogs();
      saveWorkoutLogs(seeded);
      return seeded;
    }
    try {
      final List<dynamic> list = json.decode(data);
      return list.map((e) => WorkoutLog.fromMap(e)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<bool> saveWorkoutLogs(List<WorkoutLog> logs) async {
    final List<Map<String, dynamic>> data = logs.map((e) => e.toMap()).toList();
    return await _prefs.setString(_keyWorkoutLogs, json.encode(data));
  }

  Future<void> addWorkoutLog(WorkoutLog log) async {
    final logs = getWorkoutLogs();
    logs.add(log);
    await saveWorkoutLogs(logs);
    
    // Evaluate if the user is ready to progress to the next phase based on pain feedback!
    await _evaluatePhaseProgression();
  }

  // Auto-progress user if their recent logs show consistent recovery and low pain
  Future<void> _evaluatePhaseProgression() async {
    final injury = getInjuryProfile();
    if (injury == null) return;

    final logs = getWorkoutLogs().where((l) => l.injuryArea == injury.injuryArea).toList();
    if (logs.length < 3) return; // Need at least 3 completed logs to evaluate progression

    // Take the 3 most recent logs
    final recentLogs = logs.sublist(logs.length - 3);
    final averagePainAfter = recentLogs.map((l) => l.painAfter).reduce((a, b) => a + b) / 3;

    String currentPhase = injury.recoveryPhase;
    String newPhase = currentPhase;

    if (currentPhase == "Proteksi" && averagePainAfter <= 6) {
      newPhase = "Mobilitas";
    } else if (currentPhase == "Mobilitas" && averagePainAfter <= 3) {
      newPhase = "Penguatan";
    }

    if (newPhase != currentPhase) {
      final updatedInjury = InjuryProfile(
        injuryArea: injury.injuryArea,
        initialPainLevel: injury.initialPainLevel,
        recoveryPhase: newPhase,
        startedAt: injury.startedAt,
      );
      await saveInjuryProfile(updatedInjury);
    }
  }

  // --- Workout Engine / Exercise Database ---
  DailyWorkoutSession getWorkoutSession(String area, String phase) {
    List<Exercise> exercises = [];
    int duration = 0;

    switch (area) {
      case 'Bahu':
        if (phase == 'Proteksi') {
          exercises = [
            Exercise(
              id: 'sh_p1',
              name: 'Pendulum Shoulder Stretch',
              durationSeconds: 60,
              reps: 1,
              sets: 3,
              description: 'Bungkukkan badan ke depan, topang satu tangan di meja. Biarkan lengan yang cedera tergantung lurus ke bawah, lalu ayunkan perlahan secara melingkar menggunakan gravitasi.',
              equipment: ['Kursi / Meja'],
              animationType: 'pendulum',
            ),
            Exercise(
              id: 'sh_p2',
              name: 'Scapular Squeeze',
              durationSeconds: 5,
              reps: 10,
              sets: 3,
              description: 'Berdiri tegak dengan kedua lengan di sisi tubuh. Tarik bahu ke belakang dan jepit belikat Anda bersamaan perlahan. Tahan 5 detik lalu rileks.',
              equipment: ['Tanpa Alat'],
              animationType: 'scapular',
            ),
            Exercise(
              id: 'sh_p3',
              name: 'Isometric Shoulder External Rotation',
              durationSeconds: 10,
              reps: 5,
              sets: 3,
              description: 'Berdiri menghadap sisi tembok. Tekuk siku 90 derajat, dorong punggung pergelangan tangan ke arah luar menekan dinding secara perlahan. Tahan kontraksi.',
              equipment: ['Tembok'],
              animationType: 'isometric',
            ),
          ];
          duration = 10;
        } else if (phase == 'Mobilitas') {
          exercises = [
            Exercise(
              id: 'sh_m1',
              name: 'Wall Finger Crawls',
              durationSeconds: 15,
              reps: 10,
              sets: 3,
              description: 'Berdiri menghadap tembok. Tempelkan jari-jari tangan ke tembok lalu jalankan jari ke atas perlahan sejauh toleransi nyeri, lalu jalankan kembali ke bawah.',
              equipment: ['Tembok'],
              animationType: 'wall_crawls',
            ),
            Exercise(
              id: 'sh_m2',
              name: 'Towel Internal Rotation Stretch',
              durationSeconds: 30,
              reps: 3,
              sets: 3,
              description: 'Pegang handuk kecil di belakang punggung. Tangan yang sehat menarik handuk ke atas sehingga melatih kelenturan internal rotasi bahu yang sakit di bagian bawah.',
              equipment: ['Handuk'],
              animationType: 'towel_stretch',
            ),
            Exercise(
              id: 'sh_m3',
              name: 'Active Shoulder Abduction',
              durationSeconds: 8,
              reps: 12,
              sets: 3,
              description: 'Mengangkat lengan yang sakit ke samping tubuh secara perlahan hingga setinggi bahu tanpa menggunakan beban tambahan, lalu turunkan dengan terkontrol.',
              equipment: ['Tanpa Alat'],
              animationType: 'abduction',
            ),
          ];
          duration = 12;
        } else {
          exercises = [
            Exercise(
              id: 'sh_s1',
              name: 'Banded External Rotation',
              durationSeconds: 6,
              reps: 12,
              sets: 3,
              description: 'Ikat resistance band pada tiang setinggi siku. Tekuk siku 90 derajat, jepit handuk kecil di ketiak. Tarik karet ke arah luar menjauhi perut.',
              equipment: ['Resistance Band', 'Handuk'],
              animationType: 'banded_ext',
            ),
            Exercise(
              id: 'sh_s2',
              name: 'Prone Y-Raise',
              durationSeconds: 8,
              reps: 10,
              sets: 3,
              description: 'Tidur tengkurap di matras. Bentuk lengan menyerupai huruf Y dengan jempol menghadap ke langit-langit. Angkat kedua tangan menjauhi lantai perlahan.',
              equipment: ['Matras'],
              animationType: 'prone_y',
            ),
            Exercise(
              id: 'sh_s3',
              name: 'Dumbbell/Bottle Scaption',
              durationSeconds: 8,
              reps: 12,
              sets: 3,
              description: 'Genggam botol air atau dumbbell ringan. Angkat lengan ke atas dan luar membentuk sudut 30 derajat dari sumbu tubuh. Fokus pada otot bahu samping.',
              equipment: ['Dumbbell Ringan / Botol Air'],
              animationType: 'scaption',
            ),
          ];
          duration = 15;
        }
        break;

      case 'Lutut':
        if (phase == 'Proteksi') {
          exercises = [
            Exercise(
              id: 'kn_p1',
              name: 'Quad Sets (Paha Depan)',
              durationSeconds: 10,
              reps: 10,
              sets: 3,
              description: 'Duduk selonjor di lantai. Letakkan gulungan handuk kecil di bawah lutut. Tekan lutut ke bawah menekan handuk dan tegangkan otot paha depan. Tahan 10 detik.',
              equipment: ['Handuk Gulung'],
              animationType: 'quad_sets',
            ),
            Exercise(
              id: 'kn_p2',
              name: 'Straight Leg Raise',
              durationSeconds: 6,
              reps: 12,
              sets: 3,
              description: 'Tidur terlentang, tekuk lutut kaki yang sehat. Luruskan kaki yang sakit dan angkat setinggi 30 cm dari lantai secara perlahan. Tahan 2 detik lalu turunkan.',
              equipment: ['Matras'],
              animationType: 'leg_raise',
            ),
            Exercise(
              id: 'kn_p3',
              name: 'Ankle Pumps',
              durationSeconds: 2,
              reps: 20,
              sets: 2,
              description: 'Tidur terlentang atau duduk santai. Gerakkan pergelangan kaki naik (menunjuk ke wajah) dan turun (jinjit) secara dinamis untuk melancarkan sirkulasi darah.',
              equipment: ['Tanpa Alat'],
              animationType: 'ankle_pumps',
            ),
          ];
          duration = 9;
        } else if (phase == 'Mobilitas') {
          exercises = [
            Exercise(
              id: 'kn_m1',
              name: 'Heel Slides',
              durationSeconds: 8,
              reps: 12,
              sets: 3,
              description: 'Tidur terlentang. Seret tumit kaki yang sakit mendekati bokong secara perlahan hingga terasa regangan nyaman di lutut, kemudian kembalikan selonjor.',
              equipment: ['Kaos Kaki / Alas Licin'],
              animationType: 'heel_slides',
            ),
            Exercise(
              id: 'kn_m2',
              name: 'Passive Knee Extension',
              durationSeconds: 60,
              reps: 2,
              sets: 2,
              description: 'Duduk di kursi, letakkan tumit kaki yang sakit di kursi lain di depan Anda. Biarkan gravitasi meluruskan sendi lutut secara pasif selama 60 detik.',
              equipment: ['Dua Kursi'],
              animationType: 'passive_extension',
            ),
            Exercise(
              id: 'kn_m3',
              name: 'Low Step-Ups',
              durationSeconds: 5,
              reps: 10,
              sets: 3,
              description: 'Berdiri di depan tangga pendek atau balok rendah (5-10cm). Melangkah naik dengan kaki yang cedera terlebih dahulu, lalu turun kembali secara bergantian.',
              equipment: ['Anak Tangga Rendah'],
              animationType: 'step_ups',
            ),
          ];
          duration = 11;
        } else {
          exercises = [
            Exercise(
              id: 'kn_s1',
              name: 'Wall Squats with Ball',
              durationSeconds: 10,
              reps: 12,
              sets: 3,
              description: 'Sandarkan punggung ke tembok dengan menaruh bola/bantal di belakang punggung. Turunkan tubuh hingga posisi squat setengah (lutut ditekuk maks 60 derajat).',
              equipment: ['Tembok', 'Bola / Bantal'],
              animationType: 'wall_squat',
            ),
            Exercise(
              id: 'kn_s2',
              name: 'Glute Bridges',
              durationSeconds: 8,
              reps: 15,
              sets: 3,
              description: 'Tidur terlentang dengan lutut ditekuk dan telapak kaki di lantai. Angkat pinggul hingga lurus dengan paha dan badan. Kontraksikan bokong.',
              equipment: ['Matras'],
              animationType: 'glute_bridges',
            ),
            Exercise(
              id: 'kn_s3',
              name: 'Seated Calf Raises',
              durationSeconds: 4,
              reps: 15,
              sets: 3,
              description: 'Duduk tegak di kursi, beri beban ringan di atas paha. Angkat tumit setinggi mungkin (jinjit posisi duduk) untuk memperkuat betis yang menopang lutut.',
              equipment: ['Kursi', 'Beban Ringan / Botol'],
              animationType: 'calf_raises',
            ),
          ];
          duration = 14;
        }
        break;

      case 'Ankle':
        if (phase == 'Proteksi') {
          exercises = [
            Exercise(
              id: 'ak_p1',
              name: 'Ankle Pumps & Circles',
              durationSeconds: 4,
              reps: 20,
              sets: 3,
              description: 'Luruskan kaki. Pompa pergelangan kaki ke atas-bawah lalu putar searah jarum jam dan sebaliknya untuk meredakan bengkak dan menjaga sirkulasi.',
              equipment: ['Tanpa Alat'],
              animationType: 'ankle_circles',
            ),
            Exercise(
              id: 'ak_p2',
              name: 'Towel Scrunches',
              durationSeconds: 10,
              reps: 10,
              sets: 2,
              description: 'Letakkan handuk tipis di lantai. Taruh kaki di atasnya, lalu gunakan jari-jari kaki untuk meremas dan menarik handuk mendekati Anda.',
              equipment: ['Handuk Tipis'],
              animationType: 'towel_scrunches',
            ),
            Exercise(
              id: 'ak_p3',
              name: 'Isometric Eversion',
              durationSeconds: 10,
              reps: 5,
              sets: 3,
              description: 'Posisikan kaki bersebelahan dengan kaki meja. Dorong bagian luar kaki yang cedera ke arah luar menekan kaki meja secara perlahan tanpa bergerak.',
              equipment: ['Kaki Meja / Tembok'],
              animationType: 'isometric_ankle',
            ),
          ];
          duration = 8;
        } else if (phase == 'Mobilitas') {
          exercises = [
            Exercise(
              id: 'ak_m1',
              name: 'Ankle Alphabet',
              durationSeconds: 60,
              reps: 1,
              sets: 2,
              description: 'Angkat kaki sedikit dari lantai. Gunakan ibu jari kaki sebagai pena untuk menulis alfabet A sampai Z di udara. Melatih mobilitas multi-arah.',
              equipment: ['Tanpa Alat'],
              animationType: 'alphabet',
            ),
            Exercise(
              id: 'ak_m2',
              name: 'Gastroc Calf Stretch',
              durationSeconds: 30,
              reps: 3,
              sets: 3,
              description: 'Menghadap tembok, posisikan kaki yang cedera lurus di belakang dengan tumit menempel lantai. Tekuk lutut kaki depan hingga betis belakang terasa meregang.',
              equipment: ['Tembok'],
              animationType: 'calf_stretch',
            ),
            Exercise(
              id: 'ak_m3',
              name: 'Soleus Calf Stretch',
              durationSeconds: 30,
              reps: 3,
              sets: 3,
              description: 'Sama seperti betis regang sebelumnya, tetapi tekuk sedikit lutut kaki belakang Anda. Ini memindahkan regangan ke otot soleus bagian bawah betis.',
              equipment: ['Tembok'],
              animationType: 'soleus_stretch',
            ),
          ];
          duration = 10;
        } else {
          exercises = [
            Exercise(
              id: 'ak_s1',
              name: 'Single-Leg Balance',
              durationSeconds: 30,
              reps: 1,
              sets: 3,
              description: 'Berdiri dengan satu kaki yang cedera. Coba jaga keseimbangan selama 30 detik. Siapkan pegangan kursi terdekat untuk keamanan.',
              equipment: ['Kursi (Pengaman)'],
              animationType: 'single_balance',
            ),
            Exercise(
              id: 'ak_s2',
              name: 'Banded Eversion/Inversion',
              durationSeconds: 6,
              reps: 12,
              sets: 3,
              description: 'Kaitkan resistance band pada kaki yang sehat. Dorong kaki yang cedera ke arah luar (eversion) atau dalam (inversion) melawan beban karet.',
              equipment: ['Resistance Band'],
              animationType: 'banded_ankle',
            ),
            Exercise(
              id: 'ak_s3',
              name: 'Double-Leg Heel Raises',
              durationSeconds: 4,
              reps: 15,
              sets: 3,
              description: 'Berdiri tegak, pegang sandaran kursi. Jinjitlah dengan menopang beban pada kedua kaki perlahan, lalu turunkan tumit ke lantai secara perlahan.',
              equipment: ['Kursi'],
              animationType: 'heel_raises',
            ),
          ];
          duration = 12;
        }
        break;

      case 'Pinggang':
      default:
        if (phase == 'Proteksi') {
          exercises = [
            Exercise(
              id: 'ws_p1',
              name: 'Pelvic Tilts',
              durationSeconds: 8,
              reps: 10,
              sets: 3,
              description: 'Tidur terlentang, tekuk lutut. Kontraksikan otot perut, ratakan punggung bawah sehingga menempel rapat dengan lantai. Tahan beberapa detik.',
              equipment: ['Matras'],
              animationType: 'pelvic_tilts',
            ),
            Exercise(
              id: 'ws_p2',
              name: 'Double Knee to Chest',
              durationSeconds: 30,
              reps: 3,
              sets: 3,
              description: 'Tidur terlentang. Angkat kedua lutut perlahan, pegang di bawah tempurung lutut lalu tarik lembut mendekati dada hingga pinggang bawah meregang nyaman.',
              equipment: ['Matras'],
              animationType: 'knee_to_chest',
            ),
            Exercise(
              id: 'ws_p3',
              name: 'Gluteal Squeezes',
              durationSeconds: 10,
              reps: 10,
              sets: 2,
              description: 'Tidur terlentang atau selonjoran. Kencangkan/kempit otot pantat Anda sekuat mungkin, tahan 10 detik lalu lepaskan perlahan.',
              equipment: ['Tanpa Alat'],
              animationType: 'glute_squeeze',
            ),
          ];
          duration = 8;
        } else if (phase == 'Mobilitas') {
          exercises = [
            Exercise(
              id: 'ws_m1',
              name: 'Cat-Cow Stretch',
              durationSeconds: 8,
              reps: 10,
              sets: 3,
              description: 'Posisi merangkak. Lengkungkan punggung ke atas seperti kucing (Cat) sambil menunduk, lalu lekukkan punggung ke bawah sambil mendongak perlahan (Cow).',
              equipment: ['Matras'],
              animationType: 'cat_cow',
            ),
            Exercise(
              id: 'ws_m2',
              name: 'Bird-Dog Core Stretch',
              durationSeconds: 10,
              reps: 8,
              sets: 3,
              description: 'Posisi merangkak. Luruskan satu tangan ke depan dan kaki berlawanan ke belakang sejajar lantai perlahan. Jaga panggul tetap seimbang.',
              equipment: ['Matras'],
              animationType: 'bird_dog',
            ),
            Exercise(
              id: 'ws_m3',
              name: 'Child\'s Pose',
              durationSeconds: 45,
              reps: 3,
              sets: 1,
              description: 'Duduk bertumpu pada tumit kaki, lebarkan lutut. Rentangkan tangan lurus jauh ke depan di lantai, turunkan dada dan dahi hingga mendekati matras.',
              equipment: ['Matras'],
              animationType: 'child_pose',
            ),
          ];
          duration = 10;
        } else {
          exercises = [
            Exercise(
              id: 'ws_s1',
              name: 'Glute Bridges Strength',
              durationSeconds: 8,
              reps: 12,
              sets: 3,
              description: 'Tidur terlentang, lutut tekuk. Angkat bokong ke atas sejajar bahu dan paha. Tahan di puncak kontraksi selama 3 detik sebelum turun.',
              equipment: ['Matras'],
              animationType: 'glute_bridge_str',
            ),
            Exercise(
              id: 'ws_s2',
              name: 'Modified Knee Forearm Plank',
              durationSeconds: 30,
              reps: 3,
              sets: 3,
              description: 'Posisi plank bertumpu pada kedua siku/lengan bawah, namun lutut tetap menempel lantai sebagai tumpuan kaki. Kencangkan otot core perut.',
              equipment: ['Matras'],
              animationType: 'knee_plank',
            ),
            Exercise(
              id: 'ws_s3',
              name: 'Bird-Dog Holds',
              durationSeconds: 5,
              reps: 12,
              sets: 3,
              description: 'Dari posisi merangkak, julurkan tangan kanan dan kaki kiri lurus. Tahan posisi ini selama 5 detik lalu ganti sisi berlawanan secara bergantian.',
              equipment: ['Matras'],
              animationType: 'bird_dog_hold',
            ),
          ];
          duration = 12;
        }
        break;
    }

    return DailyWorkoutSession(
      id: '${area.toLowerCase()}_${phase.toLowerCase()}',
      title: 'Latihan $area - Fase $phase',
      phase: phase,
      exercises: exercises,
      durationMinutes: duration,
    );
  }

  // --- Seed Mock Recovery History (For premium line charts out of the box) ---
  List<WorkoutLog> _seedMockLogs() {
    final List<WorkoutLog> list = [];
    final now = DateTime.now();
    
    // We mock the user having been on a knee injury recovery path for the past 6 days,
    // starting with high pain and gradually improving (Load Management success visualization)
    final List<int> painBeforeValues = [8, 7, 7, 6, 5, 5];
    final List<int> painAfterValues =  [7, 6, 5, 4, 3, 3];
    final List<String> phases = ["Proteksi", "Proteksi", "Mobilitas", "Mobilitas", "Mobilitas", "Penguatan"];
    
    for (int i = 5; i >= 0; i--) {
      final date = now.subtract(Duration(days: i + 1));
      list.add(WorkoutLog(
        id: 'mock_log_$i',
        date: date,
        injuryArea: 'Lutut',
        phase: phases[5 - i],
        painBefore: painBeforeValues[5 - i],
        painAfter: painAfterValues[5 - i],
        exercisesCompleted: 3,
        durationMinutes: 10 + (5 - i),
        isCompleted: true,
      ));
    }
    
    return list;
  }
}

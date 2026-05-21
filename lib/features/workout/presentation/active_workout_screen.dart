import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme.dart';
import '../../../core/models/models.dart';
import '../../../core/providers/providers.dart';

class ActiveWorkoutScreen extends ConsumerStatefulWidget {
  const ActiveWorkoutScreen({super.key});

  @override
  ConsumerState<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends ConsumerState<ActiveWorkoutScreen> with TickerProviderStateMixin {
  late AnimationController _exercisePlayerController;
  Timer? _timer;
  
  int _currentExerciseIndex = 0;
  int _secondsRemaining = 30;
  bool _isPlaying = false;
  
  // Pain feedback states
  int _painBefore = 5;
  int _painFeedbackValue = 3;
  bool _hasTriggeredFeedback = false;
  bool _isPainWarningTriggered = false;

  @override
  void initState() {
    super.initState();
    // Animated circle simulation of the active workout repetition loop
    _exercisePlayerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    // Fetch pain scale from active injury
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final injury = ref.read(injuryProfileProvider);
      if (injury != null) {
        setState(() {
          _painBefore = injury.initialPainLevel;
          _painFeedbackValue = injury.initialPainLevel;
        });
      }
      _startSession();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _exercisePlayerController.dispose();
    super.dispose();
  }

  void _startSession() {
    final session = ref.read(activeWorkoutSessionProvider);
    if (session == null || session.exercises.isEmpty) return;

    setState(() {
      _secondsRemaining = session.exercises[_currentExerciseIndex].durationSeconds;
      _isPlaying = true;
    });

    _runTimer();
  }

  void _runTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isPlaying) {
        if (_secondsRemaining > 1) {
          setState(() {
            _secondsRemaining--;
          });
        } else {
          _nextStep();
        }
      }
    });
  }

  void _togglePlay() {
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        _exercisePlayerController.repeat(reverse: true);
      } else {
        _exercisePlayerController.stop();
      }
    });
  }

  void _nextStep() {
    final session = ref.read(activeWorkoutSessionProvider);
    if (session == null) return;

    // Trigger pain feedback in the middle (e.g. after the 1st exercise completes)
    if (_currentExerciseIndex == 0 && !_hasTriggeredFeedback) {
      _timer?.cancel();
      _exercisePlayerController.stop();
      setState(() {
        _isPlaying = false;
      });
      _showPainFeedbackPopup();
      return;
    }

    if (_currentExerciseIndex < session.exercises.length - 1) {
      setState(() {
        _currentExerciseIndex++;
        _secondsRemaining = session.exercises[_currentExerciseIndex].durationSeconds;
        _isPlaying = true;
      });
      _exercisePlayerController.repeat(reverse: true);
      _runTimer();
    } else {
      // Completed all exercises!
      _finishWorkout();
    }
  }

  void _finishWorkout() async {
    _timer?.cancel();
    _exercisePlayerController.stop();

    final session = ref.read(activeWorkoutSessionProvider);
    final injury = ref.read(injuryProfileProvider);
    if (session == null || injury == null) return;

    // Build the log entry
    final log = WorkoutLog(
      id: 'log_${DateTime.now().millisecondsSinceEpoch}',
      date: DateTime.now(),
      injuryArea: injury.injuryArea,
      phase: injury.recoveryPhase,
      painBefore: _painBefore,
      painAfter: _painFeedbackValue,
      exercisesCompleted: session.exercises.length - (_isPainWarningTriggered ? 1 : 0), // if skipped 1 exercise
      durationMinutes: session.durationMinutes,
      isCompleted: true,
    );

    // Save in Riverpod
    await ref.read(workoutLogsProvider.notifier).addLog(log);

    if (!mounted) return;

    // Go to summary
    context.go('/workout/summary', extra: {
      'painBefore': _painBefore,
      'painAfter': _painFeedbackValue,
      'completedCount': log.exercisesCompleted,
      'durationMinutes': log.durationMinutes,
    });
  }

  void _showPainFeedbackPopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          final scaleColor = _painFeedbackValue <= 3 
              ? AppTheme.painMild 
              : _painFeedbackValue <= 6 
                  ? AppTheme.painModerate 
                  : AppTheme.painSevere;

          return AlertDialog(
            backgroundColor: AppTheme.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text(
              'Evaluasi Nyeri Real-Time',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Bagaimana tingkat rasa nyeri Anda saat melakukan gerakan tadi?',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, height: 1.4),
                ),
                const SizedBox(height: 24),
                
                // Pain Scale display
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _painFeedbackValue.toString(),
                      style: TextStyle(fontSize: 48, fontWeight: FontWeight.w800, color: scaleColor),
                    ),
                    const Text('/10', style: TextStyle(color: AppTheme.textSecondary, fontSize: 18)),
                  ],
                ),
                const SizedBox(height: 12),

                Slider(
                  value: _painFeedbackValue.toDouble(),
                  min: 1.0,
                  max: 10.0,
                  divisions: 9,
                  activeColor: scaleColor,
                  label: _painFeedbackValue.toString(),
                  onChanged: (val) {
                    setModalState(() {
                      _painFeedbackValue = val.round();
                    });
                    setState(() {
                      _painFeedbackValue = val.round();
                    });
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  _painFeedbackValue >= 7 
                      ? 'Nyeri Hebat! Hentikan jika lemas.' 
                      : _painFeedbackValue >= 4 
                          ? 'Nyeri Sedang. Lakukan perlahan.' 
                          : 'Nyeri Ringan. Teruskan.',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: scaleColor),
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  setState(() {
                    _hasTriggeredFeedback = true;
                  });
                  _evaluatePainResponse();
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                child: const Text('Simpan & Lanjutkan'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _evaluatePainResponse() {
    // If pain is severe (> 6) or spikes significantly by +2 relative to baseline
    final hasPainSpiked = _painFeedbackValue - _painBefore >= 2;
    final isPainSevere = _painFeedbackValue >= 6;

    if (isPainSevere || hasPainSpiked) {
      // Trigger medical safety alert recommending load adaptation
      setState(() {
        _isPainWarningTriggered = true;
      });
      _showPainWarningDialog();
    } else {
      // Safe to proceed
      _nextStep();
    }
  }

  void _showPainWarningDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppTheme.painSevere),
            SizedBox(width: 10),
            Text('Peringatan Keamanan', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'Rasa sakit Anda meningkat secara signifikan. Untuk mencegah cedera semakin parah, sistem menyarankan Anda untuk melewatkan gerakan dengan intensitas tinggi berikutnya dan beristirahat.',
          style: TextStyle(color: AppTheme.textSecondary, height: 1.4, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              // Option A: Skip exercise for safety
              _skipNextIntenseExercise();
            },
            child: const Text('Ya, Lewati Gerakan Intensif', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              // Option B: Continue with caution
              _nextStep();
            },
            child: const Text('Tetap Lanjutkan (Hati-hati)', style: TextStyle(color: AppTheme.textSecondary)),
          ),
        ],
      ),
    );
  }

  void _skipNextIntenseExercise() {
    final session = ref.read(activeWorkoutSessionProvider);
    if (session == null) return;

    if (_currentExerciseIndex < session.exercises.length - 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gerakan berikutnya dilewati demi keselamatan sendi Anda (Load Management).'),
          backgroundColor: AppTheme.painModerate,
        ),
      );
      // Skip 1 movement
      setState(() {
        _currentExerciseIndex = (_currentExerciseIndex + 2 < session.exercises.length) 
            ? _currentExerciseIndex + 2 
            : session.exercises.length - 1;
        _secondsRemaining = session.exercises[_currentExerciseIndex].durationSeconds;
        _isPlaying = true;
      });
      _exercisePlayerController.repeat(reverse: true);
      _runTimer();
    } else {
      _finishWorkout();
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(activeWorkoutSessionProvider);
    if (session == null) return const Scaffold();
    
    final exercise = session.exercises[_currentExerciseIndex];
    final progress = (_currentExerciseIndex + 1) / session.exercises.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(session.title),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () {
              _timer?.cancel();
              context.go('/dashboard');
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Progress Bar
              LinearProgressIndicator(
                value: progress,
                backgroundColor: AppTheme.cardBg,
                valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
                minHeight: 6,
                borderRadius: BorderRadius.circular(3),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Gerakan ${_currentExerciseIndex + 1} dari ${session.exercises.length}',
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                  ),
                  Text(
                    '${(progress * 100).round()}% Selesai',
                    style: const TextStyle(color: AppTheme.primary, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const Spacer(),

              // High-fidelity Mock Video Player Animated Canvas
              Center(
                child: AnimatedBuilder(
                  animation: _exercisePlayerController,
                  builder: (context, child) {
                    final value = _exercisePlayerController.value;
                    return Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.primary.withOpacity(0.2),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primary.withOpacity(0.08 * value),
                            blurRadius: 30 * value,
                            spreadRadius: 5 * value,
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Breath/Tension expansion ring
                          Container(
                            width: 140 + (40 * value),
                            height: 140 + (40 * value),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.primary.withOpacity(0.05 * value),
                            ),
                          ),
                          Icon(
                            exercise.animationType == 'isometric' || exercise.animationType == 'quad_sets'
                                ? Icons.hourglass_empty_rounded
                                : Icons.directions_run_rounded,
                            size: 64,
                            color: Colors.white.withOpacity(0.6 + (0.4 * value)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const Spacer(),

              // Timer Display
              Center(
                child: Column(
                  children: [
                    Text(
                      '${(_secondsRemaining ~/ 60).toString().padLeft(2, '0')}:${(_secondsRemaining % 60).toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      exercise.reps != null ? '${exercise.sets ?? 3} Set x ${exercise.reps} Reps' : 'Latihan Durasi Pasif',
                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Title and details
              Text(
                exercise.name,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                exercise.description,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.4),
              ),
              const Spacer(),

              // Controls Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Back / Stop Button
                  IconButton(
                    icon: const Icon(Icons.skip_previous_rounded, size: 36, color: AppTheme.textSecondary),
                    onPressed: _currentExerciseIndex > 0
                        ? () {
                            setState(() {
                              _currentExerciseIndex--;
                              _secondsRemaining = session.exercises[_currentExerciseIndex].durationSeconds;
                            });
                          }
                        : null,
                  ),

                  // Play / Pause Circle Button
                  GestureDetector(
                    onTap: _togglePlay,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        shape: BoxShape.circle,
                        boxShadow: AppTheme.glowShadow,
                      ),
                      child: Icon(
                        _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                        size: 36,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  // Next Button
                  IconButton(
                    icon: const Icon(Icons.skip_next_rounded, size: 36, color: Colors.white),
                    onPressed: _nextStep,
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

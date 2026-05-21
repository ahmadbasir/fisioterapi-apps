import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme.dart';
import '../../../core/providers/providers.dart';

class WorkoutOverviewScreen extends ConsumerWidget {
  const WorkoutOverviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(activeWorkoutSessionProvider);
    final injury = ref.watch(injuryProfileProvider);

    if (session == null || injury == null) {
      return const Scaffold(
        body: Center(child: Text('Tidak ada latihan aktif saat ini.')),
      );
    }

    // Extract unique equipments
    final equipments = session.exercises.expand((e) => e.equipment).toSet().toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Persiapan Latihan'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => context.go('/dashboard'),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Session Title banner
              Text(
                session.title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Fase ${injury.recoveryPhase} Pemulihan Cedera ${injury.injuryArea}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 24),

              // Metrics row
              Row(
                children: [
                  Expanded(
                    child: _buildMetricTile(
                      context,
                      'Durasi Sesi',
                      '${session.durationMinutes} mnt',
                      Icons.timer_outlined,
                      AppTheme.secondary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricTile(
                      context,
                      'Total Gerakan',
                      '${session.exercises.length} Gerakan',
                      Icons.fitness_center_rounded,
                      AppTheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Equipment box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.04)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Peralatan yang Diperlukan:',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: equipments.map((eq) {
                        return Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.cardBg,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            eq,
                            style: const TextStyle(color: Colors.white, fontSize: 11),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Movements Timeline Header
              const Text(
                'Daftar Gerakan Latihan',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 12),

              // Movements List view
              Expanded(
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  itemCount: session.exercises.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final exercise = session.exercises[index];
                    final repsText = exercise.reps != null ? '${exercise.reps} Reps' : '';
                    final setsText = exercise.sets != null ? '${exercise.sets} Sets' : '';
                    final durationText = '${exercise.durationSeconds}s';
                    final instructionSubtitle = [setsText, repsText, durationText].where((e) => e.isNotEmpty).join(' • ');

                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Number Badge
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: AppTheme.primary.withOpacity(0.12),
                            child: Text(
                              (index + 1).toString(),
                              style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  exercise.name,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  instructionSubtitle,
                                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  exercise.description,
                                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 11, height: 1.3),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Launch Button
              ElevatedButton(
                onPressed: () {
                  context.push('/workout/active');
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                ),
                child: const Text('Mulai Latihan Mandiri'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricTile(BuildContext context, String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

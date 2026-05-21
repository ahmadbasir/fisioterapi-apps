import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme.dart';
import '../../../core/providers/providers.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProfileProvider);
    final injury = ref.watch(injuryProfileProvider);
    final session = ref.watch(activeWorkoutSessionProvider);
    final logs = ref.watch(workoutLogsProvider);

    // Calculate weekly compliance (completed workouts in the last 7 days)
    final now = DateTime.now();
    final recentLogs = logs.where((l) => now.difference(l.date).inDays < 7).toList();
    final weeklyCount = recentLogs.length;

    // Greeting message
    final name = user?.email.split('@').first ?? 'Teman Sehat';
    final capitalizeName = name.isEmpty ? 'Pengguna' : name[0].toUpperCase() + name.substring(1);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Welcome bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Halo, $capitalizeName',
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tetap konsisten, raih pemulihan optimal!',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => context.go('/settings'),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: AppTheme.surface,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.person_rounded, color: AppTheme.primary),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 28),

              // Active Injury Card
              if (injury != null) ...[
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: AppTheme.premiumShadow,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.spa_rounded, size: 14, color: Colors.white),
                                const SizedBox(width: 6),
                                Text(
                                  'Fase ${injury.recoveryPhase}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.query_stats_rounded, color: Colors.white70),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Pemulihan Cedera ${injury.injuryArea}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Nyeri Awal: ${injury.initialPainLevel}/10 • Dimulai sejak ${injury.startedAt.day}/${injury.startedAt.month}/${injury.startedAt.year}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),

              // Today's workout session banner
              Text(
                'Menu Rehabilitasi Hari Ini',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              if (session != null) ...[
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.04)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                session.title,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${session.exercises.length} Gerakan • Durasi ±${session.durationMinutes} menit',
                                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.play_arrow_rounded, color: AppTheme.primary, size: 28),
                          )
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(color: Colors.white10),
                      const SizedBox(height: 12),
                      
                      // Equipment list
                      Row(
                        children: [
                          const Icon(Icons.hardware_rounded, color: AppTheme.painModerate, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Alat: ${session.exercises.expand((e) => e.equipment).toSet().join(", ")}',
                              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      
                      // Start button
                      ElevatedButton(
                        onPressed: () => context.push('/workout/overview'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Mulai Latihan Sekarang'),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(20),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('Silakan pilih cedera Anda terlebih dahulu.'),
                ),
              ],
              const SizedBox(height: 24),

              // Compliance & Stats Section
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withOpacity(0.04)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Kepatuhan Latihan', style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.check_circle_rounded, color: AppTheme.painMild, size: 24),
                              const SizedBox(width: 10),
                              Text(
                                '$weeklyCount Sesi / 7 Hari',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withOpacity(0.04)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Total Terapi', style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.timer_rounded, color: AppTheme.secondary, size: 24),
                              const SizedBox(width: 10),
                              Text(
                                '${logs.length} Sesi Terapi',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context, 0),
    );
  }

  Widget _buildBottomNav(BuildContext context, int activeIndex) {
    return BottomNavigationBar(
      currentIndex: activeIndex,
      backgroundColor: AppTheme.background,
      selectedItemColor: AppTheme.primary,
      unselectedItemColor: AppTheme.textMuted,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      onTap: (index) {
        if (index == 0) return;
        if (index == 1) context.go('/report');
        if (index == 2) context.go('/settings');
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_rounded),
          label: 'Dasbor',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.analytics_rounded),
          label: 'Progres',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings_rounded),
          label: 'Profil',
        ),
      ],
    );
  }
}

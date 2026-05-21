import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme.dart';

class WorkoutSummaryScreen extends StatelessWidget {
  final int painBefore;
  final int painAfter;
  final int completedCount;
  final int durationMinutes;

  const WorkoutSummaryScreen({
    super.key,
    required this.painBefore,
    required this.painAfter,
    required this.completedCount,
    required this.durationMinutes,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate pain level shift
    final painReduction = painBefore - painAfter;
    final isImproved = painReduction > 0;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),

              // Achievement Glowing Icon
              Container(
                alignment: Alignment.center,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.painMild.withOpacity(0.12),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.painMild.withOpacity(0.2),
                        blurRadius: 30,
                        spreadRadius: 2,
                      )
                    ],
                  ),
                  child: const Icon(
                    Icons.emoji_events_rounded,
                    size: 64,
                    color: AppTheme.painMild,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Title
              Text(
                'Sesi Selesai! Kerja Bagus!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Setiap latihan kecil mempercepat kembalinya mobilitas sendi Anda. Anda luar biasa!',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.textSecondary, height: 1.4, fontSize: 13),
              ),
              const SizedBox(height: 36),

              // Achievement Recap Box
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.04)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatColumn('Waktu Terapi', '$durationMinutes mnt'),
                        Container(width: 1, height: 40, color: Colors.white10),
                        _buildStatColumn('Gerakan Selesai', '$completedCount/3'),
                        Container(width: 1, height: 40, color: Colors.white10),
                        _buildStatColumn('Nyeri (VAS)', '$painBefore ➔ $painAfter'),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Divider(color: Colors.white10),
                    const SizedBox(height: 12),
                    
                    // Pain reduction insight
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isImproved ? Icons.trending_down_rounded : Icons.trending_flat_rounded,
                          color: isImproved ? AppTheme.painMild : AppTheme.textSecondary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isImproved
                              ? 'Skala nyeri Anda berkurang $painReduction poin sesudah latihan.'
                              : 'Rasa sakit Anda stabil. Jaga gerakan tetap terkontrol.',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isImproved ? AppTheme.painMild : AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Spacer(),

              // Share option mockup
              OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Pencapaian berhasil disalin! Bagikan ke fisioterapis Anda.'),
                      backgroundColor: AppTheme.primary,
                    ),
                  );
                },
                icon: const Icon(Icons.share_rounded),
                label: const Text('Bagikan Progres Sesi'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 12),

              // Back to dashboard
              ElevatedButton(
                onPressed: () {
                  context.go('/dashboard');
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                ),
                child: const Text('Kembali ke Dasbor'),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Colors.white),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10),
        ),
      ],
    );
  }
}

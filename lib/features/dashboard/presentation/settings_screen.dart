import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme.dart';
import '../../../core/providers/providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProfileProvider);
    final injury = ref.watch(injuryProfileProvider);

    final email = user?.email ?? 'pengguna@fisioterapi.com';
    final age = user?.age ?? 0;
    final weight = user?.weight ?? 0.0;
    final height = user?.height ?? 0.0;
    final activity = user?.activityLevel ?? 'Sedang';

    // Calculate BMI
    double bmi = 0.0;
    if (height > 0) {
      final heightM = height / 100.0;
      bmi = weight / (heightM * heightM);
    }

    String getBmiCategory(double val) {
      if (val < 18.5) return 'Berat Kurang';
      if (val < 25.0) return 'Normal (Ideal)';
      if (val < 30.0) return 'Berat Lebih';
      return 'Obesitas';
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Text(
                'Profil & Pengaturan',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Kelola data kesehatan dan preferensi aplikasi Anda',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 28),

              // Profile overview card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.04)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: const BoxDecoration(
                        color: AppTheme.cardBg,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.person_rounded, color: AppTheme.primary, size: 30),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            email.split('@').first.toUpperCase(),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            email,
                            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Physical stats section
              Text(
                'Data Fisik Anda',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.04)),
                ),
                child: Column(
                  children: [
                    _buildStatRow('Usia', '$age Tahun'),
                    const Divider(color: Colors.white10),
                    _buildStatRow('Tinggi Badan', '${height.round()} cm'),
                    const Divider(color: Colors.white10),
                    _buildStatRow('Berat Badan', '${weight.round()} kg'),
                    const Divider(color: Colors.white10),
                    _buildStatRow('Indeks Massa Tubuh (BMI)', '${bmi.toStringAsFixed(1)} (${getBmiCategory(bmi)})'),
                    const Divider(color: Colors.white10),
                    _buildStatRow('Tingkat Aktivitas', activity),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Injury Settings Section
              Text(
                'Program Pemulihan Aktif',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.04)),
                ),
                child: injury != null
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Cedera ${injury.injuryArea}',
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'Fase ${injury.recoveryPhase}',
                                  style: const TextStyle(color: AppTheme.primary, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Jika Anda mengalami cedera baru atau salah memilih lokasi cedera, Anda dapat mengatur ulang status pemulihan aktif Anda.',
                            style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, height: 1.4),
                          ),
                          const SizedBox(height: 20),
                          
                          // Reset active injury
                          ElevatedButton.icon(
                            onPressed: () {
                              _showResetDialog(context, ref);
                            },
                            icon: const Icon(Icons.refresh_rounded, size: 18),
                            label: const Text('Atur Ulang Status Pemulihan'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.painModerate,
                              minimumSize: const Size.fromHeight(48),
                            ),
                          ),
                        ],
                      )
                    : const Text('Belum ada program pemulihan yang aktif.'),
              ),
              const SizedBox(height: 32),

              // Sign Out
              ElevatedButton.icon(
                onPressed: () {
                  ref.read(userProfileProvider.notifier).logout();
                  // router handles redirection to login
                },
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Keluar dari Akun'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.painSevere.withOpacity(0.12),
                  foregroundColor: AppTheme.painSevere,
                  side: const BorderSide(color: AppTheme.painSevere, width: 1.5),
                  minimumSize: const Size.fromHeight(50),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context, 2),
    );
  }

  void _showResetDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Atur Ulang Pemulihan?'),
        content: const Text(
          'Ini akan menghapus area cedera dan tingkat keparahan saat ini. Anda harus melakukan pengisian ulang kuesioner Red Flags. Riwayat log harian Anda tetap tersimpan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(injuryProfileProvider.notifier).resetInjury();
              // Router guard automatically redirects to '/triage/body-map' since injury is null!
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.painSevere),
            child: const Text('Ya, Atur Ulang'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13)),
        ],
      ),
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
        if (index == 2) return;
        if (index == 0) context.go('/dashboard');
        if (index == 1) context.go('/report');
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

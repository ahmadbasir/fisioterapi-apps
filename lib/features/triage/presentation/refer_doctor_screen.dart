import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme.dart';

class ReferDoctorScreen extends StatelessWidget {
  const ReferDoctorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              
              // Warning Icon glowing
              Container(
                alignment: Alignment.center,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.painSevere.withOpacity(0.12),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.painSevere.withOpacity(0.2),
                        blurRadius: 30,
                        spreadRadius: 2,
                      )
                    ],
                  ),
                  child: const Icon(
                    Icons.warning_rounded,
                    size: 64,
                    color: AppTheme.painSevere,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              Text(
                'Perhatian: Diperlukan Evaluasi Medis!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Berdasarkan kuesioner awal yang Anda isi, cedera Anda tergolong berisiko tinggi dan membutuhkan evaluasi klinis langsung oleh tenaga kesehatan profesional.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),

              // Recommendations Box
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.04)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Rekomendasi Penanganan:',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    _buildRecommendationRow(
                      Icons.local_hospital_rounded,
                      'Kunjungi Spesialis Rehabilitasi Medis',
                      'Konsultasi ke Dokter Sp.KFR atau Orthopedi terdekat.',
                    ),
                    const SizedBox(height: 12),
                    _buildRecommendationRow(
                      Icons.cancel_presentation_rounded,
                      'Jangan Memaksakan Latihan',
                      'Latihan fisik intens pada sendi berisiko memperparah robekan tendon atau ligamen.',
                    ),
                    const SizedBox(height: 12),
                    _buildRecommendationRow(
                      Icons.phone_in_talk_rounded,
                      'Layanan Ambulans Gawat Darurat',
                      'Hubungi Hotline 119 jika Anda mengalami nyeri tak tertahankan pasca trauma.',
                    ),
                  ],
                ),
              ),
              
              const Spacer(),

              // Export/Print Triage Report mockup
              OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Laporan Triage diekspor! Silakan tunjukkan PDF ini ke dokter Anda.'),
                      backgroundColor: AppTheme.primary,
                    ),
                  );
                },
                icon: const Icon(Icons.picture_as_pdf_rounded),
                label: const Text('Ekspor Laporan Triage (PDF)'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 12),

              // Reset & Go back button
              ElevatedButton(
                onPressed: () {
                  // Go back to selection so they can fix incorrect selections
                  context.go('/triage/body-map');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.cardBg,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                ),
                child: const Text('Kembali ke Pemilihan Sendi', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecommendationRow(IconData icon, String title, String desc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppTheme.painModerate, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11, height: 1.3),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

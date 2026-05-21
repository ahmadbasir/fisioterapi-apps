import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme.dart';
import '../../../core/providers/providers.dart';

class DisclaimerScreen extends ConsumerStatefulWidget {
  const DisclaimerScreen({super.key});

  @override
  ConsumerState<DisclaimerScreen> createState() => _DisclaimerScreenState();
}

class _DisclaimerScreenState extends ConsumerState<DisclaimerScreen> {
  bool _isAccepted = false;
  bool _isLoading = false;

  void _agree() async {
    if (!_isAccepted) return;

    setState(() {
      _isLoading = true;
    });

    await ref.read(userProfileProvider.notifier).acceptDisclaimer();

    setState(() {
      _isLoading = false;
    });

    // Router automatically catches the updated profile disclaimer flag and forwards to '/triage/body-map'
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Disclaimer'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Security Icon
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.painModerate.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.gavel_rounded,
                    size: 40,
                    color: AppTheme.painModerate,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Pernyataan Keamanan Medis',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Scrollable Legal/Medical text box
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: Scrollbar(
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(right: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDisclaimerBullet(
                            'Bukan Pengganti Dokter',
                            'Aplikasi ini menyediakan program rehabilitasi mandiri khusus untuk cedera otot/sendi ringan. Ini BUKAN diagnosis medis formal dan bukan pengganti saran dokter profesional.',
                          ),
                          const SizedBox(height: 14),
                          _buildDisclaimerBullet(
                            'Kriteria Cedera Ringan',
                            'Program latihan hanya ditujukan bagi cedera ringan tanpa indikasi serius. Jika Anda mengalami mati rasa hebat, ketidakmampuan menopang berat badan, deformitas sendi, atau rasa sakit setelah trauma berat, segera hubungi dokter.',
                          ),
                          const SizedBox(height: 14),
                          _buildDisclaimerBullet(
                            'Load Management & Respon Nyeri',
                            'Saat melakukan latihan, Anda wajib memantau tingkat nyeri (VAS Scale). Jika rasa nyeri melebihi batas toleransi Anda (> 5 dari 10), Anda wajib menghentikan gerakan dan memilih opsi modifikasi beban.',
                          ),
                          const SizedBox(height: 14),
                          _buildDisclaimerBullet(
                            'Batasan Tanggung Jawab',
                            'Dengan menyetujui, Anda bertanggung jawab penuh atas pelaksanaan gerakan yang Anda lakukan dan membebaskan pihak pengembang dari risiko medis yang muncul akibat kelalaian pembacaan instruksi.',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Agree checkbox
              CheckboxListTile(
                value: _isAccepted,
                onChanged: (val) {
                  setState(() {
                    _isAccepted = val ?? false;
                  });
                },
                activeColor: AppTheme.primary,
                checkColor: Colors.white,
                contentPadding: EdgeInsets.zero,
                title: Text(
                  'Saya mengonfirmasi bahwa cedera saya bersifat RINGAN dan menyetujui semua ketentuan medis di atas.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: _isAccepted ? Colors.white : AppTheme.textSecondary,
                    height: 1.4,
                  ),
                ),
                controlAffinity: ListTileControlAffinity.leading,
              ),
              const SizedBox(height: 24),

              // Agree Button
              ElevatedButton(
                onPressed: _isAccepted ? _agree : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isAccepted ? AppTheme.primary : AppTheme.surface,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Saya Mengerti & Setuju'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDisclaimerBullet(String title, String desc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.check_circle_outline_rounded,
              color: AppTheme.painModerate,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          desc,
          style: const TextStyle(
            fontSize: 13,
            color: AppTheme.textSecondary,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme.dart';
import '../../../core/providers/providers.dart';

class RedFlagsScreen extends ConsumerStatefulWidget {
  final String injuryArea;

  const RedFlagsScreen({super.key, required this.injuryArea});

  @override
  ConsumerState<RedFlagsScreen> createState() => _RedFlagsScreenState();
}

class _RedFlagsScreenState extends ConsumerState<RedFlagsScreen> {
  // Red Flag questions state
  bool _flagDeformity = false;
  bool _flagInabilityToBear = false;
  bool _flagNumbness = false;
  bool _flagTrauma = false;

  // Pain scale VAS (1 to 10)
  double _painLevel = 5.0;

  bool _isAnyRedFlagChecked() {
    return _flagDeformity || _flagInabilityToBear || _flagNumbness || _flagTrauma;
  }

  // Helper to get color and description based on pain level
  Color _getPainColor(double level) {
    if (level <= 3.0) return AppTheme.painMild;
    if (level <= 6.0) return AppTheme.painModerate;
    return AppTheme.painSevere;
  }

  String _getPainText(double level) {
    if (level <= 3.0) return 'Ringan';
    if (level <= 6.0) return 'Sedang';
    return 'Hebat / Akut';
  }

  String _getPainActionText(double level) {
    if (level <= 3.0) return 'Latihan dinilai aman untuk pemulihan mandiri.';
    if (level <= 6.0) return 'Latihan akan difokuskan pada pemulihan mobilitas sendi dahulu.';
    return 'Latihan akan dimulai dengan proteksi ketat & pengompresan es.';
  }

  String _getPainEmoji(double level) {
    if (level <= 3.0) return '😊'; // Smiling
    if (level <= 6.0) return '😐'; // Neutral
    return '😢'; // Pained
  }

  void _processTriage() async {
    if (_isAnyRedFlagChecked()) {
      // Direct hard block and route to Doctor Referral
      context.go('/triage/refer');
    } else {
      // Save injury profile which calculates the correct rehab phase
      await ref.read(injuryProfileProvider.notifier).setInjury(
        widget.injuryArea,
        _painLevel.round(),
      );
      // The router takes care of moving to dashboard since we have active injury now
      if (!mounted) return;
      context.go('/dashboard');
    }
  }

  Widget _buildRedFlagCheck(String title, String subtitle, bool value, ValueChanged<bool?> onChanged) {
    return Container(
      decoration: BoxDecoration(
        color: value ? AppTheme.painSevere.withOpacity(0.06) : AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: value ? AppTheme.painSevere.withOpacity(0.5) : Colors.white.withOpacity(0.04),
          width: 1.5,
        ),
      ),
      child: CheckboxListTile(
        value: value,
        onChanged: onChanged,
        activeColor: AppTheme.painSevere,
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            subtitle,
            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.3),
          ),
        ),
        controlAffinity: ListTileControlAffinity.leading,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activePainColor = _getPainColor(_painLevel);

    return Scaffold(
      appBar: AppBar(
        title: Text('Pemeriksaan ${widget.injuryArea}'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Warning
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.primary.withOpacity(0.1)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, color: AppTheme.primary, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Silakan jawab sejujurnya untuk memastikan program pemulihan aman dijalankan.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Section 1: Red Flags Check list
              Text(
                '1. Apakah Anda Mengalami Gejala Ini?',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),

              _buildRedFlagCheck(
                'Perubahan Bentuk Sendi (Deformitas)',
                'Tulang terlihat bergeser, membengkok tidak wajar, atau ada tonjolan tulang aneh.',
                _flagDeformity,
                (val) => setState(() => _flagDeformity = val ?? false),
              ),
              const SizedBox(height: 12),
              _buildRedFlagCheck(
                'Hilang Kemampuan Menahan Beban',
                'Sama sekali tidak bisa berdiri, menapakkan kaki, atau memegang barang karena lemas/sakit ekstrim.',
                _flagInabilityToBear,
                (val) => setState(() => _flagInabilityToBear = val ?? false),
              ),
              const SizedBox(height: 12),
              _buildRedFlagCheck(
                'Mati Rasa / Kebas Hebat',
                'Ada rasa kesemutan hebat, kebas/baal, atau ujung jari kaki/tangan terasa sedingin es.',
                _flagNumbness,
                (val) => setState(() => _flagNumbness = val ?? false),
              ),
              const SizedBox(height: 12),
              _buildRedFlagCheck(
                'Nyeri Pasca Benturan Hebat',
                'Cedera disebabkan kecelakaan parah, jatuh tinggi, disertai bengkak ekstrim langsung dalam beberapa menit.',
                _flagTrauma,
                (val) => setState(() => _flagTrauma = val ?? false),
              ),
              const SizedBox(height: 32),

              // Section 2: Pain Scale VAS Slider
              Text(
                '2. Berapa Skala Nyeri Anda Saat Ini?',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),

              // Visual representation of VAS Pain scale
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.04)),
                ),
                child: Column(
                  children: [
                    // Dynamic feedback row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Visual Analog Scale (VAS)',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  _painLevel.round().toString(),
                                  style: TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.w800,
                                    color: activePainColor,
                                  ),
                                ),
                                const Text('/10', style: TextStyle(color: AppTheme.textSecondary, fontSize: 16)),
                              ],
                            ),
                          ],
                        ),
                        // Animated face reaction mock
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: activePainColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: activePainColor.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              Text(
                                _getPainEmoji(_painLevel),
                                style: const TextStyle(fontSize: 24),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _getPainText(_painLevel),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: activePainColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Slider
                    Slider(
                      value: _painLevel,
                      min: 1.0,
                      max: 10.0,
                      divisions: 9,
                      activeColor: activePainColor,
                      label: _painLevel.round().toString(),
                      onChanged: (val) {
                        setState(() {
                          _painLevel = val;
                        });
                      },
                    ),
                    // Labels row
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Min (1)', style: TextStyle(fontSize: 10, color: AppTheme.painMild)),
                          Text('Sedang (5)', style: TextStyle(fontSize: 10, color: AppTheme.painModerate)),
                          Text('Maks (10)', style: TextStyle(fontSize: 10, color: AppTheme.painSevere)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: Colors.white10),
                    const SizedBox(height: 8),
                    // Pain action tip
                    Text(
                      _getPainActionText(_painLevel),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.4),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Action Buttons
              if (_isAnyRedFlagChecked()) ...[
                // Danger Button - Redirect to Doctor
                ElevatedButton(
                  onPressed: _processTriage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.painSevere,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shadowColor: AppTheme.painSevere.withOpacity(0.3),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.white),
                      SizedBox(width: 10),
                      Text('Evaluasi Keamanan Cedera'),
                    ],
                  ),
                ),
              ] else ...[
                // Safe Activation Button
                ElevatedButton(
                  onPressed: _processTriage,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                  ),
                  child: const Text('Aktifkan Program Pemulihan'),
                ),
              ],
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

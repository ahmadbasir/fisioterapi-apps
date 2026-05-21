import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme.dart';
import '../../../core/models/models.dart';
import '../../../core/providers/providers.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  
  String _selectedActivity = 'Sedang'; // Default to Moderate
  bool _isLoading = false;

  @override
  void dispose() {
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final currentUser = ref.read(userProfileProvider);
    if (currentUser != null) {
      final updatedProfile = UserProfile(
        uid: currentUser.uid,
        email: currentUser.email,
        age: int.parse(_ageController.text.trim()),
        weight: double.parse(_weightController.text.trim()),
        height: double.parse(_heightController.text.trim()),
        activityLevel: _selectedActivity,
        isDisclaimerAccepted: false, // Remains false until accepted next
      );

      await ref.read(userProfileProvider.notifier).saveProfile(updatedProfile);
    }

    setState(() {
      _isLoading = false;
    });

    // Router automatically catches the profile update and forwards to '/disclaimer'
  }

  Widget _buildActivityCard(String level, String label, String desc, IconData icon) {
    final isSelected = _selectedActivity == level;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedActivity = level;
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary.withOpacity(0.12) : AppTheme.surface,
          border: Border.all(
            color: isSelected ? AppTheme.primary : Colors.white.withOpacity(0.08),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected ? AppTheme.premiumShadow : [],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primary : AppTheme.cardBg,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : AppTheme.textSecondary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isSelected ? Colors.white : AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    desc,
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected ? AppTheme.textPrimary.withOpacity(0.8) : AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lengkapi Profil Fisik'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Bantu kami memahami fisik Anda',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Data fisik digunakan untuk menentukan program rehabilitasi yang aman bagi sendi Anda.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 32),

                // Age, Weight, Height Fields
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _ageController,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Usia',
                          suffixText: 'thn',
                          contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 18),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Harus diisi';
                          final val = int.tryParse(value);
                          if (val == null || val < 10 || val > 100) return '10-100 tahun';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _heightController,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Tinggi',
                          suffixText: 'cm',
                          contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 18),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Harus diisi';
                          final val = double.tryParse(value);
                          if (val == null || val < 100 || val > 250) return '100-250 cm';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _weightController,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        decoration: const InputDecoration(
                          labelText: 'Berat',
                          suffixText: 'kg',
                          contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 18),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Harus diisi';
                          final val = double.tryParse(value);
                          if (val == null || val < 30 || val > 200) return '30-200 kg';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Activity Level Header
                Text(
                  'Tingkat Aktivitas Harian',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                // Activity Cards
                _buildActivityCard(
                  'Rendah',
                  'Rendah (Sedentary)',
                  'Bekerja di balik meja, jarang berolahraga',
                  Icons.airline_seat_recline_normal_rounded,
                ),
                const SizedBox(height: 12),
                _buildActivityCard(
                  'Sedang',
                  'Sedang (Aktif Ringan)',
                  'Jalan kaki harian, olahraga 1-2 kali seminggu',
                  Icons.directions_walk_rounded,
                ),
                const SizedBox(height: 12),
                _buildActivityCard(
                  'Tinggi',
                  'Tinggi (Sering Olahraga)',
                  'Pekerja fisik berat, atletis, latihan 4+ kali seminggu',
                  Icons.directions_run_rounded,
                ),
                const SizedBox(height: 48),

                // Save Profile Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _save,
                  style: ElevatedButton.styleFrom(
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
                      : const Text('Simpan & Lanjutkan'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

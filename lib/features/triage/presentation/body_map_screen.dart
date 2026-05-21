import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme.dart';

class BodyMapSelectionScreen extends StatefulWidget {
  const BodyMapSelectionScreen({super.key});

  @override
  State<BodyMapSelectionScreen> createState() => _BodyMapSelectionScreenState();
}

class _BodyMapSelectionScreenState extends State<BodyMapSelectionScreen> {
  String? _selectedArea;

  final List<InjuryAreaCard> _areas = [
    InjuryAreaCard(
      name: 'Bahu',
      englishName: 'Shoulder',
      description: 'Nyeri angkat lengan, kaku sendi putar, cidera cuff rotator.',
      icon: Icons.accessibility_new_rounded,
    ),
    InjuryAreaCard(
      name: 'Pinggang',
      englishName: 'Waist / Lower Back',
      description: 'Nyeri punggung bawah akibat postur buruk, tegang otot lumbar.',
      icon: Icons.airline_seat_flat_angled_rounded,
    ),
    InjuryAreaCard(
      name: 'Lutut',
      englishName: 'Knee',
      description: 'Nyeri tempurung lutut, cedera tendon patella ringan.',
      icon: Icons.directions_run_rounded,
    ),
    InjuryAreaCard(
      name: 'Ankle',
      englishName: 'Ankle / Pergelangan Kaki',
      description: 'Keseleo ringan (sprain), bengkak ringan sisi luar.',
      icon: Icons.directions_walk_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Area Cedera'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Di mana titik rasa sakit Anda?',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Pilih salah satu area utama untuk memulai pemeriksaan red flags dan merumuskan program rehabilitasi.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 28),

              // Anatomy outline preview panel
              Container(
                padding: const EdgeInsets.all(16),
                height: 140,
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.04)),
                ),
                child: Row(
                  children: [
                    // Anatomy graphic mock
                    Container(
                      width: 80,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppTheme.cardBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Icon(Icons.accessibility_rounded, size: 50, color: AppTheme.textMuted),
                          if (_selectedArea == 'Bahu')
                            const Positioned(top: 20, child: CircleAvatar(radius: 8, backgroundColor: AppTheme.painSevere)),
                          if (_selectedArea == 'Pinggang')
                            const Positioned(top: 42, child: CircleAvatar(radius: 8, backgroundColor: AppTheme.painSevere)),
                          if (_selectedArea == 'Lutut')
                            const Positioned(bottom: 25, child: CircleAvatar(radius: 8, backgroundColor: AppTheme.painSevere)),
                          if (_selectedArea == 'Ankle')
                            const Positioned(bottom: 10, child: CircleAvatar(radius: 8, backgroundColor: AppTheme.painSevere)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedArea == null 
                                ? 'Belum Ada Pilihan' 
                                : 'Area Terpilih: $_selectedArea',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _selectedArea == null 
                                ? 'Ketuk salah satu kartu di bawah untuk meninjau detail cedera.' 
                                : 'Selanjutnya kami akan menanyakan 4 kuesioner red flags untuk menilai kelayakan latihan.',
                            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Grid-list of cards
              Expanded(
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  itemCount: _areas.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final area = _areas[index];
                    final isSelected = _selectedArea == area.name;
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedArea = area.name;
                        });
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected ? AppTheme.primary.withOpacity(0.08) : AppTheme.surface,
                          border: Border.all(
                            color: isSelected ? AppTheme.primary : Colors.white.withOpacity(0.05),
                            width: isSelected ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(16),
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
                                area.icon,
                                color: isSelected ? Colors.white : AppTheme.textSecondary,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        area.name,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        '(${area.englishName})',
                                        style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    area.description,
                                    style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.4),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Forward Button
              ElevatedButton(
                onPressed: _selectedArea == null
                    ? null
                    : () {
                        context.push('/triage/assessment/$_selectedArea');
                      },
                child: const Text('Lanjutkan Pemeriksaan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class InjuryAreaCard {
  final String name;
  final String englishName;
  final String description;
  final IconData icon;

  InjuryAreaCard({
    required this.name,
    required this.englishName,
    required this.description,
    required this.icon,
  });
}

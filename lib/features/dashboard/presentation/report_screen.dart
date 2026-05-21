import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../app/theme.dart';
import '../../../core/providers/providers.dart';

class ReportScreen extends ConsumerWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logs = ref.watch(workoutLogsProvider);

    // Keep only the last 7 logs for the line chart to avoid overcrowding
    final chartLogs = logs.length > 7 ? logs.sublist(logs.length - 7) : logs;

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
                'Laporan Progres',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Rekam jejak pemulihan cedera Anda',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 24),

              // Interactive fl_chart Line Chart Card
              Text(
                'Tren Skala Nyeri (VAS Scale)',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.fromLTRB(10, 20, 20, 16),
                height: 280,
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.04)),
                ),
                child: chartLogs.isEmpty
                    ? const Center(child: Text('Belum ada riwayat latihan.'))
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Legend
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildLegendItem('Sebelum Latihan', AppTheme.painSevere, isDashed: true),
                              const SizedBox(width: 20),
                              _buildLegendItem('Sesudah Latihan', AppTheme.painMild, isDashed: false),
                            ],
                          ),
                          const SizedBox(height: 20),
                          // Line Chart View
                          Expanded(
                            child: LineChart(
                              LineChartData(
                                gridData: FlGridData(
                                  show: true,
                                  drawVerticalLine: false,
                                  getDrawingHorizontalLine: (value) => FlLine(
                                    color: Colors.white.withOpacity(0.05),
                                    strokeWidth: 1,
                                  ),
                                ),
                                titlesData: FlTitlesData(
                                  show: true,
                                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      interval: 2,
                                      getTitlesWidget: (value, meta) {
                                        return Text(
                                          value.toInt().toString(),
                                          style: const TextStyle(color: AppTheme.textMuted, fontSize: 10),
                                        );
                                      },
                                      reservedSize: 22,
                                    ),
                                  ),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 28,
                                      interval: 1,
                                      getTitlesWidget: (value, meta) {
                                        final index = value.toInt();
                                        if (index >= 0 && index < chartLogs.length) {
                                          final log = chartLogs[index];
                                          return Padding(
                                            padding: const EdgeInsets.only(top: 8.0),
                                            child: Text(
                                              '${log.date.day}/${log.date.month}',
                                              style: const TextStyle(color: AppTheme.textMuted, fontSize: 9),
                                            ),
                                          );
                                        }
                                        return const SizedBox();
                                      },
                                    ),
                                  ),
                                ),
                                borderData: FlBorderData(show: false),
                                minX: 0,
                                maxX: (chartLogs.length - 1).toDouble(),
                                minY: 0,
                                maxY: 10,
                                lineBarsData: [
                                  // Line for Pain BEFORE
                                  LineChartBarData(
                                    spots: chartLogs.asMap().entries.map((e) {
                                      return FlSpot(e.key.toDouble(), e.value.painBefore.toDouble());
                                    }).toList(),
                                    isCurved: true,
                                    color: AppTheme.painSevere,
                                    dashArray: [5, 5],
                                    barWidth: 2,
                                    isStrokeCapRound: true,
                                    dotData: FlDotData(
                                      show: true,
                                      getDotPainter: (spot, percent, barData, index) =>
                                          FlDotCirclePainter(radius: 3, color: AppTheme.painSevere),
                                    ),
                                  ),
                                  // Line for Pain AFTER
                                  LineChartBarData(
                                    spots: chartLogs.asMap().entries.map((e) {
                                      return FlSpot(e.key.toDouble(), e.value.painAfter.toDouble());
                                    }).toList(),
                                    isCurved: true,
                                    color: AppTheme.painMild,
                                    barWidth: 3,
                                    isStrokeCapRound: true,
                                    dotData: FlDotData(
                                      show: true,
                                      getDotPainter: (spot, percent, barData, index) =>
                                          FlDotCirclePainter(radius: 4, color: AppTheme.painMild),
                                    ),
                                    belowBarData: BarAreaData(
                                      show: true,
                                      color: AppTheme.painMild.withOpacity(0.08),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
              const SizedBox(height: 24),

              // Calendar Consistency
              Text(
                'Kalender Kepatuhan Sesi',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.04)),
                ),
                child: Column(
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Riwayat 14 Hari Terakhir', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
                        Icon(Icons.calendar_month_rounded, color: AppTheme.primary, size: 18),
                      ],
                    ),
                    const SizedBox(height: 18),
                    // Grid mapping last 14 days
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 14,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childAspectRatio: 1.0,
                      ),
                      itemBuilder: (context, index) {
                        // Date of 14 - index days ago
                        final date = DateTime.now().subtract(Duration(days: 13 - index));
                        // Check if a completed log exists for this date
                        final completed = logs.any((l) =>
                            l.date.year == date.year &&
                            l.date.month == date.month &&
                            l.date.day == date.day &&
                            l.isCompleted);

                        return Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: completed ? AppTheme.painMild.withOpacity(0.15) : AppTheme.cardBg,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: completed ? AppTheme.painMild : Colors.white.withOpacity(0.05),
                              width: completed ? 1.5 : 1,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                date.day.toString(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: completed ? Colors.white : AppTheme.textSecondary,
                                ),
                              ),
                              if (completed)
                                const Icon(Icons.check, size: 10, color: AppTheme.painMild),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Historic Log details
              Text(
                'Riwayat Log Sesi',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: logs.length,
                separatorBuilder: (context, index) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final log = logs[logs.length - 1 - index]; // Descending order
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.painMild.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.check_rounded, color: AppTheme.painMild, size: 18),
                            ),
                            const SizedBox(width: 14),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Sesi Cedera ${log.injuryArea}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Fase ${log.phase} • ${log.date.day}/${log.date.month}/${log.date.year}',
                                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Nyeri: ${log.painBefore} ➔ ${log.painAfter}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${log.durationMinutes} menit',
                              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context, 1),
    );
  }

  Widget _buildLegendItem(String label, Color color, {required bool isDashed}) {
    return Row(
      children: [
        Container(
          width: 18,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
        ),
      ],
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
        if (index == 1) return;
        if (index == 0) context.go('/dashboard');
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

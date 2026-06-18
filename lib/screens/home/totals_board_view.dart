import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../domain/log_models.dart';
import '../../domain/logbook_repository.dart';
import '../../domain/reference_data.dart';
import '../../theme/log_palette.dart';
import '../../theme/log_type.dart';
import '../../widgets/document_card.dart';
import '../../widgets/hours_readout.dart';
import '../../widgets/wings_ring.dart';

class TotalsBoardView extends StatelessWidget {
  final LogbookRepository repo;
  const TotalsBoardView({super.key, required this.repo});

  @override
  Widget build(BuildContext context) {
    final totals = repo.totals();
    if (totals.flights == 0) {
      return _empty();
    }

    final byCategory = repo.totalsByCategory()
      ..sort((a, b) => b.value.total.compareTo(a.value.total));

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
      children: [
        DocumentCard(
          crest: true,
          child: Row(
            children: [
              WingsRing(
                size: 96,
                progress: _ratio(totals.pic, totals.total),
                stroke: 9,
                child: HoursReadoutMini(hours: totals.total, caption: 'total'),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Career totals', style: LogType.heading()),
                    const SizedBox(height: 10),
                    _line('PIC', totals.pic),
                    _line('Dual received', totals.dualReceived),
                    _line('Cross-country', totals.crossCountry),
                    _line('Night', totals.nightTime),
                    _line('Instrument', totals.instrument),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        DocumentCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Hours by category', style: LogType.heading()),
              const SizedBox(height: 18),
              SizedBox(
                height: 188,
                child: _CategoryChart(data: byCategory),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text('LANDINGS', style: LogType.label(color: LogPalette.inkSoft)),
        const SizedBox(height: 10),
        Row(
          children: [
            _landingCell('Day', totals.dayLandings, Icons.wb_sunny_rounded),
            const SizedBox(width: 12),
            _landingCell(
                'Night', totals.nightLandings, Icons.nightlight_round),
            const SizedBox(width: 12),
            _landingCell('Total', totals.totalLandings, Icons.flight_land_rounded),
          ],
        ),
      ],
    );
  }

  double _ratio(double part, double whole) =>
      whole <= 0 ? 0 : (part / whole).clamp(0, 1).toDouble();

  Widget _line(String label, double hours) => Padding(
        padding: const EdgeInsets.only(bottom: 5),
        child: Row(
          children: [
            Expanded(
              child: Text(label,
                  style: LogType.body(color: LogPalette.inkSoft)),
            ),
            Text(hours.toStringAsFixed(1),
                style: LogType.hours(15, color: LogPalette.ink)),
          ],
        ),
      );

  Widget _landingCell(String label, int value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: LogPalette.sheet,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: LogPalette.rule),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: LogPalette.navy),
            const SizedBox(height: 8),
            Text('$value', style: LogType.hours(22)),
            const SizedBox(height: 2),
            Text(label, style: LogType.caption()),
          ],
        ),
      ),
    );
  }

  Widget _empty() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
      children: [
        DocumentCard(
          crest: true,
          child: Column(
            children: [
              const Icon(Icons.bar_chart_rounded,
                  size: 48, color: LogPalette.navy),
              const SizedBox(height: 14),
              Text('No totals yet', style: LogType.heading()),
              const SizedBox(height: 8),
              Text(
                'Log a flight and your hours will be summed here automatically, broken down by category.',
                style: LogType.body(),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CategoryChart extends StatelessWidget {
  final List<MapEntry<String, LogTotals>> data;
  const _CategoryChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final shown = data.take(6).toList();
    final maxY = shown.isEmpty
        ? 1.0
        : shown
            .map((e) => e.value.total)
            .reduce((a, b) => a > b ? a : b)
            .clamp(1, double.infinity)
            .toDouble();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY * 1.18,
        barTouchData: BarTouchData(enabled: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY / 2,
          getDrawingHorizontalLine: (v) =>
              const FlLine(color: LogPalette.rule, strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                final i = value.toInt();
                if (i < 0 || i >= shown.length) {
                  return const SizedBox.shrink();
                }
                final cat = ReferenceData.categoryById(shown[i].key);
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(cat.glyph,
                      style: const TextStyle(fontSize: 15)),
                );
              },
            ),
          ),
        ),
        barGroups: [
          for (var i = 0; i < shown.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: shown[i].value.total,
                  width: 22,
                  color: i == 0 ? LogPalette.navy : LogPalette.gold,
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(3)),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class BarChartWidget extends StatelessWidget {
  final Map<String, Map<String, double>> daten;
  final String zeitraum;

  const BarChartWidget({
    super.key,
    required this.daten,
    required this.zeitraum,
  });

  @override
  Widget build(BuildContext context) {
    final labels = daten.keys.toList();
    final kategorien = daten.values.expand((map) => map.keys).toSet().toList();
    final farben = _getFarben();
    final farbMap = _getFarbMap(kategorien, farben);

    return BarChart(
      BarChartData(
        maxY: 500,
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(sideTitles: _buildLeftTitles()),
          bottomTitles: AxisTitles(sideTitles: _buildBottomTitles(labels)),
        ),
        barGroups: List.generate(
          labels.length,
          (index) => _buildBarGroup(
            index,
            labels[index],
            daten[labels[index]]!,
            kategorien,
            farbMap,
          ),
        ),
        barTouchData: _buildBarTouchData(kategorien, farbMap),
      ),
    );
  }

  List<Color> _getFarben() => [
    Colors.purple.shade800,
    Colors.yellow.shade800,
    Colors.orange.shade800,
    Colors.cyan.shade800,
    Colors.brown.shade800,
    Colors.pink.shade800,
  ];

  Map<String, Color> _getFarbMap(List<String> kategorien, List<Color> farben) {
    return {
      for (int i = 0; i < kategorien.length; i++)
        kategorien[i]: farben[i % farben.length],
    };
  }

  SideTitles _buildLeftTitles() {
    return SideTitles(
      showTitles: true,
      reservedSize: 45,
      interval: 100,
      getTitlesWidget:
          (value, _) =>
              Text('${value.toInt()} €', style: const TextStyle(fontSize: 15)),
    );
  }

  SideTitles _buildBottomTitles(List<String> labels) {
    return SideTitles(
      showTitles: true,
      interval: 1,
      getTitlesWidget: (value, _) {
        final index = value.toInt();
        if (index < 0 || index >= labels.length) return const SizedBox.shrink();
        return Text(
          labels[index],
          style: const TextStyle(fontSize: 15, color: Color(0xffA0CAFD)),
        );
      },
    );
  }

  BarChartGroupData _buildBarGroup(
    int index,
    String label,
    Map<String, double> catMap,
    List<String> kategorien,
    Map<String, Color> farbMap,
  ) {
    if (zeitraum == 'Heute') {
      return BarChartGroupData(
        x: index,
        barsSpace: 50,
        barRods:
            kategorien.map((kategorie) {
              final value = catMap[kategorie] ?? 0;
              return BarChartRodData(
                toY: value,
                width: 20,
                color: farbMap[kategorie],
                borderRadius: BorderRadius.circular(20),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: 400,
                  color: const Color(0xffD1E4FF),
                ),
              );
            }).toList(),
      );
    } else {
      final summe = catMap.values.fold(0.0, (sum, v) => sum + v);
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: summe.clamp(0, 400),
            width: 22,
            color: const Color(0xff194975),
            borderRadius: BorderRadius.circular(20),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: 400,
              color: const Color(0xffD1E4FF),
            ),
          ),
        ],
      );
    }
  }

  BarTouchData _buildBarTouchData(
    List<String> kategorien,
    Map<String, Color> farbMap,
  ) {
    return BarTouchData(
      enabled: true,
      touchTooltipData: BarTouchTooltipData(
        getTooltipColor: (_) => const Color(0xffA0CAFD),
        getTooltipItem: (group, groupIndex, rod, rodIndex) {
          final kategorie =
              zeitraum == 'Heute' ? kategorien[rodIndex] : 'Ausgaben';
          final farbe =
              zeitraum == 'Heute'
                  ? farbMap[kategorie] ?? Colors.grey
                  : const Color(0xff003258);
          return BarTooltipItem(
            '$kategorie\n${rod.toY.toStringAsFixed(2)} €',
            TextStyle(color: farbe, fontWeight: FontWeight.bold, fontSize: 14),
          );
        },
      ),
    );
  }
}

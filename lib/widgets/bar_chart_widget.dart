import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class BarChartWidget extends StatelessWidget {
  final Map<String, Map<String, double>> data;
  final String period;

  const BarChartWidget({super.key, required this.data, required this.period});

  @override
  Widget build(BuildContext context) {
    final labels = data.keys.toList();
    final categories = data.values.expand((map) => map.keys).toSet().toList();
    final colors = _getColors();
    final colorsMap = _getColorsMap(categories, colors);

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
            data[labels[index]]!,
            categories,
            colorsMap,
          ),
        ),
        barTouchData: _buildBarTouchData(categories, colorsMap),
      ),
    );
  }

  List<Color> _getColors() => [
    Colors.purple.shade800,
    Colors.yellow.shade800,
    Colors.orange.shade800,
    Colors.cyan.shade800,
    Colors.brown.shade800,
    Colors.pink.shade800,
  ];

  Map<String, Color> _getColorsMap(List<String> categories, List<Color> colors) {
    return {
      for (int i = 0; i < categories.length; i++)
        categories[i]: colors[i % colors.length],
    };
  }

  SideTitles _buildLeftTitles() {
    return SideTitles(
      showTitles: true,
      reservedSize: 45,
      interval: 100,
      getTitlesWidget: (value, _) =>
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
    List<String> categories,
    Map<String, Color> colorMap,
  ) {
    if (period == 'Heute') {
      return BarChartGroupData(
        x: index,
        barsSpace: 50,
        barRods: categories.map((category) {
          final value = catMap[category] ?? 0;
          return BarChartRodData(
            toY: value,
            width: 20,
            color: colorMap[category],
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
      final sum = catMap.values.fold(0.0, (sum, v) => sum + v);
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: sum.clamp(0, 400),
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
    List<String> categories,
    Map<String, Color> colorMap,
  ) {
    return BarTouchData(
      enabled: true,
      touchTooltipData: BarTouchTooltipData(
        getTooltipColor: (_) =>
            period == 'Heute' ? Colors.white : const Color(0xffA0CAFD),
        getTooltipItem: (group, groupIndex, rod, rodIndex) {
          final category = period == 'Heute'
              ? categories[rodIndex]
              : 'Ausgaben';
          final color = period == 'Heute'
              ? colorMap[category] ?? Colors.grey
              : const Color(0xff003258);
          return BarTooltipItem(
            '$category\n${rod.toY.toStringAsFixed(2)} €',
            TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14),
          );
        },
      ),
    );
  }
}

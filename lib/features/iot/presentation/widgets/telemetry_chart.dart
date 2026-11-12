import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class TelemetryChart extends StatelessWidget {
  final List<FlSpot> humiditySpots;
  final List<FlSpot> temperatureSpots;

  const TelemetryChart({
    required this.humiditySpots,
    required this.temperatureSpots,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.5,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: LineChart(
            LineChartData(
              lineBarsData: [
                LineChartBarData(
                  spots: humiditySpots,
                  isCurved: true,
                  color: const Color(0xFF00838F),
                  barWidth: 3,
                  dotData: const FlDotData(show: false),
                ),
                LineChartBarData(
                  spots: temperatureSpots,
                  isCurved: true,
                  color: const Color(0xFFEF6C00),
                  barWidth: 3,
                  dotData: const FlDotData(show: false),
                ),
              ],
              titlesData: const FlTitlesData(
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              gridData: const FlGridData(show: true, drawVerticalLine: false),
            ),
          ),
        ),
      ),
    );
  }
}
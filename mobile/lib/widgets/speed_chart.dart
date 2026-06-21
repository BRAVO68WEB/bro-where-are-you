import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class SpeedChart extends StatelessWidget {
  final List<double> speeds; // m/s values
  final List<DateTime> timestamps;

  const SpeedChart({
    super.key,
    required this.speeds,
    required this.timestamps,
  });

  @override
  Widget build(BuildContext context) {
    if (speeds.length < 2) {
      return const SizedBox(
        height: 160,
        child: Center(child: Text('Not enough data', style: TextStyle(color: Colors.grey))),
      );
    }

    final spots = <FlSpot>[];
    for (int i = 0; i < speeds.length; i++) {
      spots.add(FlSpot(i.toDouble(), speeds[i] * 3.6)); // Convert to km/h
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'SPEED',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 140,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 10,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.grey.shade800,
                      strokeWidth: 0.5,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) => Text(
                          '${value.toInt()} km/h',
                          style: const TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      ),
                    ),
                    bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: Theme.of(context).colorScheme.primary,
                      barWidth: 2,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Theme.of(context).colorScheme.primary.withAlpha(30),
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (spots) => spots.map((spot) =>
                        LineTooltipItem(
                          '${spot.y.toStringAsFixed(1)} km/h',
                          TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 12),
                        ),
                      ).toList(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

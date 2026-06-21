import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ElevationChart extends StatelessWidget {
  final List<double> altitudes; // meters
  final List<DateTime> timestamps;

  const ElevationChart({
    super.key,
    required this.altitudes,
    required this.timestamps,
  });

  @override
  Widget build(BuildContext context) {
    if (altitudes.length < 2) {
      return const SizedBox(
        height: 160,
        child: Center(child: Text('Not enough data', style: TextStyle(color: Colors.grey))),
      );
    }

    final spots = <FlSpot>[];
    for (int i = 0; i < altitudes.length; i++) {
      spots.add(FlSpot(i.toDouble(), altitudes[i]));
    }

    final minY = altitudes.reduce((a, b) => a < b ? a : b);
    final maxY = altitudes.reduce((a, b) => a > b ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ELEVATION',
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
                    horizontalInterval: ((maxY - minY) / 3).clamp(1, 100),
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.grey.shade800,
                      strokeWidth: 0.5,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 45,
                        getTitlesWidget: (value, meta) => Text(
                          '${value.toInt()}m',
                          style: const TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      ),
                    ),
                    bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  minY: (minY - 10).clamp(0, double.infinity),
                  maxY: maxY + 10,
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: Colors.green,
                      barWidth: 2,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.green.withAlpha(30),
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (spots) => spots.map((spot) =>
                        LineTooltipItem(
                          '${spot.y.toStringAsFixed(0)} m',
                          const TextStyle(color: Colors.green, fontSize: 12),
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

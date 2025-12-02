import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class LineSalesChart extends StatelessWidget {
  const LineSalesChart({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: 6,
          minY: 0,
          maxY: 120,
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 20,
                reservedSize: 35,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF3E1E12),
                    ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (value, meta) {
                  const days = [
                    'Sen',
                    'Sel',
                    'Rab',
                    'Kam',
                    'Jum',
                    'Sab',
                    'Min',
                  ];

                  if (value % 1 != 0) return const SizedBox.shrink();
                  int index = value.toInt();
                  if (index < 0 || index > 6) return const SizedBox.shrink();

                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      days[index],
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF3E1E12),
                      ),
                    ),
                  );
                },
              ),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              isCurved: true,
              color: const Color(0xFF8B3A22),
              barWidth: 3,
              belowBarData: BarAreaData(show: false),
              dotData: const FlDotData(show: true),
              spots: const [
                FlSpot(0, 90),
                FlSpot(1, 70),
                FlSpot(2, 100),
                FlSpot(3, 50),
                FlSpot(4, 60),
                FlSpot(5, 80),
                FlSpot(6, 90),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

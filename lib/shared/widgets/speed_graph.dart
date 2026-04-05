import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../core/theme.dart';

class SpeedGraph extends StatelessWidget {
  final List<double> samples; // m/s values
  final bool isKmh;
  final double height;

  /// If set, only the last [windowSeconds] seconds are shown (live view).
  final int? windowSeconds;

  const SpeedGraph({
    super.key,
    required this.samples,
    required this.isKmh,
    this.height = 100,
    this.windowSeconds,
  });

  double _convert(double ms) => isKmh ? ms * 3.6 : ms * 2.23694;

  @override
  Widget build(BuildContext context) {
    if (samples.isEmpty) return SizedBox(height: height);

    final raw = windowSeconds != null && samples.length > windowSeconds!
        ? samples.sublist(samples.length - windowSeconds!)
        : samples;

    final data = _downsample(raw, 200);

    final spots = List.generate(
      data.length,
      (i) => FlSpot(i.toDouble(), _convert(data[i])),
    );

    final maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
    final range = maxY;
    final paddedMax = maxY + (range * 0.15).clamp(1.0, double.infinity);

    return SizedBox(
      height: height,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: paddedMax,
          clipData: const FlClipData.all(),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: const FlTitlesData(show: false),
          lineTouchData: const LineTouchData(enabled: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.3,
              color: AppColors.accent,
              barWidth: 2,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.accent.withValues(alpha: 0.25),
                    AppColors.accent.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ],
        ),
        duration: const Duration(milliseconds: 50),
      ),
    );
  }

  List<double> _downsample(List<double> source, int maxPoints) {
    if (source.length <= maxPoints) return source;
    final step = source.length / maxPoints;
    return List.generate(
      maxPoints,
      (i) => source[(i * step).floor().clamp(0, source.length - 1)],
    );
  }
}

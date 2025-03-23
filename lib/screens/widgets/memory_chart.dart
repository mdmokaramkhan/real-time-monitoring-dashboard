import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';

import '../../services/cpu_provider.dart';
import '../../theme/app_theme.dart';

class MemoryChartCard extends StatelessWidget {
  const MemoryChartCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final cpuProvider = Provider.of<CpuProvider>(context);
    final stats = cpuProvider.stats;
    final memoryPercentage = (stats.memoryUsed / stats.memoryTotal) * 100;
    
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Theme.of(context).dividerColor.withAlpha(0.3 * 255 ~/ 1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.storage_outlined,
                  color: Colors.purple,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Text(
                  'Memory Usage',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(width: 10),
                _buildMemoryIndicator(context, memoryPercentage),
                const Spacer(),
                OutlinedButton.icon(
                  icon: const Icon(Icons.file_download, size: 18),
                  label: const Text('Export'),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Export feature coming soon')),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 30.0),
              child: Text(
                'Monitoring last 30 seconds of memory activity',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildStatCard(
                  context, 
                  'Current', 
                  '${memoryPercentage.toStringAsFixed(1)}%',
                  color: Colors.purple
                ),
                const SizedBox(width: 12),
                _buildStatCard(
                  context, 
                  'Used', 
                  '${(stats.memoryUsed / 1024).toStringAsFixed(1)} GB',
                  color: Colors.deepPurple
                ),
                const SizedBox(width: 12),
                _buildStatCard(
                  context, 
                  'Total', 
                  '${(stats.memoryTotal / 1024).toStringAsFixed(1)} GB',
                  color: Colors.blueGrey
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _buildMemoryChart(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemoryIndicator(BuildContext context, double memoryPercentage) {
    Color color;
    if (memoryPercentage < 50) {
      color = AppTheme.success;
    } else if (memoryPercentage < 80) {
      color = AppTheme.warning;
    } else {
      color = AppTheme.error;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '${memoryPercentage.toStringAsFixed(1)}%',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }
  
  Widget _buildStatCard(BuildContext context, String label, String value, {required Color color}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Theme.of(context).dividerColor.withOpacity(0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemoryChart(BuildContext context) {
    final cpuProvider = Provider.of<CpuProvider>(context);
    final memoryData = cpuProvider.smoothedMemoryHistory;
    
    if (memoryData.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart,
              size: 64,
              color: Colors.purple.withAlpha(0.3 * 255 ~/ 1),
            ),
            const SizedBox(height: 20),
            Text(
              'Collecting memory data...',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Text(
              'Start monitoring to see real-time memory usage',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    
    final spots = <FlSpot>[];
    for (int i = 0; i < memoryData.length; i++) {
      spots.add(FlSpot(i.toDouble(), memoryData[i]));
    }
    
    return Padding(
      padding: const EdgeInsets.only(right: 16, left: 6, top: 16, bottom: 16),
      child: LineChart(
        LineChartData(
          lineTouchData: LineTouchData(
            enabled: true,
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (List<LineBarSpot> touchedSpots) {
                return touchedSpots.map((spot) {
                  final int secondsAgo = memoryData.length - 1 - spot.x.toInt();
                  return LineTooltipItem(
                    '${spot.y.toStringAsFixed(1)}%\n${secondsAgo == 0 ? 'now' : '$secondsAgo s ago'}',
                    TextStyle(
                      color: Colors.purple,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }).toList();
              },
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            horizontalInterval: 20,
            verticalInterval: 5,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Theme.of(context).dividerColor.withOpacity(0.15),
                strokeWidth: 1,
              );
            },
            getDrawingVerticalLine: (value) {
              return FlLine(
                color: Theme.of(context).dividerColor.withOpacity(0.15),
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              axisNameWidget: const Padding(
                padding: EdgeInsets.only(top: 10.0),
                child: Text('Last 30 seconds'),
              ),
              axisNameSize: 20,
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 5,
                getTitlesWidget: (value, meta) {
                  final int secondsAgo = memoryData.length - 1 - value.toInt();
                  if (secondsAgo < 0 || value.toInt() % 5 != 0) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      secondsAgo == 0 ? 'now' : '-${secondsAgo}s',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              axisNameWidget: const Padding(
                padding: EdgeInsets.only(right: 10.0),
                child: Text('Memory %'),
              ),
              axisNameSize: 20,
              sideTitles: SideTitles(
                showTitles: true,
                interval: 20,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${value.toInt()}%',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  );
                },
                reservedSize: 36,
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.3)),
          ),
          minX: 0,
          maxX: (spots.length - 1).toDouble(),
          minY: 0,
          maxY: 100,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.25,
              preventCurveOverShooting: true,
              color: Colors.purple,
              gradient: LinearGradient(
                colors: [
                  Colors.deepPurple,
                  Colors.purple,
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              barWidth: 4,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: false,
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    Colors.purple.withOpacity(0.4),
                    Colors.purple.withOpacity(0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';

import '../../models/system_stats.dart';
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
        padding: const EdgeInsets.all(16.0), // Reduced padding to match disk chart
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section - more compact
            Row(
              children: [
                Icon(Icons.memory_rounded, color: Colors.purple, size: 20),
                const SizedBox(width: 6),
                Text('Memory Usage', style: Theme.of(context).textTheme.titleLarge),
                const Spacer(),
                _buildMemoryIndicator(context, memoryPercentage),
              ],
            ),
            
            const SizedBox(height: 12), // Reduced spacing
            
            // Progress bar section
            _buildUsageProgressBar(context, stats, memoryPercentage),
            
            const SizedBox(height: 12), // Reduced spacing
            const Divider(height: 1),
            const SizedBox(height: 8), // Reduced spacing
            
            // Memory chart
            Expanded(
              child: _buildMemoryChart(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemoryIndicator(BuildContext context, double memoryPercentage) {
    Color color = _getUsageColor(memoryPercentage);
    
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

  Widget _buildUsageProgressBar(BuildContext context, SystemStats stats, double memoryPercentage) {
    final usageColor = _getUsageColor(memoryPercentage);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: memoryPercentage / 100,
            backgroundColor: Colors.grey.shade200,
            color: usageColor,
            minHeight: 10, // Slightly smaller for compactness
          ),
        ),
        
        // Labels for used and free - more compact
        const SizedBox(height: 4), // Reduced spacing
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Used: ${(stats.memoryUsed / 1024).toStringAsFixed(1)} GB',
              style: TextStyle(
                fontSize: 12, // Smaller font
                fontWeight: FontWeight.w500,
                color: usageColor,
              ),
            ),
            Text(
              'Free: ${((stats.memoryTotal - stats.memoryUsed) / 1024).toStringAsFixed(1)} GB',
              style: TextStyle(
                fontSize: 12, // Smaller font
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildMemoryChart(BuildContext context) {
    final cpuProvider = Provider.of<CpuProvider>(context);
    final memoryData = cpuProvider.smoothedMemoryHistory;
    
    // If no data, show loading state
    if (memoryData.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Colors.purple,
            ),
            const SizedBox(height: 16),
            Text(
              'Loading memory information...',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
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
      padding: const EdgeInsets.only(right: 16, left: 6, top: 8, bottom: 8),
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
                padding: EdgeInsets.only(top: 8.0),
                child: Text('Last 30 seconds', style: TextStyle(fontSize: 12)),
              ),
              axisNameSize: 16,
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
                padding: EdgeInsets.only(right: 8.0),
                child: Text('Memory %', style: TextStyle(fontSize: 12)),
              ),
              axisNameSize: 16,
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
                reservedSize: 30,
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
  
  // Helper methods

  Color _getUsageColor(double percentage) {
    if (percentage < 50) return AppTheme.success;
    if (percentage < 80) return AppTheme.warning;
    return AppTheme.error;
  }
}

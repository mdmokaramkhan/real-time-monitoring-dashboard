import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:real_time_monitoring_dashboard/screens/widgets/cpu_chart.dart';
import 'package:real_time_monitoring_dashboard/screens/widgets/memory_chart.dart';

import '../services/cpu_provider.dart';
import '../theme/app_theme.dart';
import '../screens/widgets/metric_card.dart';

class OverviewPage extends StatelessWidget {
  const OverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CpuProvider>(context);
    final stats = provider.stats;
    final screenSize = MediaQuery.of(context).size;
    
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section
            Row(
              children: [
                Text(
                  'System Overview',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const Spacer(),
                _buildStatusIndicator(provider.isMonitoring),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Current system performance metrics',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            
            // Top section with system metrics
            _buildMetricsSection(context, stats, screenSize),
            
            const SizedBox(height: 32),
            
            // Charts section
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SizedBox(
                    height: 400,
                    child: const CpuChartCard(),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: SizedBox(
                    height: 400,
                    child: const MemoryChartCard(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(bool isMonitoring) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isMonitoring ? AppTheme.success.withAlpha(0.15 * 255 ~/ 1) : AppTheme.error.withAlpha(0.15 * 255 ~/ 1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isMonitoring ? AppTheme.success : AppTheme.error,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isMonitoring ? AppTheme.success : AppTheme.error,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            isMonitoring ? 'Monitoring Active' : 'Monitoring Paused',
            style: TextStyle(
              color: isMonitoring ? AppTheme.success : AppTheme.error,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // Build metrics section with responsive layout
  Widget _buildMetricsSection(
    BuildContext context, 
    dynamic stats,
    Size screenSize,
  ) {
    // Helper function to determine color based on value
    Color getValueColor(double percentage) {
      if (percentage < 50) return AppTheme.success;
      if (percentage < 80) return AppTheme.warning;
      return AppTheme.error;
    }
    
    // Define metrics data
    final metrics = [
      MetricData(
        'CPU Usage',
        stats.cpuString,
        Icons.memory,
        getValueColor(stats.cpuUsage),
      ),
      MetricData(
        'Memory',
        stats.memoryString,
        Icons.storage,
        getValueColor(stats.memoryUsed / stats.memoryTotal * 100),
      ),
      MetricData(
        'Disk',
        stats.diskString,
        Icons.sd_storage,
        getValueColor(stats.diskUsage),
      ),
      MetricData(
        'Temperature',
        stats.temperatureString,
        Icons.thermostat,
        getValueColor(stats.temperature / 80 * 100),
      ),
    ];
    
    // Calculate the appropriate layout
    int crossAxisCount = _calculateCrossAxisCount(screenSize.width);
    double aspectRatio = _calculateAspectRatio(screenSize.width);
    
    // For desktop-oriented layout
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: aspectRatio,
      ),
      itemCount: metrics.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final metric = metrics[index];
        return MetricCard(
          title: metric.title,
          value: metric.value,
          icon: metric.icon,
          valueColor: metric.color,
        );
      },
    );
  }

  // Calculate the appropriate number of columns based on screen width
  int _calculateCrossAxisCount(double width) {
    if (width < 600) return 1;      // Small screens
    if (width < 900) return 2;      // Medium screens
    if (width < 1400) return 4;     // Large screens
    return 4;                       // Desktops and large displays
  }
  
  // Calculate the appropriate aspect ratio based on screen width
  double _calculateAspectRatio(double width) {
    if (width < 600) return 3.0;    // Small screens
    if (width < 900) return 3.2;    // Medium screens
    if (width < 1400) return 3.0;   // Large screens
    return 3.2;                     // Desktops
  }
}

// Helper class to store metric data
class MetricData {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  
  MetricData(this.title, this.value, this.icon, this.color);
}

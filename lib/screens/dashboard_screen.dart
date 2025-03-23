import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/cpu_provider.dart';
import '../theme/app_theme.dart';
import 'widgets/metric_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CpuProvider>(context);
    final stats = provider.stats;
    final screenSize = MediaQuery.of(context).size;
    
    // Helper function to determine color based on value
    Color getValueColor(double percentage) {
      if (percentage < 50) return AppTheme.success;
      if (percentage < 80) return AppTheme.warning;
      return AppTheme.error;
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Row(
          children: [
            Icon(
              Icons.dashboard_rounded,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 12),
            const Text('System Monitor Dashboard'),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(provider.isMonitoring ? Icons.pause : Icons.play_arrow),
            tooltip: provider.isMonitoring ? 'Pause Monitoring' : 'Start Monitoring',
            onPressed: () {
              provider.isMonitoring 
                ? provider.stopMonitoring() 
                : provider.startMonitoring();
            },
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Data',
            onPressed: () {
              // Add refresh functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Refreshing data...')),
              );
            },
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings coming soon!')),
              );
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
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
            _buildMetricsSection(context, stats, getValueColor, screenSize),
            
            const SizedBox(height: 32),
            
            // Future charts or detailed metrics
            Expanded(
              child: _buildDetailedSection(context, stats),
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
    Color Function(double) getValueColor,
    Size screenSize,
  ) {
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
    
    // Calculate the appropriate layout for desktop
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

  // Placeholder for detailed metrics section (charts, graphs, etc.)
  Widget _buildDetailedSection(BuildContext context, dynamic stats) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
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
                Text(
                  'Performance History',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                OutlinedButton.icon(
                  icon: const Icon(Icons.file_download, size: 18),
                  label: const Text('Export Data'),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Export feature coming soon')),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.bar_chart,
                      size: 64,
                      color: Theme.of(context).colorScheme.primary.withAlpha(0.3 * 255 ~/ 1),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Detailed metrics charts coming soon!',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'This area will contain performance history charts and data visualization',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
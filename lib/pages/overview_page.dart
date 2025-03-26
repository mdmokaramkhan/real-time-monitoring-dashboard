import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:real_time_monitoring_dashboard/screens/widgets/cpu_chart.dart';
import 'package:real_time_monitoring_dashboard/screens/widgets/memory_chart.dart';
import 'package:real_time_monitoring_dashboard/screens/widgets/system_info_card.dart';
// ignore: unused_import
import 'package:real_time_monitoring_dashboard/widgets/library_status_widget.dart';

import '../services/cpu_provider.dart';
import '../theme/app_theme.dart';
import '../screens/widgets/metric_card.dart';
import '../screens/widgets/disk_storage_card.dart';

class OverviewPage extends StatelessWidget {
  const OverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CpuProvider>(context);
    final stats = provider.stats;
    final screenSize = MediaQuery.of(context).size;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
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
            const SizedBox(height: 16),
            
            // // Add the library status widget
            // const LibraryStatusWidget(),
            
            // const SizedBox(height: 16),
            
            // Top section with system metrics
            _buildMetricsSection(context, stats, screenSize),
            
            const SizedBox(height: 32),
            
            // Charts section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // CPU and Memory charts in a row
                LayoutBuilder(
                  builder: (context, constraints) {
                    // On small screens, stack the charts vertically
                    if (constraints.maxWidth < 800) {
                      return Column(
                        children: [
                          SizedBox(
                            height: 400,
                            child: const CpuChartCard(),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            height: 400,
                            child: const MemoryChartCard(),
                          ),
                        ],
                      );
                    }
                    
                    // On larger screens, show charts side by side
                    return Row(
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
                    );
                  }
                ),
                
                const SizedBox(height: 20),
                
                // Disk chart and System Info row
                LayoutBuilder(
                  builder: (context, constraints) {
                    // Calculate appropriate height based on width
                    final chartHeight = constraints.maxWidth < 800 ? 300.0 : 350.0;
                    
                    // On small screens, stack the cards vertically
                    if (constraints.maxWidth < 800) {
                      return Column(
                        children: [
                          SizedBox(
                            height: chartHeight,
                            child: const DiskStorageCard(),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            height: chartHeight,
                            child: const SystemInfoCard(),
                          ),
                        ],
                      );
                    }
                    
                    // On larger screens, show cards side by side with responsive sizing
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Disk storage card (takes 60% of the width on larger screens)
                        Expanded(
                          flex: 6,
                          child: SizedBox(
                            height: chartHeight,
                            child: const DiskStorageCard(),
                          ),
                        ),
                        
                        const SizedBox(width: 20),
                        
                        // System info card (takes 40% of the width on larger screens)
                        Expanded(
                          flex: 4,
                          child: SizedBox(
                            height: chartHeight,
                            child: const SystemInfoCard(),
                          ),
                        ),
                      ],
                    );
                  }
                ),
                
                // Add some bottom padding
                const SizedBox(height: 20),
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

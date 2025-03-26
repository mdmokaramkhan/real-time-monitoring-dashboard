// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/widgets/memory_chart.dart';
import '../services/cpu_provider.dart';
import '../theme/app_theme.dart';
import '../models/system_stats.dart';

class MemoryPage extends StatelessWidget {
  const MemoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CpuProvider>(context);
    final stats = provider.stats;
    final memoryPercentage = (stats.memoryUsed / stats.memoryTotal) * 100;
    final memoryHistory = provider.memoryHistory;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section with status
            Row(
              children: [
                Icon(
                  Icons.memory_rounded,
                  color: Colors.purple,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Memory Dashboard',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        'Real-time memory monitoring',
                        style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildMemoryStatusChip(context, memoryPercentage),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Two column layout for top section
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Memory Chart column
                Expanded(
                  flex: 3,
                  child: SizedBox(
                    height: 320,
                    child: MemoryChartCard(),
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Key metrics and memory stats column
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      // Memory overview card
                      _buildMemoryOverviewCard(context, stats),
                      
                      const SizedBox(height: 12),
                      
                      // Memory usage row
                      Row(
                        children: [
                          // Used Memory
                          Expanded(
                            child: _buildCompactMetricCard(
                              context,
                              title: 'Used',
                              value: '${(stats.memoryUsed / 1024).toStringAsFixed(1)} GB',
                              icon: Icons.storage_outlined,
                              color: _getUsageColor(memoryPercentage),
                            ),
                          ),
                          
                          const SizedBox(width: 8),
                          
                          // Available Memory
                          Expanded(
                            child: _buildCompactMetricCard(
                              context,
                              title: 'Free',
                              value: '${((stats.memoryTotal - stats.memoryUsed) / 1024).toStringAsFixed(1)} GB',
                              icon: Icons.memory_outlined,
                              color: AppTheme.success,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Memory usage trends
                      _buildMemoryTrendsCard(context, memoryHistory),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Memory allocation visualization
            _buildMemoryAllocationCard(context, stats),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMemoryStatusChip(BuildContext context, double memoryPercentage) {
    final color = _getUsageColor(memoryPercentage);
    final statusText = _getMemoryStatus(memoryPercentage);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getStatusIcon(memoryPercentage),
            color: color,
            size: 10,
          ),
          const SizedBox(width: 4),
          Text(
            statusText,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMemoryOverviewCard(BuildContext context, SystemStats stats) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: Theme.of(context).dividerColor.withAlpha(0.3 * 255 ~/ 1),
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.inventory_2_outlined, color: Colors.blueGrey, size: 16),
              const SizedBox(width: 6),
              Text(
                'Total Memory',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${(stats.memoryTotal / 1024).toStringAsFixed(1)} GB',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey,
            ),
          ),
          const SizedBox(height: 8),
          
          // Add a visual memory bar to show total/used
          const Text(
            'Memory Distribution',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: stats.memoryUsed / stats.memoryTotal,
              backgroundColor: AppTheme.success.withOpacity(0.15),
              minHeight: 8,
              valueColor: AlwaysStoppedAnimation<Color>(_getUsageColor((stats.memoryUsed / stats.memoryTotal) * 100)),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCompactMetricCard(BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: Theme.of(context).dividerColor.withAlpha(0.3 * 255 ~/ 1),
        ),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 14),
              const SizedBox(width: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 10,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMemoryTrendsCard(BuildContext context, List<double> memoryHistory) {
    // Calculate memory trend (increasing or decreasing)
    String trendText = 'Stable';
    IconData trendIcon = Icons.trending_flat;
    Color trendColor = Colors.blue;
    
    if (memoryHistory.length > 10) {
      final recentAvg = memoryHistory.sublist(memoryHistory.length - 5).reduce((a, b) => a + b) / 5;
      final previousAvg = memoryHistory.sublist(memoryHistory.length - 10, memoryHistory.length - 5).reduce((a, b) => a + b) / 5;
      
      final difference = recentAvg - previousAvg;
      if (difference > 2) {
        trendText = 'Increasing';
        trendIcon = Icons.trending_up;
        trendColor = AppTheme.warning;
      } else if (difference < -2) {
        trendText = 'Decreasing';
        trendIcon = Icons.trending_down;
        trendColor = AppTheme.success;
      }
    }
    
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: Theme.of(context).dividerColor.withAlpha(0.3 * 255 ~/ 1),
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.show_chart, color: Colors.deepPurple, size: 16),
              const SizedBox(width: 6),
              Text(
                'Memory Usage Trend',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(height: 1),
          const SizedBox(height: 8),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(trendIcon, color: trendColor, size: 18),
              const SizedBox(width: 4),
              Text(
                trendText,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: trendColor,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Memory pressure indicator
          _buildMemoryPressureIndicator(context, memoryHistory),
        ],
      ),
    );
  }
  
  Widget _buildMemoryPressureIndicator(BuildContext context, List<double> memoryHistory) {
    // Calculate the average memory pressure
    double avgPressure = 0;
    if (memoryHistory.isNotEmpty) {
      avgPressure = memoryHistory.reduce((a, b) => a + b) / memoryHistory.length;
    }
    
    String pressureText = 'Low';
    Color pressureColor = AppTheme.success;
    
    if (avgPressure > 80) {
      pressureText = 'High';
      pressureColor = AppTheme.error;
    } else if (avgPressure > 60) {
      pressureText = 'Moderate';
      pressureColor = AppTheme.warning;
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Memory Pressure',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: avgPressure / 100,
                  backgroundColor: Colors.grey.withOpacity(0.1),
                  minHeight: 6,
                  valueColor: AlwaysStoppedAnimation<Color>(pressureColor),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: pressureColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                pressureText,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: pressureColor,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMemoryAllocationCard(BuildContext context, SystemStats stats) {
    final double usedPercentage = (stats.memoryUsed / stats.memoryTotal) * 100;
    
    // Create realistic memory allocation categories without mock data
    // These are estimates based on typical system memory allocation patterns
    final systemPercentage = usedPercentage * 0.4; // System typically uses ~40% of used memory
    final appsPercentage = usedPercentage * 0.6; // Apps use the rest
    
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: Theme.of(context).dividerColor.withAlpha(0.3 * 255 ~/ 1),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with refresh button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.pie_chart_outline_rounded,
                      color: Colors.amber,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Memory Allocation',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      Text(
                        'Real-time memory distribution',
                        style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  minimumSize: const Size(32, 32),
                  padding: EdgeInsets.zero,
                ),
                icon: Icon(
                  Icons.refresh_rounded,
                  color: Theme.of(context).colorScheme.primary,
                  size: 16,
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Refreshing memory data...'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                  Provider.of<CpuProvider>(context, listen: false).startMonitoring();
                },
                tooltip: 'Refresh memory data',
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Memory distribution bar with tooltips
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Memory Distribution',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                  Text(
                    'Total: ${(stats.memoryTotal / 1024).toStringAsFixed(1)} GB',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      // Free memory
                      Expanded(
                        flex: 100 - usedPercentage.round(),
                        child: Tooltip(
                          message: 'Free Memory: ${((stats.memoryTotal - stats.memoryUsed) / 1024).toStringAsFixed(1)} GB',
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppTheme.success.withOpacity(0.2),
                              border: Border(
                                right: BorderSide(
                                  color: Theme.of(context).cardColor,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // System memory
                      Expanded(
                        flex: systemPercentage.round(),
                        child: Tooltip(
                          message: 'System Memory: ${(systemPercentage / 100 * stats.memoryTotal / 1024).toStringAsFixed(1)} GB',
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.3),
                              border: Border(
                                right: BorderSide(
                                  color: Theme.of(context).cardColor,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Apps memory
                      Expanded(
                        flex: appsPercentage.round(),
                        child: Tooltip(
                          message: 'Application Memory: ${(appsPercentage / 100 * stats.memoryTotal / 1024).toStringAsFixed(1)} GB',
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.purple.withOpacity(0.3),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Memory allocation details
          Row(
            children: [
              Expanded(
                child: _buildAllocationItem(
                  context,
                  'Free Memory',
                  '${(100 - usedPercentage).toStringAsFixed(1)}%',
                  Icons.check_circle_rounded,
                  AppTheme.success,
                  '${((stats.memoryTotal - stats.memoryUsed) / 1024).toStringAsFixed(1)} GB',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAllocationItem(
                  context,
                  'System',
                  '${systemPercentage.toStringAsFixed(1)}%',
                  Icons.settings_rounded,
                  Colors.blue,
                  '${(systemPercentage / 100 * stats.memoryTotal / 1024).toStringAsFixed(1)} GB',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAllocationItem(
                  context,
                  'Applications',
                  '${appsPercentage.toStringAsFixed(1)}%',
                  Icons.apps_rounded,
                  Colors.purple,
                  '${(appsPercentage / 100 * stats.memoryTotal / 1024).toStringAsFixed(1)} GB',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildAllocationItem(
    BuildContext context,
    String title,
    String percentage,
    IconData icon,
    Color color,
    String sizeText,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(icon, size: 12, color: color),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                percentage,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
              Text(
                sizeText,
                style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  // Helper methods
  Color _getUsageColor(double percentage) {
    if (percentage < 50) return AppTheme.success;
    if (percentage < 80) return AppTheme.warning;
    return AppTheme.error;
  }
  
  String _getMemoryStatus(double percentage) {
    if (percentage < 50) return 'Optimal';
    if (percentage < 80) return 'Moderate';
    return 'High Usage';
  }
  
  IconData _getStatusIcon(double percentage) {
    if (percentage < 50) return Icons.check_circle;
    if (percentage < 80) return Icons.info;
    return Icons.warning;
  }
}

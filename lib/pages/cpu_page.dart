// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:real_time_monitoring_dashboard/screens/widgets/cpu_chart.dart';
import '../services/cpu_provider.dart';
import '../theme/app_theme.dart';

class CpuPage extends StatefulWidget {
  const CpuPage({super.key});

  @override
  State<CpuPage> createState() => _CpuPageState();
}

class _CpuPageState extends State<CpuPage> {
  Timer? _timer;
  // int _selectedTimeRange = 60; // Default 60 seconds
  
  @override
  void initState() {
    super.initState();
    // Update UI every second
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cpuProvider = Provider.of<CpuProvider>(context);
    final systemInfo = cpuProvider.systemInfo;
    final stats = cpuProvider.stats;
    
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.memory_rounded,
                      color: AppTheme.primaryLight,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CPU Monitor',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Real-time processor statistics',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ],
                ),
                _buildCpuStatusChip(context, stats.cpuUsage),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Main Content - Using Expanded for proper sizing
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // CPU Usage and Metrics Card
                    Card(
                      margin: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                            height: 400,
                            child: const CpuChartCard(),
                          ),
                          SizedBox(height: 10,),
                            // CPU Metrics
                            Row(
                              children: [
                                Expanded(
                                  child: _buildCompactMetricCard(
                                    context,
                                    title: 'CPU Usage',
                                    value: '${stats.cpuUsage.toStringAsFixed(1)}%',
                                    icon: Icons.speed_rounded,
                                    color: _getCpuUsageColor(stats.cpuUsage),
                                    trend: 0, // Use 0 for now, can implement trend calculation later
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildCompactMetricCard(
                                    context,
                                    title: 'Temperature',
                                    value: '${stats.temperature.toStringAsFixed(1)}°C',
                                    icon: Icons.thermostat_rounded,
                                    color: _getTemperatureColor(stats.temperature),
                                    trend: 0, // Use 0 for now
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildCompactMetricCard(
                                    context,
                                    title: 'Active Cores',
                                    value: '${systemInfo.cpuCores}/${systemInfo.cpuCores}',
                                    icon: Icons.grid_4x4_rounded,
                                    color: AppTheme.info,
                                    trend: 0,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Performance and Details Cards
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Performance Card
                        Expanded(
                          flex: 1,
                          child: Card(
                            margin: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.speed_rounded, 
                                        color: AppTheme.primaryLight, 
                                        size: 18
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Performance',
                                        style: Theme.of(context).textTheme.titleMedium,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  _buildCompactPerformanceScore(context, 'Speed', 85, AppTheme.success),
                                  const SizedBox(height: 12),
                                  _buildCompactPerformanceScore(
                                    context, 
                                    'Efficiency', 
                                    _calculateEfficiencyScore(stats.cpuUsage, stats.temperature), 
                                    AppTheme.info
                                  ),
                                  const SizedBox(height: 12),
                                  _buildCompactPerformanceScore(
                                    context, 
                                    'Thermal', 
                                    _calculateTemperatureScore(stats.temperature), 
                                    _getTemperatureColor(stats.temperature)
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(width: 16),
                        
                        // CPU Details Card
                        Expanded(
                          flex: 1,
                          child: Card(
                            margin: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.info_outline_rounded, 
                                        color: AppTheme.primaryLight, 
                                        size: 18
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'CPU Details',
                                        style: Theme.of(context).textTheme.titleMedium,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  _buildCompactDetailRow('Model', _getCpuFamily(systemInfo.cpuModel)),
                                  const SizedBox(height: 12),
                                  _buildCompactDetailRow('Cores', '${systemInfo.cpuCores}'),
                                  const SizedBox(height: 12),
                                  _buildCompactDetailRow('Arch', _getCpuArchitecture(systemInfo.cpuModel)),
                                  const SizedBox(height: 12),
                                  _buildCompactDetailRow('OS', _getOSType(systemInfo.osVersion)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Compact Metric Card with trend
  Widget _buildCompactMetricCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required double trend,
  }) {
    final isPositive = trend > 0;
    
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
              if (trend != 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isPositive ? AppTheme.success.withOpacity(0.15) : AppTheme.error.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                        size: 10,
                        color: isPositive ? AppTheme.success : AppTheme.error,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${trend.abs().toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: isPositive ? AppTheme.success : AppTheme.error,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // Compact Performance Score
  Widget _buildCompactPerformanceScore(BuildContext context, String label, int score, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            Text(
              '$score%',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: score / 100,
            backgroundColor: color.withOpacity(0.15),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  // Compact Detail Row
  Widget _buildCompactDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
      ],
    );
  }

  // CPU Status Chip
  Widget _buildCpuStatusChip(BuildContext context, double cpuUsage) {
    final color = _getCpuUsageColor(cpuUsage);
    final statusText = _getCpuStatusText(cpuUsage);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getCpuStatusIcon(cpuUsage),
            color: color,
            size: 14,
          ),
          const SizedBox(width: 6),
          Text(
            statusText,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
  
  // CPU Usage Chart Card
  // Widget _buildCpuUsageChart(List<double> cpuHistory) {
  //   if (cpuHistory.isEmpty) {
  //     return Center(
  //       child: Text(
  //         'No CPU history data available',
  //         style: TextStyle(
  //           fontSize: 14,
  //           color: Theme.of(context).textTheme.bodyMedium?.color,
  //         ),
  //       ),
  //     );
  //   }
    
  //   // Only use the last X points based on selected time range
  //   final dataPoints = cpuHistory.length > _selectedTimeRange 
  //       ? cpuHistory.sublist(cpuHistory.length - _selectedTimeRange) 
  //       : cpuHistory;
    
  //   return LineChart(
  //     LineChartData(
  //       gridData: FlGridData(
  //         show: true,
  //         drawVerticalLine: true,
  //         horizontalInterval: 20,
  //         verticalInterval: 5,
  //         getDrawingHorizontalLine: (value) {
  //           return FlLine(
  //             color: Theme.of(context).dividerColor.withOpacity(0.5),
  //             strokeWidth: 1,
  //           );
  //         },
  //         getDrawingVerticalLine: (value) {
  //           return FlLine(
  //             color: Theme.of(context).dividerColor.withOpacity(0.5),
  //             strokeWidth: 1,
  //           );
  //         },
  //       ),
  //       titlesData: FlTitlesData(
  //         show: true,
  //         rightTitles: AxisTitles(
  //           sideTitles: SideTitles(showTitles: false),
  //         ),
  //         topTitles: AxisTitles(
  //           sideTitles: SideTitles(showTitles: false),
  //         ),
  //         bottomTitles: AxisTitles(
  //           sideTitles: SideTitles(
  //             showTitles: true,
  //             reservedSize: 30,
  //             interval: dataPoints.length > 30 ? dataPoints.length / 6 : 5,
  //             getTitlesWidget: (double value, TitleMeta meta) {
  //               if (value % 5 != 0 && dataPoints.length > 30) {
  //                 return const SizedBox();
  //               }
                
  //               // Calculate seconds ago
  //               final int secondsAgo = dataPoints.length - 1 - value.toInt();
  //               if (secondsAgo < 0 || secondsAgo > dataPoints.length) {
  //                 return const SizedBox();
  //               }
                
  //               String label;
  //               if (secondsAgo == 0) {
  //                 label = 'now';
  //               } else if (secondsAgo < 60) {
  //                 label = '${secondsAgo}s';
  //               } else {
  //                 label = '${(secondsAgo / 60).floor()}m';
  //               }
                
  //               return Padding(
  //                 padding: const EdgeInsets.only(top: 8.0),
  //                 child: Text(
  //                   label,
  //                   style: TextStyle(
  //                     fontSize: 11,
  //                     color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
  //                   ),
  //                 ),
  //               );
  //             },
  //           ),
  //         ),
  //         leftTitles: AxisTitles(
  //           sideTitles: SideTitles(
  //             showTitles: true,
  //             interval: 25,
  //             getTitlesWidget: (double value, TitleMeta meta) {
  //               return Padding(
  //                 padding: const EdgeInsets.only(right: 8.0),
  //                 child: Text(
  //                   '${value.toInt()}%',
  //                   style: TextStyle(
  //                     fontSize: 11,
  //                     color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
  //                   ),
  //                 ),
  //               );
  //             },
  //             reservedSize: 30,
  //           ),
  //         ),
  //       ),
  //       borderData: FlBorderData(
  //         show: true,
  //         border: Border.all(
  //           color: Theme.of(context).dividerColor,
  //           width: 1,
  //         ),
  //       ),
  //       minX: 0,
  //       maxX: (dataPoints.length - 1).toDouble(),
  //       minY: 0,
  //       maxY: 100,
  //       lineBarsData: [
  //         LineChartBarData(
  //           spots: dataPoints.asMap().entries.map((entry) {
  //             return FlSpot(entry.key.toDouble(), entry.value);
  //           }).toList(),
  //           isCurved: true,
  //           color: AppTheme.primaryLight,
  //           barWidth: 3,
  //           isStrokeCapRound: true,
  //           dotData: FlDotData(
  //             show: false,
  //           ),
  //           belowBarData: BarAreaData(
  //             show: true,
  //             gradient: LinearGradient(
  //               colors: [
  //                 AppTheme.primaryLight.withOpacity(0.3),
  //                 AppTheme.primaryLight.withOpacity(0.05),
  //               ],
  //               begin: Alignment.topCenter,
  //               end: Alignment.bottomCenter,
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
  
  // Helper methods
  Color _getCpuUsageColor(double usage) {
    if (usage < 50) return AppTheme.success;
    if (usage < 80) return AppTheme.warning;
    return AppTheme.error;
  }
  
  String _getCpuStatusText(double usage) {
    if (usage < 50) return 'Low Load';
    if (usage < 80) return 'Moderate Load';
    return 'High Load';
  }
  
  IconData _getCpuStatusIcon(double usage) {
    if (usage < 50) return Icons.check_circle;
    if (usage < 80) return Icons.info;
    return Icons.warning;
  }
  
  Color _getTemperatureColor(double temp) {
    if (temp < 60) return AppTheme.success;
    if (temp < 80) return AppTheme.warning;
    return AppTheme.error;
  }
  
  int _calculateEfficiencyScore(double cpuUsage, double temperature) {
    // Higher score for lower CPU usage and temperature
    final usageScore = 100 - cpuUsage;
    final tempScore = temperature < 70 ? 100 : (100 - (temperature - 70) * 2).clamp(0, 100);
    return ((usageScore * 0.6) + (tempScore * 0.4)).round().clamp(0, 100);
  }
  
  int _calculateTemperatureScore(double temperature) {
    if (temperature < 50) return 95;
    if (temperature < 60) return 90;
    if (temperature < 70) return 80;
    if (temperature < 80) return 60;
    if (temperature < 90) return 40;
    return 20;
  }
  
  String _getCpuFamily(String cpuModel) {
    if (cpuModel.contains('Intel')) {
      if (cpuModel.contains('Core i9')) return 'Intel Core i9';
      if (cpuModel.contains('Core i7')) return 'Intel Core i7';
      if (cpuModel.contains('Core i5')) return 'Intel Core i5';
      if (cpuModel.contains('Core i3')) return 'Intel Core i3';
      return 'Intel';
    } else if (cpuModel.contains('AMD')) {
      if (cpuModel.contains('Ryzen 9')) return 'AMD Ryzen 9';
      if (cpuModel.contains('Ryzen 7')) return 'AMD Ryzen 7';
      if (cpuModel.contains('Ryzen 5')) return 'AMD Ryzen 5';
      if (cpuModel.contains('Ryzen 3')) return 'AMD Ryzen 3';
      return 'AMD';
    } else if (cpuModel.contains('Apple')) {
      return 'Apple Silicon';
    }
    return cpuModel.split(' ').take(2).join(' ');
  }
  
  String _getCpuArchitecture(String cpuModel) {
    if (cpuModel.contains('Intel')) {
      if (cpuModel.contains('10th Gen')) return 'Comet Lake';
      if (cpuModel.contains('11th Gen')) return 'Tiger Lake';
      if (cpuModel.contains('12th Gen')) return 'Alder Lake';
      if (cpuModel.contains('13th Gen')) return 'Raptor Lake';
      return 'x86_64';
    } else if (cpuModel.contains('AMD')) {
      if (cpuModel.contains('Zen 3')) return 'Zen 3';
      if (cpuModel.contains('Zen 4')) return 'Zen 4';
      return 'x86_64';
    } else if (cpuModel.contains('Apple')) {
      return 'ARM64';
    }
    
    if (cpuModel.contains('arm') || cpuModel.contains('ARM')) {
      return 'ARM64';
    }
    
    return 'x86_64';
  }
  
  String _getOSType(String osVersion) {
    if (osVersion.contains('Windows')) {
      return 'Windows';
    } else if (osVersion.contains('Mac') || osVersion.contains('Darwin')) {
      return 'macOS';
    } else if (osVersion.contains('Linux')) {
      if (osVersion.contains('Ubuntu')) return 'Ubuntu';
      if (osVersion.contains('Debian')) return 'Debian';
      if (osVersion.contains('Fedora')) return 'Fedora';
      if (osVersion.contains('CentOS')) return 'CentOS';
      return 'Linux';
    }
    return osVersion.split(' ').first;
  }
}



